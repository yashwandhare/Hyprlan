#!/usr/bin/env bash
CACHE_DIR="$HOME/.cache"
STATE_FILE="$CACHE_DIR/caffeine-state"
PID_FILE="$CACHE_DIR/caffeine-inhibit.pid"

[ -f "$STATE_FILE" ] || exit 1
rm -f "$PID_FILE"
echo $$ > "$PID_FILE"

TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << EOF
while [ -f "$STATE_FILE" ]; do
    sleep 1
done
EOF

systemd-inhibit --what="sleep:handle-lid-switch:handle-power-key" --who="Caffeine" \
    --why="Caffeine mode: prevent sleep/suspend/lock" --mode=block bash "$TEMP_SCRIPT"

rm -f "$TEMP_SCRIPT" "$PID_FILE"
