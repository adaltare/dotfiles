# Deliberately almost empty. Fish sources, in order:
#   1. its own embedded config.fish
#   2. ~/.config/fish/conf.d/*.fish   (alphabetical)
#   3. THIS file
# Because this file runs last, nothing else can depend on it, which makes it a
# bad home for environment or PATH setup. All real configuration lives in
# conf.d/, one topic per file, numerically prefixed where load order matters:
#
#   00-env.fish      PATH, EDITOR, Homebrew, bat  (every fish, incl. `fish -c`)
#   10-zoxide.fish   zoxide + the cd override     (interactive only)
#   20-fzf.fish      FZF_* env + key bindings
#   30-aliases.fish  aliases and abbreviations    (interactive only)
#
# Functions live in functions/ and are autoloaded on first use, so they cost
# nothing at startup: fish_prompt, se, z, login_status.
#
# completions/ is intentionally empty - Homebrew already ships fish completions
# for bun, eza, fd, rg, hx, yadm and zoxide in vendor_completions.d.
#
# fish_variables holds machine-local universal-variable state and is NOT tracked
# by yadm. Never write `set -U` or a bare `fish_add_path` in tracked config: both
# land in that file and would churn on every machine.
#
# This config is an ADDITIVE port of ~/.zshrc, which stays in place and working
# as a fallback. When you change one, check whether the other needs the same
# change.
#
# MAKING FISH THE LOGIN SHELL on a new machine (both need your password, so
# ~/.config/yadm/bootstrap cannot do it - it runs non-interactively from
# launchd). `brew bundle` installs fish; then run:
#     sudo sh -c 'echo /opt/homebrew/bin/fish >> /etc/shells'
#     chsh -s /opt/homebrew/bin/fish

if status is-interactive
    # Nothing yet. Prefer a conf.d/ file over this block.
end
