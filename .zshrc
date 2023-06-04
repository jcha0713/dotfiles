# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
ZSH_DISABLE_COMPFIX="true"

# export LANG=en_US.UTF-8

# SET MANPAGER
# set it to bat
# export MANPAGER="sh -c 'col -bx | bat -l man -p'" 

# set it to nvim
export MANPAGER="col -b | nvim -c 'set ft=man'" 

# ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/.ripgreprc"

# zoxide
# eval "$(zoxide init zsh)"

export EDITOR=nvim

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/jcha0713/.oh-my-zsh"

# Flutter directory
export PATH="$PATH:/Users/jcha0713/Documents/dev/flutter/bin"

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Go
export PATH="$HOME/go/bin:$PATH"

# Nim
export PATH=/Users/jcha0713/.nimble/bin:$PATH

# PostgreSQL
export PATH="$PATH:/Applications/Postgres.app/Contents/Versions/13/bin"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
    ZSH_THEME="kolo"
else
    #ZSH_THEME="agnoster"
    ZSH_THEME="kolo"
fi

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
[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"

# MongoDB Alias
alias mongod='brew services run mongodb-community'
alias mongod-status='brew services list'
alias mongod-stop='brew services stop mongodb-community'


# code command for opening vscode in iterm
code () {VSCODE_CWD="$PWD" open -n -b "com.microsoft.VScode" --args $* ;}

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
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}


### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
#

## forgit
zinit light 'wfxr/forgit'

export TERM=xterm-256color-italic

# ========================
### Personal Aliases
# ========================


# npm run deb
alias nrd='npm run dev'

# cd
alias jhcha='cd ~/jhcha/'
alias dev='cd ~/jhcha/dev/'
alias nt='cd ~/jhcha/note/'

# clear console
alias cl='clear'

# zsh config
alias zc='nvim ~/.zshrc'
alias zs='source ~/.zshrc'

# open .
alias op='open .'

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

# copy note directory to the iCloud drive
alias note_push='rsync -avh --exclude=note/.obsidian --delete /Users/jcha0713/jhcha/note ~/Library/Mobile\ Documents/iCloud\~md\~obsidian/Documents'

# safe rm
alias rm='trash'

note () {
  if [[ "$1" == "push" ]]; then
    rsync -avh --exclude=note/.obsidian --delete /Users/jcha0713/jhcha/note ~/Library/Mobile\ Documents/iCloud\~md\~obsidian/Documents
  fi
}

# switch tmux session
function ts() {
  if [ -n "$1" ]
  then
    tmux switch -t $1
  else
   echo "no session name"
  fi
}

lfcd () {
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

ip () {
  myip=$(curl https://api.ipify.org)
  echo $myip
}

if [[ -f "$LFCD" ]]; then
    source "$LFCD"
fi

# bind <C-n> to lfcd
bindkey -s '^n' 'lfcd\n'

PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
export PATH

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
