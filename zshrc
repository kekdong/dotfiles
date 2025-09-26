# Zsh configuration optimized for Nord-themed environments

export ZDOTDIR="${ZDOTDIR:-$HOME}"
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Deduplicate search paths before manipulating PATH
typeset -U path PATH

# Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Telekasten vault (overridable)
if [ -z "${TELEKASTEN_VAULT:-}" ]; then
  if [ -d "$HOME/Workspace/Commonplace-Book" ]; then
    export TELEKASTEN_VAULT="$HOME/Workspace/Commonplace-Book"
  else
    export TELEKASTEN_VAULT="$HOME/Workspace/Commonpalce-Book"
  fi
fi

# Paths
case "$(uname -s)" in
  Darwin)
    export OS_FLAVOR="macos"
    export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
    if [ -d "$HOMEBREW_PREFIX/bin" ]; then
      path=("$HOMEBREW_PREFIX/bin" $path)
    fi
    alias ls='ls -G'
    ;;
  Linux)
    export OS_FLAVOR="linux"
    alias ls='ls --color=auto'
    ;;
  *)
    export OS_FLAVOR="unknown"
    ;;
esac

# Python tooling (uv-first)
# Ensure user-local bin is in PATH so `uv tool install` shims are discoverable
if [ -n "${XDG_BIN_HOME:-}" ]; then
  path=("$XDG_BIN_HOME" $path)
else
  path=("$HOME/.local/bin" $path)
fi

# pyenv is disabled by default. Re-enable only if explicitly requested.
# Set `ENABLE_PYENV=1` before launching the shell to turn this back on.
if [ "${ENABLE_PYENV:-}" = "1" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  if [ -d "$PYENV_ROOT/bin" ]; then
    path=("$PYENV_ROOT/bin" $path)
  fi
  if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
      eval "$(pyenv virtualenv-init -)"
    fi
  fi
fi

# nvm setup
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  source "$NVM_DIR/nvm.sh"
fi
if [ -s "$NVM_DIR/bash_completion" ]; then
  source "$NVM_DIR/bash_completion"
fi

# History configuration
HISTSIZE=5000
SAVEHIST=5000
HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS HIST_REDUCE_BLANKS SHARE_HISTORY

# Performance options
setopt prompt_subst
setopt auto_cd correct
unsetopt beep
autoload -U colors && colors

# Terminal capability detection for UI fallbacks
integer DOTFILES_IS_RAW_TTY=0 DOTFILES_HAS_TRUECOLOR=0
case ${TERM:-dumb} in
  linux|linux-16color|linux-256color|vt*|ansi|dumb|cons*)
    DOTFILES_IS_RAW_TTY=1
    ;;
esac

# Allow manual override for edge cases (0 or 1)
if [[ ${DOTFILES_FORCE_TTY_FALLBACK:-} == 0 ]]; then
  DOTFILES_IS_RAW_TTY=0
elif [[ ${DOTFILES_FORCE_TTY_FALLBACK:-} == 1 ]]; then
  DOTFILES_IS_RAW_TTY=1
fi

if command -v tput >/dev/null 2>&1; then
  DOTFILES_TERM_COLORS=$(tput colors 2>/dev/null || printf '0')
  if [[ ${DOTFILES_TERM_COLORS:-0} -ge 256 ]]; then
    DOTFILES_HAS_TRUECOLOR=1
  fi
fi
unset DOTFILES_TERM_COLORS
if [[ ${DOTFILES_FORCE_TRUECOLOR:-} == 0 ]]; then
  DOTFILES_HAS_TRUECOLOR=0
elif [[ ${DOTFILES_FORCE_TRUECOLOR:-} == 1 ]]; then
  DOTFILES_HAS_TRUECOLOR=1
fi

integer DOTFILES_ENABLE_NERD_FONT=1 DOTFILES_ENABLE_TRUECOLOR=${DOTFILES_HAS_TRUECOLOR}
if (( DOTFILES_IS_RAW_TTY )); then
  DOTFILES_ENABLE_NERD_FONT=0
  DOTFILES_ENABLE_TRUECOLOR=0
fi
if [[ ${DOTFILES_FORCE_NERD_FONT:-} == 0 ]]; then
  DOTFILES_ENABLE_NERD_FONT=0
elif [[ ${DOTFILES_FORCE_NERD_FONT:-} == 1 ]]; then
  DOTFILES_ENABLE_NERD_FONT=1
fi

export DOTFILES_ENABLE_NERD_FONT DOTFILES_ENABLE_TRUECOLOR DOTFILES_IS_RAW_TTY

# Bootstrap zsh-snap (fast plugin manager)
ZSH_SNAP_ROOT="$HOME/.zsh/plugins"
if [ ! -f "$ZSH_SNAP_ROOT/znap/znap.zsh" ]; then
  mkdir -p "$ZSH_SNAP_ROOT"
  git clone --depth 1 https://github.com/marlonrichert/zsh-snap.git "$ZSH_SNAP_ROOT/znap"
fi
source "$ZSH_SNAP_ROOT/znap/znap.zsh"

# Completions and plugins
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-autosuggestions
znap source Aloxaf/fzf-tab
znap source zsh-users/zsh-syntax-highlighting

# Native completion cache

# Prompt (Powerlevel10k with Nord accents)
if [ ! -f "$HOME/.p10k.zsh" ]; then
  ln -sf "$HOME/.dotfiles/p10k.zsh" "$HOME/.p10k.zsh"
fi
znap prompt romkatv/powerlevel10k
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# fzf bindings and defaults (Arch Linux paths)
if [ -f /usr/share/fzf/completion.zsh ]; then
  source /usr/share/fzf/completion.zsh
fi
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
  source /usr/share/fzf/key-bindings.zsh
fi

# Prefer fd; fallback to ripgrep
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
elif command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="rg --files --hidden -g '!.git'"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="rg --files --hidden -g '!.git' | xargs -r dirname | sort -u"
fi

# fzf-tab styles
zstyle ':completion:*' menu select
zstyle ':fzf-tab:*' switch-group 'ctrl-h' 'ctrl-l'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always -1 $realpath'

# Keybindings
bindkey -e
bindkey "^P" up-line-or-history
bindkey "^N" down-line-or-history

# Aliases
alias grep='grep --color=auto'
alias gs='git status'
alias vi='nvim'

# Day 5: CLI essentials integration (bat, fd, lsd/exa, zoxide, tldr)
# Prefer modern ls implementations
if command -v lsd >/dev/null 2>&1; then
  if (( DOTFILES_ENABLE_NERD_FONT )); then
    alias ls='lsd --group-dirs=first --icon=auto'
    alias ll='lsd -lah --group-dirs=first --icon=auto'
    alias la='lsd -la --group-dirs=first --icon=auto'
    alias lt='lsd --tree --depth 2 --group-dirs=first --icon=auto'
  else
    alias ls='lsd --group-dirs=first --icon=never'
    alias ll='lsd -lah --group-dirs=first --icon=never'
    alias la='lsd -la --group-dirs=first --icon=never'
    alias lt='lsd --tree --depth 2 --group-dirs=first --icon=never'
  fi
elif command -v eza >/dev/null 2>&1; then
  if (( DOTFILES_ENABLE_NERD_FONT )); then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lah --group-directories-first --icons=auto'
    alias la='eza -la --group-directories-first --icons=auto'
    alias lt='eza --tree --level=2 --group-directories-first --icons=auto'
  else
    alias ls='eza --group-directories-first --icons=never'
    alias ll='eza -lah --group-directories-first --icons=never'
    alias la='eza -la --group-directories-first --icons=never'
    alias lt='eza --tree --level=2 --group-directories-first --icons=never'
  fi
elif command -v exa >/dev/null 2>&1; then
  if (( DOTFILES_ENABLE_NERD_FONT )); then
    alias ls='exa --group-directories-first --icons=auto'
    alias ll='exa -lah --group-directories-first --icons=auto'
    alias la='exa -la --group-directories-first --icons=auto'
    alias lt='exa --tree --level=2 --group-directories-first --icons=auto'
  else
    alias ls='exa --group-directories-first'
    alias ll='exa -lah --group-directories-first'
    alias la='exa -la --group-directories-first'
    alias lt='exa --tree --level=2 --group-directories-first'
  fi
else
  alias ll='ls -lah'
  alias la='ls -la'
  alias lt='ls -lah'
fi

# bat as pager/cat if available
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --style=plain --paging=never'
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
elif command -v batcat >/dev/null 2>&1; then
  alias cat='batcat --style=plain --paging=never'
  export MANPAGER="sh -c 'col -bx | batcat -l man -p'"
fi

# zoxide (smart cd)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# tldr convenience
if command -v tldr >/dev/null 2>&1; then
  alias tl='tldr --color=always'
  alias tldrup='tldr -u'
fi

# nvitop via uv tool; fallback to `uvx` if not installed as a tool
if ! command -v nvitop >/dev/null 2>&1; then
  if command -v uvx >/dev/null 2>&1; then
    alias nvitop='uvx nvitop'
  fi
fi

# Utility functions
nvimdiffh() {
  command nvim -d "$@"
}

# Fallback for tmux truecolor (respect raw TTYs)
if (( ! DOTFILES_IS_RAW_TTY )); then
  export TERM="xterm-256color"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
