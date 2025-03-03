#!/bin/bash

set -e

echo "Setting up nix darwin and home manager"

if ! command -v nix &>/dev/null; then
  echo "Installing Nix"

  sh <(curl -L https://nixos.org/nix/install)
else
  echo "Nix is already installed"
fi

REPO_URL="https://github.com/jcha0713/dotfiles.git"
CONFIG_DIR="$HOME/dotfiles/"
BRANCH_NAME="nix"

if [ ! -d "$CONFIG_DIR" ]; then
  echo "Cloning your configuration repository..."
  git clone --branch "$BRANCH_NAME" "$REPO_URL" "$CONFIG_DIR"
else
  echo "Configuration directory already exists. Pulling latest changes..."
  cd "$CONFIG_DIR" && git pull
fi

if ! command -v darwin-rebuild &>/dev/null; then
  echo "Installing Nix Darwin..."

  nix run nix-darwin/master#darwin-rebuild --extra-experimental-features "nix-command flakes" -- switch --flake "$CONFIG_DIR#jcha_mini"
else
  echo "Nix Darwin is already installed."
fi

echo "Setup complete!"
