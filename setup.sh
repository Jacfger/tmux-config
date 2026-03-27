#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Tmux Config Setup Script
# Installs all dependencies via cargo/go, initializes submodules, and configures sesh.
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[+]${NC} $*"; }
warn()  { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[x]${NC} $*"; exit 1; }

# --- Check base toolchains ---
command -v cargo >/dev/null 2>&1 || error "cargo not found. Install Rust: https://rustup.rs"
command -v go    >/dev/null 2>&1 || error "go not found. Install Go: https://go.dev/dl"
command -v git   >/dev/null 2>&1 || error "git not found."
command -v tmux  >/dev/null 2>&1 || error "tmux not found."

# --- Install cargo packages ---
install_cargo() {
    local crate="$1"
    local bin="${2:-$1}"
    if command -v "$bin" >/dev/null 2>&1; then
        info "$bin already installed ($(command -v "$bin"))"
    else
        info "Installing $crate via cargo..."
        cargo install "$crate" --locked
    fi
}

# install fzf with binary probably
#
install_cargo zoxide zoxide
install_cargo fd-find fd
install_cargo bat bat

# --- Install Go packages ---
install_go() {
    local pkg="$1"
    local bin="$2"
    if command -v "$bin" >/dev/null 2>&1; then
        info "$bin already installed ($(command -v "$bin"))"
    else
        info "Installing $bin via go..."
        go install "$pkg"
    fi
}

install_go github.com/joshmedeski/sesh@latest sesh

# --- Initialize git submodules (plugins) ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
info "Initializing git submodules..."
cd "$SCRIPT_DIR"
git submodule update --init --recursive

# --- Create sesh config if missing ---
SESH_CONFIG="$HOME/.config/sesh/sesh.toml"
if [ -f "$SESH_CONFIG" ]; then
    info "sesh config already exists at $SESH_CONFIG"
else
    info "Creating sesh config at $SESH_CONFIG..."
    mkdir -p "$(dirname "$SESH_CONFIG")"
    cat > "$SESH_CONFIG" <<'TOML'
[default_session]
startup_command = ""

# Add named project sessions:
# [[session]]
# name = "myproject"
# path = "~/projects/myproject"
TOML
fi

# --- Summary ---
echo ""
info "Setup complete!"
echo ""
echo "  Next steps:"
echo "  1. (macOS) Disable Ctrl-Space for input source switching:"
echo "     System Settings > Keyboard > Keyboard Shortcuts > Input Sources"
echo "     Uncheck \"Select the previous input source\""
echo ""
echo "  2. (Fish shell) Add zoxide init to ~/.config/fish/config.fish:"
echo "     zoxide init fish | source"
echo ""
echo "  3. Start tmux:"
echo "     tmux new -s main"
echo ""
echo "  4. Reload config if tmux is already running:"
echo "     Press Ctrl-Space, r"
