#!/usr/bin/env bash
# Project directory switcher using zoxide + fzf
# Opens/switches to a tmux session rooted at the selected project directory

export PATH="$HOME/go/bin:$HOME/.cargo/bin:$PATH"

selected=$(zoxide query -l | fzf \
  --no-sort \
  --border-label ' Projects ' \
  --prompt '  ' \
  --header '  Jump to project (sorted by frecency)' \
  --preview 'ls -la --color=always {} 2>/dev/null || ls -la {}' \
  --preview-window 'right:55%')

[ -z "$selected" ] && exit 0

sesh connect "$selected"
