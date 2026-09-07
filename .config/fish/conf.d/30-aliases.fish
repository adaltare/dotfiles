# Aliases and abbreviations. Port of ~/.zshrc lines 69-82.
#
# WHY is-interactive: .zshrc is an interactive-only file, so these were never
# available to scripts in zsh either. Guarding them keeps `fish -c` cheap - which
# matters because fzf's history preview spawns `fish -c` per keystroke.
#
# WHY alias vs abbr:
#   alias  -> anything composed into a pipeline or called by another function.
#             Fish's `alias` is sugar for a function plus --wraps, so `ls`
#             inherits eza's completions for free.
#   abbr   -> the yadm shortcuts. These are never piped, and having the real
#             command expand in the buffer before you hit enter is worth having
#             for `yadm bootstrap`.
#
# NOT HERE: `se`. It is a pipeline, and fish's `alias` ALWAYS appends `$argv` to
# the body - it does so even when the body already mentions $argv - which would
# silently tack stray arguments onto the xargs stage, and it would set --wraps to
# the whole pipeline string. See functions/se.fish.

if status is-interactive
    alias xdg-open open
    alias lg lazygit

    alias ls eza
    alias ll 'eza --long'
    alias la 'eza --all --long'
    alias tree 'eza --tree --level 3'

    # yadm shortcuts: (s)tatus/git and (s)etup.
    # (s)elect-and-edit is functions/se.fish.
    abbr --add sg 'yadm enter lazygit'
    abbr --add ss 'yadm bootstrap'
end
