import 'common.just'

# Update all flake inputs
update-all:
  cd "{{ROOT}}" && nix flake update

# Update given flake input
update input:
  cd "{{ROOT}}" && nix flake update "{{input}}"

# Update all flake inputs
ua: update-all

# Update given flake input
u input: (update input)
