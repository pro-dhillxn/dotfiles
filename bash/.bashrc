# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# alias ls='ls --color=auto'
# alias grep='grep --color=auto'
# PS1='[\u@\h \W]\$ '
export APPDATA="/mnt/c/Users/USER/AppData/Roaming"
export WINHOME='/mnt/c/Users/USER'
export PATH="$HOME/.local/bin:$PATH"

# Own config
alias n='nvim .'
alias nv='nvim'
alias nvc='nvim --clean'
alias cl='clear'
alias lg='lazygit'
alias oc='opencode'
alias c='claude'
# alias yz='yazi'
alias v='view -'
alias t='tmux'

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
alias ls='eza -lh --group-directories-first --icons=always'
alias lsa='ls -a'
alias lt='eza --tree --group-directories-first --level=2 --long --icons=always --git'  # we can override the depth level by -L<depth>
alias lta='lt -a'


# Repo Aliases
alias db_rep='cd ~/projects/repos/sol/'
alias cc_config='nvim ~/.claude/settings.json'
alias py_auto='python ~/projects/python/automation/mj.py'
alias db_obs_sb='cd ~/projects/obsidian/shipbob'
alias db_obs='cd ~/projects/obsidian/Analytics/Analytics-Per'
# eval "$(zoxide init bash)"

# Starship init
eval "$(starship init bash)"

# default editor
export EDITOR=nvim
export VISUAL=nvim
xdg-open() {
    "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe" "$@"
}
# Command Line
# Enable Git status indicators
# export GIT_PS1_SHOWDIRTYSTATE=1   # Shows * for unstaged, + for staged changes
# export GIT_PS1_SHOWSTASHSTATE=1    # Shows $ if you have stashes
# export GIT_PS1_SHOWUNTRACKEDFILES=1 # Shows % for untracked files
# export GIT_PS1_SHOWUPSTREAM="auto"  # Shows <, >, or = for sync status
#
# # The updated prompt (Path in Green, Git info in Cyan)
# export PS1='\[\033[32m\]\w\[\033[36m\]$(__git_ps1 "(%s)")\[\033[0m\]$ '

# fzf
eval "$(fzf --bash)"

# enabling shell hist
# export HISTSIZE=1000
# export PROMPT_COMMAND="history -a"

# Temporary note / scratchpad command
alias snote='nvim -c "setlocal buftype=nofile" -c "startinsert"'

source $HOME/.config/broot/launcher/bash/br
