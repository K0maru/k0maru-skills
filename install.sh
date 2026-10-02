#!/usr/bin/env bash
set -e -u -o pipefail

# ==============================================================================
# k0maru-skills One-Click Installer
# Installs & synchronizes personal skills across:
#   - Universal Agent Skills (~/.agents/skills)
#   - Antigravity / Gemini CLI (~/.gemini/config/skills)
#   - Claude Code (~/.claude/skills)
# ==============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}"
echo "=========================================================="
echo "          ⚡ k0maru-skills One-Click Installer            "
echo "=========================================================="
echo -e "${NC}"

# Detect repository directory
if [[ -f "./scripts/sync.sh" ]]; then
  REPO_ROOT="$(pwd)"
elif [[ -d "$HOME/workspace/k0maru-skills" ]]; then
  REPO_ROOT="$HOME/workspace/k0maru-skills"
else
  # Running from curl/remote - clone repository to ~/workspace/k0maru-skills
  TARGET_CLONE_DIR="$HOME/workspace/k0maru-skills"
  echo -e "${YELLOW}Cloning k0maru-skills into $TARGET_CLONE_DIR...${NC}"
  mkdir -p "$HOME/workspace"
  git clone "git@github.com:k0maru3/k0maru-skills.git" "$TARGET_CLONE_DIR" || \
  git clone "https://github.com/k0maru3/k0maru-skills.git" "$TARGET_CLONE_DIR"
  REPO_ROOT="$TARGET_CLONE_DIR"
fi

echo -e "📂 Repository Path: ${BOLD}$REPO_ROOT${NC}"

# 1. Make all scripts executable
echo -e "\n${BLUE}▶ Setting executable permissions...${NC}"
chmod +x "$REPO_ROOT/scripts/"*.sh 2>/dev/null || true
chmod +x "$REPO_ROOT/bin/"* 2>/dev/null || true
chmod +x "$REPO_ROOT/install.sh" 2>/dev/null || true
if [[ -d "$REPO_ROOT/external/tuicr" ]]; then
  chmod +x "$REPO_ROOT/external/tuicr/"*.sh 2>/dev/null || true
fi
echo -e "${GREEN}✓ Permissions configured.${NC}"

# 2. Run sync script to link all skills
echo -e "\n${BLUE}▶ Linking all skills to agent environments...${NC}"
"$REPO_ROOT/scripts/sync.sh"

# 3. Install k0maru-skills CLI helper into ~/.local/bin
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
ln -sfn "$REPO_ROOT/bin/k0maru-skills" "$LOCAL_BIN/k0maru-skills"
echo -e "\n${GREEN}✓ Installed CLI shortcut: ${BOLD}$LOCAL_BIN/k0maru-skills${NC}"

echo -e "\n${GREEN}${BOLD}🎉 Installation and Synchronization Complete!${NC}"
echo -e "You can now manage your skills from anywhere in your terminal:"
echo -e "  ${BOLD}k0maru-skills list${NC}   - View all registered skills"
echo -e "  ${BOLD}k0maru-skills sync${NC}   - Re-sync all symlinks"
echo -e "  ${BOLD}k0maru-skills path${NC}   - Print repo location\n"
