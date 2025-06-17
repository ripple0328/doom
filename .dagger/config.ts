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

/**
 * Enhanced logging helper
 */
const logStage = (stage: string, action: string, startTime?: number) => {
  const timestamp = new Date().toISOString();
  const elapsed = startTime ? `(+${((Date.now() - startTime) / 1000).toFixed(1)}s)` : '';
  console.log(`[${timestamp}] ${stage}: ${action} ${elapsed}`);
};

/**
 * Retry helper for flaky operations
 */
const withRetry = async <T>(operation: () => Promise<T>, maxRetries = 3, delay = 1000): Promise<T> => {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await operation();
    } catch (error) {
      logStage("RETRY", `Attempt ${i + 1}/${maxRetries} failed: ${error.message}`);
      if (i === maxRetries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, delay * (i + 1)));
    }
  }
  throw new Error("Unreachable"); // TypeScript satisfaction
};

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
timeout 60 emacs --batch --eval "(progn (load-file (expand-file-name \\"early-init.el\\" user-emacs-directory)) (message \\"✅ Emacs boot test successful\\"))"`
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

      logStage("INIT", `Starting pipeline - skipDeps: ${skipDeps}, lintOnly: ${lintOnly}`, startTime);

      const src = client.host().directory(".", { exclude: ["node_modules"] });

      /**
       * Helper – prepare a base container with tool-chain + source mounted
       * Enhanced with caching for better performance
       */
      const createBaseContainer = () => {
        let c = client
          .container()
          .from("ubuntu:22.04")
          .withWorkdir("/workspace")
          // Add cache mounts for better performance
          .withMountedCache("/var/cache/apt", client.cacheVolume("apt-cache"))
          .withMountedCache("/var/lib/apt", client.cacheVolume("apt-lib"))
          .withMountedDirectory("/workspace", src)
          .withEnvVariable("DOOMDIR", "/workspace")
          .withEnvVariable("DEBIAN_FRONTEND", "noninteractive");

        if (skipDeps) {
          console.log("⚠️  SKIP_DEPS=true – skipping apt & Emacs build");
          return c;
        }

        return c
          // Add cache mount for Emacs build artifacts
          .withMountedCache("/tmp/emacs-build", client.cacheVolume("emacs-build"))
          .withExec([
            "bash",
            "-lc",
            `echo '::group::🛠️  Install build deps' && \
apt-get update && \
apt-get install -y --no-install-recommends \
  build-essential autoconf texinfo libgtk-3-dev \
  libwebkit2gtk-4.0-dev libxml2-dev libpng-dev \
  libjpeg-dev libgif-dev libxpm-dev libtiff-dev \
  libncurses-dev libgnutls28-dev libharfbuzz-dev \
  libxcb-xfixes0-dev libicu-dev direnv docker.io \
  plantuml gnuplot ripgrep fd-find git curl tar \
  ccache && \
echo '::endgroup::'`,
          ])
          .withExec([
            "bash",
            "-lc",
            `echo '::group::🔨 Build Emacs with caching' && \
export CCACHE_DIR=/tmp/emacs-build/ccache && \
export CC="ccache gcc" && \
export CXX="ccache g++" && \
cd /tmp/emacs-build && \
if [ ! -f emacs-30.1.tar.gz ]; then \
  echo "Downloading Emacs source..." && \
  curl -fsSL https://ftp.gnu.org/gnu/emacs/emacs-30.1.tar.gz -o emacs-30.1.tar.gz; \
else \
  echo "Using cached Emacs source"; \
fi && \
if [ ! -d emacs-30.1 ]; then \
  echo "Extracting Emacs source..." && \
  tar xf emacs-30.1.tar.gz; \
else \
  echo "Using cached Emacs source directory"; \
fi && \
cd emacs-30.1 && \
if [ ! -f Makefile ]; then \
  echo "Configuring Emacs..." && \
  ./configure --with-x=no --without-pop --enable-checking=yes,glyphs; \
else \
  echo "Using cached Makefile"; \
fi && \
echo "Building Emacs (with ccache)..." && \
make -j$(nproc) && \
make install && \
ccache -s && \
echo '::endgroup::'`,
          ]);
      };

      // ──────────────────── 1. Lint Stage ────────────────────
      logStage("LINT", "Starting lint stage", startTime);
      let ctLint = await withRetry(async () => 
        createBaseContainer().withExec([
          "bash",
          "-lc",
          // Lint every .el file; checkdoc returns non-zero on issues (with -q)
          `echo '::group::🔍 Lint (checkdoc)' && \
git clone --depth=1 https://github.com/doomemacs/doom-emacs.git /root/.emacs.d && \
echo "Found $(find . -maxdepth 2 -name '*.el' | wc -l) .el files to check" && \
for f in $(find . -maxdepth 2 -name '*.el'); do \
  echo \"• checking $f\"; \
  emacs --batch -Q --eval \"(progn (require 'checkdoc) (let ((checkdoc-autofix-flag t)) (checkdoc-file \\\"$f\\\")))\"; \
done && \
echo '::endgroup::'`,
        ])
      );
      logStage("LINT", "Lint stage completed", startTime);

      /* Fast-exit path for quick checks */
      if (lintOnly) {
        const lintExit = await ctLint.exitCode();
        const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
        logStage("COMPLETE", `Pipeline (LINT_ONLY) finished with exit code ${lintExit}`, startTime);
        process.exit(lintExit);
      }

      // ──────────────────── 2. Test Stage ────────────────────
      logStage("TEST", "Starting test stage (doom sync)", startTime);
      ctLint = ctLint.withExec([
        "bash",
        "-lc",
        `echo '::group::🧪 Doom sync (test stage)' && \
echo "Starting doom sync with error checking..." && \
/root/.emacs.d/bin/doom sync -e && \
echo "Doom sync completed successfully" && \
echo '::endgroup::'`,
      ]);
      logStage("TEST", "Test stage completed", startTime);

      // ──────────────────── 3. Integration Stage ─────────────
      logStage("INTEGRATION", "Starting integration stage (boot test)", startTime);
      const ctIntegration = ctLint.withExec([
        "bash",
        "-lc",
        `echo '::group::🚀 Integration – boot Emacs' && \
echo "Testing Emacs boot with configuration..." && \
timeout 60 emacs --batch --eval \"(progn (load-file (expand-file-name \\\"early-init.el\\\" user-emacs-directory)) (message \\\"✅ Emacs boot test successful\\\"))\" && \
echo '::endgroup::'`,
      ]);
      logStage("INTEGRATION", "Integration stage completed", startTime);

      // TODO(LLM): Pipe logs to Dagger LLM summariser once available

      const exitCode = await ctIntegration.exitCode();
      const elapsed = ((Date.now() - startTime) / 1000).toFixed(1);
      
      if (exitCode === 0) {
        logStage("COMPLETE", `All pipeline stages completed successfully in ${elapsed}s`, startTime);
      } else {
        logStage("ERROR", `Pipeline failed with exit code ${exitCode} after ${elapsed}s`, startTime);
      }
      process.exit(exitCode);
    },
    { 
      Workdir: process.cwd(), 
      LogOutput: process.stderr,
      // Add timeout for long-running operations
      queryTimeout: 1800000 // 30 minutes
    }
  );

} /* <-- close async function main() */

main().catch((err) => {
  console.error(`💥 Pipeline crashed:`);
  console.error({
    message: err.message,
    stack: err.stack,
    timestamp: new Date().toISOString()
  });
  process.exit(1);
});
