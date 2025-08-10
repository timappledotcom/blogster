#!/bin/bash

# Blogster Installation Script
# This script installs Blogster with proper system integration

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="blogster"
VERSION="0.2.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Blogster Installation Script v${VERSION}${NC}"
echo "=================================================="

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ] || [ ! -d "assets/icons" ]; then
    echo -e "${RED}❌ Error: Please run this script from the Blogster project root directory${NC}"
    exit 1
fi

# Build the application
echo -e "${YELLOW}🔨 Building Blogster...${NC}"
flutter build linux --release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed. Please fix any build errors and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful${NC}"

# Installation directories
INSTALL_DIR="$HOME/.local/share/blogster"
ICONS_DIR="$HOME/.local/share/icons/hicolor"
APPS_DIR="$HOME/.local/share/applications"
BIN_DIR="$HOME/.local/bin"

# Create directories
echo -e "${YELLOW}📁 Creating installation directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$ICONS_DIR"/{16x16,22x22,24x24,32x32,48x48,64x64,128x128,256x256,512x512}/apps
mkdir -p "$APPS_DIR"
mkdir -p "$BIN_DIR"

# Copy application files
echo -e "${YELLOW}📦 Installing application files...${NC}"
cp -r build/linux/x64/release/bundle/* "$INSTALL_DIR/"

# Install icons
echo -e "${YELLOW}🎨 Installing icons...${NC}"
for size in 16 22 24 32 48 64 128 256 512; do
    if [ -f "assets/icons/blogster-${size}.png" ]; then
        cp "assets/icons/blogster-${size}.png" "$ICONS_DIR/${size}x${size}/apps/blogster.png"
        echo "  ✓ Installed ${size}x${size} icon"
    fi
done

# Create launcher script
echo -e "${YELLOW}📝 Creating launcher script...${NC}"
cat > "$BIN_DIR/blogster" << EOF
#!/bin/bash
# Blogster Launcher Script
cd "$INSTALL_DIR" && ./blogster "\$@"
EOF

chmod +x "$BIN_DIR/blogster"

# Create desktop file
echo -e "${YELLOW}🖥️  Creating desktop file...${NC}"
cat > "$APPS_DIR/blogster.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Blogster
GenericName=Markdown Editor
Comment=Beautiful markdown editor for modern writers with Ubuntu design
Exec=$BIN_DIR/blogster
Icon=blogster
Terminal=false
Categories=Office;TextEditor;Development;
MimeType=text/markdown;text/plain;
Keywords=markdown;editor;blog;writing;nostr;
StartupNotify=true
StartupWMClass=com.example.blogster
EOF

# Update system databases
echo -e "${YELLOW}🔄 Updating system databases...${NC}"
gtk-update-icon-cache "$ICONS_DIR" 2>/dev/null || echo "  ⚠️  Could not update icon cache"
update-desktop-database "$APPS_DIR" 2>/dev/null || echo "  ⚠️  Could not update desktop database"

# Add to PATH if needed
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "${YELLOW}📋 Adding $BIN_DIR to PATH...${NC}"
    
    # Add to .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        echo "" >> "$HOME/.bashrc"
        echo "# Add local bin to PATH for Blogster" >> "$HOME/.bashrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
    fi
    
    # Add to .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        echo "" >> "$HOME/.zshrc"
        echo "# Add local bin to PATH for Blogster" >> "$HOME/.zshrc"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
    fi
    
    echo "  ✓ Added to shell configuration files"
    echo "  ℹ️  Please restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
fi

# Create uninstall script
echo -e "${YELLOW}🗑️  Creating uninstall script...${NC}"
cat > "$INSTALL_DIR/uninstall.sh" << EOF
#!/bin/bash
# Blogster Uninstall Script

echo "🗑️  Uninstalling Blogster..."

# Remove application files
rm -rf "$INSTALL_DIR"

# Remove icons
for size in 16 22 24 32 48 64 128 256 512; do
    rm -f "$ICONS_DIR/\${size}x\${size}/apps/blogster.png"
done

# Remove desktop file
rm -f "$APPS_DIR/blogster.desktop"

# Remove launcher
rm -f "$BIN_DIR/blogster"

# Update databases
gtk-update-icon-cache "$ICONS_DIR" 2>/dev/null || true
update-desktop-database "$APPS_DIR" 2>/dev/null || true

echo "✅ Blogster uninstalled successfully"
echo "ℹ️  Note: You may want to remove the PATH addition from ~/.bashrc or ~/.zshrc manually"
EOF

chmod +x "$INSTALL_DIR/uninstall.sh"

# Installation complete
echo ""
echo -e "${GREEN}🎉 Installation Complete!${NC}"
echo "=================================================="
echo -e "${GREEN}✅ Blogster has been installed successfully${NC}"
echo ""
echo "📍 Installation location: $INSTALL_DIR"
echo "🎨 Icons installed to: $ICONS_DIR"
echo "🖥️  Desktop file: $APPS_DIR/blogster.desktop"
echo "🔗 Launcher: $BIN_DIR/blogster"
echo ""
echo -e "${BLUE}🚀 How to run Blogster:${NC}"
echo "  1. Type 'blogster' in terminal (after restarting terminal)"
echo "  2. Search for 'Blogster' in Activities (GNOME)"
echo "  3. Run: $BIN_DIR/blogster"
echo ""
echo -e "${BLUE}🗑️  To uninstall:${NC}"
echo "  Run: $INSTALL_DIR/uninstall.sh"
echo ""
echo -e "${YELLOW}ℹ️  Note: You may need to restart GNOME Shell (Alt+F2, type 'r') or log out/in to see the icon in the dock.${NC}"

# Test launch
echo ""
read -p "🚀 Would you like to launch Blogster now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}🚀 Launching Blogster...${NC}"
    cd "$INSTALL_DIR" && ./blogster &
    echo "✅ Blogster started in background"
fi

echo ""
echo -e "${GREEN}🎉 Enjoy using Blogster!${NC}"
