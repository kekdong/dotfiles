#!/usr/bin/env bash
set -euo pipefail

# Pick a file with fzf and open it with nvim in a new tmux window.
# Designed to run inside `tmux display-popup -E`, which provides a real tty.
if ! command -v fzf >/dev/null 2>&1; then
  exit 0
fi

if command -v fd >/dev/null 2>&1; then
  finder=(fd -H -t f)
elif command -v rg >/dev/null 2>&1; then
  finder=(rg --files --hidden -g '!.git')
else
  finder=(find . -type f)
fi

selection="$("${finder[@]}" 2>/dev/null | fzf || true)"
if [ -n "$selection" ]; then
  if [ -n "${TMUX:-}" ]; then
    exec tmux new-window -c "$PWD" "nvim -- $(printf '%q' "$selection")"
  fi
  exec nvim -- "$selection"
fi
