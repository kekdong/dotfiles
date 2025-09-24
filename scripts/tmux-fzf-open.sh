#!/usr/bin/env bash
set -euo pipefail

# Open a file via fzf-tmux and edit in Neovim
if ! command -v fzf-tmux >/dev/null 2>&1; then
  exit 0
fi

if command -v fd >/dev/null 2>&1; then
  map_cmd=(fd -H -t f)
elif command -v rg >/dev/null 2>&1; then
  map_cmd=(rg --files --hidden -g '!.git')
else
  map_cmd=(find . -type f)
fi

selection="$(${map_cmd[@]} 2>/dev/null | fzf-tmux -p 80%,80% || true)"
if [ -n "$selection" ]; then
  exec nvim "$selection"
fi

