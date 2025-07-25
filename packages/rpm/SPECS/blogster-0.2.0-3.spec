Name:           blogster
Version:        0.2.0
Release:        3
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
mkdir -p $RPM_BUILD_ROOT/usr/share/icons/hicolor/48x48/apps
mkdir -p $RPM_BUILD_ROOT/usr/share/icons/hicolor/64x64/apps
mkdir -p $RPM_BUILD_ROOT/usr/share/icons/hicolor/128x128/apps
mkdir -p $RPM_BUILD_ROOT/usr/share/icons/hicolor/256x256/apps
mkdir -p $RPM_BUILD_ROOT/usr/share/icons/hicolor/512x512/apps

# Copy the Flutter bundle to /opt/blogster
cp -r blogster data lib $RPM_BUILD_ROOT/opt/blogster/

# Install icon files
cp icons/blogster-48.png $RPM_BUILD_ROOT/usr/share/icons/hicolor/48x48/apps/blogster.png
cp icons/blogster-64.png $RPM_BUILD_ROOT/usr/share/icons/hicolor/64x64/apps/blogster.png
cp icons/blogster-128.png $RPM_BUILD_ROOT/usr/share/icons/hicolor/128x128/apps/blogster.png
cp icons/blogster-256.png $RPM_BUILD_ROOT/usr/share/icons/hicolor/256x256/apps/blogster.png
cp icons/blogster-512.png $RPM_BUILD_ROOT/usr/share/icons/hicolor/512x512/apps/blogster.png

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
Icon=blogster
Terminal=false
Type=Application
Categories=Office;TextEditor;
MimeType=text/markdown;text/plain;
StartupNotify=true
Keywords=markdown;editor;blog;nostr;microblog;writing;publishing;
EOF

%files
/opt/blogster/*
/usr/bin/blogster
/usr/share/applications/blogster.desktop
/usr/share/icons/hicolor/*/apps/blogster.png

%post
# Update icon cache
if [ -x /usr/bin/gtk-update-icon-cache ]; then
    /usr/bin/gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || :
fi

%postun
# Update icon cache
if [ -x /usr/bin/gtk-update-icon-cache ]; then
    /usr/bin/gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || :
fi

%changelog
* Fri Jul 25 2025 Tim Parkin <tim@parzzix.net> - 0.2.0-3
- Added proper application icon with multiple sizes
- Fixed dock icon display issue
- Improved desktop integration

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