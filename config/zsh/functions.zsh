function dvt() {
  local template_name="base"
  local third_party_mode="prompt"
  local template_repo="github:jcha0713/nix-dev-templates"
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --third-party|-t)
        third_party_mode="true"
        shift
        ;;
      --own-repo|-o)
        third_party_mode="false"
        shift
        ;;
      --template-repo|-r)
        template_repo="$2"
        shift 2
        ;;
      --help|-h)
        echo "Usage: dvt [template] [options]"
        echo ""
        echo "Templates:"
        echo "  base     - Base environment with common tools"
        echo "  node     - Node.js development environment"
        echo "  bun      - Bun development environment"
        echo ""
        echo "Options:"
        echo "  -t, --third-party    Force third-party protection mode"
        echo "  -o, --own-repo       Force own repository mode"
        echo "  -r, --template-repo  Use different template repository"
        echo "  -h, --help           Show this help"
        echo ""
        echo "Examples:"
        echo "  dvt                  # Use base template with prompt"
        echo "  dvt bun           # Bun template with prompt"
        echo "  dvt bun --third-party  # Bun template with forced protection"
        return 0
        ;;
      *)
        template_name="$1"
        shift
        ;;
    esac
  done
  
  # Prompt for third-party mode if not explicitly set
  if [[ "$third_party_mode" == "prompt" ]]; then
    echo "🤔 Repository Protection Setup"
    echo ""
    echo "Third-party protection prevents accidentally committing flake files"
    echo "to repositories you don't own (useful when contributing to open source)."
    echo ""
    read "response?Enable third-party protection? (y/n): "
    
    if [[ "$response" =~ ^[Yy] ]]; then
      third_party_mode="true"
      echo "🛡️ Third-party protection will be enabled"
    else
      third_party_mode="false"
      echo "🏠 Own repository mode selected"
    fi
    echo ""
  fi

  export DVT_THIRD_PARTY="$third_party_mode"
  
  echo "🚀 Initializing $template_name template..."
  
  # Initialize the flake template
  if ! nix flake init -t "$template_repo#$template_name"; then
    echo "❌ Failed to initialize template: $template_name"
    echo "💡 Try: nix flake show $template_repo"
    return 1
  fi
  
  # Show the generated flake
  echo ""
  echo "📄 Generated flake.nix:"
  if command -v bat &> /dev/null; then
    bat flake.nix
  else
    cat flake.nix
  fi
  
  echo ""
  echo "🔧 Template initialized successfully!"
  echo ""

  # # Reset direnv files if in git repo
  # if git rev-parse --git-dir > /dev/null 2>&1; then
  #   git reset .envrc .direnv 2>/dev/null || true
  #   echo "🔄 Reset direnv files"
  # fi

  echo "📄 Creating .envrc..."
  echo "use flake" > .envrc
  echo ""

  # Ask about direnv
  read "response?Continue with direnv allow? (y/n): "
  if [[ "$response" =~ ^[Yy] ]]; then
    direnv allow
    echo ""
    echo "✅ Environment activated!"
  else
    direnv revoke 2>/dev/null || true
    echo ""
    echo "⏸️  Aborted. You can run 'direnv allow' manually later."
    echo "💡 Or use: nix develop"
  fi
}
