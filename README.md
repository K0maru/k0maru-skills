# k0maru-skills 🧠⚡

Personal Agent Skills & Workflow Hub for **Antigravity**, **Claude Code**, and **Universal Agent Skills (`~/.agents/skills`)**.

This repository manages customized prompts, workflows, and tool integrations tailored to personal engineering style, code review habits, and domain modeling.

---

## 📁 Repository Structure

```text
k0maru-skills/
├── core/                  # Original workflows & custom-crafted skills
│   └── (Your personal tailored skills)
├── vendor/                # Adapted & curated skills from the open-source community
│   └── mattpocock/        # Curated engineering & productivity skills (with attribution)
├── external/              # Third-party tools & standalone integrations
│   ├── tuicr/             # Code review TUI integration (tmux, zellij, Herdr, cmux)
│   ├── herdr/             # Herdr terminal multiplexer controller
│   ├── find-skills/       # Skill discovery tool (skills.sh)
│   ├── ui-ux-pro-max/     # UI/UX intelligence dataset
│   └── design-taste-frontend/
├── licenses/              # Upstream open-source license copies
│   ├── LICENSE-mattpocock.txt
│   └── LICENSE-tuicr.txt
├── scripts/
│   └── sync.sh            # One-click symlink distributor
└── README.md
```

---

## 🚀 Quick Start

### 1. View Available Skills

```bash
./scripts/sync.sh --list
```

### 2. Sync to Agent Environments

Run the sync script to automatically create/update symlinks across all your agent directories (`~/.agents/skills/`, `~/.gemini/config/skills/`, `~/.claude/skills/`):

```bash
./scripts/sync.sh
```

To preview changes without touching the disk:

```bash
./scripts/sync.sh --dry-run
```

---

## ⚖️ Credits & Attribution

This repository respects open-source software and includes adapted or vendored works under the **MIT License**:

- **[mattpocock/skills](https://github.com/mattpocock/skills)** by Matt Pocock:
  - Source for curated engineering, productivity, and agent skills in `vendor/mattpocock/`.
  - Licensed under the MIT License (see [licenses/LICENSE-mattpocock.txt](licenses/LICENSE-mattpocock.txt)).
- **[agavra/tuicr](https://github.com/agavra/tuicr)** by tuicr contributors:
  - Source for the `tuicr` review workflow and terminal multiplexer wrappers in `external/tuicr/`.
  - Licensed under the MIT License (see [licenses/LICENSE-tuicr.txt](licenses/LICENSE-tuicr.txt)).
- Community skills (`ui-ux-pro-max`, `design-taste-frontend`, `herdr`, `find-skills`, `figures4papers`) remain copyright of their respective authors under permissive open-source licenses.

---

## 📄 License

Original additions and repository structure are licensed under the **MIT License** © 2026 K0maru. See [LICENSE](LICENSE) for details.
