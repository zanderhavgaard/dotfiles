#!/bin/zsh

#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|

# make sure the correct character set is used
export LANG="en_US.UTF-8"

# tell zsh to use colors
export TERM="xterm-256color"

# ===== Typewritten customization =====
# export TYPEWRITTEN_PROMPT_LAYOUT="singleline"
# export TYPEWRITTEN_SYMBOL="❯"
# export TYPEWRITTEN_SYMBOL=">"
# export TYPEWRITTEN_CURSOR="underscore"
# export TYPEWRITTEN_RIGHT_PROMPT_PREFIX="> "
# export TYPEWRITTEN_GIT_RELATIVE_PATH=true

# ===== antigen =====

# use antigen
# here installed from the AUR
source /usr/share/zsh/share/antigen.zsh

# use oh-my-zsh plugins
antigen use oh-my-zsh

# oh-my-zsh plugins
antigen bundle git
antigen bundle docker
antigen bundle docker-compose
antigen bundle fzf
antigen bundle python

# plugins
antigen bundle zdharma/fast-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle "MichaelAquilina/zsh-autoswitch-virtualenv"
antigen bundle hlissner/zsh-autopair
antigen bundle chrissicool/zsh-256color
antigen bundle djui/alias-tips
antigen bundle ael-code/zsh-colored-man-pages
antigen bundle zpm-zsh/colorize
antigen bundle "MichaelAquilina/zsh-auto-notify"

# theme
antigen theme https://github.com/reobin/typewritten
# antigen theme romkatv/powerlevel10k

# commit antigen commands
antigen apply

# ====== Custom settings =====
# show hidden files in tabcompletion
# setopt globdots

# Enable Ctrl-x-e to edit command line
autoload -U edit-command-line

# source custom commands
source ~/.env
source ~/.aliases
source ~/.env-local

# needed for docker plugin
autoload -Uz compinit
compinit

# btw I use Arch...
pfetch

# To customize prompt, run `p10k configure` or edit ~/dotfiles/.p10k.zsh.
# [[ ! -f ~/dotfiles/.p10k.zsh ]] || source ~/dotfiles/.p10k.zsh
