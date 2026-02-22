#!/usr/bin/env bash
updates_pacman=$(checkupdates 2>/dev/null | wc -l)
updates_aur=$(paru -Qua 2>/dev/null | grep -v "\[ignored\]" | wc -l)
updates=$((updates_pacman + updates_aur))
printf '{"text": "%s", "alt": "%s", "tooltip": "%s updates"}' "$updates" "$updates" "$updates"
