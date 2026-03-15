# Tmux Configuration

Custom tmux setup with which-key discovery, telescope-like fuzzy switchers, and project-based session management.

## Features

### Ctrl-Space Prefix

The prefix key is remapped from `Ctrl-b` to `Ctrl-Space`.

### Which-Key Popup

Press `prefix + Space` to open a which-key style popup showing all available keybindings, organized by category. Powered by [tmux-which-key](https://github.com/alexwforsythe/tmux-which-key).

### Active Session Switcher (`prefix + s`)

Shows only active tmux sessions with a live pane preview. Quick way to jump between running sessions.

### Full Session Switcher (`prefix + S`)

A telescope-like fuzzy finder across all session sources. Uses [sesh](https://github.com/joshmedeski/sesh) + [fzf](https://github.com/junegunn/fzf) in a floating popup with preview.

**Controls inside the popup:**
- Type to fuzzy search
- `Enter` to connect to selected session
- `Ctrl-a` — show all (sessions + zoxide + config)
- `Ctrl-t` — show only active tmux sessions
- `Ctrl-x` — show configured sessions (from `~/.config/sesh/sesh.toml`)
- `Ctrl-d` — show zoxide directories
- `Ctrl-f` — browse filesystem (`fd` search from `~`)

### Window Switcher (`prefix + w`)

Lists all windows across all sessions with a live preview of the pane content. Shows session name, window index, window name, current command, and working directory.

### Project Switcher (`prefix + p`)

Fuzzy-finds project directories using [zoxide](https://github.com/ajeetdsouza/zoxide) frecency data. Selecting a directory creates a new tmux session (or switches to an existing one) rooted at that directory. All new panes and windows in the session inherit the project root as their working directory.

### Other Keybindings

| Binding | Action |
|---|---|
| `prefix + r` | Reload tmux config |
| `prefix + c` | New window (inherits cwd) |
| `prefix + \|` | Split pane horizontally (inherits cwd) |
| `prefix + -` | Split pane vertically (inherits cwd) |
| `prefix + h/j/k/l` | Navigate panes (vim-style) |
| `prefix + H/J/K/L` | Resize panes |

## How tmux Finds This Config

Tmux automatically looks for config files in this order:

1. `~/.tmux.conf`
2. `$XDG_CONFIG_HOME/tmux/tmux.conf` (defaults to `~/.config/tmux/tmux.conf`)

This repo lives at `~/.config/tmux/`, so tmux picks it up automatically — no symlinks or sourcing needed. If you have a `~/.tmux.conf` file, it takes priority and this config will be ignored; remove or rename it.

## Prerequisites

The following tools must be installed and available in your `PATH`. Requires [Rust/cargo](https://rustup.rs) and [Go](https://go.dev/dl) toolchains.

| Tool | Purpose | Install |
|---|---|---|
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | `cargo install fzf` |
| [sesh](https://github.com/joshmedeski/sesh) | Session manager | `go install github.com/joshmedeski/sesh@latest` |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Directory frecency tracker | `cargo install zoxide` |
| [fd](https://github.com/sharkdp/fd) | Fast file finder | `cargo install fd-find` |
| [bat](https://github.com/sharkdp/bat) | Syntax-highlighted file viewer | `cargo install bat` |

### macOS: Disable Ctrl-Space Input Source Shortcut

macOS reserves `Ctrl-Space` for switching input sources by default. You must disable it:

1. Open **System Settings**
2. Go to **Keyboard > Keyboard Shortcuts > Input Sources**
3. Uncheck **"Select the previous input source"** (or rebind it)

### zoxide Initialization (Fish Shell)

Add to your `~/.config/fish/config.fish` if not already present:

```fish
zoxide init fish | source
```

This ensures zoxide tracks your directory visits, which powers the project switcher.

## Installation

### Quick Setup

Run the setup script to install all dependencies and configure everything:

```bash
cd ~/.config/tmux
./setup.sh
```

Then start tmux:

```bash
tmux new -s main
```

### Manual Setup

1. **Clone this repo** (with submodules) to `~/.config/tmux/`:

   ```bash
   git clone --recurse-submodules <repo-url> ~/.config/tmux
   ```

2. **Install dependencies** (requires cargo and go):

   ```bash
   cargo install fzf zoxide fd-find bat
   go install github.com/joshmedeski/sesh@latest
   ```

3. **Create sesh config** at `~/.config/sesh/sesh.toml`:

   ```toml
   [default_session]
   startup_command = ""

   # Add named project sessions:
   # [[session]]
   # name = "myproject"
   # path = "~/projects/myproject"
   ```

4. **Start tmux**:

   ```bash
   tmux new -s main
   ```

5. **Reload config** (if tmux was already running):

   Press `Ctrl-Space` then `r` to reload.

## File Structure

```
~/.config/tmux/
├── tmux.conf                      # Main tmux configuration
├── plugins/
│   └── tmux-which-key/            # Which-key plugin (git submodule)
├── scripts/
│   ├── active-session-switcher.sh # Active tmux sessions picker
│   ├── session-switcher.sh        # sesh + fzf all-source session picker
│   ├── window-switcher.sh         # fzf window picker with preview
│   └── project-switcher.sh        # zoxide + fzf project directory picker
├── setup.sh                       # Dependency installer
└── README.md

~/.config/sesh/
└── sesh.toml                      # sesh session configuration
```

## Troubleshooting

- **Ctrl-Space not working:** Check that macOS input source shortcut is disabled (see above).
- **`~/.tmux.conf` exists:** Remove or rename it — it takes priority over `~/.config/tmux/tmux.conf`.
- **Tools not found in popups:** The scripts add `~/go/bin` and `~/.cargo/bin` to PATH. If your tools are installed elsewhere, edit the `export PATH=...` line at the top of each script in `scripts/`.
- **Which-key not showing:** Ensure submodules are initialized: `git submodule update --init --recursive` in `~/.config/tmux/`, then `prefix + r` to reload.
