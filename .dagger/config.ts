import { dag, Container, Directory, object, func, Service } from "@dagger.io/dagger";

@object()
class DoomCi {
  /**
   * Builds the base environment with Ubuntu, system dependencies, Emacs, and Doom Emacs.
   */
  @func()
  buildEnv(): Container {
    const aptPackages = [
      "build-essential", "autoconf", "texinfo", "libgtk-3-dev",
      "libwebkit2gtk-4.0-dev", "libxml2-dev", "libpng-dev", "libjpeg-dev",
      "libgif-dev", "libxpm-dev", "libtiff-dev", "libncurses-dev",
      "libgnutls28-dev", "libharfbuzz-dev", "libxcb-xfixes0-dev", "libicu-dev",
      "direnv", "docker.io", // docker.io might not be needed if not running docker-in-dagger
      "plantuml", "gnuplot", "ripgrep", "fd-find", "git", "curl", "tar",
    ];

    let ctr = dag.container()
      .from("ubuntu:22.04")
      .withEnvVariable("DEBIAN_FRONTEND", "noninteractive")
      .withExec(["apt-get", "update"])
      .withExec(["apt-get", "install", "-y", ...aptPackages])
      .withExec([
        "bash", "-lc",
        "cd /tmp && curl -fsSL https://ftp.gnu.org/gnu/emacs/emacs-30.1.tar.gz -o emacs-30.1.tar.gz && tar xf emacs-30.1.tar.gz"
      ])
      .withExec([
        "bash", "-lc",
        "cd /tmp/emacs-30.1 && ./configure --with-x=no --without-pop && make -j$(nproc) && make install"
      ])
      .withExec([
        "git", "clone", "--depth=1",
        "https://github.com/doomemacs/doom-emacs.git",
        "/root/.emacs.d"
      ]);
    return ctr;
  }

  /**
   * Tests a given Doom Emacs configuration directory.
   * @param configDir The directory containing the Doom Emacs user configuration (init.el, packages.el, config.org).
   */
  @func()
  async test(configDir: Directory): Promise<string> {
    const envCtr = this.buildEnv();

    return await envCtr
      .withMountedDirectory("/workspace", configDir)
      .withEnvVariable("DOOMDIR", "/workspace")
      .withWorkdir("/workspace") // Ensures doom sync runs in the context of user config
      .withExec(["bash", "-lc", "set -e; /root/.emacs.d/bin/doom sync -e && emacs --batch -l /root/.emacs.d/init.el"])
      .stdout();
  }
}
