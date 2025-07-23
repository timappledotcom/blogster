# Blogster Installation Guide

## Package Downloads

You can download pre-built packages for your Linux distribution from the [latest release](https://github.com/Parzzix/blogster/releases/latest).

## Debian/Ubuntu (.deb package)

### Download and Install
```bash
# Download the .deb package
wget https://github.com/Parzzix/blogster/releases/download/v0.1.1/blogster_0.1.1-1.deb

# Install the package
sudo dpkg -i blogster_0.1.1-1.deb

# Install dependencies if needed
sudo apt-get install -f
```

### Running
After installation, you can run Blogster from:
- Application menu (Office category)
- Terminal: `blogster`

## Red Hat/Fedora/SUSE (.rpm package)

### Download and Install
```bash
# Download the .rpm package
wget https://github.com/Parzzix/blogster/releases/download/v0.1.1/blogster-0.1.1-1.x86_64.rpm

# Install the package (Fedora/RHEL)
sudo dnf install blogster-0.1.1-1.x86_64.rpm

# Or for older systems
sudo yum install blogster-0.1.1-1.x86_64.rpm

# Or for SUSE
sudo zypper install blogster-0.1.1-1.x86_64.rpm
```

### Running
After installation, you can run Blogster from:
- Application menu (Office category)
- Terminal: `blogster`

## Build from Source

### Prerequisites
- Flutter 3.32.7 or later
- Linux development tools

### Build Steps
```bash
# Clone the repository
git clone https://github.com/Parzzix/blogster.git
cd blogster

# Install dependencies
flutter pub get

# Build the application
flutter build linux --release

# Run the built application
./build/linux/x64/release/bundle/blogster
```

## Features

- **📝 Clean Interface**: Distraction-free writing environment
- **👀 Live Preview**: Edit, preview, and split modes
- **🌙 Dark Mode**: Light and dark themes
- **📱 Responsive Design**: Works on desktop and mobile
- **📚 Document Library**: Organized drafts and published posts
- **🏷️ Tag Support**: Content categorization with hashtags
- **🌐 Nostr Publishing**: Decentralized content sharing
- **💾 Auto-Save**: Never lose your work
- **🎨 Syntax Highlighting**: Beautiful code blocks
- **🔍 Smart Search**: Quick document discovery

## Support

If you encounter any issues, please:
1. Check the [Issues](https://github.com/Parzzix/blogster/issues) page
2. Create a new issue with details about your system and the problem

## Contributing

We welcome contributions! Please see our [GitHub repository](https://github.com/Parzzix/blogster) for more information.

---

**Made with ❤️ by [Parzzix](https://github.com/Parzzix) - Open-source tools for hobbyists, by hobbyists.**
