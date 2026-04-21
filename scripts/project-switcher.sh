#!/usr/bin/env bash
# Project directory switcher using zoxide + fzf
# Opens/switches to a tmux session rooted at the selected project directory

export PATH="$HOME/go/bin:$HOME/.cargo/bin:$PATH"

set_ghostty_project_title() {
  local target="$1"
  local project title client_tty

  project=$(basename "$target")
  title="${project} [$(hostname -s)]"

  client_tty=$(tmux display-message -p '#{client_tty}' 2>/dev/null)
  if [ -n "$client_tty" ] && [ -c "$client_tty" ]; then
    printf '\033]0;%s\007' "$title" > "$client_tty"
  else
    printf '\033]0;%s\007' "$title"
  fi
}

selected=$(zoxide query -l | fzf \
  --no-sort \
  --border-label ' Projects ' \
  --prompt '  ' \
  --header '  Jump to project (sorted by frecency)' \
  --preview 'ls -la --color=always {} 2>/dev/null || ls -la {}' \
  --preview-window 'right:55%')

[ -z "$selected" ] && exit 0

set_ghostty_project_title "$selected"
sesh connect "$selected"
