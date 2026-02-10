# ~/.zshrc - Interactive shell configuration

autoload -Uz compinit && compinit
autoload -Uz vcs_info

# History settings
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt append_history share_history hist_ignore_dups

# Prompt with git branch
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
PROMPT='%F{cyan}%~%f%F{yellow}${vcs_info_msg_0_}%f %# '

# Useful aliases
alias ls='ls --color=auto'
alias ll='ls -lAh'
alias grep='grep --color=auto'
alias g='git'
alias gst='git status'
alias gco='git checkout'

# Key bindings
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
