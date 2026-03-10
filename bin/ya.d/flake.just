import 'common.just'

# Update all flake inputs
update-all:
  cd "{{ROOT}}" && nix flake update

# Update given flake input
update input:
  cd "{{ROOT}}" && nix flake update "{{input}}"

ua: update-all

u input: (update input)
