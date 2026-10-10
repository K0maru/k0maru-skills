#!/usr/bin/env bash
set -e -u -o pipefail

# ==============================================================================
# k0maru-skills Dependency Health Check (Doctor)
# Diagnoses external CLI tools and runtimes required or recommended by skills.
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

MISSING_DEPS=()
MISSING_COMMANDS=()

check_cli() {
  local name="$1"
  local cmd="$2"
  local skill="$3"
  local type="$4" # "Recommended", "Optional", "Required"
  local install_hint="$5"
  local version_cmd="${6:-}"

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
    MISSING_DEPS+=("$name|$skill|$type|$install_hint")
    MISSING_COMMANDS+=("$install_hint")
  fi
}

echo -e "\n${BLUE}${BOLD}==========================================================${NC}"
echo -e "${BLUE}${BOLD}       🔍 k0maru-skills Dependency Health Check           ${NC}"
echo -e "${BLUE}${BOLD}==========================================================${NC}"

# 1. Code Review & Terminal Inspection
echo -e "\n${BOLD}📦 Code Review & Terminal Walkthrough${NC} ${DIM}(core/code-review, external/tuicr)${NC}"
check_cli "Open Code Review (ocr)" "ocr" "core/code-review" "Recommended" \
  "npm install -g @alibaba-group/open-code-review" \
  "ocr --version | head -n1"

check_cli "tuicr" "tuicr" "core/code-review, external/tuicr" "Recommended" \
  "brew install tuicr   # or: cargo install tuicr" \
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
  MISSING_DEPS+=("Terminal Multiplexer|external/tuicr, external/herdr|Recommended|brew install tmux  # or: brew install zellij")
  MISSING_COMMANDS+=("brew install tmux")
fi

# 3. Scientific Visualization
echo -e "\n${BOLD}📊 Scientific Figure Making${NC} ${DIM}(external/scientific-figure-making, figures4papers)${NC}"
check_cli "Python 3" "python3" "scientific-figure-making" "Required" \
  "brew install python3" \
  "python3 --version"

printf "  %-24s " "matplotlib & numpy"
if python3 -c "import matplotlib, numpy" >/dev/null 2>&1; then
  py_pkg_ver="$(python3 -c "import matplotlib; print('v' + matplotlib.__version__)" 2>/dev/null || true)"
  echo -e "${GREEN}✓ Installed${NC} ${DIM}($py_pkg_ver)${NC}"
else
  echo -e "${DIM}✗ Missing (Optional)${NC}"
  printf "    ${DIM}↳ Used by: external/scientific-figure-making${NC}\n"
  MISSING_DEPS+=("Python Viz Packages|external/scientific-figure-making|Optional|uv pip install matplotlib numpy  # or: pip3 install matplotlib numpy")
  MISSING_COMMANDS+=("pip3 install matplotlib numpy")
fi

# 4. Base Tooling
echo -e "\n${BOLD}🛠️ Base Development Tools${NC}"
check_cli "Git" "git" "All skills" "Required" \
  "brew install git" \
  "git --version"

check_cli "Node.js / npm" "node" "ocr, setup-pre-commit" "Recommended" \
  "brew install node" \
  "node --version"

echo -e "\n----------------------------------------------------------"

# Summary & actionable instructions
if [[ ${#MISSING_DEPS[@]} -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}✨ All external dependencies are installed and ready to go!${NC}\n"
else
  echo -e "${YELLOW}${BOLD}💡 Missing Optional / Recommended Tools:${NC}"
  echo -e "Some skills offer enhanced capabilities when their external companion CLIs are installed.\n"
  
  echo -e "${BOLD}To install missing dependencies, run:${NC}"
  # Print unique deduplicated commands
  printf '%s\n' "${MISSING_COMMANDS[@]}" | awk '!seen[$0]++' | while read -r cmd; do
    echo -e "  ${CYAN}$cmd${NC}"
  done
  echo ""
fi
