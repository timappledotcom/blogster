Name:           blogster
Version:        0.1.1
Release:        1%{?dist}
Summary:        Beautiful markdown editor with Nostr publishing

License:        MIT
URL:            https://github.com/Parzzix/blogster
Source0:        %{name}-%{version}.tar.gz

BuildArch:      x86_64
Requires:       glibc, libstdc++, glib2, gtk3

%description
Blogster is a minimalist, distraction-free markdown editor with
live preview and decentralized publishing support via Nostr protocol.

Features include:
- Clean, distraction-free writing interface
- Live markdown preview with split-screen mode
- Tag support for content organization
- Nostr protocol integration for decentralized publishing
- Dark and light themes
- Cross-platform support
- Auto-save functionality

%prep
%setup -q

%build
# No build needed, pre-built binary

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/lib/blogster
mkdir -p $RPM_BUILD_ROOT/usr/bin
mkdir -p $RPM_BUILD_ROOT/usr/share/applications

cp -r * $RPM_BUILD_ROOT/usr/lib/blogster/

# Create launcher script
cat > $RPM_BUILD_ROOT/usr/bin/blogster << 'EOF'
#!/bin/bash
cd /usr/lib/blogster
exec ./blogster "$@"
EOF

chmod +x $RPM_BUILD_ROOT/usr/bin/blogster

# Create desktop file
cat > $RPM_BUILD_ROOT/usr/share/applications/blogster.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Blogster
Comment=Beautiful markdown editor with Nostr publishing
Exec=blogster
Icon=blogster
Terminal=false
Categories=Office;WordProcessor;
StartupWMClass=blogster
MimeType=text/markdown;text/plain;
EOF

%files
/usr/lib/blogster/
/usr/bin/blogster
/usr/share/applications/blogster.desktop

%changelog
* Wed Jul 23 2025 Parzzix <support@parzzix.com> - 0.1.1-1
- Added Lightning Network payment support
- Enhanced support documentation

* Wed Jul 23 2025 Parzzix <support@parzzix.com> - 0.1.0-1
- Initial release
- Markdown editor with live preview
- Nostr publishing integration
- Tag support for content organization
