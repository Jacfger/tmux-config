#!/usr/bin/env bash
# Active tmux sessions only — with pane preview

export PATH="$HOME/go/bin:$HOME/.cargo/bin:$PATH"

set_ghostty_project_title() {
  local project="$1"
  local title client_tty
  title="${project} [$(hostname -s)]"

  client_tty=$(tmux display-message -p '#{client_tty}' 2>/dev/null)
  if [ -n "$client_tty" ] && [ -c "$client_tty" ]; then
    printf '\033]0;%s\007' "$title" > "$client_tty"
  else
    printf '\033]0;%s\007' "$title"
  fi
}

project_name_from_session() {
  local session="$1"
  local session_path

  session_path=$(tmux display-message -p -t "$session" '#{session_path}' 2>/dev/null)
  if [ -n "$session_path" ]; then
    basename "$session_path"
  else
    printf '%s' "$session"
  fi
}

target=$(tmux list-sessions -F "#{session_name} │ #{session_windows} windows │ #{session_path}" | \
  fzf \
    --no-sort \
    --border-label ' Active Sessions ' \
    --prompt '  ' \
    --header '  Active tmux sessions' \
    --preview 'tmux capture-pane -ep -t "$(echo {} | cut -d" " -f1):"' \
    --preview-window 'right:55%' | \
  cut -d' ' -f1)

if [ -n "$target" ]; then
  project=$(project_name_from_session "$target")
  set_ghostty_project_title "$project"
  tmux switch-client -t "$target"
fi
