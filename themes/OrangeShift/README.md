# OrangeShift SDDM Theme

A sleek, modern glassmorphic SDDM greeter theme built with Qt6 / QML. Features custom typography, live clock, session switcher, user management, and power controls.

---

## ✨ Features

- **Glassmorphic Design**: Translucent layered cards with glowing accents and borders.
- **Custom Typography**: Includes *Outfit*, *Bebas Neue*, and *JetBrainsMono*.
- **Live Clock & Date**: High-contrast clock display with accent underline and live updating.
- **Interactive Login**:
  - Auto-focus on keystroke
  - Reveal/Hide password toggle
  - Caps Lock warning indicator
  - Error shake animation on failed authentication
  - Return / Enter key submission
- **Session & User Selection**: Polished custom dropdowns for Wayland/X11 desktop sessions and user accounts.
- **Power Management**: Sleek Suspend, Reboot, and Power Off action buttons with SVG icons and tooltips.
- **Highly Customizable**: Easily swap wallpapers, blur radius, fonts, and datetime formats in `theme.conf`.

---

## 🎨 Configuration (`theme.conf`)

Edit `theme.conf` to customize:
- `Background`: Set wallpaper path (e.g. `backgrounds/background2.png` or custom image).
- `BlurRadius`: Adjust wallpaper blur (default: `40`, set to `0` for crisp wallpaper).
- `FontFamily` & `TimeFont`: Typography family.
- `TimeFormat` & `DateFormat`: Custom datetime formats.

---

## 🚀 Testing & Installation

### Preview Theme
```bash
./preview.sh
```

### Install to System
```bash
sudo ./setup.sh
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
