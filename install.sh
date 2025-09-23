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
case "$OS_NAME" in
  Darwin)
    log "macOS detected"
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

log "Setup complete. Launch zsh and run 'tmux source-file ~/.tmux.conf' if tmux was already running."
log "For Neovim plugin installation, start nvim; lazy.nvim will bootstrap itself automatically."
