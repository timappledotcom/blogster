# Changelog

All notable changes to Blogster will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0-3] - 2025-07-25

### 🎨 Icon & Desktop Integration Fix
- **FIXED**: Application icon now displays properly in dock and application menus
- **ADDED**: Custom Blogster icon with professional design (pen and paper theme)
- **IMPROVED**: Multiple icon sizes (48x48, 64x64, 128x128, 256x256, 512x512) for better scaling
- **ENHANCED**: Better desktop integration with proper icon cache updates
- **FIXED**: Minor null safety issue in file saving

## [0.2.0-2] - 2025-07-25

### 🔧 Package Installation Fix
- **FIXED**: Package installation conflicts with other Flutter applications
- **CHANGED**: Moved installation from `/usr/bin/` to `/opt/blogster/` to prevent conflicts
- **IMPROVED**: Better cross-platform package compatibility
- **NOTE**: If you have version 0.2.0-1 installed, please uninstall it first before installing 0.2.0-2

## [0.2.0] - 2025-07-25

### 🚀 Major Features Added

#### Dual Platform Publishing
- **NEW**: Publish to both Nostr and Micro.blog simultaneously
- **NEW**: Unified publish dialog with platform selection (Nostr, Micro.blog, or Both)
- **NEW**: Platform-specific credential management
- **NEW**: Robust error handling for partial publishing failures
- **NEW**: Smart publishing logic that continues if one platform fails

#### Image Upload Support
- **NEW**: Multi-platform image upload support
  - Micro.blog: Direct upload to your media library
  - nostr.build: Popular Nostr image hosting service
  - Imgur: Anonymous upload as fallback
- **NEW**: Automatic markdown generation for uploaded images
- **NEW**: File validation and size limits (10MB max)
- **NEW**: Manual URL input option for existing images
- **NEW**: Clipboard integration - URLs automatically copied after upload

#### Advanced Spellcheck System
- **NEW**: Comprehensive spellcheck with 370,000+ English words
- **NEW**: Technical dictionary including:
  - 100+ programming languages (JavaScript, Python, Rust, Go, etc.)
  - 60+ operating systems (Linux, Windows, macOS, Android, etc.)
  - 100+ network protocols (HTTP, TCP, WebSocket, OAuth, etc.)
  - 200+ development tools and frameworks
- **NEW**: Manual correction input for custom fixes
- **NEW**: Markdown-aware processing (ignores code blocks, links, images)
- **NEW**: Personal dictionary with add/ignore functionality
- **NEW**: Smart suggestions using Levenshtein distance algorithm

#### Enhanced Document Management
- **NEW**: Persistent tags and categories saved with published documents
- **NEW**: Document metadata tracking which platforms were used
- **NEW**: Enhanced BlogsterDocument model with tags and publishedPlatforms fields
- **NEW**: Metadata persistence using .meta files alongside documents

### 🎨 UI/UX Improvements

#### Publishing Experience
- **NEW**: Enhanced publish dialog with platform-specific settings
- **NEW**: Category selector for Micro.blog with refresh functionality
- **NEW**: Visual indicators for credential status
- **NEW**: Better error messages and success feedback
- **NEW**: Progress indicators during publishing

#### Editor Enhancements
- **NEW**: Image button in toolbar for easy image insertion
- **NEW**: Spellcheck button in toolbar for quick access
- **NEW**: Improved visual feedback throughout the application
- **NEW**: Better document library organization

### 🔧 Technical Improvements

#### Architecture
- **NEW**: Micro.blog service with app token authentication
- **NEW**: Image service supporting multiple upload platforms
- **NEW**: Comprehensive spellcheck service with online dictionary loading
- **NEW**: Enhanced credential management for multiple platforms

#### Data Management
- **NEW**: Document metadata persistence system
- **NEW**: Improved error handling and user feedback
- **NEW**: Better word boundary detection for spellcheck
- **NEW**: Robust file validation and processing

### 📦 Package Updates
- **NEW**: Updated DEB package with enhanced description
- **NEW**: Updated RPM package with comprehensive feature list
- **NEW**: Improved desktop integration with better MIME type support

### 🐛 Bug Fixes
- **FIXED**: Credential loading on app startup
- **FIXED**: Word extraction for spellcheck accuracy
- **FIXED**: Document tagging persistence
- **FIXED**: Platform-specific publishing logic

## [0.1.0] - 2025-07-24

### Initial Release
- Basic markdown editor with live preview
- Nostr publishing support with BIP-340 signatures
- Dark mode and light mode themes
- Syntax highlighting for code blocks
- Document library management
- Cross-platform support (Linux, Android, Windows)
- Basic credential management for Nostr

---

## Download

### Version 0.2.0
- **DEB Package**: [blogster_0.2.0-1.deb](releases/v0.2.0/blogster_0.2.0-1.deb)
- **RPM Package**: [blogster-0.2.0-1.x86_64.rpm](releases/v0.2.0/blogster-0.2.0-1.x86_64.rpm)

### Version 0.1.0
- **DEB Package**: [blogster_0.1.1-1.deb](releases/v0.1.1/blogster_0.1.1-1.deb)
- **RPM Package**: [blogster-0.1.1-1.x86_64.rpm](releases/v0.1.1/blogster-0.1.1-1.x86_64.rpm)

## Installation

### Ubuntu/Debian
```bash
wget https://github.com/Parzzix/blogster/releases/download/v0.2.0/blogster_0.2.0-1.deb
sudo dpkg -i blogster_0.2.0-1.deb
sudo apt-get install -f  # Fix any dependency issues
```

### Fedora/RHEL/CentOS
```bash
wget https://github.com/Parzzix/blogster/releases/download/v0.2.0/blogster-0.2.0-1.x86_64.rpm
sudo rpm -i blogster-0.2.0-1.x86_64.rpm
```