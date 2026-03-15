# Tmux Configuration

Custom tmux setup with which-key discovery, telescope-like fuzzy switchers, and project-based session management.

## Features

### Ctrl-Space Prefix

The prefix key is remapped from `Ctrl-b` to `Ctrl-Space`.

### Which-Key Popup

Press `prefix + Space` to open a which-key style popup showing all available keybindings, organized by category. Powered by [tmux-which-key](https://github.com/alexwforsythe/tmux-which-key).

### Session Switcher (`prefix + s`)

A telescope-like fuzzy finder for tmux sessions. Uses [sesh](https://github.com/joshmedeski/sesh) + [fzf](https://github.com/junegunn/fzf) in a floating popup with preview.

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

## Prerequisites

The following tools must be installed and available in your `PATH`:

| Tool | Purpose | Install |
|---|---|---|
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder | `cargo install fzf` or `go install github.com/junegunn/fzf@latest` |
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

1. **Clone this repo** (or copy files) to `~/.config/tmux/`:

   ```bash
   git clone <repo-url> ~/.config/tmux
   ```

2. **Install TPM** (Tmux Plugin Manager):

   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
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

4. **Start tmux** and install plugins:

   ```bash
   tmux new -s main
   ```

   Inside tmux, press `Ctrl-Space` then `Shift-I` to install TPM plugins (including tmux-which-key).

5. **Reload config**:

   Press `Ctrl-Space` then `r` to reload.

## File Structure

```
~/.config/tmux/
├── tmux.conf                  # Main tmux configuration
├── scripts/
│   ├── session-switcher.sh    # sesh + fzf session picker
│   ├── window-switcher.sh     # fzf window picker with preview
│   └── project-switcher.sh    # zoxide + fzf project directory picker
└── README.md

~/.config/sesh/
└── sesh.toml                  # sesh session configuration

~/.tmux/plugins/
└── tpm/                       # Tmux Plugin Manager (auto-installed)
    └── ...
```
