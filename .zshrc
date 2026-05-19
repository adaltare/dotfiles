# $PATH
# Add Bun binaries to PATH
# export PATH="$PATH:$BUN_INSTALL/bin"
# Add Go binaries to PATH
# export PATH="$PATH:$HOME/go/bin"

# Set preferred editor
export EDITOR=hx

# zoxide
# A smarter cd command, inspired by z and autojump.
# It remembers which directories you use most frequently, so you can "jump" to
# them in just a few keystrokes. zoxide works on all major shells.
eval "$(zoxide init zsh)"
unalias z 2> /dev/null
unalias zi 2> /dev/null
j() {
  if [ $# -gt 0 ]; then
    __zoxide_z "$*"
  else
    __zoxide_zi "$@"
  fi
}

# Hide homebrew's auto-update message
export HOMEBREW_NO_AUTO_UPDATE=1

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--reverse --style full --height=12 --prompt= --preview 'bat -n --color=always --theme=base16 --plain {}'"
export FZF_CTRL_T_OPTS="--style=minimal --prompt='> ' --info=inline-right --height=8 --preview=''"

# Fzf color scheme
_gen_fzf_default_opts() {
  local color00='#282c34'
  local color01='#353b45'
  local color02='#3e4451'
  local color03='#545862'
  local color04='#565c64'
  local color05='#abb2bf'
  local color06='#b6bdca'
  local color07='#c8ccd4'
  local color08='#e06c75'
  local color09='#d19a66'
  local color0A='#e5c07b'
  local color0B='#98c379'
  local color0C='#56b6c2'
  local color0D='#61afef'
  local color0E='#c678dd'
  local color0F='#be5046'
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS
   --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D
   --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C
   --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D"
}
_gen_fzf_default_opts

# Add this function to ~/.zshrc
fuzzyfind-tracked-configs() {
  $EDITOR "$(yadm ls-files | fzf)"
}
zle -N fuzzyfind-tracked-configs
bindkey '^o' fuzzyfind-tracked-configs  # Press Ctrl+O to trigger

# Set bat color theme
export BAT_THEME_DARK=base16

# Aliases
alias lg="lazygit"
alias dot="yadm enter lazygit"

# Bun completions
[ -s "/Users/hermits/.bun/_bun" ] && source "/Users/hermits/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"

if [[ $IN_ZED == true ]]; then
    # Very simple prompt
    autoload -U colors && colors
    PROMPT="%{$fg[green]%}$> %{$reset_color%}"
else
    # Very simple prompt
    autoload -U colors && colors
    PROMPT="%{$fg[green]%}%2~ %{$fg[blue]%}$>%{$reset_color%} "
    # Starship Prompt
    # The minimal, blazing-fast, and infinitely customizable prompt for any shell!
    # eval "$(starship init zsh)"
fi

# Search with ripgrep, select results with fzf, preview with bat showing context
z() {
    rg --line-number --no-heading --color=always --smart-case "$@" | \
    fzf --ansi --delimiter : --preview 'bat --style=numbers --color=always --line-range {2}::4 --highlight-line {2} {1}'
}
