# Development Guide

[![Doom Emacs CI](https://github.com/ripple0328/.doom.d/actions/workflows/ci.yml/badge.svg)](https://github.com/ripple0328/.doom.d/actions/workflows/ci.yml)

This document contains technical details for developers working on this Doom Emacs configuration.

## Repository Layout

| Path | Purpose |
|------|---------|
| `config.org` | Main literate configuration (tangled into Lisp on `doom sync`) |
| `config.local.el` | **Untracked** personal overrides (created locally) |
| `init.el` | Doom module list (generated from template) |
| `.dagger/config.ts` | Container recipe used by CI & local `npm run pipeline` |
| `.github/workflows/ci.yml` | GitHub Actions runner that executes the Dagger pipeline |
| `.gitignore` | Explicitly ignores `config.local.el`, cache folders, etc. |
| `TESTING.md` | Detailed documentation of the lint + test + integration pipeline |

---

## How We Keep Personal Information Secure

1. **Environment variables first**
   All user-specific values (name, email, API tokens, file paths) are read from the environment when available.

2. **Local overrides in `config.local.el`**
   A file that lives next to `config.org`, is loaded at startup, but is *never* committed (see `.gitignore`).
   Use it to set `user-full-name`, `user-mail-address`, SMTP settings, API keys, etc.

3. **Encrypted credentials via `auth-source`**
   Passwords belong in `~/.authinfo.gpg` (or the file pointed to by `$AUTHINFO_FILE`).
   Emacs decrypts it on demand; the plaintext never touches the repo.

4. **Automated checks**
   The CI container loads the config in batch mode.  If private data were hard-coded, the pipeline would fail on other machines, making leaks obvious.

---

## Development Files

- **`TESTING.md`**: Step-by-step guide to the **lint / test / integration** pipeline that now runs on every push (see section below).
-   **`.dagger/config.ts`**: Contains the main Dagger pipeline logic written in TypeScript. This script defines the steps to build Emacs, set up Doom Emacs, and test the configuration.
-   **`.github/workflows/ci.yml`**: Defines the GitHub Actions workflow that triggers the CI pipeline on relevant file changes.
-   **`package.json`**:
    -   Declares project metadata and dependencies (like `@dagger.io/dagger`).
    -   Defines the `pipeline` script (`node --loader ts-node/esm .dagger/config.ts`) used by the CI workflow (and for local execution) to run the Dagger pipeline.
    -   Specifies `"type": "module"`, indicating the project uses ES Module syntax.
-   **`tsconfig.json`**: Configures the TypeScript compiler options. It's set up for an ES Module project (`"module": "NodeNext"`).
-   **`dagger.json`**: Dagger project file specifying the project name, SDK (typescript), and the main source file (`.dagger/config.ts`).
-   **`config.org`**: Literate configuration tangled to `config.el` for Doom.
    -   Now reorganised and annotated for easier navigation (see the *Secure Configuration* and *Setup* sections at the top).

## Setting Up Development Environment

You may export variables in your shell profile (`.zshrc`, `.bashrc`) **or** use [direnv](https://direnv.net/) for per-project scopes.

Examples:

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

## Testing Pipeline

Sometimes you just want a **fast confidence check** instead of running the
full container build (which compiles Emacs from source and can take several
minutes). Two environment variables make this possible:

| Variable     | Effect | Typical use-case |
|--------------|--------|------------------|
| `LINT_ONLY`  | Runs only the **Lint** stage (static `checkdoc` over every `*.el`) and exits. | Instant feedback while iterating on small Lisp edits |
| `SKIP_DEPS`  | Skips the lengthy **apt + Emacs build** step. Assumes you already have a suitable Emacs binary in the base image. | CI warm-cache or local machines with Emacs pre-installed |

Examples:

```bash
# 1. Fastest: just lint the code ( < 30 s on cached Docker image )
LINT_ONLY=true npm run pipeline

# 2. Lint + full test stages, but reuse host Emacs instead of rebuilding
SKIP_DEPS=true npm run pipeline

# 3. Full pipeline (lint → test → integration) – can take several minutes
npm run pipeline
```

What each stage does:

* **Lint**   – `checkdoc` ensures docstrings & style guidelines are met.  
* **Test**   – `doom sync -e` byte-compiles the config & resolves packages.  
* **Integration** – Boots Emacs in batch mode to prove the whole config loads.  

> ℹ️ Expect the **full** run to pull an Ubuntu image, install build
> dependencies and compile Emacs 30.  Subsequent runs are faster thanks to
> Docker layer caching.

## Environment Variables

Set **`USER_FULL_NAME`** and **`USER_MAIL_ADDRESS`** environment variables to populate your personal information when Emacs starts (aliases `EMACS_USER_NAME` / `EMACS_USER_EMAIL` are still accepted for backwards-compatibility).  
The configuration defaults to empty strings if these variables are unset.

```bash
# Generic identity
export USER_FULL_NAME="John Doe"
export USER_MAIL_ADDRESS="john@example.com"

# Mail / SMTP
export EMACS_SMTP_USER="john@example.com"
export EMACS_SMTP_PASSWORD="app-password-here"   # Prefer auth-source, see below

# Org notes location
export ORG_NOTES_DIR="$HOME/Documents/notes"

# Tokens
export GITHUB_TOKEN="ghp_…"
```

Variables are read in `config.org` *before* anything else, so they are available to all later code.

---

## Local Configuration Loader

During tangling `config.org` writes the snippet:

```elisp
(let ((local (expand-file-name "config.local.el" doom-user-dir)))
  (when (file-exists-p local)
    (load local)))
```

At startup Emacs:

1. Looks for `~/.doom.d/config.local.el`.
2. Loads it **after** basic defaults so you can override any variable or call arbitrary Emacs Lisp.
3. Continues with the rest of the configuration.

Because the file is ignored by Git, you are free to place individualized or experimental code here.

### Creating a Skeleton

```elisp
;;; ~/.doom.d/config.local.el -*- lexical-binding: t; -*-

(setq user-full-name  (or (getenv "EMACS_USER_NAME")  "John Doe")
      user-mail-address (or (getenv "EMACS_USER_EMAIL") "john@example.com"))

;; Example mu4e setup
(after! mu4e
  (set-email-account! "Gmail"
    `((smtpmail-smtp-user     . ,user-mail-address)
      ;; …
      )))
```

---

## Encrypted Authentication File (`~/.authinfo.gpg`)

`auth-source` automatically reads credentials from an **encrypted** netrc-style file.

1. Install `gpg` and create a GPG key if you do not have one.
2. Create `~/.authinfo` with entries like:

   ```
   machine smtp.gmail.com login john@example.com password app-password-here port 587
   ```

3. Run

   ```bash
   gpg -c ~/.authinfo   # or use gpg --encrypt --recipient <KEYID>
   rm ~/.authinfo       # keep only the .gpg file
   ```

4. Ensure the path is correct (default `~/.authinfo.gpg` or set `$AUTHINFO_FILE`).
5. Emacs decrypts it transparently when SMTP or other packages request credentials.

---

## Contributing

PRs and issues are welcome—but **never check in personal secrets**.  Follow the security model above and run `npm run pipeline` before pushing.