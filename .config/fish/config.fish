# Fish config.
# Runs for every fish, so anything slow goes under `status is-interactive`.
# Always use `--global`, never `set -U`/bare fish_add_path: those write to
# fish_variables, which is machine-local and not tracked by yadm.

# --- Environment -------------------------------------------------------------

# Homebrew first, then ~/.local/bin, so ~/.local/bin ends up in front.
set -q HOMEBREW_PREFIX; or /opt/homebrew/bin/brew shellenv fish | source
fish_add_path --global --move --path $HOME/.local/bin

set -gx EDITOR hx
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx BAT_THEME_DARK base16

# fzf. Keep the quotes: unquoted {} is fish brace expansion.
set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
set -gx FZF_DEFAULT_OPTS \
    --reverse --style full --height=12 --prompt= \
    "--preview 'bat -n --color=always --theme=base16 --plain {}'"
set -gx FZF_CTRL_T_OPTS \
    --style=minimal "--prompt='> '" --info=inline-right --height=8 "--preview=''"

if not status is-interactive
    return
end

# --- Interactive -------------------------------------------------------------

fzf --fish | source

# `--cmd cd` keeps the name `z` free for the ripgrep search below.
zoxide init fish --cmd cd | source
function cd --wraps __zoxide_z --description 'zoxide cd; bare cd opens the picker'
    if test (count $argv) -eq 0
        # Same fzf look as Ctrl+T, fed from zoxide's frecency-ordered list.
        set -l dir (zoxide query --list | FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS --scheme=path" fzf)
        and __zoxide_cd $dir
    else
        __zoxide_z $argv
    end
end

alias xdg-open open
alias lg lazygit
alias ls eza
alias ll 'eza --long'
alias la 'eza --all --long'
alias tree 'eza --tree --level 3'

abbr --add sg 'yadm enter lazygit'
abbr --add ss 'yadm bootstrap'

function fish_prompt
    string join '' -- (set_color green) (prompt_pwd --full-length-dirs 2) (set_color --reset) (set_color blue) ' $> '
end

# yadm: fuzzy-pick a tracked dotfile and edit it, with the Ctrl+T fzf look.
function se --description 'yadm: fuzzy-select a tracked file and edit it'
    set -l file (git --git-dir=$HOME/.local/share/yadm/repo.git --work-tree=$HOME -C $HOME ls-files \
        | FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS --scheme=path" fzf)
    and $EDITOR -- $HOME/$file
end

# Search file contents: ripgrep -> fzf, previewed in bat at the matching line.
# Opens the picked matches (Tab to pick several) in $EDITOR at that line and column.
function z --description 'ripgrep + fzf + bat: search file contents and edit'
    set -l hits (rg --line-number --column --no-heading --color=always --smart-case $argv \
        | fzf --ansi --multi --exit-0 --delimiter : \
            --preview 'bat --style=numbers --color=always --line-range {2}::4 --highlight-line {2} {1}')
    # rg exits 1 for "no matches" (2 is an error it has already printed).
    if test $pipestatus[1] -eq 1
        echo "z: no matches for: $argv" >&2
        return 1
    end
    set -q hits[1]; and $EDITOR -- (string replace -r '^(.*?:\d+:\d+):.*' '$1' -- $hits)
end

# Shown when a new interactive shell starts.
function fish_greeting
    login_status
end

# Dotfile / sync health summary.
function login_status --description 'Local dotfile / sync health summary'
    if test -f $HOME/.local/state/login_script.failed
        echo (set_color yellow)"⚠ Failed to sync configs"(set_color normal)"  Check errors with "(set_color cyan)"cat /tmp/login_script.log"(set_color normal)
    end

    # Plain git on yadm's repo: same output as `yadm status`, minus ~185ms of wrapper.
    if set -l lines (git --git-dir=$HOME/.local/share/yadm/repo.git --work-tree=$HOME status --porcelain --branch 2>/dev/null)
        set -l dirty (math (count $lines) - 1)
        set -l ahead 0
        string match -rq -- '\[ahead (?<ahead_n>\d+)\]' $lines[1]; and set ahead $ahead_n
        set -l parts
        test $dirty -gt 0; and set -a parts "$dirty uncommitted"
        test $ahead -gt 0; and set -a parts "$ahead unpushed"
        if set -q parts[1]
            echo (set_color yellow)"⚠ Unsynced configs: "(string join ', ' $parts)(set_color normal)" — review with: "(set_color cyan)"sg"(set_color normal)
        end
    end
end
