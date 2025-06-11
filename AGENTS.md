# Doom Emacs CI Agent

This agent defines a Dagger-driven pipeline to verify a Doom Emacs configuration.
It supports both local Docker CLI fallback and the container-native Dagger engine (e.g., in CI).

The pipeline will:

- Detect and use the host Docker daemon (via `DOCKER_HOST` or `/var/run/docker.sock`) for local runs.
- Fall back to the Dagger engine when no host Docker socket is present (for CI scenarios).
- Isolate Dagger’s on-disk cache under `.dagger/cache`.
- Download and build Emacs 30.1 from the official GNU tarball (with X disabled) into the container.
- Install all necessary system dependencies:
  - `build-essential`, `autoconf`, `texinfo`, GTK, WebKit2GTK, XML2, PNG, JPEG, GIF, XPM, TIFF, ncurses,
    GnuTLS, HarfBuzz, libxcb, ICU, direnv, docker.io, plantuml, gnuplot, ripgrep, fd-find, and Git.
- Clone the Doom Emacs core repository (latest stable) and run `doom sync -e`.
- Smoke-test the Doom configuration by launching Emacs headlessly:
  - If `DOOMDIR/early-init.el` exists, batch-load it.
  - Else if `DOOMDIR/init.el` exists, batch-load it.
  - Otherwise, batch-load the core Doom `init.el`.
- Exit with zero if the Emacs startup succeeds, or non-zero if any failure occurs.

## Usage

### Local

```bash
npm install
npm run pipeline
```

### GitHub Actions

The `.github/workflows/ci.yml` workflow checks out the repository, installs Node.js,
runs `npm ci`, and then invokes:

```yaml
- run: npm run pipeline
```

which executes the same Dagger pipeline and fails on any startup errors.
