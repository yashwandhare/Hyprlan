#!/usr/bin/env bash

if systemctl --user is-active --quiet caffeine-inhibit.service; then
    echo '{"text": "", "tooltip": "Caffeine: Enabled", "class": "active"}'
else
    echo '{"text": "", "tooltip": "", "class": ""}'
fi