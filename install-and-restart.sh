#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER=$(whoami)
SERVICE_NAME="nanobot"

echo "Installing nanobot from $SCRIPT_DIR..."
uv tool install "$SCRIPT_DIR" --force

if [[ "$OSTYPE" == "darwin"* ]]; then
    PLIST="/Library/LaunchDaemons/com.nanobot.gateway.plist"
    if [[ -f "$PLIST" ]]; then
        echo "Stopping launchd service..."
        sudo launchctl unload "$PLIST" 2>/dev/null || true
        echo "Starting launchd service..."
        sudo launchctl load "$PLIST"
        echo "Done. Logs: /tmp/nanobot.log"
    else
        PLIST_USER="$HOME/Library/LaunchAgents/com.nanobot.gateway.plist"
        if [[ -f "$PLIST_USER" ]]; then
            echo "Stopping user launchd service..."
            launchctl unload "$PLIST_USER" 2>/dev/null || true
            echo "Starting user launchd service..."
            launchctl load "$PLIST_USER"
            echo "Done. Logs: /tmp/nanobot.log"
        else
            echo "No launchd plist found. Run manually with: nanobot gateway"
        fi
    fi
else
    if systemctl --user list-unit-files | grep -q "$SERVICE_NAME"; then
        echo "Restarting systemd user service..."
        systemctl --user restart "$SERVICE_NAME"
        echo "Done. Status: systemctl --user status $SERVICE_NAME"
    elif systemctl list-unit-files | grep -q "$SERVICE_NAME"; then
        echo "Restarting systemd system service..."
        sudo systemctl restart "$SERVICE_NAME"
        echo "Done. Status: sudo systemctl status $SERVICE_NAME"
    else
        echo "No systemd service found. Run manually with: nanobot gateway"
    fi
fi
