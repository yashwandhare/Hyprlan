#!/usr/bin/env bash

# -----------------------------------------------------
# Caffeine Inhibit Daemon
# Blocks sleep, suspend, lid-switch, power-key via systemd
# Runs in background; stays active while caffeine state file exists
# Kill this process to release inhibitions
# -----------------------------------------------------

CACHE_DIR="$HOME/.cache"
STATE_FILE="$CACHE_DIR/caffeine-state"
PID_FILE="$CACHE_DIR/caffeine-inhibit.pid"

# Exit if state file doesn't exist (caffeine not enabled)
[ -f "$STATE_FILE" ] || exit 1

# Remove old PID file if it exists
rm -f "$PID_FILE"

# Store this script's PID so it can be killed later
echo $$ > "$PID_FILE"

# Run systemd-inhibit to block sleep, lid-close, power-key
# Create a temp script to avoid quoting issues
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << EOF
while [ -f "$STATE_FILE" ]; do
    sleep 1
done
EOF

# Use --what with colon-separated operations
systemd-inhibit \
    --what="sleep:handle-lid-switch:handle-power-key" \
    --who="Caffeine" \
    --why="Caffeine mode: prevent sleep/suspend/lock" \
    --mode=block \
    bash "$TEMP_SCRIPT"

rm -f "$TEMP_SCRIPT"

# Cleanup PID file when exiting
rm -f "$PID_FILE"
