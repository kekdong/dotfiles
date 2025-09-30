#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOME="${HOME}"

log() { printf "[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

link_file() {
  local source_path="$1"
  local target_path="$2"
  mkdir -p "$(dirname "$target_path")"
  ln -snf "$source_path" "$target_path"
  log "linked $(basename "$source_path") -> $target_path"
}

ensure_pyenv() {
  local pyenv_root="$TARGET_HOME/.pyenv"
  if [ -d "$pyenv_root" ]; then
    log "pyenv already present at $pyenv_root"
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    log "Warning: git not found; skipping pyenv bootstrap"
    return
  fi

  log "Bootstrapping pyenv"
  git clone --depth 1 https://github.com/pyenv/pyenv.git "$pyenv_root" \
    && log "pyenv installed to $pyenv_root" \
    || log "Warning: failed to clone pyenv repository"
}

ensure_nvm() {
  local nvm_dir="$TARGET_HOME/.nvm"
  if [ -d "$nvm_dir" ]; then
    log "nvm already present at $nvm_dir"
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    log "Warning: git not found; skipping nvm bootstrap"
    return
  fi

  log "Bootstrapping nvm"
  git clone --depth 1 https://github.com/nvm-sh/nvm.git "$nvm_dir" \
    && log "nvm installed to $nvm_dir" \
    || log "Warning: failed to clone nvm repository"
}

log "Detecting platform..."
OS_NAME="$(uname -s)"

# macOS-specific bootstrap helpers
ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    log "Homebrew already installed"
    return
  fi
  if ! command -v curl >/dev/null 2>&1; then
    log "Warning: curl not found; cannot install Homebrew automatically"
    return
  fi
  log "Installing Homebrew (this may prompt for password)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    && log "Homebrew installation complete" \
    || log "Warning: Homebrew install script failed"

  # Add brew to PATH for Apple Silicon default path
  if [ -d "/opt/homebrew/bin" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
  fi
}

brew_install_cli() {
  if ! command -v brew >/dev/null 2>&1; then
    log "brew not available; skip package installation"
    return
  fi
  log "Updating Homebrew"
  brew update || true
  # Core CLI set to complement zshrc aliases and Neovim setup
  local pkgs=(
    git
    zsh
    neovim
    tmux
    ripgrep
    fd
    fzf
    bat
    eza
    lsd
    zoxide
    tldr
  )
  log "Installing CLI packages: ${pkgs[*]}"
  brew install "${pkgs[@]}" || true

  # Install fzf key-bindings if provided by brew
  if [ -f "$(brew --prefix 2>/dev/null)/opt/fzf/install" ]; then
    "$(brew --prefix)/opt/fzf/install" --no-bash --no-fish --key-bindings --completion || true
  fi
}

install_im_select_cli() {
  if ! command -v brew >/dev/null 2>&1; then
    log "brew not available; skip im-select installation"
    return
  fi

  if command -v im-select >/dev/null 2>&1; then
    log "im-select already installed"
    return
  fi

  if ! brew tap | grep -q '^daipeihust/tap$'; then
    log "Adding daipeihust/tap for im-select"
    brew tap daipeihust/tap || log "Warning: failed to add daipeihust/tap"
  fi

  log "Installing im-select CLI"
  brew install daipeihust/tap/im-select || log "Warning: failed to install im-select"
}

case "$OS_NAME" in
  Darwin)
    log "macOS detected"
    ensure_homebrew
    brew_install_cli
    install_im_select_cli
    ;;
  Linux)
    log "Linux detected"
    ;;
  *)
    log "Warning: unsupported OS ($OS_NAME). Proceeding with generic setup."
    ;;
 esac

log "Linking tmux configuration"
link_file "$DOTFILES_DIR/tmux.conf" "$TARGET_HOME/.tmux.conf"

ensure_tpm() {
  local tpm_dir="$TARGET_HOME/.tmux/plugins/tpm"
  if [ -d "$tpm_dir" ]; then
    log "TPM already present at $tpm_dir"
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    log "Warning: git not found; skipping TPM bootstrap"
    return
  fi

  log "Bootstrapping TPM (tmux plugin manager)"
  mkdir -p "$(dirname "$tpm_dir")"
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir" \
    && log "TPM installed to $tpm_dir" \
    || log "Warning: failed to clone TPM repository"
}

ensure_tpm

ensure_pyenv
ensure_nvm

log "Linking zsh configuration"
link_file "$DOTFILES_DIR/zshrc" "$TARGET_HOME/.zshrc"
link_file "$DOTFILES_DIR/p10k.zsh" "$TARGET_HOME/.p10k.zsh"

log "Linking Neovim configuration"
link_file "$DOTFILES_DIR/nvim/init.lua" "$TARGET_HOME/.config/nvim/init.lua"

log "Linking bat configuration"
link_file "$DOTFILES_DIR/bat/config" "$TARGET_HOME/.config/bat/config"

log "Linking WezTerm configuration"
link_file "$DOTFILES_DIR/wezterm/wezterm.lua" "$TARGET_HOME/.wezterm.lua"

#############################
# Telekasten vault bootstrap
#############################
# Default vault path matches Obsidian vault repo name.
# Note: GitHub repo is intentionally named 'Commonpalce-Book'.
# Prefer an existing local vault if found (handles prior typos),
# otherwise default to the repo's directory name.
WORKSPACE_DIR="$TARGET_HOME/Workspace"
DEFAULT_VAULT_A="$WORKSPACE_DIR/Commonplace-Book"
DEFAULT_VAULT_B="$WORKSPACE_DIR/Commonpalce-Book"

if [ -n "${TELEKASTEN_VAULT:-}" ]; then
  # If env points to the misspelled path but the correct one exists, prefer the existing correct path
  if [ "$TELEKASTEN_VAULT" = "$DEFAULT_VAULT_B" ] && [ -d "$DEFAULT_VAULT_A" ]; then
    VAULT_DIR="$DEFAULT_VAULT_A"
    log "TELEKASTEN_VAULT points to Commonpalce-Book; using existing Commonplace-Book instead"
  else
    VAULT_DIR="$TELEKASTEN_VAULT"
  fi
elif [ -d "$DEFAULT_VAULT_A" ]; then
  VAULT_DIR="$DEFAULT_VAULT_A"
else
  VAULT_DIR="$DEFAULT_VAULT_B"
fi

REPO_URL="git@github.com:kekdong/Commonpalce-Book.git"

log "Configuring Telekasten vault at $VAULT_DIR"

# Ensure Workspace exists
mkdir -p "$WORKSPACE_DIR"

# If the vault directory doesn't exist, try to clone it first
if [ ! -d "$VAULT_DIR" ]; then
  if command -v git >/dev/null 2>&1; then
    log "Vault not found; cloning Commonpalce-Book from $REPO_URL"
    if git clone --depth 1 "$REPO_URL" "$VAULT_DIR"; then
      log "Cloned vault repository to $VAULT_DIR"
    else
      log "Warning: failed to clone vault repository; creating directory instead"
      mkdir -p "$VAULT_DIR"
    fi
  else
    log "git not found; creating vault directory at $VAULT_DIR"
    mkdir -p "$VAULT_DIR"
  fi
fi

# Match Obsidian config: Areas/Journal/Daily and Resources/Templates
mkdir -p "$VAULT_DIR/Areas/Journal/Daily" "$VAULT_DIR/Areas/Journal/Weekly" "$VAULT_DIR/Resources/Templates"

# Sync Telekasten templates (do not overwrite existing files)
if [ -d "$DOTFILES_DIR/nvim/telekasten_templates" ]; then
  log "Syncing Telekasten templates into Resources/Templates (no overwrite)"
  VAULT_TEMPLATES_DIR="$VAULT_DIR/Resources/Templates"
  for f in "$DOTFILES_DIR"/nvim/telekasten_templates/*; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    if [ -e "$VAULT_TEMPLATES_DIR/$base" ]; then
      log "template exists, skip: $base"
    else
      cp "$f" "$VAULT_TEMPLATES_DIR/$base"
      log "installed template: $base"
    fi
  done
fi

log "Setup complete. Launch zsh and run 'tmux source-file ~/.tmux.conf' if tmux was already running."
log "For Neovim plugin installation, start nvim; lazy.nvim will bootstrap itself automatically."
log "Tip: On Arch, install extras: sudo pacman -S --needed ripgrep fd neovim tmux"

# Optional: Arch package helper for Day5 CLI essentials
arch_install_day5() {
  if ! command -v pacman >/dev/null 2>&1; then
    log "pacman not found; skip Day5 helper"
    return
  fi
  local pkgs=(bat fd lsd tldr zoxide)
  # exa is deprecated upstream; prefer eza if available in repo
  if pacman -Si eza >/dev/null 2>&1; then
    pkgs+=(eza)
  else
    pkgs+=(exa)
  fi
  log "Day5 suggested packages: ${pkgs[*]}"
  if [ "${PACMAN_AUTO_INSTALL:-0}" = "1" ]; then
    sudo pacman -S --needed "${pkgs[@]}"
  else
    log "To install Day5 set: sudo pacman -S --needed ${pkgs[*]}"
  fi
}

# Uncomment to auto-run (requires sudo):
# arch_install_day5
