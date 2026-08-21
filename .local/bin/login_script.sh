#!/usr/bin/env bash
#
# login_script.sh - tasks to run once per login, via the com.user.login_script
# LaunchAgent (~/Library/LaunchAgents/com.user.login_script.plist).
#
# launchd runs this with a minimal environment, so PATH is set explicitly
# below rather than relying on ~/.zshrc. Add further login tasks here.
#
# Logs: /tmp/login_script.log and /tmp/login_script_error.log

export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"

echo "=== [$(date)] login_script.sh started"

yadm bootstrap

echo "=== [$(date)] login_script.sh finished"
