---
name: code-review
description: Terminal-first, interactive code review and guided walkthrough with tuicr and Herdr. Supports AI-guided reading for complex logic, Fowler smell baseline, spec verification, and bi-directional TUI annotation.
---

# Code Review & Guided Walkthrough

A terminal-native review workflow designed to rebuild developer mental models, prevent vibe coding degradation, and provide deep architectural inspection.

It supports two complementary workflows:
1. **Interactive Terminal Review (`tuicr` + AI 领读)**: Opens an interactive split-pane TUI where the AI leaves reading guides and the user inspects with Vim keybindings.
2. **Automated Dual-Axis Audit**: Standards (code smells & conventions) vs. Spec (functional correctness & scope creep).

---

## Workflow 1: Interactive Terminal Review & AI 带读 (Default)

Use this when the user says "review this", "带我读代码", "帮我审查这次改动", or when evaluating recent code.

### Step 1: Detect Terminal & Split Pane
Check the environment:
- If running under **Herdr** (`$HERDR_ENV=1`): Use the Herdr wrapper (`tuicr-wrapper-herdr.sh`).
- If running under **tmux** (`$TMUX`): Use `tuicr-wrapper.sh`.
- If running under **Zellij** (`$ZELLIJ`): Use `tuicr-wrapper-zellij.sh`.
- Otherwise: Instruct user to launch `tuicr -w` or `tuicr -r <revset>`.

### Step 2: "AI 领读" 铺路标 (Paving the Path)
**Do not let the user drown in unfamiliar code.** Before the user begins reviewing, analyze the diff and write structured, line-level notes into the session via `tuicr review add`:

```bash
tuicr review add --repo /path/to/repo --session <slug> \
  --target-file <file> --line <line> --type note \
  --username "AI-Mentor" "<Comment>"
```

**What to annotate:**
1. **宏观数据流 (Data Flow)**: Mark where inputs enter and where key state transformations happen.
2. **解构黑魔法 (De-sugaring)**: For dense or unfamiliar syntax (Rust ownership patterns, advanced TypeScript conditional types, complex regex, subtle concurrency locks), write a 1-sentence plain explanation of what the logic translates to.
3. **隐患与防御点 (Edge Cases / Fragile Logic)**: Mark lines that require extra scrutiny (null checks, timeouts, race conditions).
4. **潜在异味 (Smells / Over-engineering)**: Mark with `--type suggestion` or `--type issue` if code violates YAGNI or reimplements standard library utilities.

### Step 3: Human Review in TUI
The user reviews in the split pane with Vim keybindings:
- `j` / `k` to navigate.
- Reads AI notes inline.
- Presses `Enter` or `c` to leave their own questions, `issue`s, or `suggestion`s.
- Quits `tuicr` (`q`) when done.

### Step 4: Retrieve Feedback & Action
Once the user finishes review, retrieve all comments:
```bash
tuicr review comments --repo /path/to/repo --session <slug>
```
- Answer user `note` questions thoroughly with simple mental models.
- Fix all `issue` and `suggestion` items in the code.

---

## Workflow 2: Automated Dual-Axis Audit

Use when the user asks for a formal, non-interactive audit or PR comparison against a base commit (`HEAD~N`, `main`, or PR).

### Axis 1: Standards & Smell Baseline
Check against repo documentation (`CODING_STANDARDS.md`, `CONTRIBUTING.md`) PLUS Fowler's Code Smell baseline:

- **Mysterious Name**: Names that obscure purpose or disguise side-effects.
- **Duplicated Code**: Identical or copy-pasted structures across hunks.
- **Feature Envy**: Logic that reaches into another module's internals rather than placing behavior with data.
- **Primitive Obsession**: Strings/numbers used where a domain type should exist.
- **Shotgun Surgery**: A single conceptual change requiring edits scattered across too many unrelated files.
- **Speculative Generality / Over-engineering**: Abstractions, hooks, or parameters added "just in case" without immediate need.
- **Reinventing Stdlib**: Writing custom helpers for operations natively supported by modern language APIs.

### Axis 2: Spec & Scope
Check against originating prompt, issue, or spec:
1. **Missing Requirements**: Features the prompt/issue requested that were skipped.
2. **Scope Creep / Unrequested Edits**: Code modified that had nothing to do with the prompt.
3. **Flawed Implementation**: Logic that compiles/runs but fails in edge cases or misses error branches.

### Report Format
Present findings clearly:
```markdown
## Standards & Code Health
- `path/to/file:L42` [Smell Name]: Description and recommended inline fix.

## Spec & Requirements
- [Scope / Bug]: Discrepancy between requirement and actual implementation.

## Mental Model Summary
- 3-sentence executive summary of the overall architecture and data flow.
```
