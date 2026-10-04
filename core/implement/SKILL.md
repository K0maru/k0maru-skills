---
name: implement
description: "Implement a piece of work based on a spec or set of tickets. Defaults to delegating execution to a dedicated subagent to isolate context and verify work test-first."
---

# Implement (Subagent-Driven Execution)

Executes work described in a specification or task tickets. **Defaults to spawning a subagent** for the actual coding work, keeping the main orchestrator's context window clean, focused, and ready for high-level verification.

---

## 🚀 Execution Protocol

### Step 1: Analyze & Batch Tickets
1. Read the provided ticket(s), spec, or issue description.
2. Verify acceptance criteria, target files, and affected architectural seams.
3. If there are multiple tickets, identify dependencies and order them into an execution queue.

### Step 2: Dispatch Subagent (Default Behavior)
For each ticket (or coherent batch of work), spawn a dedicated subagent via `invoke_subagent` (or equivalent tool) with an explicit, bounded prompt:

**Subagent Prompt Requirements:**
- **Goal & Scope**: State exactly what ticket/feature is being implemented, and explicitly forbid modifying unrelated files.
- **TDD Requirement**: Use `/tdd` where possible — write tests for boundaries/interfaces first, implement, then verify.
- **Verification**: Run typechecking (`tsc`, `mypy`, `cargo check`, etc.) and the relevant unit test files until green.
- **Commit**: Commit the completed changes with a clear commit message referencing the ticket.
- **Report**: Return a concise summary of files changed, tests added, and any architectural trade-offs made.

### Step 3: Orchestrator Verification
Once the subagent finishes and reports back:
1. Verify the overall test suite passes on the workspace.
2. Check for any unexpected scope creep or file modifications (`git status`, `git diff --stat`).
3. If multiple sequential tickets exist, proceed to dispatch the next ticket's subagent.

### Step 4: Hand Off to Review & Decision Gate
Once all ticket implementations are complete:
- Invoke `/code-review` to trigger OCR delegation pre-review and present an executive summary.
- Prompt the human Tech Lead to choose next action: submit PR directly, launch interactive `tuicr` walkthrough in a split pane, or execute auto-fixes.
