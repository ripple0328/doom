# Doom Emacs Dagger CI Pipeline

This project provides a Dagger.io based CI pipeline for testing a Doom Emacs configuration. It ensures that the Emacs configuration, along with Doom Emacs, can be successfully built, initialized, and that user init files can be loaded without batch errors.

## How it Works

The CI process is orchestrated through a GitHub Actions workflow that utilizes a Dagger pipeline defined in TypeScript.

### GitHub Actions Workflow (`.github/workflows/ci.yml`)

-   **Trigger**: The workflow runs on pushes or pull requests that modify Emacs Lisp files (`**/*.el`), Org files (`**/*.org`), or the workflow files themselves (`.github/workflows/**`).
-   **Environment**: It runs on an `ubuntu-latest` runner.
-   **Steps**:
    1.  **Checkout Code**: Checks out the repository content.
    2.  **Setup Node.js**: Sets up Node.js version 18.
    3.  **Install Dependencies**: Runs `npm ci` to install Node.js dependencies defined in `package-lock.json` (primarily `@dagger.io/dagger`, `ts-node`, `typescript`).
    4.  **Run Pipeline**: Executes `npm run pipeline`, which in turn runs the Dagger pipeline script (`.dagger/config.ts`).

### Dagger Pipeline (`.dagger/config.ts`)

The core of the CI logic resides in this TypeScript file, executed by `ts-node`. It has two main modes of operation:

1.  **Docker Fallback Mode**:
    -   This mode is activated if a local Docker daemon is accessible (via `DOCKER_HOST` environment variable or the default `/var/run/docker.sock` socket).
    -   It directly uses `docker run` with an `ubuntu:22.04` image.
    -   **Key operations**:
        -   Mounts the current project directory into `/workspace` in the container.
        -   Sets the `DOOMDIR` environment variable to `/workspace`.
        -   Installs system dependencies (build tools, X11/GTK libs for Emacs, etc.) and Emacs 30.1 from source (compiled without X support, `--with-x=no --without-pop`).
        -   Clones the Doom Emacs repository (`https://github.com/doomemacs/doom-emacs.git`) into `/root/.emacs.d`.
        -   Runs `doom sync -e` to synchronize the Doom Emacs configuration.
        -   Attempts to load user init files in batch mode: first `/workspace/early-init.el`, then `/workspace/init.el`. If neither exists, it falls back to loading Doom's default init file (`/root/.emacs.d/init.el`).
        -   The script uses `set -e` to ensure any command failure leads to a non-zero exit code.

2.  **Dagger SDK Mode**:
    -   If a local Docker daemon isn't detected, the script uses the `@dagger.io/dagger` TypeScript SDK to define and run the pipeline (e.g., in Dagger Cloud or a local Dagger Engine).
    -   **Key operations**:
        -   Utilizes an `ubuntu:22.04` base container.
        -   Mounts the project source into `/workspace`.
        -   Sets `DOOMDIR=/workspace`.
        -   Optionally installs system dependencies and Emacs 30.1 (same as Docker fallback mode), unless `SKIP_DEPS=true` is set in the environment.
        -   Clones Doom Emacs into `/root/.emacs.d`.
        -   Runs `doom sync -e` and then attempts to load user init files or the default Doom init file in batch mode (similar to the Docker fallback).
        -   The script also uses `set -e` for robustness.

## Key Files and Their Roles

-   **`.dagger/config.ts`**: Contains the main Dagger pipeline logic written in TypeScript. This script defines the steps to build Emacs, set up Doom Emacs, and test the configuration.
-   **`.github/workflows/ci.yml`**: Defines the GitHub Actions workflow that triggers the CI pipeline on relevant file changes.
-   **`package.json`**:
    -   Declares project metadata and dependencies (like `@dagger.io/dagger`).
    -   Defines the `pipeline` script (`node --loader ts-node/esm .dagger/config.ts`) used by the CI workflow (and for local execution) to run the Dagger pipeline.
    -   Specifies `"type": "module"`, indicating the project uses ES Module syntax.
-   **`tsconfig.json`**: Configures the TypeScript compiler options. It's set up for an ES Module project (`"module": "NodeNext"`).
-   **`dagger.json`**: Dagger project file specifying the project name, SDK (typescript), and the main source file (`.dagger/config.ts`).
-   **`config.org`**: Literate configuration tangled to `config.el` for Doom.

## Local Execution

To run the Dagger pipeline locally (assuming you have Node.js, npm, and Dagger CLI installed, or Docker for the fallback mode):

1.  **Install Node.js dependencies**:
    ```bash
    npm ci
    ```
2.  **Run the pipeline**:
    ```bash
    npm run pipeline
    ```
    -   If you have Docker running and accessible, this will likely trigger the Docker fallback mode.
    -   Otherwise, it will attempt to run using the Dagger SDK (which might require being logged into Dagger Cloud or having a local Dagger Engine running).
    -   You can influence dependency installation in the Dagger SDK mode by setting the `SKIP_DEPS` environment variable:
        ```bash
        SKIP_DEPS=true npm run pipeline
        ```
