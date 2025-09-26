#!/bin/bash

sketchybar --add item wifi right \
    --subscribe wifi wifi_change \
    --set wifi \
    icon=􀧓 \
    script="$PLUGIN_DIR/wifi.sh"
