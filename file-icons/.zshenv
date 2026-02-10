# ~/.zshenv - Always sourced for every zsh session (interactive or not)

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_STATE_HOME="${HOME}/.local/state"

# Zsh configuration directory
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

# Application defaults
export PAGER="less"
export LESS="-R --quit-if-one-screen"
export MANPAGER="less -X"

# Development environment
export GOPATH="${HOME}/go"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"

# Disable telemetry for common tools
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export HOMEBREW_NO_ANALYTICS=1
