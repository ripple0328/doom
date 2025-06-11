#!/usr/bin/env ts-node
import fs from "fs";
import { connect } from "@dagger.io/dagger";

async function main() {
  const dockerHostEnv = process.env.DOCKER_HOST;
  const defaultSock = "/var/run/docker.sock";
  if (dockerHostEnv) {
    console.log(`🔌 Using Docker host from DOCKER_HOST: ${dockerHostEnv}`);
  } else if (fs.existsSync(defaultSock)) {
    console.log(`🔌 Found Docker socket at ${defaultSock}, using host Docker daemon`);
  } else {
    console.log("🔌 Docker host not found, falling back to Dagger default engine");
  }

  await connect(async (client) => {
    const skipDeps = process.env.SKIP_DEPS === "true";

    const src = client.host().directory(".", { exclude: ["node_modules"] });

    let ct = client.container().from("ubuntu:22.04")
      .withWorkdir("/workspace")
      .withMountedDirectory("/workspace", src)
      .withEnvVariable("DOOMDIR", "/workspace");

    if (!skipDeps) {
      ct = ct.withExec([
        "bash", "-lc",
        "apt-get update && apt-get install -y git gcc g++ make cmake pkg-config libtool libgtk-3-dev libwebkit2gtk-4.0-dev libxml2-dev libpng-dev libjpeg-dev libgif-dev libxpm-dev libtiff-dev libncurses-dev libgnutls28-dev libharfbuzz-dev libxcb-xfixes0-dev libicu-dev direnv docker.io plantuml gnuplot"
      ]);
    } else {
      console.log("⚠️  SKIP_DEPS=true; skipping dependencies installation");
    }

    ct = ct.withExec(["git", "clone", "--depth=1", "https://github.com/doomemacs/doom-emacs.git", "/root/.emacs.d"]);
    ct = ct.withExec(skipDeps
      ? ["/root/.emacs.d/bin/doom", "--help"]
      : ["/root/.emacs.d/bin/doom", "sync", "-e"]
    );
    ct = ct.withExec(skipDeps
      ? ["/root/.emacs.d/bin/doom", "--help"]
      : ["/root/.emacs.d/bin/doom", "doctor"]
    );

    const exitCode = await ct.exitCode();
    process.exit(exitCode);
  });
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});