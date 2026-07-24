# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


# Own config
alias n='nvim .'
alias nv='nvim'
alias nvc='nvim --clean'
alias cl='clear'
alias lg='lazygit'
alias oc='opencode'
alias c='claude'
alias v='view -'
alias t='tmux'
alias pya='python /mnt/c/Users/USER/Projects/Python/Automation/mj.py'
alias ex='explorer.exe'

# Yazi to cd into directory as we exit it
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

# activate python venv
alias av='source .venv/bin/activate'
alias dv='deactivate'

# cd Aliases, eza
alias ..='cd ../'
alias ...='cd ../..'
alias ls='eza -lh --group-directories-first --icons=always --git'
alias lsa='ls -a'
alias lt='eza --tree --group-directories-first --level=2 --long --icons=always --git'  # we can override the depth level by -L<depth>
alias lta='lt -a'

# Starship init
eval "$(starship init bash)"

# default editor
export EDITOR=nvim
export VISUAL=nvim

# fzf
eval "$(fzf --bash)"


# Temporary note / scratchpad command
alias snote='nvim -c "setlocal buftype=nofile" -c "startinsert"'

[ -f ~/.bashrc.local ] && source ~/.bashrc.local

# enabling vi mode
set -o vi

export PATH="$HOME/.local/bin:$PATH"
