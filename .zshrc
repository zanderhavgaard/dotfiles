#!/usr/bin/env zsh

#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|

# make sure the correct character set is used
export LANG="en_US.UTF-8"

# tell zsh to use colors
export TERM="xterm-256color"

# setup GPG key
export GPG_TTY=$(tty)

# === zplug ===

# init zplug
source /usr/share/zsh/scripts/zplug/init.zsh

# oh-my-zsh plugins
zplug "plugins/fzf", from:oh-my-zsh
zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "plugins/ripgrep", from:oh-my-zsh
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/gitignore", from:oh-my-zsh
zplug "plugins/gh", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "plugins/kubernetes", from:oh-my-zsh
zplug "plugins/aws", from:oh-my-zsh
zplug "plugins/python", from:oh-my-zsh
zplug "plugins/pip", from:oh-my-zsh
zplug "plugins/golang", from:oh-my-zsh

# plugins
zplug "zsh-users/zsh-autosuggestions"
zplug "MichaelAquilina/zsh-autoswitch-virtualenv"
zplug "hlissner/zsh-autopair"
zplug "chrissicool/zsh-256color"
zplug "djui/alias-tips"
# zplug "ael-code/zsh-colored-man-pages"
zplug "MichaelAquilina/zsh-auto-notify"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# load zplug plugins
# zplug load --verbose
zplug load

# === end zplug ===

# use starship prompt, must be installed seperately
# on arch: pacman -S starship
# starship is configured in a seperate configuration file
# located in ~/.config/starship.toml
eval "$(starship init zsh)"

# ====== Custom settings =====
# show hidden files in tabcompletion
# setopt globdots

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line

# source custom commands
source ~/.env
source ~/.aliases
source ~/.env-local

# init zoxide
# eval "$(zoxide init zsh)"

# btw I use Arch...
pfetch
