# LLM Integration Guide

> **File:** `LLM-INTEGRATION.md`  
> **Audience:** Contributors who want to add Large-Language-Model super-powers to the existing Dagger pipeline for Doom Emacs.

---

## 1  What Is Dagger’s LLM Core-Type?

Dagger v0.18 introduced a **first-class `LLM` core type** (see the official [docs](https://docs.dagger.io/api/llm)):

* Attach objects (logs, files, directories …) to a model.
* Send a `prompt` and receive a structured response.
* Provider-agnostic – OpenAI, Anthropic, Google Gemini, Ollama, etc.  
  (anything exposing an *OpenAI-compatible* HTTP API).

The API surface is intentionally minimal:

```ts
const summary = await client
  .llm()
  .withProvider("openai")          // or "anthropic", "gemini", "ollama", …
  .withModel("gpt-4o-mini")        // model/vendor specific
  .withTemperature(0.2)
  .withSystemMessage("You are an Emacs-Lisp code-review bot.")
  .chat("Explain this stack trace:", containerLogs);
```

The result (`summary`) is a plain string, ready to be pushed to CI logs, Slack, GitHub PR comments, etc.

---

## 2  Why Add an LLM to Our Pipeline?

| Pain-point                              | Traditional fix | LLM-powered improvement                |
|-----------------------------------------|-----------------|----------------------------------------|
| Long, noisy compiler / package errors   | Manually scroll | Auto-generated **bullet-list summary** |
| Style-lint violations (`checkdoc`)      | Fix by reading  | Ask model to **autofix** and return a patch |
| New contributor confusion               | Docs           | Chat agent suggests next steps in CI logs |
| Investigating byte-compilation failures | Reproduce local | LLM proposes **minimal repro** steps   |

---

## 3  Prerequisites

1. **API key** – export one of:
   ```bash
   export OPENAI_API_KEY="sk-…"
   # or
   export ANTHROPIC_API_KEY="…"
   # or any other provider env var recognised by Dagger
   ```

2. Ensure you are running **Dagger ≥ 0.18** (`dagger version`).

3. No extra npm deps – the functionality lives in the engine.

---

## 4  Wiring an LLM Into `.dagger/config.ts`

Below is a **self-contained patch** you can drop into the existing pipeline.
It hooks after each stage, summarises logs, and uploads the result as a
pipeline annotation.

```ts
// top of file
import type { LLM } from "@dagger.io/dagger";

// helper ──────────────────────────────────────────────────────────────
async function summarise(client: Client, title: string, logs: string) {
  // Guard – skip if no provider key is present
  if (!process.env.OPENAI_API_KEY && !process.env.ANTHROPIC_API_KEY) {
    return;
  }

  const llm: LLM = client
    .llm()
    .withProvider("openai")        // change if you prefer Anthropic, etc.
    .withModel("gpt-3.5-turbo")    // cheap + fast
    .withMaxTokens(400)
    .withTemperature(0);

  const summary = await llm.chat(`
You are an Emacs expert.  Summarise the log below into
max 10 bullet points.  Highlight any errors or warnings.

\`\`\`text
${logs}
\`\`\`
`);

  console.log("🧠  LLM summary:");
  console.log(summary);
}

// inside main() after each .withExec()
const lintLogs = await ctLint.stdout();           // capture
await summarise(client, "Lint stage", lintLogs);  // summarise
```

**Key points**

* We **only call `summarise` if an API key is set**, keeping default runs free.
* `stdout()` / `stderr()` returns the buffered logs of the previous step.
* No secrets leak – Dagger masks provider keys in CI logs.

---

## 5  Practical Use-Cases for Doom Emacs

### 5.1  Auto-fix `checkdoc` Warnings

```ts
const lintResult = await ctLint.stdout();

const patch = await client.llm()
  .withProvider("openai")
  .withSystemMessage("You are an Emacs-Lisp autofix bot.")
  .chat(`
Given the following checkdoc output, provide a unified diff that fixes the
issues.  Strictly output only the diff.

${lintResult}
`);

if (patch.startsWith("---")) {
  await src.applyPatch(patch);    // core.Container method
}
```

### 5.2  Suggest Package Pins

Capture failing `doom sync` output and ask the model to propose
`package!` pin directives:

```ts
const testLogs = await ctTest.stdout();
const advice = await client.llm()
  .withProvider("openai")
  .withModel("gpt-4o-mini")
  .chat(`
The following 'doom sync' failed.  Suggest MELPA commit pins that would
resolve the problem.  Output as a Markdown list.

${testLogs}
`);
console.log(advice);
```

### 5.3  Explain a Byte-Compilation Trace in CI

```ts
const integrationLogs = await ctIntegration.stderr();
await summarise(client, "Integration stage", integrationLogs);
```

---

## 6  Integrating With Emacs Runtime

Nothing prevents you from invoking an LLM *inside Emacs* for dynamic
refactors.  Example (placed in `config.local.el`):

```elisp
(defun my-ai-fix-region (beg end)
  "Ask an LLM to rewrite the active region."
  (interactive "r")
  (let* ((text (buffer-substring-no-properties beg end))
         (resp (dagger-llm-chat
                :prompt (format "Rewrite the elisp to be more idiomatic:\n%s" text))))
    (delete-region beg end)
    (insert resp)))
```

The `dagger-llm-chat` helper could be a thin wrapper that calls the same
HTTP endpoint used by the pipeline, giving you **local + CI parity**.

---

## 7  Security Considerations

| Concern                     | Mitigation                                                      |
|-----------------------------|-----------------------------------------------------------------|
| Proprietary code exfil      | Only send *logs* or *diffs*, never the full source tree.        |
| Token leakage               | Use Dagger **Secret** objects; they are redacted in UI/logs.    |
| Model hallucination         | Treat output as advisory; keep human review in the loop.        |
| Cost overruns               | Set `MAX_TOKENS` / `TEMPERATURE`, or wrap calls in a budgeter.  |

---

## 8  Future Ideas

* **Conversational Re-runner** – a GitHub bot that lets you comment
  `@bot /rerun with fix-imports` which feeds your command into the LLM,
  edits config, and re-executes the pipeline.

* **Automated changelog** – summarise diffs between two commits and
  append to `CHANGELOG.org`.

* **Chat-UI inside Emacs** – stream Dagger LLM responses into a
  `vterm` buffer for an in-editor Copilot.

---

## 9  TL;DR

1. Export an API key (`OPENAI_API_KEY=…`).  
2. Copy the `summarise()` helper into `.dagger/config.ts`.  
3. Capture logs with `.stdout()` / `.stderr()` and feed them to the LLM.  
4. Profit 🎉 – your CI now speaks!

Happy hacking!
