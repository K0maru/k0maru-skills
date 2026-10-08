# k0maru-skills 🧠⚡

> **Personal Agent Skills & Workflow Hub**  
> Custom-tailored for **Ghostty + Herdr + tuicr** and synchronized across **Antigravity**, **Claude Code**, and **Universal Agent Skills (`~/.agents/skills`)**.

---

## 🎯 Design Philosophy & Customization Notice

> [!IMPORTANT]
> **Personal Environment Customization Notice（个人定制说明）**  
> This repository is **not a generic drop-in skill pack**. It has been deeply customized and tuned specifically for **@K0maru's personal engineering workflow and local environment**:
> - **Terminal-First Workflow**: Designed around **Ghostty** and the **Herdr** terminal multiplexer (`HERDR_ENV=1`), with fallback support for `tmux` and `zellij`.
> - **Anti-Vibe-Coding**: Built specifically to counteract developer skill degradation caused by blind AI reliance. Emphasizes interactive code reading, TDD contracts, architectural stress-testing, and rigorous review.
> - **IDE-Free Code Review**: Fully integrated with **[`tuicr`](https://github.com/agavra/tuicr)** so code reviews and AI-guided walkthroughs happen completely within split-pane terminal TUIs without opening heavy GUI editors.
> - **Subagent-Driven Execution**: Workflows default to delegating heavy implementation tickets to isolated subagents to preserve main context cleanliness.

---

## 📁 Repository Structure

```text
k0maru-skills/
├── core/                  # 🌟 Original & Heavily Custom-Crafted Workflows
│   ├── code-review/       # Terminal-native tuicr review + AI guided reading (铺路标)
│   ├── implement/         # Subagent-delegated ticket execution + auto-review handoff
│   ├── grilling/          # Architectural stress-testing with ADR persistence
│   └── init-agents/       # Standardized AGENTS.md constitution generator with desensitized Bot attribution
│
├── vendor/                # 🛠️ Curated & Adapted Open-Source Skills
│   └── mattpocock/        # Filtered from mattpocock/skills (irrelevant teaching skills removed)
│       ├── engineering/   # codebase-design, domain-modeling, tdd, diagnosing-bugs, etc.
│       ├── productivity/  # handoff, wait-what, writing-for-agents, etc.
│       └── misc/          # git-guardrails-claude-code, setup-pre-commit
│
├── external/              # 🔌 Upstream Tooling & Integrations
│   ├── tuicr/             # Code review TUI and multiplexer wrappers
│   ├── herdr/             # Herdr terminal multiplexer controller
│   ├── find-skills/       # Skill discovery tool (skills.sh)
│   ├── ui-ux-pro-max/     # UI/UX design intelligence dataset
│   ├── design-taste-frontend/
│   └── figures4papers/    # Scientific & publication figure making
│
├── licenses/              # ⚖️ Upstream Open-Source License Archives
│   ├── LICENSE-mattpocock.txt
│   └── LICENSE-tuicr.txt
│
├── bin/
│   └── k0maru-skills      # Global CLI management tool
├── scripts/
│   └── sync.sh            # Automated multi-agent symlink distributor
└── install.sh             # One-click installer
```

---

## 🌟 Key Custom Workflow Highlights

### 1. `core/code-review` (OCR Delegation & Terminal Review)
- **OCR 委托模式智能预审 (Delegation Pre-Scan)**: Invokes `ocr delegate preview` and `ocr delegate rule` to extract module topology and language-specific rules (Go NPE, Rust lifetime, Svelte reactivity) with zero extra API key cost.
- **人机决策门禁 (Interactive Decision Gate)**: Produces an executive summary (tests, scope, smells) and prompts the human Tech Lead to choose:
  1. *(Recommended)* Directly submit/update PR.
  2. Launch `tuicr` in a split pane for deep guided walkthrough.
  3. Dispatch subagents to auto-fix findings.
  4. Approve and merge PR to `dev`.
- **AI 领读铺路标 (Guided Walkthrough)**: When entering `tuicr`, the AI annotates:
  - 🌊 **宏观数据流 (Data Flow)**: Entry points, key transformations, state mutations.
  - 🔍 **解构黑魔法 (De-sugaring)**: Translates dense/esoteric syntax into plain, readable equivalents.
  - 🛡️ **脆弱防御点 (Fragile Logic)**: Highlights edge cases, missing null-checks, or race conditions.
- **Bi-Directional Feedback**: Human leaves comments in the TUI; AI retrieves them via `tuicr review comments` to answer questions or execute refactorings.

### 2. `core/implement` (Subagent Delegation)
- **Context Isolation**: Instead of muddying the main orchestrator's conversation with compilation errors and diffs, work is delegated to isolated subagents.
- **Strict Execution Contract**: Mandates TDD at interface seams, clean typechecking, and targeted commits.
- **Auto-Review Handoff**: Chains directly into `code-review` delegation pre-scan and human decision gate upon completion.

### 3. `core/grilling` (Anti-Vibe-Coding Stress Test)
- Replaces disjointed stub skills with a relentless, frontier-based architectural interview.
- Forces clarification of failure modes, boundary contracts, and YAGNI reductions before coding.
- Offers automatic persistence of key architectural decisions to ADRs or `CONTEXT.md`.

### 4. `core/init-agents` (Workflow Constitution & Bot Desensitization)
- **Automatic Stack Detection**: Inspects git branches, linters (`clippy`/`biome`/`ruff`), package managers, and test suites.
- **Battle-Tested 7-Module Architecture**: Scaffolds `AGENTS.md` with Master-Worker isolation, `/to-spec ➔ /to-tickets ➔ /implement` loop, dual-trunk git branching (`Squash & Merge` into `dev`, `Merge Commit` into `main`), and non-negotiable project iron laws.
- **Strict Bot Desensitization**: Ensures public configs never leak private Bot User IDs or App IDs, dynamically binding to local `git config --get agent.coauthor`.

---

## 🚀 Quick Start & Installation

### One-Click Setup

Run the installer to set executable permissions, synchronize symlinks across all your local agent environments, and register the `k0maru-skills` CLI:

```bash
./install.sh
```

Or on a fresh machine:
```bash
git clone git@github.com:K0maru/k0maru-skills.git ~/workspace/k0maru-skills
cd ~/workspace/k0maru-skills && ./install.sh
```

---

## 🛠️ CLI Management (`k0maru-skills`)

After running `install.sh`, you can manage your skills globally from any terminal pane:

```bash
# List all registered skills and their originating categories
k0maru-skills list

# Re-synchronize and clean up dangling symlinks across all agent environments
k0maru-skills sync

# Print repository path
k0maru-skills path
```

---

## ⚖️ Credits & Acknowledgements (参考来源与致谢)

This repository stands on the shoulders of the open-source community. Sincere gratitude to the following authors and projects:

- **[mattpocock/skills](https://github.com/mattpocock/skills)** by **Matt Pocock**:
  - The foundation for the curated engineering and productivity patterns in `vendor/mattpocock/`.
  - Filtered to eliminate personal course scaffolding and adapted for production engineering workflows.
  - Licensed under the **MIT License** (see [licenses/LICENSE-mattpocock.txt](licenses/LICENSE-mattpocock.txt)).
- **[agavra/tuicr](https://github.com/agavra/tuicr)** by **tuicr contributors**:
  - The outstanding terminal code review TUI that powers the interactive review and guided reading workflow.
  - Licensed under the **MIT License** (see [licenses/LICENSE-tuicr.txt](licenses/LICENSE-tuicr.txt)).
- **Community Skills Authors**:
  - `ui-ux-pro-max`, `design-taste-frontend`, `herdr`, `find-skills`, `figures4papers` are credited to their respective creators under permissive open-source licenses.
  - `DietrichGebert/ponytail` for the inspiration regarding anti-overengineering and code diet principles.

---

## ⚠️ Disclaimer (免责声明)

1. **Personal Workflow Specificity**: This repository is tailored specifically to the author's personal hardware, operating system (macOS), terminal emulator (Ghostty), multiplexer (Herdr), and editor setup. Prompts, paths, and integration hooks may not work identically in different development setups without modification.
2. **"AS IS" Warranty**: The code, scripts, and prompts in this repository are provided "AS IS", without warranty of any kind, express or implied.
3. **Agent Autonomy**: Skills and workflows grant autonomous agents permission to run commands, create files, and dispatch subagents. Users adopting these workflows are responsible for verifying commands and maintaining appropriate git guardrails.

---

## 📄 License

Original modifications, core workflows, tooling scripts, and repository structure are licensed under the **MIT License** © 2026 K0maru. See [LICENSE](LICENSE) for full details.
