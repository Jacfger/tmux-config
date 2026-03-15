#!/bin/sh
# Active tmux sessions only — with pane preview

export PATH="$HOME/go/bin:$HOME/.cargo/bin:$PATH"

target=$(tmux list-sessions -F "#{session_name} │ #{session_windows} windows │ #{session_path}" | \
  fzf \
    --no-sort \
    --border-label ' Active Sessions ' \
    --prompt '  ' \
    --header '  Active tmux sessions' \
    --preview 'tmux capture-pane -ep -t "$(echo {} | cut -d" " -f1):"' \
    --preview-window 'right:55%' | \
  cut -d' ' -f1)

[ -n "$target" ] && tmux switch-client -t "$target"
