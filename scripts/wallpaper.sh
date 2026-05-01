#!/usr/bin/env bash

# Quote the variable to safely handle any spaces in the filename
Wallpaper="$1"

# Use the quoted variable in your command
awww img "$Wallpaper" --transition-step 255 --transition-fps 60 --transition-duration 1.4 --transition-type any
