#     ____ ___  _  _  ___   ___
#    |_  // __|| || || _ \ / __|
#  _  / / \__ \| __ ||   /| (__
# (_)/___||___/|_||_||_|_\ \___|
#

# make sure the correct character set is used
export LANG="en_DK.UTF-8"

# tell zsh to use colors
export TERM="xterm-256color"

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
antigen bundle caarlos0/zsh-open-pr

# theme
# antigen theme https://github.com/denysdovhan/spaceship-zsh-theme spaceship
# antigen theme https://github.com/reobin/typewritten
# antigen theme https://github.com/hohmannr/bubblified
antigen bundle mafredri/zsh-async
antigen bundle sindresorhus/pure

# commit antigen commands
antigen apply

# ====== Custom settings =====
# show hidden files in tabcompletion
# setopt globdots

# source custom commands
source ~/.env
source ~/.aliases
source ~/.env-local

# needed for docker plugin
autoload -Uz compinit
compinit

# btw I use Arch...
pfetch

