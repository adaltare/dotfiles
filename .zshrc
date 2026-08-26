# $PATH

# Add personal scripts to PATH
export PATH="$HOME/.local/bin:$PATH"

# Add Bun binaries to PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

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
cd() {
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

# Set bat color theme
export BAT_THEME_DARK=base16

# Aliases
alias lg="lazygit"
alias dot="yadm enter lazygit"
alias ls="eza"
alias ll="eza --long"
alias la="eza --all --long"
alias tree="eza --tree --level 3"

# Bun completions
[ -s "/Users/hermits/.bun/_bun" ] && source "/Users/hermits/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"

# Very simple prompt
autoload -U colors && colors
PROMPT="%{$fg[green]%}%2~ %{$fg[blue]%}$>%{$reset_color%} "

# Status summary shown at the top of every new shell. This runs on every
# shell start, so every check here must be local and fast - no network, no
# fetches. Total cost is ~0.2s, nearly all of it the single yadm call.
_login_status() {
  # The marker is written by ~/.config/yadm/bootstrap and cleared on its next
  # successful run, so a failure keeps showing until it's actually fixed.
  local boot_failed=0
  [[ -f "$HOME/.local/state/login_script.failed" ]] && boot_failed=1

  # One `yadm status --porcelain --branch` yields both the uncommitted count
  # and the ahead count; running status and rev-list separately cost twice as
  # much. Note "up to date" here means nothing local is outstanding - it says
  # nothing about being behind origin, since detecting that needs a fetch.
  local yadm_ok=0 dirty=0 ahead=0 out branch_line
  local -a lines
  if out=$(yadm status --porcelain --branch 2>/dev/null); then
    yadm_ok=1
    lines=("${(@f)out}")
    branch_line=${lines[1]}
    dirty=$(( ${#lines} - 1 ))
    if [[ $branch_line == *'[ahead '* ]]; then
      ahead=${branch_line#*\[ahead }
      ahead=${ahead%%[^0-9]*}
    fi
  fi

  # rclone bisync has its own LaunchAgent running every 5 minutes. launchd
  # remembers the last run's exit status, which is a far better signal than
  # grepping its error log - that log is mostly harmless NOTICE lines.
  local rclone_exit
  rclone_exit=$(launchctl print "gui/${UID}/com.user.rclonebisync" 2>/dev/null \
    | awk '/last exit code =/ {print $NF; exit}')

  if (( boot_failed )); then
    print -P "%F{yellow}⚠ config sync failed%f — check it with: %F{cyan}cat /tmp/login_script.log%f"
  elif (( yadm_ok && dirty == 0 && ahead == 0 )); then
    print -P "%F{green}✓ config up to date%f"
  fi

  if (( yadm_ok && (dirty > 0 || ahead > 0) )); then
    local -a parts
    (( dirty > 0 )) && parts+="$dirty uncommitted"
    (( ahead > 0 )) && parts+="$ahead unpushed"
    print -P "%F{yellow}⚠ config sync: ${(j:, :)parts}%f — review with: %F{cyan}s g%f"
  fi

  if [[ -n $rclone_exit && $rclone_exit != 0 ]]; then
    print -P "%F{yellow}⚠ rclone bisync failed%f — check it with: %F{cyan}tail -20 /tmp/rclone-bisync-error.log%f"
  fi
}
_login_status
unset -f _login_status

# Search with ripgrep, select results with fzf, preview with bat showing context
z() {
    rg --line-number --no-heading --color=always --smart-case "$@" | \
    fzf --ansi --delimiter : --preview 'bat --style=numbers --color=always --line-range {2}::4 --highlight-line {2} {1}'
}
