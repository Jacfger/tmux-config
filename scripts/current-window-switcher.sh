#!/usr/bin/env bash
# Telescope-like window switcher using fzf
# Shows windows in the current session only with live pane preview

export PATH="$HOME/go/bin:$HOME/.cargo/bin:$PATH"

current_session=$(tmux display-message -p '#S')

target=$(tmux list-windows \
  -F "#{session_name}:#{window_index} │ #{window_name} │ #{pane_current_command} │ #{pane_current_path}" | \
  fzf \
    --no-sort \
    --border-label ' Windows ' \
    --prompt '  ' \
    --header "  Windows in session: $current_session" \
    --preview 'tmux capture-pane -ep -t "$(echo {} | cut -d" " -f1)"' \
    --preview-window 'right:55%' | \
  awk '{print $1}')

[ -n "$target" ] && tmux switch-client -t "$target"
