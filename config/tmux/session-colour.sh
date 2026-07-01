#!/usr/bin/env bash
# ~/.config/tmux/session-colour.sh
#
# Gives each tmux session a stable accent colour based on its creation order,
# so you can tell sessions apart at a glance in the status bar.
# Session 1 = blue, Session 2 = green, Session 3 = orange, then repeats.
#
# Run automatically by tmux.conf on client-session-changed / session-created.

set -euo pipefail

colours=(
  "#81A1C1"  # blue
  "#A3BE8C"  # green
  "#D08770"  # orange
)
gray_light="#D8DEE9"

session="$(tmux display-message -p '#S')"

# Rank of this session by creation time among all current sessions (1-indexed)
index="$(tmux list-sessions -F '#{session_created} #{session_name}' \
    | sort -n \
    | awk '{print $2}' \
    | grep -n -x -F "$session" \
    | head -1 \
    | cut -d: -f1)"
[[ -z "$index" ]] && index=1

colour="${colours[$(( (index - 1) % ${#colours[@]} ))]}"

tmux set-option -t "$session" status-left "#[fg=${colour},bold] #S #[fg=${gray_light},nobold]| "
tmux set-option -t "$session" window-status-current-format "#[fg=${colour},bold] #[underscore]#I:#W"
tmux set-option -t "$session" pane-active-border-style "fg=${colour}"
