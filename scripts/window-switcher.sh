#!/usr/bin/env bash
# Telescope-like window switcher using fzf
# Shows all windows across all sessions with live pane preview

export PATH="$HOME/go/bin:$HOME/.cargo/bin:$PATH"

target=$(tmux list-windows -a \
  -F "#{session_name}:#{window_index} │ #{window_name} │ #{pane_current_command} │ #{pane_current_path}" | \
  fzf \
    --no-sort \
    --border-label ' Windows ' \
    --prompt '  ' \
    --header '  All windows across sessions' \
    --preview 'tmux capture-pane -ep -t "$(echo {} | cut -d" " -f1)"' \
    --preview-window 'right:55%' | \
  awk '{print $1}')

[ -n "$target" ] && tmux switch-client -t "$target"
