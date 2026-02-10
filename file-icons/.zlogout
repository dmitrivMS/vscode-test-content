# ~/.zlogout - Executed when a login shell exits

# Clear the terminal
clear

# Kill any lingering ssh-agent processes
if [[ -n "$SSH_AGENT_PID" ]]; then
    eval "$(ssh-agent -k)" > /dev/null 2>&1
fi

# Remove temporary files
rm -f ~/.zsh_tmp_* 2>/dev/null
rm -f /tmp/zsh-${USER}-* 2>/dev/null

# Log the logout time
echo "$(date '+%Y-%m-%d %H:%M:%S') - $USER logged out" >> ~/.logout_log

echo "Session ended. Goodbye!"
