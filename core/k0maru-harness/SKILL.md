---
name: k0maru-harness
description: Orchestrate end-to-end task lifecycle, component readiness probe, and multi-stage verification pipelines across the decoupled K0maru agent harness (k0maru-router, k0maru-verifier, k0maru-workspace, k0maru-memory).
---

# k0maru-harness (Decoupled E2E Task Pipeline & Orchestration)

A lightweight, daemonless orchestration harness that coordinates end-to-end agent task execution across four decoupled Unix-philosophy pillars:
1. **k0maru-router**: Cross-repo Task Router, Discrete Signal & Receipt Bus (`~/.k0maru/signals/`, `~/.k0maru/receipts/`) [Core Orchestrator].
2. **k0maru-verifier**: Deterministic Physical Test Oracle, Linter & Receipt Signer [Optional Selection].
3. **k0maru-workspace**: Git Worktree Ephemeral Sandbox & Zero-Conflict Isolation [Optional Selection].
4. **k0maru-memory**: Zero-Daemon Long-Term Memory Hub & Living ADR Guard [Optional Selection].

---

## 🎯 When to Use

1. **Component Readiness Check**: Probe binary availability and file bus readiness across all 4 pillars before starting complex workflows.
2. **End-to-End Task Verification**: Execute a multi-stage closed-loop pipeline for code changes:
   - Sandbox Provisioning (Git worktree isolation)
   - Patch Application (Git apply)
   - Physical Oracle Verification (Cargo / Pytest / NPM test, linter, scope guard)
   - Sandbox Teardown / Merge
   - Discrete Signal Bus Emission (`~/.k0maru/signals/`)
   - Memory Hub Crystallization (`k0maru session flush`)
3. **Decoupled Fallback**: Run tasks in environments where only a subset of tools is installed—the harness will gracefully skip missing optional components without failing.

---

## 🚀 Execution Seams

### Seam 1: CLI (`k0maru-router pipeline` or `k0maru-router e2e`)

```bash
# 1. Probe readiness of harness components (<5ms)
k0maru-router pipeline check
# Output in JSON format:
k0maru-router pipeline check --json

# 2. Run E2E pipeline for in-place verification
k0maru-router pipeline run --task-id task_feature_01 --verify

# 3. Run isolated verification with Git Worktree sandbox
k0maru-router pipeline run \
  --task-id task_feature_01 \
  --workspace /path/to/repo \
  --isolate \
  --patch /path/to/changes.patch \
  --verify \
  --emit-signal \
  --crystallize-memory
```

### Seam 2: MCP Tools (`check_pipeline_health`, `run_e2e_pipeline`)

```json
// Probe health across all 4 pillars:
check_pipeline_health({})

// Execute automated verification pipeline:
run_e2e_pipeline({
  "task_id": "task_verifier_diff_gate_01",
  "workspace": "/Users/k0maru3/workspace/k0maru-agent-verifier",
  "verify": true,
  "emit_signal": true
})
```

---

## 🧩 Architectural Invariants & Decoupling

- **Strict Modularity**: Zero static compile-time linkage between the 4 binaries.
- **File-Bus Driven**: All inter-tool communication occurs via filesystem contracts (`~/.k0maru/signals/`, `~/.k0maru/receipts/`).
- **Optionality (选配)**:
  - If `k0maru-workspace` is missing: Falls back to in-place workspace execution.
  - If `k0maru-verifier` is missing: Skips physical oracle and marks stage as skipped.
  - If `k0maru-memory` is missing: Skips memory crystallization cleanly.
