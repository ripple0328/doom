# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **Doom Emacs configuration** repository with automated CI/CD testing using Dagger. The configuration is written in literate programming style using `config.org` which tangles to `config.el`. It includes a comprehensive testing pipeline that validates the configuration in containerized environments.

## Key Files and Architecture

- **`config.org`** - Main literate configuration file (tangled to `config.el` on `doom sync`)
- **`config.el`** - Generated Emacs Lisp configuration (auto-generated from `config.org`)
- **`config.local.el`** - Untracked personal overrides file (not in git, used for local customization)
- **`init.el`** - Doom module definitions and flags
- **`packages.el`** - Package declarations and configurations
- **`.dagger/config.ts`** - Dagger pipeline for CI/CD testing

## Key Bindings

- **`SPC l`** - LLM Assistant menu (gptel integration with AI/ChatGPT)
  - `SPC l c` - Chat with LLM
  - `SPC l s` - Send to LLM
  - `SPC l m` - LLM menu
  - `SPC l r` - Rewrite with LLM
  - `SPC l a` - Add context
  - `SPC l f` - Add file to context
  - **`SPC l o`** - Code Assistant submenu
    - `SPC l o r` - Code review
    - `SPC l o e` - Explain code
    - `SPC l o f` - Refactor code
    - `SPC l o d` - Debug help
    - `SPC l o o` - Optimize code
    - `SPC l o t` - Write tests
    - `SPC l o s` - Start coding session
    - `SPC l o p` - Add project context

## Common Commands

### Development Workflow
```bash
# Install dependencies
npm ci

# Sync Doom configuration (tangle config.org and install packages)
doom sync

# Test configuration locally with full pipeline
npm run pipeline

# Quick lint-only check (fastest)
LINT_ONLY=true npm run pipeline

# Test without rebuilding Emacs (medium speed)
SKIP_DEPS=true npm run pipeline
```

### Testing Pipeline Stages
1. **Lint** - `checkdoc` validation of all `.el` files (with retry logic and minimal Emacs install)
2. **Test** - `doom sync -e` byte-compilation and package resolution  
3. **Integration** - Boot Emacs in batch mode with the configuration

### GitHub Actions Matrix
The CI runs three test variants:
- **lint** - Fast linting with minimal Emacs installation (`LINT_ONLY=true`)
- **skip-deps** - Full pipeline reusing host Emacs (`SKIP_DEPS=true`)
- **full** - Complete pipeline building Emacs from source (main/PR only)

### Performance Optimizations
The pipeline includes several caching optimizations:
- **APT cache** - Cached package downloads via mounted cache volumes
- **Emacs build cache** - Cached source downloads and ccache for compilation
- **Enhanced logging** - Detailed timestamps and stage tracking
- **Retry logic** - Automatic retries for flaky network operations

## Environment Variables for Configuration

The configuration reads personal information from environment variables to avoid committing sensitive data:

- `USER_FULL_NAME` / `EMACS_USER_NAME` - User's full name
- `USER_MAIL_ADDRESS` / `EMACS_USER_EMAIL` - User's email address
- `ORG_NOTES_DIR` - Directory for org-mode notes (defaults to `~/Documents/notes/`)
- `EMACS_SMTP_USER` - SMTP username for email
- `EMACS_SMTP_PASSWORD` - SMTP password (prefer auth-source)
- `GITHUB_TOKEN` - GitHub API token
- `AUTHINFO_FILE` - Path to encrypted auth file (defaults to `~/.authinfo.gpg`)

## Security Model

1. **Environment variables first** - All personal data comes from env vars
2. **Local overrides** - `config.local.el` for machine-specific settings (gitignored)
3. **Encrypted credentials** - Use `~/.authinfo.gpg` for passwords/tokens
4. **Automated validation** - CI ensures no personal data is hardcoded

## Package Management

- Add packages in `packages.el` using `(package! package-name)`
- Use `doom sync` after adding packages
- Configuration for packages goes in `config.org`

## Literate Programming

The main configuration is in `config.org` with code blocks that tangle to `config.el`. When editing:
- Modify `config.org`, not `config.el` directly
- Run `doom sync` to tangle and apply changes
- Each section has org-mode headers and explanatory text

## Testing Before Commits

Always run the pipeline before committing:
```bash
# Quick validation
LINT_ONLY=true npm run pipeline

# Full validation (takes longer, builds Emacs from source)
npm run pipeline
```

The CI runs three test variants: lint-only, skip-deps, and full pipeline.