# Tmux Configuration Setup — Which-Key, Telescope-like Switcher, Project Sessions

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Set up a tmux configuration with Ctrl-Space prefix, which-key discovery popup, and telescope-like fuzzy session/window/project switchers.

**Architecture:** Fresh tmux config at `~/.config/tmux/tmux.conf` using TPM for plugin management. `tmux-which-key` provides keybinding discovery. `sesh` (Go binary) + `fzf` provide telescope-like session/project switching via `display-popup`. Custom fzf script handles window switching. `zoxide` (already installed) powers project directory frecency.

**Tech Stack:** tmux 3.5, TPM, tmux-which-key, sesh, fzf, zoxide, bat (for previews)

**System prerequisites:** macOS, Homebrew, Fish shell. User already has: fzf 0.60.3, zoxide 0.9.7. Need to install: bat, sesh, TPM.

**macOS note:** User must disable Ctrl-Space for input source switching in System Settings > Keyboard > Keyboard Shortcuts > Input Sources.

---

## Chunk 1: Foundation — Prefix, TPM, Base Config

### Task 1: Install dependencies

**Files:** None (system packages)

- [ ] **Step 1: Install bat and sesh via Homebrew**

```bash
brew install bat sesh
```

- [ ] **Step 2: Verify installations**

```bash
bat --version   # Expected: bat 0.24+ or similar
sesh --version  # Expected: sesh 2.x+
```

- [ ] **Step 3: Install TPM**

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

---

### Task 2: Create base tmux.conf with Ctrl-Space prefix

**Files:**
- Create: `~/.config/tmux/tmux.conf`

- [ ] **Step 1: Write the base config**

```tmux
# =============================================================================
# Tmux Configuration
# =============================================================================

# --- Prefix ---
unbind C-b
set -g prefix C-Space
bind C-Space send-prefix

# --- General ---
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g escape-time 10
set -g history-limit 50000
set -g display-time 4000
set -g status-interval 5
set -g focus-events on
setw -g aggressive-resize on
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm-256color:RGB"

# --- Keybindings ---
# Reload config
bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

# Split panes (keep cwd)
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# New window (keep cwd)
bind c new-window -c "#{pane_current_path}"

# Pane navigation (vim-style)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Pane resizing
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# --- Plugins ---
set -g @plugin 'tmux-plugins/tpm'

# Initialize TPM (keep at bottom)
run '~/.tmux/plugins/tpm/tpm'
```

- [ ] **Step 2: Start tmux and verify prefix works**

```bash
tmux new -s test
# Press Ctrl-Space, then r — should display "Config reloaded"
# Press Ctrl-Space, then c — should create new window
# Press Ctrl-Space, then | — should split vertically
```

- [ ] **Step 3: Install TPM plugins**

Inside tmux, press `prefix + I` (Ctrl-Space, then Shift-I) to install plugins.

- [ ] **Step 4: Commit**

```bash
cd ~/.config/tmux
git add tmux.conf
git commit -m "feat: base tmux config with Ctrl-Space prefix and TPM"
```

---

## Chunk 2: Which-Key Popup

### Task 3: Install and configure tmux-which-key

**Files:**
- Modify: `~/.config/tmux/tmux.conf` (add plugin)
- Create: `~/.config/tmux/plugins/tmux-which-key/config.yaml` (after TPM installs it, we customize)

- [ ] **Step 1: Add tmux-which-key plugin to tmux.conf**

Add before the `run '~/.tmux/plugins/tpm/tpm'` line:

```tmux
# Which-key popup (shows available keys after prefix)
set -g @plugin 'alexwforsythe/tmux-which-key'
```

- [ ] **Step 2: Install the plugin**

Inside tmux, press `prefix + I` to install.

- [ ] **Step 3: Verify which-key works**

Press `prefix + Space` — a popup menu should appear showing available keybindings.

- [ ] **Step 4: Customize which-key config**

After installation, tmux-which-key generates its config at `~/.tmux/plugins/tmux-which-key/config.yaml`. Edit it to add our custom bindings and organize categories. Key customizations:

```yaml
# In the config.yaml, ensure these sections exist:
keybindings:
  prefix_table: Space
title:
  style: align=centre,bold
  prefix: tmux
  prefix_style: fg=green,bold
position:
  x: C
  y: C

# Add custom items for our session/window/project switchers (Task 5-7 will define the commands)
```

The exact config depends on what tmux-which-key generates by default — review the generated file and adjust. The plugin auto-discovers your existing bindings, so most of the which-key menu populates automatically.

- [ ] **Step 5: Commit**

```bash
cd ~/.config/tmux
git add tmux.conf
git commit -m "feat: add tmux-which-key for keybinding discovery popup"
```

---

## Chunk 3: Telescope-like Switchers — Sessions, Windows, Projects

### Task 4: Configure sesh for session management

**Files:**
- Create: `~/.config/sesh/sesh.toml`

- [ ] **Step 1: Create sesh config**

```toml
[default_session]
preview_command = "eza --all --git --icons --color=always {} 2>/dev/null || ls -la {}"
startup_command = ""

# Add project directories you frequently use as named sessions:
# [[session]]
# name = "dotfiles"
# path = "~/.config"
#
# [[session]]
# name = "myproject"
# path = "~/projects/myproject"
```

- [ ] **Step 2: Verify sesh lists sessions**

```bash
# In a tmux session:
sesh list
# Should show at least the current tmux session
```

- [ ] **Step 3: Commit**

```bash
cd ~/.config/tmux
git add -f docs/  # plans only for now
git commit -m "docs: add sesh config instructions"
```

---

### Task 5: Create session switcher script (telescope-like)

**Files:**
- Create: `~/.config/tmux/scripts/session-switcher.sh`
- Modify: `~/.config/tmux/tmux.conf`

- [ ] **Step 1: Create the scripts directory**

```bash
mkdir -p ~/.config/tmux/scripts
```

- [ ] **Step 2: Write the session switcher script**

```bash
#!/usr/bin/env bash
# Telescope-like session switcher using sesh + fzf
# Shows active sessions, configured sessions, and zoxide directories

sesh connect "$(
  sesh list --icons | fzf-tmux -p 80%,70% \
    --no-sort --ansi \
    --border-label ' Sessions ' \
    --prompt '  ' \
    --header '  ctrl-a: all | ctrl-t: tmux | ctrl-x: config | ctrl-d: zoxide | ctrl-f: find' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-a:change-prompt(  )+reload(sesh list --icons)' \
    --bind 'ctrl-t:change-prompt(  )+reload(sesh list --icons -t)' \
    --bind 'ctrl-x:change-prompt(  )+reload(sesh list --icons -c)' \
    --bind 'ctrl-d:change-prompt(  )+reload(sesh list --icons -z)' \
    --bind 'ctrl-f:change-prompt(  )+reload(fd -H -d 2 -t d . ~)' \
    --preview-window 'right:55%' \
    --preview 'sesh preview {}'
)"
```

- [ ] **Step 3: Make it executable**

```bash
chmod +x ~/.config/tmux/scripts/session-switcher.sh
```

- [ ] **Step 4: Add keybinding to tmux.conf**

Add to the Keybindings section in tmux.conf:

```tmux
# Session switcher (telescope-like)
bind s display-popup -E -w 80% -h 70% "~/.config/tmux/scripts/session-switcher.sh"
```

- [ ] **Step 5: Reload and test**

```bash
tmux source-file ~/.config/tmux/tmux.conf
# Press prefix + s — should show fzf popup with sessions
# Type to fuzzy search, Enter to connect
# Ctrl-d to switch to zoxide directories view
```

- [ ] **Step 6: Commit**

```bash
cd ~/.config/tmux
git add scripts/session-switcher.sh tmux.conf
git commit -m "feat: telescope-like session switcher with sesh + fzf"
```

---

### Task 6: Create window switcher script

**Files:**
- Create: `~/.config/tmux/scripts/window-switcher.sh`
- Modify: `~/.config/tmux/tmux.conf`

- [ ] **Step 1: Write the window switcher script**

```bash
#!/usr/bin/env bash
# Telescope-like window switcher using fzf
# Shows all windows across all sessions with preview

target=$(tmux list-windows -a -F "#{session_name}:#{window_index} │ #{window_name} │ #{pane_current_command} │ #{pane_current_path}" | \
  fzf-tmux -p 80%,70% \
    --no-sort \
    --border-label ' Windows ' \
    --prompt '  ' \
    --header '  All windows across sessions' \
    --with-nth=1.. \
    --preview 'tmux capture-pane -ep -t "$(echo {} | cut -d" " -f1)"' \
    --preview-window 'right:55%' | \
  cut -d' ' -f1)

[ -n "$target" ] && tmux switch-client -t "$target"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x ~/.config/tmux/scripts/window-switcher.sh
```

- [ ] **Step 3: Add keybinding to tmux.conf**

```tmux
# Window switcher (telescope-like)
bind w display-popup -E -w 80% -h 70% "~/.config/tmux/scripts/window-switcher.sh"
```

- [ ] **Step 4: Reload and test**

```bash
tmux source-file ~/.config/tmux/tmux.conf
# Create a few windows and sessions first:
# prefix + c (new window), prefix + c (another)
# Then prefix + w — should show fzf popup with all windows
# Preview pane should show the content of each window
```

- [ ] **Step 5: Commit**

```bash
cd ~/.config/tmux
git add scripts/window-switcher.sh tmux.conf
git commit -m "feat: telescope-like window switcher with fzf and preview"
```

---

### Task 7: Create project directory switcher

**Files:**
- Create: `~/.config/tmux/scripts/project-switcher.sh`
- Modify: `~/.config/tmux/tmux.conf`

- [ ] **Step 1: Write the project switcher script**

This is specifically for switching by project directory, leveraging zoxide's frecency data. When selected, it creates/connects to a tmux session named after the project directory, with the working directory set to the project root.

```bash
#!/usr/bin/env bash
# Project directory switcher using zoxide + fzf
# Opens/switches to a tmux session rooted at the selected project directory

selected=$(zoxide query -l | fzf-tmux -p 80%,70% \
  --no-sort \
  --border-label ' Projects ' \
  --prompt '  ' \
  --header '  Jump to project (sorted by frecency)' \
  --preview 'eza --all --git --icons --color=always {} 2>/dev/null || ls -la {}' \
  --preview-window 'right:55%')

[ -z "$selected" ] && exit 0

# Use directory basename as session name (replace dots with underscores for tmux compatibility)
session_name=$(basename "$selected" | tr '.' '_')

# Connect via sesh (creates session if it doesn't exist, switches if it does)
sesh connect "$selected"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x ~/.config/tmux/scripts/project-switcher.sh
```

- [ ] **Step 3: Add keybinding to tmux.conf**

```tmux
# Project switcher (zoxide-powered)
bind p display-popup -E -w 80% -h 70% "~/.config/tmux/scripts/project-switcher.sh"
```

- [ ] **Step 4: Reload and test**

```bash
tmux source-file ~/.config/tmux/tmux.conf
# Press prefix + p — should show fzf popup with project directories from zoxide
# Select one — should create/switch to a session named after the directory
# The session's working directory should be the selected project root
```

- [ ] **Step 5: Commit**

```bash
cd ~/.config/tmux
git add scripts/project-switcher.sh tmux.conf
git commit -m "feat: project directory switcher with zoxide + fzf"
```

---

## Chunk 4: Integration — Wire Switchers into Which-Key

### Task 8: Add switcher entries to tmux-which-key config

**Files:**
- Modify: `~/.tmux/plugins/tmux-which-key/config.yaml`

- [ ] **Step 1: Review the generated which-key config**

```bash
cat ~/.tmux/plugins/tmux-which-key/config.yaml
```

Understand the structure before modifying.

- [ ] **Step 2: Add custom menu entries for our switchers**

In the `items` section of `config.yaml`, add/modify entries so the which-key popup shows our telescope-like switchers. Add a "Find" submenu:

```yaml
  # Add these items (adjust position in the list as appropriate):
  - name: Sessions
    key: s
    command: display-popup -E -w 80% -h 70% "~/.config/tmux/scripts/session-switcher.sh"
  - name: Windows
    key: w
    command: display-popup -E -w 80% -h 70% "~/.config/tmux/scripts/window-switcher.sh"
  - name: Projects
    key: p
    command: display-popup -E -w 80% -h 70% "~/.config/tmux/scripts/project-switcher.sh"
```

Alternatively, group them under a submenu:

```yaml
  - name: +find
    key: f
    menu:
      - name: Sessions
        key: s
        command: display-popup -E -w 80% -h 70% "~/.config/tmux/scripts/session-switcher.sh"
      - name: Windows
        key: w
        command: display-popup -E -w 80% -h 70% "~/.config/tmux/scripts/window-switcher.sh"
      - name: Projects
        key: p
        command: display-popup -E -w 80% -h 70% "~/.config/tmux/scripts/project-switcher.sh"
```

- [ ] **Step 3: Regenerate which-key bindings**

```bash
# tmux-which-key needs to regenerate after config changes:
~/.tmux/plugins/tmux-which-key/plugin.sh
```

- [ ] **Step 4: Test the full flow**

```bash
# In tmux:
# 1. Press prefix + Space → which-key popup appears
# 2. See our custom entries (s/w/p or f submenu)
# 3. Press the key → appropriate fzf switcher opens
# 4. Select item → switches to target
```

- [ ] **Step 5: Commit**

```bash
cd ~/.config/tmux
git add tmux.conf
git commit -m "feat: integrate switchers into which-key menu"
```

---

## Summary of Keybindings

| Binding | Action |
|---------|--------|
| `Ctrl-Space` | Prefix key |
| `prefix + Space` | Which-key popup (shows all available keys) |
| `prefix + s` | Session switcher (sesh + fzf) |
| `prefix + w` | Window switcher (fzf with preview) |
| `prefix + p` | Project switcher (zoxide + fzf) |
| `prefix + r` | Reload config |
| `prefix + c` | New window (inherits cwd) |
| `prefix + \|` | Split horizontal (inherits cwd) |
| `prefix + -` | Split vertical (inherits cwd) |
| `prefix + h/j/k/l` | Navigate panes (vim-style) |
| `prefix + H/J/K/L` | Resize panes |

## Dependencies to Install

```bash
brew install bat sesh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

## macOS Prerequisite

Disable Ctrl-Space for input source switching:
System Settings > Keyboard > Keyboard Shortcuts > Input Sources > uncheck "Select the previous input source"
