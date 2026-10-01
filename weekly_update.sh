#!/bin/bash
#
# Weekly crawl + localize + publish pipeline for doctruyen14.
# Invoked by launchd (com.doctruyen14.weeklyupdate) every Sunday at 16:00.

set -uo pipefail

PROJECT_DIR="/Users/cuongtm/Downloads/us.sitesucker.mac.sitesucker-pro/doctruyen14"
LOG_FILE="$PROJECT_DIR/weekly_update.log"

cd "$PROJECT_DIR" || exit 1

exec >> "$LOG_FILE" 2>&1

echo "===== Run started at $(date "+%Y-%m-%d %H:%M:%S") ====="

# Keep the Mac awake until this script exits. The 15:59 scheduled wake only
# lasts ~1 minute before idle sleep kicks in, which stalls SiteSucker mid-crawl
# and makes osascript fail with "AppleEvent timed out (-1712)".
# -u/-d also turn the display on and keep it on: with no active display,
# SiteSucker stops responding to Apple Events right after launch.
caffeinate -dimsu -w $$ &

git pull
status=$?
if [ $status -ne 0 ]; then
    echo "ERROR: git pull failed with status $status"
    exit 1
fi

# A SiteSucker instance left over from a failed run may be stuck behind a modal
# panel and would swallow our Apple Events, so always start from a fresh launch.
# (The launch-time Open panel itself is disabled via:
#  defaults write us.sitesucker.mac.sitesucker-pro NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false)
if pgrep -x "SiteSucker Pro" > /dev/null; then
    echo "Found a running SiteSucker Pro instance, quitting it first."
    pkill -x "SiteSucker Pro"
    sleep 5
fi

osascript doctruyen14_weekly.scpt
status=$?
if [ $status -ne 0 ]; then
    echo "ERROR: osascript doctruyen14_weekly.scpt failed with status $status"
    pkill -x "SiteSucker Pro"
    exit 1
fi

./5_localize.sh
status=$?
if [ $status -ne 0 ]; then
    echo "ERROR: 5_localize.sh failed with status $status"
    exit 1
fi

./tags_categories.sh
status=$?
if [ $status -ne 0 ]; then
    echo "ERROR: tags_categories.sh failed with status $status"
    exit 1
fi

git add -A

if git diff --cached --quiet; then
    echo "No changes to commit."
else
    if git commit -m "Update $(date "+%d/%m/%Y")"; then
        if git push; then
            echo "Pushed successfully."
        else
            echo "ERROR: git push failed."
            exit 1
        fi
    else
        echo "ERROR: git commit failed."
        exit 1
    fi
fi

echo "===== Run finished at $(date "+%Y-%m-%d %H:%M:%S") ====="
