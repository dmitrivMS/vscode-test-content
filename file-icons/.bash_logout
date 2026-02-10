# ~/.bash_logout - executed when a login shell exits

# Clear the terminal screen for security
if [ "$SHLVL" = 1 ]; then
    clear
fi

# Kill any running SSH agent started by this session
if [ -n "$SSH_AGENT_PID" ]; then
    ssh-agent -k > /dev/null 2>&1
fi

# Remove temporary files created during the session
rm -f "$HOME/.bash_history_tmp" 2>/dev/null

# Log the logout time
echo "$(date '+%Y-%m-%d %H:%M:%S') - $USER logged out" >> "$HOME/.logout_log"
