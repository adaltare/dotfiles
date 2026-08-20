#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Sync Documents
# @raycast.mode FullOutput

# Optional parameters:
# @raycast.icon 🔄

rclone bisync ~/Documents gdrive:Documents --create-empty-src-dirs --filters-file ~/.config/rclone/doc-filters.txt
