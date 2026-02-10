# ~/.zprofile - Executed for login shells before .zshrc

# Set default editor
export EDITOR="vim"
export VISUAL="code"

# Homebrew setup (macOS)
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Add local bin directories to PATH
typeset -U path
path=(
    $HOME/.local/bin
    $HOME/.cargo/bin
    $HOME/go/bin
    /usr/local/bin
    $path
)
export PATH

# Set language and locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
