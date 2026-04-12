# Add PHP exacutables to PATH
export PATH="$PATH:/opt/homebrew/opt/php@8.2/bin"
export PATH="$PATH:/opt/homebrew/opt/php@8.2/sbin"
export PATH="$PATH:$HOME/.composer/vendor/bin"

# Add Go binaries to PATH
export PATH="$PATH:$HOME/go/bin"

# Set my favorite editor
export EDITOR=zed

# Aliases
alias lg="lazygit"
alias art="php artisan"
alias dot="yadm enter lazygit"

# Bun completions
[ -s "/Users/hermits/.bun/_bun" ] && source "/Users/hermits/.bun/_bun"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$PATH:$BUN_INSTALL/bin"

if [[ $IN_ZED == true ]]; then
    # Very simple prompt
    autoload -U colors && colors
    PROMPT="%{$fg[green]%}$> %{$reset_color%}"
else
    # Starship Prompt
    # The minimal, blazing-fast, and infinitely customizable prompt for any shell!
    eval "$(starship init zsh)"
fi
