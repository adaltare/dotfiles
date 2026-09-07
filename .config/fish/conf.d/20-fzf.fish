# fzf: environment, colours, and key bindings. Port of ~/.zshrc lines 34-64.
#
# `source <(fzf --zsh)` has no fish equivalent - fish has no process
# substitution - so the idiom is `fzf --fish | source`. `fzf --fish` emits BOTH
# halves (key-bindings.fish and completion.fish), same as --zsh.
#
# WHY the env vars are OUTSIDE the is-interactive guard but the source is inside:
# The variables are exported, so a script that runs fzf inherits them and gets
# the same look. The `source` half calls `bind`, which is meaningless (and noisy)
# in a non-interactive shell. Setting the vars first also matters because fzf's
# init inspects FZF_CTRL_T_COMMAND to decide whether to install that binding at
# all.
#
# WHY _gen_fzf_default_opts is gone: in zsh that function existed only to make a
# long export readable, by appending a second block to the first. Fish joins an
# exported list with a single space, so the whole thing is one `set -gx` with one
# element per logical group - fewer moving parts, and no function left lying
# around afterwards.
#
# QUOTING INVARIANTS - all three of these silently corrupt the value if broken:
#   * The --preview element must carry LITERAL single quotes inside it. fzf
#     re-parses FZF_DEFAULT_OPTS with its own quote-aware tokenizer, so it needs
#     to see the quotes; fish must not strip them. Hence "--preview '...'".
#   * {} / {1} / {2} are fish BRACE EXPANSION when unquoted - `{2}` collapses to
#     `2`, so `--line-range {2}::4` would silently become `--line-range 2::4`.
#     The quotes around each element prevent that.
#   * `$` interpolates inside fish double quotes. Nothing here uses `$` today; if
#     a preview command ever needs one, escape it or restructure the element.
#
# Colour scheme is one_dark, matching BAT_THEME_DARK=base16 in 00-env.fish.

set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND

set -gx FZF_DEFAULT_OPTS \
    --reverse --style full --height=12 --prompt= \
    "--preview 'bat -n --color=always --theme=base16 --plain {}'" \
    "--color=bg+:#353b45,bg:#282c34,spinner:#56b6c2,hl:#61afef" \
    "--color=fg:#565c64,header:#61afef,info:#e5c07b,pointer:#56b6c2" \
    "--color=marker:#56b6c2,fg+:#b6bdca,prompt:#e5c07b,hl+:#61afef"

set -gx FZF_CTRL_T_OPTS \
    --style=minimal "--prompt='> '" --info=inline-right --height=8 "--preview=''"

if status is-interactive
    command -q fzf; and fzf --fish | source
end
