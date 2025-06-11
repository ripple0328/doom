#!/usr/bin/env ts-node
import fs from "fs";
import path from "path";
import { spawn } from "child_process";
import { connect } from "@dagger.io/dagger";

async function main() {
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
      `DEBIAN_FRONTEND=noninteractive apt-get update && \
apt-get install -y build-essential autoconf texinfo libgtk-3-dev libwebkit2gtk-4.0-dev libxml2-dev \
libpng-dev libjpeg-dev libgif-dev libxpm-dev libtiff-dev libncurses-dev \
libgnutls28-dev libharfbuzz-dev libxcb-xfixes0-dev libicu-dev direnv docker.io \
plantuml gnuplot ripgrep fd-find git curl tar && \
cd /tmp && curl -fsSL https://ftp.gnu.org/gnu/emacs/emacs-30.1.tar.gz -o emacs-30.1.tar.gz && \
tar xf emacs-30.1.tar.gz && cd emacs-30.1 && ./configure --with-x=no --without-pop && make -j$(nproc) && make install && \
cd /workspace && git clone --depth=1 https://github.com/doomemacs/doom-emacs.git /root/.emacs.d && \
/root/.emacs.d/bin/doom sync -e && \
if [ -f /workspace/early-init.el ]; then \
  emacs --batch --load /workspace/early-init.el; \
elif [ -f /workspace/init.el ]; then \
  emacs --batch --load /workspace/init.el; \
else \
  emacs --batch -l /root/.emacs.d/init.el; \
fi`
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

    const src = client.host().directory(".", { exclude: ["node_modules"] });

    let ct = client
      .container()
      .from("ubuntu:22.04")
      .withWorkdir("/workspace")
      .withMountedDirectory("/workspace", src)
      .withEnvVariable("DOOMDIR", "/workspace");

    if (!skipDeps) {
      ct = ct.withExec([
        "bash",
        "-lc",
        `DEBIAN_FRONTEND=noninteractive apt-get update && \
apt-get install -y build-essential autoconf texinfo libgtk-3-dev libwebkit2gtk-4.0-dev libxml2-dev \
libpng-dev libjpeg-dev libgif-dev libxpm-dev libtiff-dev libncurses-dev \
libgnutls28-dev libharfbuzz-dev libxcb-xfixes0-dev libicu-dev direnv docker.io \
plantuml gnuplot ripgrep fd-find git curl tar && \
cd /tmp && curl -fsSL https://ftp.gnu.org/gnu/emacs/emacs-30.1.tar.gz -o emacs-30.1.tar.gz && \
tar xf emacs-30.1.tar.gz && cd emacs-30.1 && ./configure --with-x=no --without-pop && make -j$(nproc) && make install`,
      ]);
    } else {
      console.log("⚠️ SKIP_DEPS=true; skipping dependencies installation");
    }

    ct = ct.withExec([
      "git",
      "clone",
      "--depth=1",
      "https://github.com/doomemacs/doom-emacs.git",
      "/root/.emacs.d",
    ]);
    ct = ct.withExec(
      skipDeps
        ? ["/root/.emacs.d/bin/doom", "--help"]
        : ["/root/.emacs.d/bin/doom", "sync", "-e"]
    );
    ct = ct.withExec(
      skipDeps
        ? ["/root/.emacs.d/bin/doom", "--help"]
        : ["bash", "-lc",
           "/root/.emacs.d/bin/doom sync -e && if [ -f /workspace/early-init.el ]; then emacs --batch --load /workspace/early-init.el; elif [ -f /workspace/init.el ]; then emacs --batch --load /workspace/init.el; else emacs --batch -l /root/.emacs.d/init.el; fi"
        ]
    );

    const exitCode = await ct.exitCode();
    process.exit(exitCode);
  },
  { Workdir: process.cwd(), LogOutput: process.stderr }
);
}

main().catch((err) => {
  console.error(err.stack || err);
  process.exit(1);
});
