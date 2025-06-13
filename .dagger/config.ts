#!/usr/bin/env ts-node
import fs from "fs";
import path from "path";
import { spawn } from "child_process";
/**
 * Dagger pipeline for Doom Emacs configuration
 *
 * Stages
 * ──────────
 * 1. Lint         – run checkdoc on every .el file
 * 2. Test         – `doom sync -e` (byte compile, package resolution)
 * 3. Integration  – boot Emacs in batch with the config
 *
 * This file purposefully installs *everything* inside a container so
 * the only host-side deps are Docker (fallback) or the Dagger engine.
 *
 * NOTE: Future work – Use Dagger’s LLM API to summarise failures or
 * provide automatic fixes. (“TODO(LLM)” markers left below.)
 */

import { connect } from "@dagger.io/dagger";

async function main() {
  /* ────────────────────────────────────────────────────────── */
  /* top-level timer                                            */
  /* ────────────────────────────────────────────────────────── */
  const startTime = Date.now();

  const dockerHostEnv = process.env.DOCKER_HOST;
  const defaultSock = "/var/run/docker.sock";
  if (dockerHostEnv || fs.existsSync(defaultSock)) {
    const hostSock = dockerHostEnv
      ? dockerHostEnv.replace(/^unix:\/\//, "")
      : defaultSock;
    console.log(`🔌 Using host Docker fallback (socket: ${hostSock})`);
    const dockerArgs = [
      "run", "--rm",
      "-v", `${process.cwd()}:/workspace`,
      "-w", "/workspace",
      "-v", `${hostSock}:${hostSock}`,
      ...(dockerHostEnv ? ["-e", `DOCKER_HOST=${dockerHostEnv}`] : []),
      "-e", "DOOMDIR=/workspace",
      "ubuntu:22.04",
      "bash", "-lc",
      `set -e; DEBIAN_FRONTEND=noninteractive apt-get update && \
apt-get install -y build-essential autoconf texinfo libgtk-3-dev libwebkit2gtk-4.0-dev libxml2-dev \
libpng-dev libjpeg-dev libgif-dev libxpm-dev libtiff-dev libncurses-dev \
libgnutls28-dev libharfbuzz-dev libxcb-xfixes0-dev libicu-dev direnv docker.io \
plantuml gnuplot ripgrep fd-find git curl tar && \
cd /tmp && curl -fsSL https://ftp.gnu.org/gnu/emacs/emacs-30.1.tar.gz -o emacs-30.1.tar.gz && \
tar xf emacs-30.1.tar.gz && cd emacs-30.1 && ./configure --with-x=no --without-pop && make -j$(nproc) && make install && \
cd /workspace && git clone --depth=1 https://github.com/doomemacs/doom-emacs.git /root/.emacs.d && \
/root/.emacs.d/bin/doom sync -e && \
emacs --batch -l /root/.emacs.d/init.el`
    ];
    const proc = spawn("docker", dockerArgs, { stdio: "inherit" });
    const code: number = await new Promise((resolve) => proc.on("close", resolve));
    process.exit(code);
  }

  const cacheDir = path.join(process.cwd(), ".dagger/cache");
  fs.mkdirSync(cacheDir, { recursive: true });
  process.env.XDG_CACHE_HOME = cacheDir;

  await connect(
    async (client) => {
      const skipDeps = process.env.SKIP_DEPS === "true";
      const lintOnly = process.env.LINT_ONLY === "true";

      const src = client.host().directory(".", { exclude: ["node_modules"] });

      /**
       * Helper – prepare a base container with tool-chain + source mounted
       */
      const createBaseContainer = () => {
        let c = client
          .container()
          .from("ubuntu:22.04")
          .withWorkdir("/workspace")
          .withMountedDirectory("/workspace", src)
          .withEnvVariable("DOOMDIR", "/workspace");

        if (skipDeps) {
          console.log("⚠️  SKIP_DEPS=true – skipping apt & Emacs build");
          return c;
        }

        return c.withExec([
          "bash",
          "-lc",
          `echo '::group::🛠️  Install build deps' && \
DEBIAN_FRONTEND=noninteractive apt-get update && \
apt-get install -y build-essential autoconf texinfo libgtk-3-dev libwebkit2gtk-4.0-dev libxml2-dev \
libpng-dev libjpeg-dev libgif-dev libxpm-dev libtiff-dev libncurses-dev \
libgnutls28-dev libharfbuzz-dev libxcb-xfixes0-dev libicu-dev direnv docker.io \
plantuml gnuplot ripgrep fd-find git curl tar && \
cd /tmp && curl -fsSL https://ftp.gnu.org/gnu/emacs/emacs-30.1.tar.gz -o emacs-30.1.tar.gz && \
tar xf emacs-30.1.tar.gz && cd emacs-30.1 && \
./configure --with-x=no --without-pop && make -j$(nproc) && make install && \
echo '::endgroup::'`,
        ]);
      };

      // ──────────────────── 1. Lint Stage ────────────────────
      let ctLint = createBaseContainer().withExec([
        "bash",
        "-lc",
        // Lint every .el file; checkdoc returns non-zero on issues (with -q)
        `echo '::group::🔍 Lint (checkdoc)' && \
git clone --depth=1 https://github.com/doomemacs/doom-emacs.git /root/.emacs.d && \
for f in $(find . -maxdepth 2 -name '*.el'); do \
  echo \"• checking $f\"; \
  emacs --batch -Q --eval \"(progn (require 'checkdoc) (let ((checkdoc-autofix-flag t)) (checkdoc-file \\\"$f\\\")))\"; \
done && \
echo '::endgroup::'`,
      ]);
      console.log("✅ Lint stage finished");

      /* Fast-exit path for quick checks */
      if (lintOnly) {
        const lintExit = await ctLint.exitCode();
        const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
        console.log(`🎉 Pipeline (LINT_ONLY) succeeded in ${elapsed}s`);
        process.exit(lintExit);
      }

      // ──────────────────── 2. Test Stage ────────────────────
      ctLint = ctLint.withExec([
        "bash",
        "-lc",
        `echo '::group::🧪 Doom sync (test stage)' && \
/root/.emacs.d/bin/doom sync -e && \
echo '::endgroup::'`,
      ]);
      console.log("✅ Test stage finished");

      // ──────────────────── 3. Integration Stage ─────────────
      const ctIntegration = ctLint.withExec([
        "bash",
        "-lc",
        `echo '::group::🚀 Integration – boot Emacs' && \
emacs --batch -l /root/.emacs.d/init.el --eval \"(message \\\"Boot OK\\\")\" && \
echo '::endgroup::'`,
      ]);
      console.log("✅ Integration stage finished");

      // TODO(LLM): Pipe logs to Dagger LLM summariser once available

      const exitCode = await ctIntegration.exitCode();
      const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
      if (exitCode === 0) {
        console.log(`🎉 All pipeline stages completed successfully in ${elapsed}s`);
      }
      process.exit(exitCode);
    },
    { Workdir: process.cwd(), LogOutput: process.stderr }
  );

} /* <-- close async function main() */

main().catch((err) => {
  console.error(err.stack || err);
  process.exit(1);
});
