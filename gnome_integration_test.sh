#!/bin/bash

# GNOME Dock Integration Test for Blogster

echo "🔍 GNOME Dock Integration Diagnostics"
echo "======================================"

# Check desktop file
echo "📋 Desktop File Check:"
if [ -f ~/.local/share/applications/blogster.desktop ]; then
    echo "  ✓ Desktop file exists"
    echo "  📍 Content check:"
    grep -E "(Name=|Exec=|Icon=|StartupWMClass=)" ~/.local/share/applications/blogster.desktop | sed 's/^/    /'
else
    echo "  ❌ Desktop file missing"
fi

# Check icons
echo ""
echo "🎨 Icon Check:"
if [ -f ~/.local/share/icons/hicolor/64x64/apps/blogster.png ]; then
    echo "  ✓ Icon files exist"
    echo "  📍 Icon sizes available:"
    find ~/.local/share/icons/hicolor -name "blogster.png" | wc -l | sed 's/^/    /'
else
    echo "  ❌ Icon files missing"
fi

# Check if app is in GNOME's database
echo ""
echo "🔍 GNOME Database Check:"
if command -v gio >/dev/null 2>&1; then
    gio list applications | grep -i blogster && echo "  ✓ Found in GNOME applications" || echo "  ⚠️  Not found in GNOME database"
fi

# Manual launch test
echo ""
echo "🚀 Launch Test:"
echo "  Starting Blogster..."
~/.local/bin/blogster &
LAUNCH_PID=$!
echo "  📍 PID: $LAUNCH_PID"

# Wait and check if it's running
sleep 2
if kill -0 $LAUNCH_PID 2>/dev/null; then
    echo "  ✅ Blogster is running successfully"
    
    # Check window properties after a moment
    sleep 2
    echo ""
    echo "🪟 Window Properties Check:"
    # Try to find the window
    if command -v wmctrl >/dev/null 2>&1; then
        wmctrl -l | grep -i blogster && echo "  ✓ Window found by wmctrl" || echo "  ⚠️  Window not found by wmctrl"
    else
        echo "  ℹ️  wmctrl not available for window detection"
    fi
    
else
    echo "  ❌ Blogster failed to start"
fi

echo ""
echo "📋 Recommendations:"
echo "  1. Restart GNOME Shell: Alt+F2, type 'r', press Enter"
echo "  2. Log out and log back in"
echo "  3. Search 'Blogster' in Activities overview"
echo "  4. Right-click running app in dock and select 'Add to Favorites'"

echo ""
echo "🎯 Manual Steps to Add to Dock:"
echo "  1. Press Super key (Windows key)"
echo "  2. Type 'Blogster'"
echo "  3. Right-click the Blogster icon"
echo "  4. Select 'Add to Favorites'"
