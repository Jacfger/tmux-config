#!/usr/bin/env bash
# Telescope-like session switcher using sesh + fzf
# Shows active sessions, configured sessions, and zoxide directories

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

project_name_from_connected_session() {
  local root

  root=$(sesh root 2>/dev/null)
  if [ -n "$root" ]; then
    basename "$root"
  fi
}

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

if [ -n "$selected" ]; then
  if sesh connect "$selected"; then
    project=$(project_name_from_connected_session)
    [ -n "$project" ] && set_ghostty_project_title "$project"
  fi
fi
