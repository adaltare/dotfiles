# Search file contents with ripgrep, pick a hit with fzf, preview it in bat with
# the matching line highlighted. Port of the `z` function at the bottom of
# ~/.zshrc.
#
# WHY this name is available at all: conf.d/10-zoxide.fish initialises zoxide
# with `--cmd cd`. The DEFAULT `zoxide init fish` emits `alias z=__zoxide_z` from
# conf.d, and fish only autoloads functions/NAME.fish when NAME is not already
# defined - so dropping --cmd cd would make this file silently never load. There
# is no error and no warning; `z` would just quietly be zoxide. The same trap
# exists in zsh, which is why .zshrc has `unalias z`.
#
# "$@" -> $argv. NOT "$argv": ripgrep needs the pattern and any flags as separate
# arguments, and quoting would collapse them into one.
#
# QUOTING INVARIANT: the entire --preview argument must be SINGLE-quoted. In
# fish, an unquoted {1} / {2} is BRACE EXPANSION and collapses to 1 / 2, so
# `--line-range {2}::4` would degrade to `--line-range 2::4` on every call and
# the preview would silently always start at line 2. Single quotes also keep
# fzf's placeholders intact for fzf's own parser.

function z --description 'ripgrep + fzf + bat: search file contents'
    rg --line-number --no-heading --color=always --smart-case $argv \
        | fzf --ansi --delimiter : \
            --preview 'bat --style=numbers --color=always --line-range {2}::4 --highlight-line {2} {1}'
end
