#!/bin/bash
#
# Daily crawl + localize + publish pipeline for doctruyen14.
# Invoked by launchd (com.doctruyen14.dailyupdate) every day at 16:00.

set -uo pipefail

PROJECT_DIR="/Users/cuongtm/Downloads/us.sitesucker.mac.sitesucker-pro/doctruyen14"
LOG_FILE="$PROJECT_DIR/daily_update.log"

cd "$PROJECT_DIR" || exit 1

exec >> "$LOG_FILE" 2>&1

echo "===== Run started at $(date "+%Y-%m-%d %H:%M:%S") ====="

git pull
status=$?
if [ $status -ne 0 ]; then
    echo "ERROR: git pull failed with status $status"
    exit 1
fi

osascript doctruyen14.scpt
status=$?
if [ $status -ne 0 ]; then
    echo "ERROR: osascript doctruyen14.scpt failed with status $status"
    exit 1
fi

./5_localize.sh
status=$?
if [ $status -ne 0 ]; then
    echo "ERROR: 5_localize.sh failed with status $status"
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
