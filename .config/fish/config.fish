if status is-interactive
    set -g fish_greeting ""

    if set -q TERMUX_VERSION; or test -d /data/data/com.termux
        set -gx EDITOR micro
        set -gx VISUAL micro

        # Quick dotfile sync helper
        function dotsync
            bash "$HOME/dotfiles/sync.sh" $argv
        end

        # Run root commands with Termux binaries in PATH
        function rsu
            set -l cmd (string escape -- $argv)
            su -c "PATH=$PREFIX/bin:\$PATH $cmd"
        end

        # Keep pkglist.txt updated after package changes
        function pkg --wraps pkg
            command pkg $argv
            set -l rc $status
            if test $rc -eq 0; and contains -- $argv[1] install uninstall upgrade up
                if test -d "$HOME/dotfiles"
                    command pkg list-installed 2>/dev/null | cut -d"/" -f1 | sort -u > "$HOME/dotfiles/pkglist.txt"
                end
            end
            return $rc
        end
    end
end
