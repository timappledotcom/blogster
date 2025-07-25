Name:           blogster
Version:        0.2.0
Release:        2
Summary:        Beautiful markdown editor with dual-platform publishing
License:        MIT
URL:            https://github.com/Parzzix/blogster
Source0:        %{name}-%{version}.tar.gz
BuildArch:      x86_64

Requires:       glibc, gtk3, glib2

%description
Blogster is a modern, beautiful markdown editor designed for writers who want
to publish to multiple platforms. Features include:

* Dual-platform publishing to Nostr and Micro.blog
* Advanced spellcheck with 370k+ word dictionary
* Image upload support (Micro.blog, nostr.build, Imgur)
* Live preview with syntax highlighting
* Tag and category management
* Dark mode support
* Cross-platform compatibility

Perfect for bloggers, technical writers, and content creators who want to
reach audiences on both decentralized and traditional platforms.

%prep
%setup -q

%build
# No build needed for pre-compiled Flutter app

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/opt/blogster
mkdir -p $RPM_BUILD_ROOT/usr/bin
mkdir -p $RPM_BUILD_ROOT/usr/share/applications

# Copy the Flutter bundle to /opt/blogster
cp -r * $RPM_BUILD_ROOT/opt/blogster/

# Create wrapper script in /usr/bin
cat > $RPM_BUILD_ROOT/usr/bin/blogster << 'EOF'
#!/bin/bash
exec /opt/blogster/blogster "$@"
EOF
chmod +x $RPM_BUILD_ROOT/usr/bin/blogster

# Install desktop file
cat > $RPM_BUILD_ROOT/usr/share/applications/blogster.desktop << EOF
[Desktop Entry]
Name=Blogster
Comment=Beautiful markdown editor with dual-platform publishing
Exec=/opt/blogster/blogster
Icon=text-editor
Terminal=false
Type=Application
Categories=Office;TextEditor;
MimeType=text/markdown;text/plain;
EOF

%files
/opt/blogster/*
/usr/bin/blogster
/usr/share/applications/blogster.desktop

%changelog
* Fri Jul 25 2025 Tim Parkin <tim@parzzix.net> - 0.2.0-2
- Fixed installation path conflicts by moving to /opt/blogster
- Prevents conflicts with other Flutter applications

* Fri Jul 25 2025 Tim Parkin <tim@parzzix.net> - 0.2.0-1
- Major feature release
- Added dual-platform publishing (Nostr and Micro.blog)
- Added advanced spellcheck with 370k+ word dictionary
- Added image upload support for multiple platforms
- Enhanced UI with better publishing workflow
- Added tag and category management
- Improved document metadata tracking

* Thu Jul 24 2025 Tim Parkin <tim@parzzix.net> - 0.1.0-1
- Initial release
- Basic markdown editor with Nostr publishing
- Live preview and syntax highlighting
- Dark mode support