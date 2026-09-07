# zoxide, plus the cd-is-zoxide behaviour ported from ~/.zshrc.
#
# WHY `--cmd cd` and not the default init plus a hand-written functions/cd.fish:
#
# 1. THE `z` NAME. Default `zoxide init fish` emits `alias z=__zoxide_z`. Fish
#    only autoloads functions/NAME.fish if NAME is not ALREADY defined, and
#    conf.d runs before anything can call `z`. So that alias would permanently
#    shadow our functions/z.fish (the ripgrep search) - silently, with no error,
#    forever. `--cmd cd` emits cd/cdi only and leaves `z` and `zi` free. This is
#    the single most important reason for the flag. Do not drop it. It is the
#    fish equivalent of `unalias z` in .zshrc.
#
# 2. It gets the completion wiring right for free: zoxide emits
#    `complete --erase --command cd` plus a `commandline --replace` in
#    __zoxide_z_complete. Hand-rolling means reproducing that by hand.
#
# NON-REASON (a myth worth writing down, because it looks true): zoxide's init
# contains a block that does
#     status get-file functions/cd.fish | string replace ... | source
# to build __zoxide_cd_internal, which reads as "zoxide copies YOUR cd.fish and
# therefore recurses". It does not. In fish 4.x, `status list-files` and
# `status get-file` read fish's EMBEDDED filesystem - the function library
# compiled into the binary; share/fish/functions does not exist on disk at all.
# Verified: `status get-file functions/fish_prompt.fish` returns fish's stock
# prompt, not the custom one in this repo. So __zoxide_cd_internal is always a
# rename of fish's own cd. A hand-written wrapper WOULD have been safe; it is
# just worse, for reason 1.
#
# WHY interactive-only: __zoxide_hook is an `--on-variable PWD` handler that
# shells out to `zoxide add` on every directory change. Letting that fire in
# `fish -c` subshells (fzf spawns them per keystroke for previews) would be pure
# cost and would pollute the database with scripted cds. This matches zsh, where
# all of it lives in .zshrc and is therefore interactive-only too.

if status is-interactive
    command -q zoxide; and zoxide init fish --cmd cd | source

    # Restore the zsh behaviour: bare `cd` opens the interactive picker.
    #
    # zoxide's own __zoxide_z sends a zero-arg call to `__zoxide_cd $HOME`, so
    # plain `--cmd cd` would give `cd` -> home and `cdi` -> picker. .zshrc has
    # bare `cd` -> __zoxide_zi, so we re-wrap. This must live HERE and not in
    # functions/cd.fish: the alias above already defined `cd`, and fish never
    # autoloads a name that is already defined.
    #
    # Verified still working through this wrapper: `cd -`, prevd, nextd, and the
    # directory history fish's real cd maintains (__zoxide_cd_internal is that
    # same function under another name).
    #
    # $argv is passed unquoted, unlike zsh's `__zoxide_z "$*"`. zoxide's fish
    # implementation expects separate keywords and matches entries containing
    # all of them, which is the upstream-intended behaviour.
    if functions --query __zoxide_z
        function cd --wraps __zoxide_z --description 'zoxide cd; bare cd opens the picker'
            if test (count $argv) -eq 0
                __zoxide_zi
            else
                __zoxide_z $argv
            end
        end
    end
end
