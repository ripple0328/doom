# Testing & CI/CD Guide

This document explains **how the Doom Emacs configuration is automatically verified** and how you can reproduce every step locally with nothing but **Docker + Dagger** installed on your machine.

---

## 1.  What Gets Tested?

| Stage | Goal | Tooling |
|-------|------|---------|
| **Lint** | Static analysis of every `*.el` file (`checkdoc`) to catch style & docstring issues early | Emacs 30.1 in batch mode |
| **Test** | `doom sync -e` byte-compiles and resolves packages; fails if any package or byte-compilation error occurs | Doom Emacs CLI |
| **Integration** | Boots Emacs **with your config** in batch mode and exits; proves the editor can start end-to-end | Emacs 30.1 |

All three stages run inside the same Ubuntu container; no host packages are required.

---

## 2.  Pipeline Architecture

```
┌──────────────┐        ┌──────────┐        ┌──────────────┐
│  Lint Stage  │ ───▶   │ Test     │ ───▶   │ Integration  │
│  checkdoc    │        │ doom sync│        │ emacs --batch│
└──────────────┘        └──────────┘        └──────────────┘
```

### Key points

* **Single container build** – the image is created once, then reused for each step.
* **No cache pollution** – the repo is mounted read-only; build artifacts live in container layers.
* **Exit code propagation** – a non-zero exit in any command makes the whole job fail.

---

## 3.  Running the Tests Locally

### Prerequisites

* Docker Engine OR a running **Dagger Engine**
* `npm` (only for launching the script)

### Quick start

```bash
git clone <repo> ~/.doom.d
cd ~/.doom.d
npm ci                # install dagger sdk + ts-node
npm run pipeline      # executes .dagger/config.ts

# Skip the lengthy Emacs build if you trust the global binary:
SKIP_DEPS=true npm run pipeline
```

What happens:

1. **Docker present** → the script uses *Docker fallback mode* (`docker run …`).
2. **No Docker socket** → the script connects to the Dagger daemon and runs the same steps remotely.

Both paths perform identical work.

---

## 4.  How It Works in CI (GitHub Actions)

```
.github/workflows/ci.yml
   └─▶ checkout
       └─▶ npm ci
           └─▶ npm run pipeline   # same entry-point as local
```

The matrix triggers on any change to `*.el`, `*.org`, or workflow files.  
Because CI runs the identical container recipe, you get **“works-on-my-machine” parity**.

---

## 5.  Dagger Integration Details

* **Language**: TypeScript (`.dagger/config.ts`)
* **Highlights**
  * Detects Docker socket → fallback to `docker run`
  * Otherwise uses the **Dagger Engine** via `@dagger.io/dagger`
  * Creates a cache directory `.dagger/cache` for buildkit & module cache
  * Each logical phase is wrapped in `::group::` annotations for readable logs

```ts
// simplify: create base image
const base = client.container()
  .from("ubuntu:22.04")
  .withWorkdir("/workspace")
  .withMountedDirectory("/workspace", src);

// Lint, Test, Integration … chained via withExec
```

### Adding More Steps

You can chain additional `.withExec([...])` calls—for example, unit tests for custom lisp libraries.

---

## 6.  LLM Integration Possibilities 🧠

Dagger exposes an [`LLM` core type](https://docs.dagger.io/api/llm):

* **Automated failure summaries** – pipe container logs to an LLM to generate concise explanations.
* **Autofix suggestions** – send the diff & error message, receive an Emacs-Lisp patch.
* **Chat-ops** – trigger reruns or parameterised builds from chat messages.

The current pipeline includes **TODO(LLM)** comments where such hooks can be inserted once an OpenAI-compatible provider key is available:

```ts
// TODO(LLM): Pipe logs to Dagger LLM summariser once available
```

To experiment:

1. Set `export OPENAI_API_KEY=…` (or another provider key recognised by Dagger).
2. Extend `.dagger/config.ts`:

```ts
const llm = client.llm().withProvider("openai");
await llm.chat("Summarise this stack trace:", logs);
```

---

## 7.  Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `cannot connect to Docker daemon` | Docker not running or socket path different | `sudo systemctl start docker` or set `DOCKER_HOST` |
| Emacs build takes forever | First run compiles from source | Use `SKIP_DEPS=true` if you have Emacs ≥29 already installed system-wide |
| `doom sync` fails with missing package | MELPA outage or proxy | Re-run; if persistent, pin the package version in `packages.el` |
| Lint stage fails on docstring style | `checkdoc` is strict | Add proper docstrings or ignore with `checkdoc-force-docstrings-flag` |
| CI passes locally but not in GitHub | Inconsistent env vars | Ensure you commit `.envrc` or document required variables in README |

---

## 8.  Reference Commands

| Action | Command |
|--------|---------|
| Full pipeline (default) | `npm run pipeline` |
| Skip dependency install | `SKIP_DEPS=true npm run pipeline` |
| Only lint | `SKIP_DEPS=true LINT_ONLY=true npm run pipeline` (add a flag in the script) |
| Inspect container | `docker run -it --entrypoint bash $(docker build -q .)` |

---

Happy hacking & may your Emacs always boot on the first try!  
