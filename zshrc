# Zsh configuration optimized for Solarized Osaka Dark environments

export ZDOTDIR="${ZDOTDIR:-$HOME}"
export EDITOR="nvim"
export VISUAL="$EDITOR"

# Deduplicate search paths before manipulating PATH
typeset -U path PATH

# Locale: set LANG only; leave LC_* overridable per category
export LANG="en_US.UTF-8"

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
    # Podman (rootless) Docker-compatible socket for tools like lazydocker.
    # Only claim DOCKER_HOST when the socket actually exists and nothing
    # else has set it (keeps real-Docker setups working).
    if [ -z "${DOCKER_HOST:-}" ]; then
      podman_sock="${XDG_RUNTIME_DIR:-/run/user/$UID}/podman/podman.sock"
      if [ -S "$podman_sock" ]; then
        export DOCKER_HOST="unix://$podman_sock"
      fi
      unset podman_sock
    fi
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
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS SHARE_HISTORY

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

# Trust the terminal's own truecolor advertisement instead of guessing
# from the 256-color count. WezTerm sets COLORTERM directly and tmux >= 3.2
# propagates it into panes when the outer terminal supports RGB.
# For terminals that support truecolor but don't advertise it, set
# DOTFILES_FORCE_TRUECOLOR=1.
if [[ ${COLORTERM:-} == (truecolor|24bit) ]]; then
  DOTFILES_HAS_TRUECOLOR=1
elif [[ ${TERM:-} == (*-direct*|wezterm|xterm-kitty|alacritty) ]]; then
  DOTFILES_HAS_TRUECOLOR=1
fi

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

# Summarize capability profile for downstream configs and quick inspection
typeset -g DOTFILES_UI_PROFILE='ascii-16color'
if (( DOTFILES_ENABLE_NERD_FONT )); then
  DOTFILES_UI_PROFILE='nerdfont-'
else
  DOTFILES_UI_PROFILE='ascii-'
fi
if (( DOTFILES_ENABLE_TRUECOLOR )); then
  DOTFILES_UI_PROFILE+="truecolor"
else
  DOTFILES_UI_PROFILE+="16color"
fi

export DOTFILES_ENABLE_NERD_FONT DOTFILES_ENABLE_TRUECOLOR DOTFILES_IS_RAW_TTY DOTFILES_UI_PROFILE

# Hint 24-bit color support to apps that check COLORTERM.
# Never unset or overwrite a terminal-provided COLORTERM.
if (( DOTFILES_ENABLE_TRUECOLOR )) && [[ -z ${COLORTERM:-} ]]; then
  export COLORTERM=truecolor
fi

if [[ -o interactive ]]; then
  # zsh-snap is bootstrapped by install.sh; never clone from the network
  # during shell startup.
  ZSH_SNAP_ROOT="$HOME/.zsh/plugins"
  if [[ -r "$ZSH_SNAP_ROOT/znap/znap.zsh" ]]; then
    source "$ZSH_SNAP_ROOT/znap/znap.zsh"

    # Completions and plugins
    znap source zsh-users/zsh-completions
    typeset -gA ZSH_HIGHLIGHT_STYLES
    if (( DOTFILES_ENABLE_TRUECOLOR )); then
      typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#637981'
      ZSH_HIGHLIGHT_STYLES[comment]='fg=#637981'
    else
      typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=7'
      ZSH_HIGHLIGHT_STYLES[comment]='fg=7'
    fi

    # fzf-tab must load after completion initialization and before plugins
    # that wrap ZLE widgets, including zsh-autosuggestions.
    znap source Aloxaf/fzf-tab

    # Prefer lightweight in-memory context, then history, then completion.
    # Suggestions are asynchronous; skip re-fetching while pasting long buffers.
    typeset -ga ZSH_AUTOSUGGEST_STRATEGY
    ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)
    typeset -g ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100

    znap source zsh-users/zsh-autosuggestions
    znap source zsh-users/zsh-syntax-highlighting

    # Prompt (Powerlevel10k with Solarized Osaka accents)
    znap prompt romkatv/powerlevel10k
    [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
  else
    print -u2 "dotfiles: zsh-snap not found; run install.sh from your dotfiles checkout to bootstrap plugins"
  fi

  # fzf bindings and defaults (Arch Linux paths)
  if [ -f /usr/share/fzf/completion.zsh ]; then
    source /usr/share/fzf/completion.zsh
  fi
  if [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh
  fi
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

# Solarized Osaka Dark palette for fzf.
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} \
  --color=bg+:#002c38,bg:#001419,border:#063540 \
  --color=fg:#9eabac,gutter:#001419,header:#c94c16 \
  --color=hl+:#c94c16,hl:#c94c16,info:#637981 \
  --color=marker:#c94c16,pointer:#c94c16,prompt:#c94c16 \
  --color=query:#9eabac:regular,scrollbar:#063540 \
  --color=separator:#063540,spinner:#c94c16"

if [[ -o interactive ]]; then
  # fzf-tab styles
  zstyle ':completion:*' menu select
  zstyle ':fzf-tab:*' switch-group 'ctrl-h' 'ctrl-l'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always -1 $realpath'

  # Keybindings
  bindkey -e
  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey "^P" up-line-or-beginning-search
  bindkey "^N" down-line-or-beginning-search
  bindkey "^[[A" up-line-or-beginning-search
  bindkey "^[[B" down-line-or-beginning-search
  [[ -n ${terminfo[kcuu1]:-} ]] &&
    bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
  [[ -n ${terminfo[kcud1]:-} ]] &&
    bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi

# Aliases
alias grep='grep --color=auto'
alias gs='git status'
alias vi='nvim'
alias vim='nvim'

# Day 5: CLI essentials integration (bat, fd, eza, zoxide, tldr)
# Prefer eza; fallback to exa; else stock ls
dotfiles_setup_ls_aliases() {
  if command -v eza >/dev/null 2>&1; then
    local base="eza --group-directories-first"
    if (( DOTFILES_ENABLE_NERD_FONT )); then
      base+=" --icons=auto"
    else
      base+=" --icons=never"
    fi
    alias ls="${base}"
    alias ll="${base} -lah"
    alias la="${base} -la"
    alias lt="${base} --tree --level=2"
    return
  fi

  if command -v exa >/dev/null 2>&1; then
    local base="exa --group-directories-first"
    if (( DOTFILES_ENABLE_NERD_FONT )); then
      base+=" --icons=auto"
    fi
    alias ls="${base}"
    alias ll="${base} -lah"
    alias la="${base} -la"
    alias lt="${base} --tree --level=2"
    return
  fi

  alias ll='ls -lah'
  alias la='ls -la'
  alias lt='ls -lah'
}
dotfiles_setup_ls_aliases
unset -f dotfiles_setup_ls_aliases

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

# Fallback for truecolor ONLY on legacy/unknown terminals
# Do not override TERM in WezTerm/tmux/modern terminals.
if (( ! DOTFILES_IS_RAW_TTY )); then
  # Avoid changing TERM inside tmux or when terminal already sets a good value
  if [[ -z "${TMUX:-}" ]]; then
    case "${TERM:-}" in
      ""|dumb|xterm|xterm-color)
        export TERM="xterm-256color"
        ;;
      *)
        # Keep terminal-provided TERM (e.g. wezterm, tmux-256color, screen-256color)
        ;;
    esac
  fi
fi

if [[ -o interactive ]]; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi
