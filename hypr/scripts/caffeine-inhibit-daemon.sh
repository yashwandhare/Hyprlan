#!/usr/bin/env bash
CACHE_DIR="$HOME/.cache"
STATE_FILE="$CACHE_DIR/caffeine-state"
PID_FILE="$CACHE_DIR/caffeine-inhibit.pid"

[ -f "$STATE_FILE" ] || exit 1
rm -f "$PID_FILE"
echo $$ > "$PID_FILE"

# Ensure hypridle is stopped (no lock screen timeouts)
systemctl --user stop hypridle.service 2>/dev/null

TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << EOF
while [ -f "$STATE_FILE" ]; do
    sleep 1
done
EOF

# Block sleep, suspend, idle, power/lid events - comprehensive lock
systemd-inhibit --what="sleep:shutdown:idle:handle-lid-switch:handle-power-key:handle-suspend-key:handle-hibernate-key" \
    --who="Caffeine" --why="Caffeine mode: no sleep/suspend/lock/idle" --mode=block bash "$TEMP_SCRIPT"

rm -f "$TEMP_SCRIPT" "$PID_FILE"
