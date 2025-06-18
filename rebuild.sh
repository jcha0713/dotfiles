#!/bin/bash

platform=$(uname -ms)

case $platform in
'Darwin x86_64')
  config=jcha_16
  ;;
'Darwin arm64')
  config=jcha_mini
  ;;
*)
  echo "Unsupported platform: $platform"
  exit 1
  ;;
esac

echo "Detected platform: $platform"
echo "Using config: $config"

darwin-rebuild switch --flake "$HOME/dotfiles#$config"
