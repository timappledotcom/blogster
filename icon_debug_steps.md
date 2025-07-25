# Icon Debugging Steps

If the icon still doesn't show up in the dock after installing v0.2.0-4, try these debugging steps:

## 1. Check if icons are installed correctly
```bash
ls -la /usr/share/icons/hicolor/48x48/apps/blogster.png
ls -la /usr/share/pixmaps/blogster.png
```

## 2. Check desktop entry
```bash
cat /usr/share/applications/blogster.desktop
```

## 3. Validate desktop entry
```bash
desktop-file-validate /usr/share/applications/blogster.desktop
```

## 4. Manually update caches
```bash
sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor
sudo update-desktop-database /usr/share/applications
```

## 5. Check if the icon is found by the system
```bash
gtk-launch blogster
# or
gio launch /usr/share/applications/blogster.desktop
```

## 6. Test icon lookup
```bash
# This should show the path to the icon
gtk-query-immodules-3.0 | grep blogster
# or try
find /usr/share/icons -name "blogster.png"
```

## 7. Check running application window class
After launching Blogster, run:
```bash
xprop WM_CLASS
# Then click on the Blogster window
```

## 8. Force desktop environment refresh
```bash
# For GNOME
killall -HUP gnome-shell
# For KDE
kbuildsycoca5
# For XFCE
xfce4-panel --restart
```

## 9. Alternative: Try absolute icon path
If nothing works, we can modify the desktop entry to use absolute path:
```
Icon=/usr/share/pixmaps/blogster.png
```

## 10. Check desktop environment
Some desktop environments handle icons differently. What desktop environment are you using?
- GNOME
- KDE
- XFCE
- Other?

Let me know the results of these tests and I can provide more targeted fixes.