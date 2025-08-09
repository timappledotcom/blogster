#!/bin/bash
# Blogster Launcher Script for GNOME Integration

# Change to the application directory for proper asset loading
cd ~/.local/share/blogster && exec ./blogster "$@"
