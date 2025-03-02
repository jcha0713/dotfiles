.PHONY: update_16 update_mini

update_16:
	darwin-rebuild switch --flake $$HOME/.config/nix#jcha_16

update_mini:
	darwin-rebuild switch --flake $$HOME/.config/nix#jcha_mini
