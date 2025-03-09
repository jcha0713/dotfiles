.PHONY: intel mini

intel:
	darwin-rebuild switch --flake $$HOME/dotfiles#jcha_16

apple:
	darwin-rebuild switch --flake $$HOME/dotfiles#jcha_mini
