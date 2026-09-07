# One-shot local health summary: are the dotfiles synced, did the bootstrap
# script fail, did rclone bisync fail? Port of _login_status in ~/.zshrc.
#
# CURRENTLY PARKED - nothing calls this. That mirrors the zsh original, where the
# call site on line 142 is commented out and the function is `unset -f`'d on 143.
# Fish expresses "defined but not running" natively: an autoloaded function is
# not even parsed until someone types its name, so parking it here costs nothing
# at startup - strictly better than zsh's define-then-unset dance.
# To re-enable, create conf.d/40-login-status.fish containing:
#     status is-interactive; and status is-login; and login_status
#
# Renamed from _login_status: a single leading underscore has no meaning in fish
# (the private convention is __), and an autoloaded file must be named exactly
# after its function, so the plain name is clearer for something you may want to
# invoke by hand as a diagnostic.
#
# EVERY CHECK HERE MUST BE LOCAL AND FAST - no network, no fetches. Total cost is
# ~0.2s, nearly all of it the single yadm call.
#
# Fish translation notes, each of which is a way this could silently go wrong:
#
#   $UID does not exist in fish - it is a zsh/bash builtin. Reading it yields the
#   empty string, which would turn the launchctl target into "gui//com.user..."
#   and make the rclone check silently always pass. Use (id -u).
#
#   `${(@f)out}` (split on newlines) is unnecessary: fish command substitution
#   already splits on newlines, so `set -l lines (yadm ...)` IS the array.
#
#   `set -l x (cmd)` DOES propagate cmd's exit status in fish, so
#   `if set -l lines (...)` correctly replaces zsh's `if out=$(...)`. Worth
#   knowing, because it is the opposite of the usual fish warning about $status
#   being clobbered.
#
#   A FAILED `string match -rq` with a named capture sets the capture variable to
#   EMPTY - it does not leave a prior value alone. So the assignment must happen
#   INSIDE the success branch, as it does below, or a repo with no [ahead N]
#   would wipe out the `set ahead 0` default.
#
#   `print -P "%F{yellow}...%f"` has no fish equivalent; use set_color, and
#   remember (set_color normal) after every coloured run or the colour bleeds
#   into whatever prints next.

function login_status --description 'Local dotfile / sync health summary'
    # The marker is written by ~/.config/yadm/bootstrap and cleared on its next
    # successful run, so a failure keeps showing until it is actually fixed.
    set -l boot_failed 0
    test -f $HOME/.local/state/login_script.failed; and set boot_failed 1

    # One `yadm status --porcelain --branch` yields both the uncommitted count
    # and the ahead count; running status and rev-list separately costs twice as
    # much. Note "up to date" here means nothing local is outstanding - it says
    # nothing about being behind origin, since detecting that needs a fetch.
    # lines[1] is always the "## branch...upstream" header, so dirty = count - 1.
    set -l yadm_ok 0
    set -l dirty 0
    set -l ahead 0
    if set -l lines (yadm status --porcelain --branch 2>/dev/null)
        set yadm_ok 1
        set dirty (math (count $lines) - 1)
        if string match -rq -- '\[ahead (?<ahead_n>\d+)\]' $lines[1]
            set ahead $ahead_n
        end
    end

    # rclone bisync has its own LaunchAgent running every 5 minutes. launchd
    # remembers the last run's exit status, which is a far better signal than
    # grepping its error log - that log is mostly harmless NOTICE lines.
    # The awk program is single-quoted so fish leaves $NF and {} alone.
    set -l rclone_exit (launchctl print "gui/"(id -u)"/com.user.rclonebisync" 2>/dev/null \
        | awk '/last exit code =/ {print $NF; exit}')

    if test $boot_failed -eq 1
        echo (set_color yellow)"⚠ Failed to sync configs"(set_color normal)"  Check errors with "(set_color cyan)"cat /tmp/login_script.log"(set_color normal)
    end

    if test $yadm_ok -eq 1; and test $dirty -gt 0 -o $ahead -gt 0
        set -l parts
        test $dirty -gt 0; and set -a parts "$dirty uncommitted"
        test $ahead -gt 0; and set -a parts "$ahead unpushed"
        echo (set_color yellow)"⚠ Unsynced configs: "(string join ', ' $parts)(set_color normal)" — review with: "(set_color cyan)"sg"(set_color normal)
    end

    if test -n "$rclone_exit"; and test "$rclone_exit" != 0
        echo (set_color yellow)"⚠ Failed to sync documents"(set_color normal)" — check rclone with: "(set_color cyan)"tail -20 /tmp/rclone-bisync-error.log"(set_color normal)
    end
end
