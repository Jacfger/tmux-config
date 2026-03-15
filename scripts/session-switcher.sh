#!/usr/bin/env bash
# Telescope-like session switcher using sesh + fzf
# Shows active sessions, configured sessions, and zoxide directories

export PATH="$HOME/go/bin:$HOME/.cargo/bin:$PATH"

selected="$(
  (sesh list --icons 2>/dev/null || sesh list) | \
  fzf \
    --no-sort --ansi \
    --border-label ' Sessions ' \
    --prompt '  ' \
    --header '  ctrl-a: all | ctrl-t: tmux | ctrl-x: config | ctrl-d: zoxide | ctrl-f: find' \
    --bind 'tab:down,btab:up' \
    --bind "ctrl-a:change-prompt(  )+reload(sesh list --icons 2>/dev/null || sesh list)" \
    --bind "ctrl-t:change-prompt(  )+reload(sesh list --icons -t 2>/dev/null || sesh list -t)" \
    --bind "ctrl-x:change-prompt(  )+reload(sesh list --icons -c 2>/dev/null || sesh list -c)" \
    --bind "ctrl-d:change-prompt(  )+reload(sesh list --icons -z 2>/dev/null || sesh list -z)" \
    --bind "ctrl-f:change-prompt(  )+reload(fd -H -d 2 -t d . ~)" \
    --preview-window 'right:55%' \
    --preview 'sesh preview {} 2>/dev/null || ls -la {}'
)"

[ -n "$selected" ] && sesh connect "$selected"
