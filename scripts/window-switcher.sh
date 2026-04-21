#!/usr/bin/env bash
# Telescope-like window switcher using fzf
# Shows all windows across all sessions with live pane preview

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

project_name_from_target() {
  local target="$1"
  local session="${target%%:*}"
  local session_path

  session_path=$(tmux display-message -p -t "$session" '#{session_path}' 2>/dev/null)
  if [ -n "$session_path" ]; then
    basename "$session_path"
  else
    printf '%s' "$session"
  fi
}

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

if [ -n "$target" ]; then
  project=$(project_name_from_target "$target")
  set_ghostty_project_title "$project"
  tmux switch-client -t "$target"
fi
