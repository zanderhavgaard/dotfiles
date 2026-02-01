status is-login; and begin
    # Login shell initialisation
end

status is-interactive; and begin

    ## Set default applications
    # — Web browser for tools like `git web--browse`, `crystal play`, etc.
    set -Ux BROWSER firefox
    # — Default editor for tools like `git commit`, `crystal init`, etc.
    set -Ux EDITOR nvim
    set -Ux VISUAL nvim
    # — Pager for long output (e.g. man, git diff)
    set -Ux PAGER less
    # — PDF viewer (used by some scripts/tools)
    set -Ux PDFVIEWER sioyek
    # — Terminal emulator (for any CLI that honors TERMINAL)
    set -Ux TERMINAL kitty

    alias task go-task

    # Abbreviations
    abbr --add -- t task
    abbr --add -- b 'black .'
    abbr --add -- cat bat
    abbr --add -- docker_clean 'docker volume prune -f && docker system prune -f'
    abbr --add -- docker_status 'echo -e "
Containers:
" && docker ps -a && echo -e "
Images:
" && docker image ls && echo -e "
Volumes:
" && docker volume ls'
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
    abbr --add -- ls 'eza --icons'
    abbr --add -- n nvim
    abbr --add -- ncdu 'ncdu --color dark -rr'
    abbr --add -- ping 'prettyping --nolegend'
    abbr --add -- pt pytest
    abbr --add -- rl run_linters
    abbr --add -- rlt 'figlet '\''run_linters'\'' ; run_linters ; figlet '\''pytest'\'' ; pytest'
    abbr --add -- ruff_fix 'ruff check . --config .ruff.toml --fix'
    abbr --add -- generate-password 'date +%s | sha256sum | base64 | head -c 64 | wl-copy'

    # Aliases

    # Interactive shell initialisation
    fzf --fish | source

    set fish_greeting # Disable greeting

    # add wrapper function for launching yazi
    function yy
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    # setup ssh-agent and add keys, supress output
    eval (ssh-agent -c) &>/dev/null
    ssh-add &>/dev/null

    echo
    pfetch

    go-task --completion fish | source

    zoxide init fish | source

    starship init fish | source

    if set -q KITTY_INSTALLATION_DIR
        set --global KITTY_SHELL_INTEGRATION no-rc
        source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
        set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
    end

    direnv hook fish | source

    set -gx PATH /home/zander/.local/bin $PATH

end
