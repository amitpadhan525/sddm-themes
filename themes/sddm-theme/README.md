# CyberAurora SDDM Theme

A sleek, modern glassmorphism SDDM greeter theme built with Qt6 / QML. Features custom typography, live clock, session switcher, user management, and power controls.

---

## ✨ Features

- **Glassmorphic Design**: Translucent layered cards with glowing accents and borders.
- **Custom Typography**: Includes *Outfit*, *Bebas Neue*, and *JetBrainsMono Nerd Font*.
- **Live Clock & Date**: High-contrast clock display with accent underline and live updating.
- **Interactive Login**:
  - Auto-focus on keystroke
  - Reveal/Hide password toggle
  - Caps Lock warning indicator
  - Error shake animation on failed authentication
  - Return / Enter key submission
- **Session & User Selection**: Polished custom dropdowns for Wayland/X11 desktop sessions (Hyprland, Plasma, Sway, GNOME, etc.) and user accounts.
- **Power Management**: Sleek Suspend, Reboot, and Power Off action buttons with SVG icons and tooltips.
- **Highly Customizable**: Easily swap wallpapers, accent colors, fonts, and opacity in `theme.conf`.

---

## 🎨 Configuration (`theme.conf`)

Edit [theme.conf](file:///home/amit/test/sddm-theme/theme.conf) to customize:
- `Background`: Set wallpaper to `backgrounds/cyberpunk.jpg` or `backgrounds/aurora.jpg` (or any custom image).
- `AccentColor`: Primary neon accent color (default: `#00e5ff`).
- `SecondaryAccent`: Secondary accent color (default: `#ff007f`).
- `CardOpacity`: Translucency of the glassmorphic card (default: `0.78`).
- `TimeFormat` & `DateFormat`: Custom datetime formats.

---

## 🚀 Testing & Installation

### Preview Theme
```bash
sddm-greeter-qt6 --test-mode --theme /home/amit/test/sddm-theme
```

### Install to System
```bash
sudo cp -r /home/amit/test/sddm-theme /usr/share/sddm/themes/CyberAurora
```

Set as active theme in `/etc/sddm.conf` or `/etc/sddm.conf.d/theme.conf`:
```ini
[Theme]
Current=CyberAurora
```
