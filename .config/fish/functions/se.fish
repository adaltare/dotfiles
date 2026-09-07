# yadm (s)elect-and-edit: fuzzy-pick a tracked dotfile and open it in $EDITOR.
# Port of the `se` alias in ~/.zshrc.
#
# WHY a function file and not an alias: fish's `alias` ALWAYS appends `$argv` to
# the body - it does so even when the body already contains $argv - so
# `alias se '... | xargs -0 -o -- $EDITOR'` silently becomes
# `... | xargs -0 -o -- $EDITOR $argv`, and it sets --wraps to the whole pipeline
# string, poisoning completions.
#
# The zsh version was single-quoted so $HOME and $EDITOR resolved at call time
# rather than at source time. In fish that concern disappears: a function body is
# parsed once but evaluated on every call, so $EDITOR is always current.
#
# INVARIANTS (all three are load-bearing on macOS):
#   --print0 / -0  : yadm tracks paths with spaces (Library/Application Support).
#                    NUL-delimited on both sides, or that splits into two names.
#   xargs -o       : BSD xargs. Reopens stdin as /dev/tty in the child, without
#                    which hx starts on a closed stdin and immediately exits.
#                    GNU xargs spells it -o too, but it is not POSIX; do not
#                    "clean it up".
#   --             : stops $EDITOR from eating a filename that starts with `-`.
#
# Takes no arguments; $argv is deliberately unused.

function se --description 'yadm: fuzzy-select a tracked file and edit it'
    yadm -C $HOME ls-files | fzf --print0 | xargs -0 -o -- $EDITOR
end
