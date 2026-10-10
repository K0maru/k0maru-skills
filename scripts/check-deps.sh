#!/usr/bin/env bash
set -e -u -o pipefail

# ==============================================================================
# k0maru-skills Dependency Health Check & Interactive TUI Installer
# Diagnoses and optionally installs companion CLI tools required by skills.
# ==============================================================================

# Formatting and Colors
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  DIM='\033[2m'
  NC='\033[0m'
else
  GREEN=''
  BLUE=''
  YELLOW=''
  RED=''
  CYAN=''
  BOLD=''
  DIM=''
  NC=''
fi

PROMPT_INSTALL=false
FORCE_INSTALL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt-install)
      PROMPT_INSTALL=true
      shift
      ;;
    -i|--install)
      FORCE_INSTALL=true
      shift
      ;;
    -h|--help)
      echo "Usage: $(basename "$0") [options]"
      echo ""
      echo "Options:"
      echo "  --prompt-install  Ask to install missing packages interactively if in a terminal"
      echo "  -i, --install     Launch interactive TUI installer directly for missing packages"
      echo "  -h, --help        Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Arrays to track missing tools for TUI selector
TUI_IDS=()
TUI_NAMES=()
TUI_SKILLS=()
TUI_DESCS=()
TUI_CMDS=()
TUI_SELECTED=()

check_cli() {
  local id="$1"
  local name="$2"
  local cmd="$3"
  local skill="$4"
  local desc="$5"
  local type="$6" # "Recommended", "Optional", "Required"
  local install_cmd="$7"
  local version_cmd="${8:-}"

  printf "  %-24s " "$name"

  if command -v "$cmd" >/dev/null 2>&1; then
    local version=""
    if [[ -n "$version_cmd" ]]; then
      version="$(eval "$version_cmd" 2>/dev/null | head -n1 | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || true)"
    fi
    if [[ -n "$version" ]]; then
      echo -e "${GREEN}✓ Installed${NC} ${DIM}($version)${NC}"
    else
      echo -e "${GREEN}✓ Installed${NC}"
    fi
  else
    if [[ "$type" == "Required" ]]; then
      echo -e "${RED}✗ Missing (Required)${NC}"
    elif [[ "$type" == "Recommended" ]]; then
      echo -e "${YELLOW}✗ Missing (Recommended)${NC}"
    else
      echo -e "${DIM}✗ Missing (Optional)${NC}"
    fi
    printf "    ${DIM}↳ Used by: %s${NC}\n" "$skill"

    TUI_IDS+=("$id")
    TUI_NAMES+=("$name")
    TUI_SKILLS+=("$skill")
    TUI_DESCS+=("$desc")
    TUI_CMDS+=("$install_cmd")
    if [[ "$type" == "Optional" ]]; then
      TUI_SELECTED+=(0)
    else
      TUI_SELECTED+=(1)
    fi
  fi
}

echo -e "\n${BLUE}${BOLD}==========================================================${NC}"
echo -e "${BLUE}${BOLD}       🔍 k0maru-skills Dependency Health Check           ${NC}"
echo -e "${BLUE}${BOLD}==========================================================${NC}"

# 1. Code Review & Terminal Walkthrough
echo -e "\n${BOLD}📦 Code Review & Terminal Walkthrough${NC} ${DIM}(core/code-review, external/tuicr)${NC}"
check_cli "ocr" "Open Code Review (ocr)" "ocr" \
  "core/code-review" \
  "AST file bundling & language rule delegation" \
  "Recommended" \
  "npm install -g @alibaba-group/open-code-review" \
  "ocr --version | head -n1"

TUICR_INSTALL_CMD="brew install tuicr"
if ! command -v brew >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1; then
  TUICR_INSTALL_CMD="cargo install tuicr"
fi

check_cli "tuicr" "tuicr" "tuicr" \
  "core/code-review, external/tuicr" \
  "Terminal interactive diff walkthrough" \
  "Recommended" \
  "$TUICR_INSTALL_CMD" \
  "tuicr --version"

# 2. Terminal Multiplexers
echo -e "\n${BOLD}🖥️ Terminal Multiplexers (Side-by-side panes)${NC} ${DIM}(tuicr walkthrough & herdr)${NC}"
has_mux=false
mux_detected=()

if command -v herdr >/dev/null 2>&1; then
  has_mux=true
  mux_detected+=("herdr")
fi
if command -v tmux >/dev/null 2>&1; then
  has_mux=true
  mux_detected+=("tmux")
fi
if command -v zellij >/dev/null 2>&1; then
  has_mux=true
  mux_detected+=("zellij")
fi

printf "  %-24s " "Multiplexer (tmux/zellij/herdr)"
if [[ "$has_mux" == true ]]; then
  echo -e "${GREEN}✓ Installed${NC} ${DIM}(Found: ${mux_detected[*]})${NC}"
else
  echo -e "${YELLOW}✗ None detected (Recommended for split-pane review)${NC}"
  printf "    ${DIM}↳ Used by: tuicr interactive review pane${NC}\n"
  TUI_IDS+=("tmux")
  TUI_NAMES+=("tmux (Multiplexer)")
  TUI_SKILLS+=("external/tuicr, external/herdr")
  TUI_DESCS+=("Side-by-side terminal review pane")
  TUI_CMDS+=("brew install tmux")
  TUI_SELECTED+=(0)
fi

# 3. Scientific Visualization
echo -e "\n${BOLD}📊 Scientific Figure Making${NC} ${DIM}(external/scientific-figure-making, figures4papers)${NC}"
check_cli "python3" "Python 3" "python3" \
  "scientific-figure-making" \
  "Runtime for scientific figure generation" \
  "Required" \
  "brew install python3" \
  "python3 --version"

PY_VIZ_INSTALL="pip3 install matplotlib numpy"
if command -v uv >/dev/null 2>&1; then
  PY_VIZ_INSTALL="uv pip install --system matplotlib numpy 2>/dev/null || pip3 install matplotlib numpy"
fi

printf "  %-24s " "matplotlib & numpy"
if python3 -c "import matplotlib, numpy" >/dev/null 2>&1; then
  py_pkg_ver="$(python3 -c "import matplotlib; print('v' + matplotlib.__version__)" 2>/dev/null || true)"
  echo -e "${GREEN}✓ Installed${NC} ${DIM}($py_pkg_ver)${NC}"
else
  echo -e "${DIM}✗ Missing (Optional)${NC}"
  printf "    ${DIM}↳ Used by: external/scientific-figure-making${NC}\n"
  TUI_IDS+=("py_viz")
  TUI_NAMES+=("matplotlib & numpy")
  TUI_SKILLS+=("external/scientific-figure-making")
  TUI_DESCS+=("Academic & publication figure making")
  TUI_CMDS+=("$PY_VIZ_INSTALL")
  TUI_SELECTED+=(0)
fi

# 4. Base Tooling
echo -e "\n${BOLD}🛠️ Base Development Tools${NC}"
check_cli "git" "Git" "git" \
  "All skills" \
  "Version control & worktree management" \
  "Required" \
  "brew install git" \
  "git --version"

check_cli "node" "Node.js / npm" "node" \
  "ocr, setup-pre-commit" \
  "Node runtime for JavaScript/CLI tools" \
  "Recommended" \
  "brew install node" \
  "node --version"

echo -e "\n----------------------------------------------------------"

# Summary evaluation
num_missing=${#TUI_IDS[@]}
if [[ $num_missing -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}✨ All external companion tools are installed and ready to go!${NC}\n"
  exit 0
fi

echo -e "${YELLOW}${BOLD}💡 Missing Optional / Recommended Tools:${NC}"
echo -e "Some skills offer enhanced capabilities when companion CLIs are installed.\n"

# Check if we should launch interactive TUI installer
SHOULD_INTERACTIVE=false
if [[ "$FORCE_INSTALL" == true ]]; then
  SHOULD_INTERACTIVE=true
elif [[ "$PROMPT_INSTALL" == true && -t 0 && -t 1 ]]; then
  echo -ne "${BOLD}Would you like to select and install missing companion tools now? [Y/n]: ${NC}"
  read -r reply || reply="n"
  if [[ -z "$reply" || "$reply" =~ ^[Yy]$ ]]; then
    SHOULD_INTERACTIVE=true
  fi
fi

if [[ "$SHOULD_INTERACTIVE" == false || ! -t 0 || ! -t 1 ]]; then
  echo -e "${BOLD}To install missing dependencies manually, run:${NC}"
  for i in "${!TUI_CMDS[@]}"; do
    echo -e "  ${CYAN}${TUI_CMDS[$i]}${NC}  ${DIM}# ${TUI_NAMES[$i]} (${TUI_SKILLS[$i]})${NC}"
  done
  echo -e "\n${DIM}Tip: Run 'k0maru-skills doctor -i' anytime for interactive package installer.${NC}\n"
  exit 0
fi

# ==============================================================================
# Interactive TUI Multi-Select Menu (RTK-style)
# ==============================================================================

# Setup terminal for raw input
cleanup_tui() {
  tput cnorm 2>/dev/null || true
  stty sane 2>/dev/null || true
}
trap cleanup_tui EXIT INT TERM

tput civis 2>/dev/null || true

cursor=0
first_draw=true
lines_per_item=2
total_draw_lines=$(( num_missing * lines_per_item + 5 ))

while true; do
  if [[ "$first_draw" == false ]]; then
    printf "\033[%dA" "$total_draw_lines"
  fi
  first_draw=false

  # Box Header
  printf "\033[2K\r%b\n" "${BLUE}${BOLD}┌────────────────────────────────────────────────────────────────────────┐${NC}"
  printf "\033[2K\r%b\n" "${BLUE}${BOLD}│ 📦 Select Companion Tools to Install (RTK-style Interactive TUI)       │${NC}"
  printf "\033[2K\r%b\n" "${BLUE}${BOLD}└────────────────────────────────────────────────────────────────────────┘${NC}"

  for i in "${!TUI_IDS[@]}"; do
    prefix="   "
    check="[ ]"
    if [[ $i -eq $cursor ]]; then
      prefix="${CYAN}${BOLD} ❯ ${NC}"
    fi
    if [[ ${TUI_SELECTED[$i]} -eq 1 ]]; then
      check="${GREEN}${BOLD}[✔]${NC}"
    else
      check="${DIM}[ ]${NC}"
    fi

    # Row 1: Checkbox + Name + Target Skill
    printf "\033[2K\r%b%b %-26s ${DIM}(%s)${NC}\n" "$prefix" "$check" "${TUI_NAMES[$i]}" "${TUI_SKILLS[$i]}"
    # Row 2: Install Command Preview
    printf "\033[2K\r       ${DIM}$ %s${NC}\n" "${TUI_CMDS[$i]}"
  done

  # Count selected
  sel_count=0
  for s in "${TUI_SELECTED[@]}"; do
    [[ $s -eq 1 ]] && sel_count=$((sel_count + 1))
  done

  printf "\033[2K\r%b\n" "${DIM}──────────────────────────────────────────────────────────────────────────${NC}"
  printf "\033[2K\r${CYAN}[↑/↓/j/k]${NC} Move  ${CYAN}[Space]${NC} Toggle  ${CYAN}[a]${NC} All  ${GREEN}${BOLD}[Enter]${NC} Install (%d)  ${DIM}[q/Esc]${NC} Skip: " "$sel_count"

  # Read key
  key=""
  IFS= read -rsn1 key || true

  if [[ "$key" == $'\x1b' ]]; then
    rest=""
    read -rsn2 -t 0.1 rest || true
    case "$rest" in
      "[A") # Arrow Up
        cursor=$(( (cursor - 1 + num_missing) % num_missing ))
        ;;
      "[B") # Arrow Down
        cursor=$(( (cursor + 1) % num_missing ))
        ;;
      "") # Escape key
        TUI_SELECTED=()
        break
        ;;
    esac
  elif [[ "$key" == "k" || "$key" == "K" ]]; then
    cursor=$(( (cursor - 1 + num_missing) % num_missing ))
  elif [[ "$key" == "j" || "$key" == "J" ]]; then
    cursor=$(( (cursor + 1) % num_missing ))
  elif [[ "$key" == " " ]]; then
    if [[ ${TUI_SELECTED[$cursor]} -eq 1 ]]; then
      TUI_SELECTED[$cursor]=0
    else
      TUI_SELECTED[$cursor]=1
    fi
  elif [[ "$key" == "a" || "$key" == "A" ]]; then
    all_active=1
    for s in "${TUI_SELECTED[@]}"; do
      [[ $s -eq 0 ]] && all_active=0 && break
    done
    for idx in "${!TUI_SELECTED[@]}"; do
      if [[ $all_active -eq 1 ]]; then
        TUI_SELECTED[$idx]=0
      else
        TUI_SELECTED[$idx]=1
      fi
    done
  elif [[ "$key" == "" ]]; then
    # Enter key -> confirm selection
    break
  elif [[ "$key" == "q" || "$key" == "Q" ]]; then
    TUI_SELECTED=()
    break
  fi
done

cleanup_tui
trap - EXIT INT TERM
echo ""

# Execute chosen installations
chosen_indices=()
for i in "${!TUI_SELECTED[@]}"; do
  if [[ ${TUI_SELECTED[$i]} -eq 1 ]]; then
    chosen_indices+=("$i")
  fi
done

if [[ ${#chosen_indices[@]} -eq 0 ]]; then
  echo -e "${YELLOW}Installation skipped. No packages selected.${NC}\n"
  exit 0
fi

echo -e "${BLUE}${BOLD}🚀 Installing ${#chosen_indices[@]} selected package(s)...${NC}\n"

for idx in "${chosen_indices[@]}"; do
  name="${TUI_NAMES[$idx]}"
  cmd="${TUI_CMDS[$idx]}"

  echo -e "${CYAN}▶ Installing $name...${NC}"
  echo -e "  ${DIM}$ $cmd${NC}"

  if eval "$cmd"; then
    echo -e "${GREEN}✓ Successfully installed $name${NC}\n"
  else
    echo -e "${RED}✗ Failed to install $name. Please check error output above.${NC}\n"
  fi
done

echo -e "${GREEN}${BOLD}🎉 Package setup complete! Running quick verification...${NC}\n"
# Quick final check
for idx in "${chosen_indices[@]}"; do
  id="${TUI_IDS[$idx]}"
  name="${TUI_NAMES[$idx]}"
  case "$id" in
    ocr)
      command -v ocr >/dev/null 2>&1 && echo -e "  ${GREEN}✓ ocr:${NC} $(ocr --version | head -n1)" || echo -e "  ${RED}✗ ocr still not found${NC}"
      ;;
    tuicr)
      command -v tuicr >/dev/null 2>&1 && echo -e "  ${GREEN}✓ tuicr:${NC} $(tuicr --version)" || echo -e "  ${RED}✗ tuicr still not found${NC}"
      ;;
    tmux)
      command -v tmux >/dev/null 2>&1 && echo -e "  ${GREEN}✓ tmux:${NC} $(tmux -V)" || echo -e "  ${RED}✗ tmux still not found${NC}"
      ;;
    py_viz)
      python3 -c "import matplotlib, numpy" >/dev/null 2>&1 && echo -e "  ${GREEN}✓ matplotlib & numpy ready${NC}" || echo -e "  ${YELLOW}⚠ matplotlib/numpy not in current python3${NC}"
      ;;
  esac
done
echo ""
