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
4. **Distributed Cross-Node Execution (Tailscale Linux Dispatch)**:
   - When the user asks to execute on a remote host (e.g., "在公司机器上跑", "去 Linux 机器测试", "发到 GPU 服务器").
   - When local environment (macOS) lacks Linux-specific toolchains, Docker daemons, or hardware access.
   - Offload heavy multi-crate compilation or large regression test batches to remote Linux workstations running `tmux` or `herdr`.

---

## 🚀 Execution Seams

### Seam 0: Top-Level Meta-Harness Porcelain (`k0maru-harness`)

```bash
# 1. Probe readiness across all 4 pillars and buses (<10ms)
k0maru-harness probe
k0maru-harness probe --json

# 2. Just-In-Time (JIT) Experience & Invariant Activation (ExpActivator thesis)
# Slashing 90% context bloat down to <180 tokens for discrete decision points:
k0maru-harness memory jit --decision "git branching"
k0maru-harness memory jit --decision "sqlite lock" --limit 2 --json

# 3. End-to-end task runner & worker loop
k0maru-harness run "Refactor authentication token" --domain AUTH-SRV --verify
k0maru-harness worker --domain HARNESS --once
```

### Seam 1: Legacy Routing & Dispatch CLI (`k0maru-router pipeline` or `k0maru-router e2e`)

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

# 4. Distributed execution on remote Linux PC over Tailscale (tmux or herdr)
k0maru-router pipeline run \
  --task-id task_remote_01 \
  --workspace /home/user/backend \
  --node company-linux \
  --remote-backend auto \
  --verify \
  --json
```

### Seam 2: MCP Tools (`check_pipeline_health`, `run_e2e_pipeline`)

```json
// Probe health across all 4 pillars:
check_pipeline_health({})

// Execute automated verification pipeline locally:
run_e2e_pipeline({
  "task_id": "task_verifier_diff_gate_01",
  "workspace": "/Users/k0maru3/workspace/k0maru-agent-verifier",
  "verify": true,
  "emit_signal": true
})

// Execute automated verification pipeline on remote node over Tailscale:
run_e2e_pipeline({
  "task_id": "task_remote_verification_01",
  "workspace": "/home/user/backend",
  "node": "company-linux",
  "remote_backend": "auto",
  "verify": true,
  "emit_signal": true
})
```

### Seam 3: Machine-Native Protocol (K-DSL 0.1)

```bash
# Print machine-native contract to inject into closed-source models (zero prose, pure DSL)
k0maru-router kdsl contract

# Convert TaskEnvelope JSON to dense 38-token K-DSL packet
k0maru-router kdsl encode task.json

# Decode K-DSL packet into AST coordinates and operations
k0maru-router kdsl decode "!δ:0.1|AUTH-SRV|src/auth.ts#v1 §AST:F[verify] @OP:SWAP_ID (a) -> (b) !Σ:VERIFY(TEST)"
```

### Seam 4: Linda Tuple Space Event Bus (`out / in / rd / list`)

```bash
# Atomic write of a task tuple into ~/.k0maru/tuples/
k0maru-router tuple out --kind TASK_READY --domain AUTH-SRV --task-id t1 --payload "<K-DSL/JSON>"

# Non-destructively inspect matching state (with optional --wait and --timeout)
k0maru-router tuple rd --kind TASK_READY --wait --timeout 30

# Atomically claim and consume a task tuple (reactive blocking wait)
k0maru-router tuple in --kind TASK_READY --domain AUTH-SRV --wait --timeout 30

# Query all active tuples in the space
k0maru-router tuple list
```

### Seam 5: Reactive Worker Loop & Autonomous Lifecycle

```bash
# 1. Start autonomous reactive worker listening for tasks in domain
k0maru-router worker --domain AUTH-SRV --once --exec "k0maru-workspace tuple-claim --domain AUTH-SRV"

# 2. Workspace claims TASK_READY, provisions sandbox, and emits SANDBOX_READY
k0maru-workspace tuple-claim --domain AUTH-SRV

# 3. Verifier runs physical quality gate with K-DSL assertion and emits TASK_VERIFIED or TASK_BLOCKED
k0maru-verifier verify --workspace ./.worktrees/t1 --task-id t1 --kdsl "!Σ:VERIFY(COMPILE,TEST)"

# 4. Workspace settles task: merges to target on pass or aborts on block, emitting TASK_COMPLETED
k0maru-workspace tuple-settle --task-id t1

# 5. Memory listens to TASK_COMPLETED and crystallizes outcomes into 01_AI_Logs
k0maru crystal --vault ~/Documents/SecondBrain --consume
```

---

## 🧩 Architectural Invariants & Decoupling

- **Strict Modularity**: Zero static compile-time linkage between the 4 binaries.
- **File-Bus Driven**: All inter-tool communication occurs via filesystem contracts (`~/.k0maru/tuples/`, `~/.k0maru/receipts/`).
- **Reactive & Non-blocking**: Uses OS-level file events and atomic file rename locks (`tuple in --wait`) with zero resident daemon overhead.
- **Optionality (选配)**:
  - If `k0maru-workspace` is missing: Falls back to in-place workspace execution.
  - If `k0maru-verifier` is missing: Skips physical oracle and marks stage as skipped.
  - If `k0maru-memory` is missing: Skips memory crystallization cleanly.
