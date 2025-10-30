#!/bin/bash

# =============================== #
#    Check System Requirements    #
# ------------------------------- #
# 1. Checking os                  #
# 2. Checking Shell               #
# 3. Checking Dependencies        #
# =============================== #

# 1. Checking os ---------------- #
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "❌️ This setup script is intended for macOS systems only."
  exit 1
fi

# 2. Checking Shell ------------- #
if [[ "$SHELL" != *"zsh"* ]]; then
  echo "⚠️ The default shell is not zsh. "
  echo "zsh をデフォルトシェルに設定してから再度実行してください。"
  exit 1
fi

# 3. Checking Dependencies ------ #
if ! command -v stow > /dev/null 2>&1; then
	echo "⚠️ GNU Stow がインストールされていません。先にインストールしてください。"
	exit 1
fi

# =============================== #
#          Symlink Setup          #
# ------------------------------- #
# 1. zsh (Oh My Zsh)              #
# 2. coding-agents                #
# =============================== #

# dotfiles ディレクトリの絶対パス
DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# zsh (Oh My Zsh) --------------- #
cd "$DOTFILES_DIR/macos" || exit 1
stow -t ~ zsh
# ------------------------------- #

# coding-agents ----------------- #
cd "$DOTFILES_DIR/macos/coding-agents/.copilot" || exit 1

# ~/.copilot ディレクトリが存在しない場合は作成
mkdir -p ~/.copilot

# 適用
stow -t ~/.copilot config.json
stow -t ~/.copilot mcp-config.json
# ------------------------------- #

exec zsh

echo "✅ Setup completed successfully!"
