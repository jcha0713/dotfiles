function dvt() {
  if ! nix flake init -t "github:the-nix-way/dev-templates#$1"; then
    echo "Failed to initialize flake"
    return 1
  fi

  if git rev-parse --git-dir > /dev/null 2>&1; then
    git reset .envrc .direnv 2>/dev/null || true
  fi

  if command -v bat &> /dev/null; then
    bat flake.nix
  else
    cat flake.nix
  fi

  read "response?Continue with direnv allow? (y/n): "
  if [[ "$response" =~ ^[Yy] ]]; then
    direnv allow
  else
    direnv revoke
    echo "Aborted. You can run 'direnv allow' manually later."
  fi
}
