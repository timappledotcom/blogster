#!/bin/bash

# Blogster Cleanup and Reinstall Script
# Ensures only one clean installation exists

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 Blogster Cleanup Script${NC}"
echo "=================================="

# Function to safely remove files
safe_remove() {
    if [ -f "$1" ] || [ -d "$1" ]; then
        echo -e "${YELLOW}  🗑️  Removing: $1${NC}"
        rm -rf "$1"
    fi
}

# Kill any running Blogster processes
echo -e "${YELLOW}🔄 Stopping any running Blogster processes...${NC}"
pkill -f "blogster" 2>/dev/null || echo "  ✓ No running processes found"

# Clean up potential installation locations
echo -e "${YELLOW}🧹 Cleaning up old installations...${NC}"

# Remove system-wide installations (if any exist)
if [ -f "/usr/share/applications/blogster.desktop" ]; then
    echo -e "${RED}⚠️  Found system-wide desktop file. You may need sudo to remove it.${NC}"
    echo "  Run: sudo rm /usr/share/applications/blogster.desktop"
fi

if ls /usr/share/icons/hicolor/*/apps/blogster.png >/dev/null 2>&1; then
    echo -e "${RED}⚠️  Found system-wide icons. You may need sudo to remove them.${NC}"
    echo "  Run: sudo find /usr/share/icons/hicolor -name 'blogster.png' -delete"
fi

# Remove user installations
echo -e "${YELLOW}📁 Cleaning user installation directories...${NC}"

# Remove old local installations
safe_remove "$HOME/.local/share/blogster"
safe_remove "$HOME/.local/share/applications/blogster.desktop"
safe_remove "$HOME/.local/bin/blogster"

# Remove old icons
echo -e "${YELLOW}🎨 Removing old icons...${NC}"
find "$HOME/.local/share/icons/hicolor" -name "blogster.png" -delete 2>/dev/null || true

# Clean up any old run scripts in the project
echo -e "${YELLOW}🧹 Cleaning project directory...${NC}"
safe_remove "/home/tim/Dev/blogster/run_blogster.sh"

# Update databases
echo -e "${YELLOW}🔄 Updating system databases...${NC}"
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" 2>/dev/null || echo "  ✓ Icon cache updated"
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || echo "  ✓ Desktop database updated"

echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo ""

# Now reinstall
echo -e "${BLUE}🚀 Reinstalling Blogster...${NC}"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "/home/tim/Dev/blogster/install.sh" ]; then
    echo -e "${RED}❌ Error: install.sh not found. Please run from Blogster project directory.${NC}"
    exit 1
fi

# Run the installation script
cd /home/tim/Dev/blogster
./install.sh

echo ""
echo -e "${GREEN}🎉 Clean installation complete!${NC}"
echo -e "${BLUE}ℹ️  You now have exactly one Blogster installation in ~/.local/share/blogster${NC}"
