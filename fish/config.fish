## Environment (global, not universal: universals persist in fish_variables
## and would shadow any change made here)
# — Web browser for tools like `git web--browse`, `crystal play`, etc.
set -gx BROWSER firefox
# — Default editor for tools like `git commit`, `crystal init`, etc.
set -gx EDITOR nvim
set -gx VISUAL nvim
# — Pager for long output (e.g. man, git diff)
set -gx PAGER less
# — PDF viewer (used by some scripts/tools)
set -gx PDFVIEWER zathura
# — Terminal emulator (for any CLI that honors TERMINAL)
set -gx TERMINAL ghostty

fish_add_path -g ~/.local/bin

# use the systemd user ssh-agent (ssh-agent.socket), unless we're in an ssh
# session that may have a forwarded agent
set -q SSH_CONNECTION; or set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/ssh-agent.socket

status is-interactive; and begin

    alias task go-task

    # Abbreviations
    abbr --add -- t task
    abbr --add -- cat bat
    abbr --add -- docker_clean 'docker volume prune -f && docker system prune -f'
    abbr --add -- firmware_update 'sudo fwupdmgr get-devices && sudo fwupdmgr refresh --force && sudo fwupdmgr get-updates && sudo fwupdmgr update'
    abbr --add -- update-grub 'sudo grub-mkconfig -o /boot/grub/grub.cfg'
    abbr --add -- g git
    abbr --add -- ghpr 'gh pr view --web'
    abbr --add -- ghre 'gh repo view --web'
    abbr --add -- gs 'git status'
    abbr --add -- gd 'git diff'
    abbr --add -- gds 'git diff --staged'
    abbr --add -- k kubectl
    abbr --add -- knr 'kubectl describe nodes |grep '\''^  Resource'\'' -A3'
    abbr --add -- l 'eza --icons --git -alh'
    abbr --add -- lg lazygit
    abbr --add -- ls eza
    abbr --add -- n nvim
    abbr --add -- h helix
    abbr --add -- ping 'prettyping --nolegend'
    abbr --add -- generate-password 'head -c 48 /dev/urandom | base64 | head -c 64 | wl-copy'

    # Interactive shell initialisation
    fzf --fish | source

    set fish_greeting # Disable greeting

    # custom functions
    source $__fish_config_dir/functions.fish

    # generating go-task completions is slow (~50ms), so cache them in the
    # (gitignored) completions dir where fish autoloads them on demand;
    # delete the file to regenerate after a go-task upgrade
    set -l go_task_comp $__fish_config_dir/completions/go-task.fish
    test -e $go_task_comp; or go-task --completion fish >$go_task_comp

    zoxide init fish | source

    starship init fish | source

    if set -q KITTY_INSTALLATION_DIR
        set --global KITTY_SHELL_INTEGRATION no-rc
        source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
        set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
    end

    direnv hook fish | source

    mise activate fish | source

    cbonsai -p
    # pfetch
    echo
end
