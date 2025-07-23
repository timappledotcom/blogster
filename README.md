# Blogster ✨

**The beautiful markdown editor for modern writers**

Blogster is a minimalist, distraction-free markdown editor designed for content creators who want to focus on writing. Built with Flutter, it combines the simplicity of traditional text editors with modern features and decentralized publishing capabilities.

![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Android%20%7C%20Windows-lightgrey.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.32.7-blue.svg)

## ✨ Features

- **📝 Clean Interface**: Distraction-free writing environment with customizable themes
- **👀 Live Preview**: Switch between edit, preview, and split modes instantly  
- **🌙 Dark Mode**: Easy on the eyes for long writing sessions
- **📱 Responsive Design**: Works beautifully on desktop and mobile devices
- **📚 Document Library**: Organize your drafts and published posts with collapsible sections
- **🏷️ Tag Support**: Categorize your content with hashtags for better organization
- **🌐 Nostr Publishing**: Share your content on the decentralized web
- **💾 Auto-Save**: Never lose your work with automatic saving every 2 seconds
- **🎨 Syntax Highlighting**: Beautiful code blocks with language support
- **🔍 Smart Search**: Find your documents quickly with search functionality
- **📤 Export Options**: Save your work in various formats

## 🚀 Getting Started

### Prerequisites

- Flutter 3.32.7 or higher
- Dart SDK
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/parzzix/blogster.git
   cd blogster
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d linux    # For Linux
   flutter run -d android  # For Android
   flutter run -d windows  # For Windows
   ```

## 📖 Usage

### Writing Your First Post

1. **Create a New Document**: Click the "New" button in the library sidebar
2. **Start Writing**: Use standard Markdown syntax for formatting
3. **Add Tags**: Click the "Tags" section below the toolbar to categorize your post
4. **Preview**: Switch to preview mode to see your formatted content
5. **Auto-Save**: Your work is automatically saved every 2 seconds

### Markdown Support

Blogster supports all standard Markdown features:

- **Headers**: `# H1`, `## H2`, `### H3`
- **Emphasis**: `**bold**`, `*italic*`
- **Code**: `` `inline` `` and ```code blocks```
- **Lists**: Ordered and unordered lists
- **Links**: `[text](url)`
- **Images**: `![alt](url)`

### Publishing to Nostr

1. **Set Up Credentials**: Go to Settings > Manage Credentials
2. **Add Your Private Key**: Enter your Nostr private key (hex format)
3. **Add Tags**: Use the tags section to categorize your post
4. **Publish**: Click the share button and select your relays

## 🛠️ Built With

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **Provider** - State management
- **Flutter Markdown** - Markdown rendering
- **Web Socket Channel** - Nostr relay communication
- **File Picker** - File operations
- **Crypto** - Cryptographic operations for Nostr

## 🌐 Nostr Integration

Blogster integrates seamlessly with the Nostr protocol:

- **Decentralized Publishing**: Share content across multiple relays
- **BIP-340 Signatures**: Secure cryptographic signing
- **NIP-01 Events**: Standard Nostr event format
- **Long-form Content**: Support for NIP-23 long-form articles
- **Tag System**: Proper hashtag support for content discovery

## 🎨 Themes & Customization

- **Light & Dark Modes**: Switch themes based on your preference
- **Responsive Design**: Adapts to different screen sizes
- **Mobile-Friendly**: Collapsible sidebar and touch-friendly interface

## 📱 Platform Support

- **Linux** ✅ - Primary development platform
- **Android** ✅ - Mobile support with responsive UI
- **Windows** ✅ - Cross-platform compatibility

## 🤝 Contributing

We welcome contributions! This project is part of the Parzzix ecosystem - open-source tools built by hobbyists, for hobbyists.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 💡 Support the Project

If Blogster helps you create amazing content, consider supporting development:

**Bitcoin**: `bc1qlfgxaq3cyx27rurq55ljhmsple9370lygputrf`

⚡ Every satoshi helps keep the project alive and open-source!

## 🙏 Acknowledgments

- Built with ❤️ by Tim Apple @ Parzzix
- Inspired by the need for a clean, distraction-free writing experience
- Thanks to the Flutter and Nostr communities

---

**Made with ❤️ by [Parzzix](https://github.com/parzzix) - Open-source tools for hobbyists, by hobbyists.**
