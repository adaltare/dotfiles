# $PATH
# Add PHP exacutables to PATH
export PATH="$PATH:/opt/homebrew/opt/php@8.2/bin"
export PATH="$PATH:/opt/homebrew/opt/php@8.2/sbin"
export PATH="$PATH:$HOME/.composer/vendor/bin"
export PATH="$PATH:$BUN_INSTALL/bin"
# Add Bun binaries to PATH
export PATH="$PATH:$BUN_INSTALL/bin"
# Add Go binaries to PATH
export PATH="$PATH:$HOME/go/bin"

# Set preferred editor
export EDITOR=zed

# zoxide
# A smarter cd command, inspired by z and autojump.
# It remembers which directories you use most frequently, so you can "jump" to
# them in just a few keystrokes. zoxide works on all major shells.
eval "$(zoxide init zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Aliases
alias lg="lazygit"
alias art="php artisan"
alias dot="yadm enter lazygit"
alias cd="z"

# Bun completions
[ -s "/Users/hermits/.bun/_bun" ] && source "/Users/hermits/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"

if [[ $IN_ZED == true ]]; then
    # Very simple prompt
    autoload -U colors && colors
    PROMPT="%{$fg[green]%}$> %{$reset_color%}"
else
    # Starship Prompt
    # The minimal, blazing-fast, and infinitely customizable prompt for any shell!
    eval "$(starship init zsh)"
fi
