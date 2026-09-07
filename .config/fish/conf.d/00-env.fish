# Environment and PATH. Fish equivalent of ~/.zprofile + the top of ~/.zshrc.
#
# WHY conf.d and not `status is-login`:
# Fish has no .zshenv/.zprofile/.zshrc split. conf.d/ is the closest thing to
# .zshenv: it runs for EVERY fish process - login, interactive, and `fish -c`.
# That is what we want for PATH, because the shells that most need Homebrew on
# PATH are often NOT login shells: Zed and VS Code integrated terminals, fish
# scripts, and anything launchd spawns. Gating this on `status is-login` would
# leave those with the bare macOS PATH (/usr/bin /bin /usr/sbin /sbin - fish
# does not add Homebrew on its own).
#
# The flip side: this file is on the hot path of every `fish -c`, including the
# subshells fzf spawns for history previews. Keep it to variable assignments.
# Nothing here may fork, hit the network, or touch disk beyond what
# fish_add_path already does.
#
# INVARIANT - order is load-bearing:
#   brew shellenv emits `fish_add_path --global --move --path`, and --move
#   RE-ORDERS entries that are already present. So Homebrew must go first and
#   ~/.local/bin second; reverse them and every shell start would shuffle
#   ~/.local/bin behind /opt/homebrew/bin. Final order matches zsh:
#   ~/.local/bin, then /opt/homebrew/{bin,sbin}, then the system paths.
#
# GOTCHA - `--global` is mandatory:
#   A bare `fish_add_path X` writes a UNIVERSAL fish_user_paths, which fish
#   persists into ~/.config/fish/fish_variables. That file is machine-local
#   state living inside a yadm-tracked directory; it would churn on every
#   machine and would survive deleting this file. Always pass --global.
#
# GOTCHA - do NOT translate `export PATH="$HOME/.local/bin:$PATH"` literally.
#   Fish has an `export` compatibility function and it happens to work, so you
#   would never notice - but it appends unconditionally, so nested shells
#   accumulate duplicate entries. fish_add_path deduplicates and silently
#   ignores directories that do not exist.

# Only pay for brew shellenv once per process tree. HOMEBREW_PREFIX is exported,
# so any nested fish already has a correct PATH inherited from its parent. This
# costs ~12ms in the outermost shell and 0 everywhere else.
if not set -q HOMEBREW_PREFIX
    /opt/homebrew/bin/brew shellenv fish | source
end

# Personal scripts. Added AFTER Homebrew so it lands in front of it.
#
# --move is required, not decorative. Without it, fish_add_path is a no-op when
# the entry is ALREADY in PATH - which is exactly the case when fish is started
# from a zsh that has run .zshrc. brew shellenv's own `--move` will by then have
# yanked /opt/homebrew/bin to the front, past ~/.local/bin, and this line would
# silently decline to fix it. --move makes the final order deterministic whether
# fish is the login shell or a nested shell.
fish_add_path --global --move --path $HOME/.local/bin

# Bun. NOTE: bun currently comes from Homebrew and ~/.bun/bin does not exist -
# only ~/.bun/install. This line is kept because fish_add_path ignores
# non-existent directories, so it is a free no-op that starts working if bun is
# ever reinstalled via its own installer.
# The zsh `[ -s "/Users/hermits/.bun/_bun" ] && source ...` line was already
# dead code (wrong username, and _bun is zsh-only) and is deliberately not
# ported; Homebrew already ships vendor_completions.d/bun.fish.
set -gx BUN_INSTALL $HOME/.bun
fish_add_path --global --move --path $BUN_INSTALL/bin

# Preferred editor. Exported so it is picked up by yadm, lazygit, git and `se`.
set -gx EDITOR hx

# Homebrew's auto-update on every invocation is slow and surprising.
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# bat's theme when the terminal reports a dark background. Also drives the fzf
# previews configured in 20-fzf.fish.
set -gx BAT_THEME_DARK base16
