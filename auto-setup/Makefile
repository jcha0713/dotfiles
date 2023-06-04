SHELL := /bin/zsh

install: install-xcode install-homebrew install-oh-my-zsh
	sudo -v
	brew update
	brew bundle --file=Brewfile

install-xcode:
	if xcode-select -p > /dev/null; then \
		echo "Xcode command line tools already installed"; \
	else \
		xcode-select --install; \
	fi

install-homebrew:
	if brew --version > /dev/null; then \
		echo "Homebrew already installed"; \
	else \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"; \
	fi

install-oh-my-zsh:
	if [ -d ~/.oh-my-zsh ]; then \
		echo "Oh My Zsh already installed"; \
	else \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	fi

clean:
	brew bundle cleanup --force --file=Brewfile

.PHONY: install install-xcode install-homebrew install-oh-my-zsh clean
