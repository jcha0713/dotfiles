import 'common.just'

# Rebuild the system
rebuild:
  sudo nixos-rebuild switch --flake "{{ROOT}}#{{flake_host}}"

# Rebuild the system
re: rebuild

# Test the rebuild
test:
  sudo nixos-rebuild test --flake "{{ROOT}}#{{flake_host}}"

# Roll back to previous generation
rollback:
  sudo nixos-rebuild --rollback switch
