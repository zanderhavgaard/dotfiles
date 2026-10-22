# add wrapper function for launching yazi
function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# launch neovide from a directory but in a separate process
function nv
    set -l dir (test -n "$argv[1]" && realpath -- $argv[1]; or pwd)
    neovide -- +"cd $dir" &>/dev/null &
    disown
end

# decode an on-screen QR code (select a region) into the clipboard —
# e.g. an otpauth:// URI to paste into a password managers's one-time password
# needs grim, slurp, zbar, wl-clipboard
function qr2clip
    set -l tmp (mktemp -t "qr.XXXXXX.png")
    grim -g (slurp) $tmp; or begin
        rm -f -- $tmp
        return 1
    end
    set -l payload (zbarimg -q --raw $tmp)
    shred -u -- $tmp
    if test -z "$payload"
        echo "qr2clip: no QR code found in the selection" >&2
        return 1
    end
    printf '%s' "$payload" | wl-copy
    echo "copied "(string length -- "$payload")" chars to the clipboard"
end

# install xterm-ghostty terminfo system-wide on remote hosts — ghostty's own
# ssh-terminfo only installs to the ssh user's ~/.terminfo, so root / sudo -i miss it
function ghostty-terminfo
    if test (count $argv) -eq 0
        echo "usage: ghostty-terminfo [user@]host..." >&2
        return 1
    end

    set -l terminfo_b64 (infocmp -x xterm-ghostty | base64 -w0)
    or begin
        echo "ghostty-terminfo: xterm-ghostty terminfo not found locally" >&2
        return 1
    end

    # POSIX sh, run on the remote with the base64 terminfo entry as $1.
    # install + verify run as a single root command so there's only one password
    # prompt; the verify uses a bogus HOME so a per-user ~/.terminfo can't satisfy it
    set -l install_script '
        f=$(mktemp) || exit 1
        trap "rm -f $f" EXIT
        echo "$1" | base64 -d >"$f"

        if ! command -v tic >/dev/null; then
            echo "tic not found on remote (install ncurses-bin / ncurses)" >&2
            exit 1
        fi

        cmd="tic -x $f && env -u TERMINFO HOME=/nonexistent infocmp xterm-ghostty >/dev/null"
        if [ "$(id -u)" = 0 ]; then
            sh -c "$cmd"
        elif command -v sudo >/dev/null; then
            sudo sh -c "$cmd"
        else
            echo "no sudo, using su (root password):"
            su root -s /bin/sh -c "$cmd"
        fi || exit

        echo "xterm-ghostty installed system-wide on $(hostname)"
    '

    # the remote login shell may be anything (fish, bash, ...), so pass the script
    # and terminfo base64-encoded (nothing to quote) and have sh decode and eval
    # it. Both go on the command line, keeping stdin free for the password prompt
    set -l script_b64 (printf %s $install_script | base64 -w0)
    set -l remote_cmd (printf 'sh -c \'eval "$(echo %s | base64 -d)"\' sh %s' $script_b64 $terminfo_b64)

    set -l failed 0
    for host in $argv
        echo "==> $host"
        ssh -t $host $remote_cmd
        or set failed 1
    end
    return $failed
end
complete -c ghostty-terminfo -x -a "(__fish_complete_user_at_hosts)"
