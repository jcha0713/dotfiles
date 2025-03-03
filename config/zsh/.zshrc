# export LANG=en_US.UTF-8

# SET MANPAGER
# set it to bat
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# set it to nvim
export MANPAGER="col -b | nvim -c 'set ft=man'"

# Prioritize Nix paths
export PATH="/Users/jcha0713/.nix-profile/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/.ripgreprc"

export EDITOR=nvim

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/jcha0713/.oh-my-zsh"

# Flutter directory
export PATH="$PATH:/Users/jcha0713/Documents/dev/flutter/bin"

# clangd
export PATH="/usr/local/opt/llvm/bin:$PATH"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Go
export PATH="$HOME/go/bin:$PATH"

# Nim
export PATH=/Users/jcha0713/.nimble/bin:$PATH

# PostgreSQL
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/13/bin"

# bob-nvim
export PATH=$PATH:/Users/jcha0713/.local/share/bob/nvim-bin

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="kolo"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  macos
  zsh-autosuggestions
  vi-mode
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

## rbenv PATH
[[ -d ~/.rbenv ]] &&
  export PATH=${HOME}/.rbenv/bin:${PATH} &&
  eval "$(rbenv init -)"

# MongoDB Alias
alias mongod='brew services run mongodb-community'
alias mongod-status='brew services list'
alias mongod-stop='brew services stop mongodb-community'

# redefine prompt_context for hiding user@hostname
#prompt_context () {
#  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
#    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"
#  fi
#}

alias luamake=/Users/jcha0713/lua-language-server/3rd/luamake/luamake

# fzf configs
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

## fzf commands
export FZF_DEFAULT_COMMAND="fd --exclude '.git' --exclude 'node_modules' --exclude 'lua-language-server'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND --type f"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"

## layout options

export FZF_DEFAULT_OPTS="--height 80% --preview-window=right,60%,border-rounded --layout reverse --border rounded --margin 1 --bind ctrl-d:preview-page-down,ctrl-u:preview-page-up"
export FZF_CTRL_T_OPTS="--preview 'bat --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -100'"

# gruvbox color theme
# export FZF_DEFAULT_OPTS='--height 80% --layout reverse --border rounded --margin 2 --bind ctrl-d:page-down,ctrl-u:page-up --color=bg+:#3c3836,bg:#32302f,spinner:#fb4934,hl:#928374,fg:#ebdbb2,header:#928374,info:#8ec07c,pointer:#fb4934,marker:#fb4934,fg+:#ebdbb2,prompt:#fb4934,hl+:#fb4934'

# fzf key mappings
#
# ctrl+o to open fzf result in nvim
bindkey -s '^o' 'nvim $(fzf)\n'

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
  cd) fzf "$@" --preview 'tree -C {} | head -200' ;;
  *) fzf "$@" ;;
  esac
}

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
  command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
  command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" &&
    print -P "%F{33} %F{34}Installation successful.%f%b" ||
    print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
[[ -n "${_comps[zinit]}" ]] || _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

## forgit
zinit light 'wfxr/forgit'

# syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting

# export TERM=xterm-256color-italic
# https://github.com/wez/wezterm/issues/415
export TERM=wezterm

# ========================
### Personal Aliases
# ========================

# npm run deb
alias nrd='npm run dev'

# cd
alias jhcha='cd ~/jhcha/'
alias dev='cd ~/jhcha/dev/'
# alias nt='cd /Users/jcha0713/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/zettelkasten'
alias nt='cd $ZK_NOTEBOOK_DIR/'

# clear console
alias cl='clear'

# zsh config
alias zc='nvim ~/.zshrc'
alias zs='source ~/.zshrc'

# open .
# alias op='open .'

# git
alias gs='git status'
alias lg='lazygit'

# Neovim
alias nv='cd ~/.config/nvim'
alias ㅜ퍄ㅡ='nvim'

# Tmux
alias tk='tmux kill-server'
alias mux='tmuxinator'

# pgcli (postgreSQL)
alias pg='pgcli'

# pnpm
alias pn='pnpm'

# copy note directory to the iCloud drive
alias note_push='rsync -avh --exclude=note/.obsidian --delete /Users/jcha0713/jhcha/note ~/Library/Mobile\ Documents/iCloud\~md\~obsidian/Documents'

# safe rm
alias rm='trash'

# @antfu/ni
alias 'p'='na'
alias 'pi'='ni'
alias 'pr'='nr'
alias 'pu'='nu'
alias 'pun'='nun'
alias 'pci'='nci'

# bob-nvim
alias nvvm='bob'

# leetcode
alias leet='nvim leetcode'

# netcat
alias nc='ncat'

# github(gh)
alias gho="gh browse"

# for remote work
alias remote='caffeinate -ims'
# ========================
### Personal Theme Config
# ========================

# https://github.com/zsh-users/zsh-autosuggestions/blob/master/README.md#configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#737246'

function note() {
  if [[ "$1" == "push" ]]; then
    rsync -avh --exclude=note/.obsidian --delete /Users/jcha0713/jhcha/note ~/Library/Mobile\ Documents/iCloud\~md\~obsidian/Documents
  fi
}

# switch tmux session
function ts() {
  if [ -n "$1" ]; then
    tmux switch -t $1
  else
    echo "no session name"
  fi
}

function lfcd() {
  tmp="$(mktemp)"
  lf -last-dir-path="$tmp" "$@"
  if [ -f "$tmp" ]; then
    dir="$(cat "$tmp")"
    rm -f "$tmp"
    if [ -d "$dir" ]; then
      if [ "$dir" != "$(pwd)" ]; then
        cd "$dir"
      fi
    fi
  fi
}

# clipboard -> awk -> clipboard
cp_awk() {
  if [ -z "$1" ]; then
    echo "You must supply an awk command."
    return 1
  fi
  pbpaste | awk "$1" | pbcopy
}

# replace the given string with a newline
nl_awk() {
  if [ -z "$1" ]; then
    echo "You must supply an awk command."
    return 1
  fi

  before=$(pbpaste)
  pbpaste | awk '{gsub("'$1'", "\n"); print $0;}' | pbcopy
  after=$(pbpaste)

  echo "Press Enter to view the differences in fzf..."
  read -r _ # Wait for Enter key

  diff -u <(echo "$before") <(echo "$after")
}

# wezterm: rename workspace
rnw() {
  if [ -z "$1" ]; then
    echo "You must supply a name."
    echo "Usage: rnw <new-workspace-name>"
    return 1
  fi

  wezterm cli rename-workspace "$1"

  echo "Successfully renamed workspace to $1"
}

if [[ -f "$LFCD" ]]; then
  source "$LFCD"
fi

# # bind <C-n> to lfcd
# bindkey -s '^n' 'lfcd\n'

# bind <C-n> to yazi
bindkey -s '^n' 'yazi\n'

function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
export PATH

# NVM
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "/Users/jcha0713/.bun/_bun" ] && source "/Users/jcha0713/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# zoxide
eval "$(zoxide init zsh)"

# fnm
export PATH="/Users/jcha0713/Library/Application Support/fnm:$PATH"
eval "$(fnm env --shell zsh)"

# 1password
source /Users/jcha0713/.config/op/plugins.sh

# zk
export ZK_NOTEBOOK_DIR="$HOME/jhcha/note"
alias note="yazi $ZK_NOTEBOOK_DIR"

function capture() {
  zk new --title "$*" "$ZK_NOTEBOOK_DIR/captures"
}

function get_project_name() {
  local project_name

  if [ -n "$1" ]; then
    # Use provided argument if it exists
    project_name="$1"
  elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Get the git repository name if we're in a git directory
    project_name=$(basename -s .git $(git config --get remote.origin.url) 2>/dev/null)

    if [ -z "$project_name" ]; then
      # Fallback to local repo name if no remote exists
      project_name=$(basename $(git rev-parse --show-toplevel))
    fi
  else
    echo "Error: Please provide a project name or run from within a git repository"
    return 1
  fi

  echo "$project_name"
  return 0
}

function devlog() {
  project_name=$(get_project_name "$1")

  if [ $? -ne 0 ]; then
    return 1
  fi

  # Create full path
  local project_path="$ZK_NOTEBOOK_DIR/project/dev/$project_name"
  local log_path="$project_path/log"

  # Create directories if they don't exist
  if [ ! -d "$project_path" ]; then
    echo "Creating project directory: $project_path"
    mkdir -p "$log_path"
  elif [ ! -d "$log_path" ]; then
    echo "Creating log directory: $log_path"
    mkdir -p "$log_path"
  fi

  zk new --extra project=$project_name --no-input "$log_path"
}

function project() {
  local project_type="dev"
  local project_arg=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -a | --active)
      project_type="active"
      shift
      ;;
    *)
      # Save non-flag arguments
      project_arg="$1"
      shift
      ;;
    esac
  done

  project_name=$(get_project_name "$project_arg")

  echo $project_name

  if [ $? -ne 0 ]; then
    return 1
  fi

  local project_path="$ZK_NOTEBOOK_DIR/project/$project_type/$project_name"
  local project_file="$project_path/$project_name.md"

  if [ ! -d "$project_path" ]; then
    echo "Creating project directory: $project_path"
    mkdir -p "$project_path"
  fi

  # zk
  zk new --title=$project_name --extra project=$project_name --no-input "$project_path"
}

alias dl="devlog"
alias p="project"

# nix(quick config access)
alias nixc='nvim ~/.config/nix/flake.nix'
alias nixs='darwin-rebuild switch --flake ~/.config/nix#jcha_16'
