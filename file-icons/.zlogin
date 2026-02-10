# ~/.zlogin - Executed for login shells after .zshrc

# Compile zcompdump for faster startup
if [[ -s "${ZDOTDIR:-$HOME}/.zcompdump" && (! -s "${ZDOTDIR:-$HOME}/.zcompdump.zwc" || \
    "${ZDOTDIR:-$HOME}/.zcompdump" -nt "${ZDOTDIR:-$HOME}/.zcompdump.zwc") ]]; then
    zcompile "${ZDOTDIR:-$HOME}/.zcompdump"
fi

# Print system info on login
echo "Welcome back, $USER!"
echo "Host: $(hostname)"
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
echo "Date: $(date '+%A, %B %d %Y %H:%M')"

# Start ssh-agent if not running
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
