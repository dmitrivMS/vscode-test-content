# ~/.bash_profile - executed for login shells

# Set locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Paths
export PATH="$HOME/.local/bin:$HOME/go/bin:/usr/local/bin:$PATH"
export GOPATH="$HOME/go"
export CARGO_HOME="$HOME/.cargo"

# History settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups

# Enable color support
export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# Source bashrc for interactive settings
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
