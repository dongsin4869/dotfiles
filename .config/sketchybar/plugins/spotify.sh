#!/bin/bash

# Open app on middle click
if [ "$BUTTON" = "other" ]; then
    open -a 'Spotify'
    exit 0
fi

# Toggle play/pause on left click
if [ "$BUTTON" = "left" ]; then
    osascript -e 'tell application "Spotify" to playpause'
fi

# Skip to next song on right click
if [ "$BUTTON" = "right" ]; then
    osascript -e 'tell application "Spotify" to next track'
fi

# Check if Spotify is running first
if ! pgrep -x "Spotify" >/dev/null; then
    sketchybar --set "$NAME" label="Spotify Not Running" icon="􀊄" drawing=on
    exit 0
fi

# Get current track info from Spotify
CURRENT_SONG=$(osascript -e 'tell application "Spotify" to return (name of current track) & " - " & (artist of current track)')
PAUSED=$(osascript -e 'tell application "Spotify" to return player state as string')

if [ "$PAUSED" = "paused" ]; then
    ICON=􀊄
else
    ICON=􁁒
fi

if [ -n "$CURRENT_SONG" ] && [ "$CURRENT_SONG" != " - " ]; then
    sketchybar --set "$NAME" label="$CURRENT_SONG" icon="$ICON" drawing=on
else
    sketchybar --set "$NAME" label="Not Playing" icon="$ICON" drawing=on
fi
