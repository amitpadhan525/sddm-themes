# Phantom Red Theme

![Phantom Red Theme Preview](phantom-red.png)

**Phantom Red** is a dark, tactical, gaming-inspired SDDM login theme. It features a symmetric layout with hooded skull soldiers with glowing red eyes, set against a dark smoky background with floating red embers. The UI is clean and minimalist, highlighting a glowing massive digital clock, dynamic user greetings, and a bottom control dock. It is built to run on modern Qt6-based SDDM environments.

---

## Features

- **Tactical Dark Aesthetic**: Symmetric layout featuring dual hooded tactical skull characters with glowing red eyes, surrounded by a dark smoky atmosphere and floating fire sparks.
- **Massive Neon Digital Clock**: A prominent, bold digital clock using the Bebas Neue typeface with an elegant neon red outline glow effect.
- **Dynamic Greetings**: Welcomes the active user (e.g. "Good Morning, AMIT") with the username highlighted in neon red, and displays the formatted local date underneath.
- **Capsule Password Input**: A clean, capsule-shaped password field with a custom `ENTER PASSWORD` placeholder and glowing neon red borders on focus.
- **Fluid Animations**: Smooth parallel entry animations on load and physical "shake" feedback on failed login attempts.
- **Bottom Control Dock**: A compact, floating action bar at the bottom containing session selection, a network indicator, and a system power menu (Shutdown, Reboot).
- **Customizable**: Background wallpaper, blur activation, and blur strength are configurable via a configuration file.

---

## File Structure

The project has a clean, QML-only structure (no compilation required):

```text
phantom-red/
├── assets/               # Wallpapers and graphical assets
│   └── wallpaper.png
├── fonts/                # Theme typography
│   ├── BebasNeue.ttf
│   └── Outfit.ttf
├── CustomComboBox.qml    # Custom-styled combo boxes
├── LICENSE               # MIT License
├── Main.qml              # Main theme layout and behavior
├── metadata.desktop      # SDDM theme metadata
├── phantom-red.png       # Preview screenshot
├── README.md             # This documentation
├── setup.txt             # Installation guide
└── theme.conf            # User configuration variables
```

---

## Installation

For detailed step-by-step instructions, please refer to the [setup.txt](setup.txt) file, or follow the steps below:

1. **Install Prerequisites**:
   Ensure you have the required Qt6 QML modules installed for your distribution:
   - **Arch Linux**: `sudo pacman -S sddm qt6-5compat qt6-declarative qt6-svg`
   - **Fedora**: `sudo dnf install sddm qt6-qt5compat qt6-qtdeclarative qt6-qtsvg`
   - **Ubuntu/Debian**: `sudo apt install sddm qml6-module-qt5compat-graphicaleffects qml6-module-qtqml qml6-module-qtquick-layouts qml6-module-qtquick-controls`

2. **Copy Theme Files**:
   Create the theme folder and copy the repository contents:
   ```bash
   sudo mkdir -p /usr/share/sddm/themes/phantom-red
   sudo cp -r CustomComboBox.qml Main.qml metadata.desktop theme.conf assets fonts /usr/share/sddm/themes/phantom-red/
   ```

3. **Set Permissions**:
   Ensure the files are readable by the system `sddm` user:
   ```bash
   sudo find /usr/share/sddm/themes/phantom-red -type d -exec chmod 755 {} \;
   sudo find /usr/share/sddm/themes/phantom-red -type f -exec chmod 644 {} \;
   ```

4. **Activate the Theme**:
   Add or update the current theme configuration. We recommend using a separate config file under `/etc/sddm.conf.d/`:
   ```bash
   sudo mkdir -p /etc/sddm.conf.d
   echo -e "[Theme]\nCurrent=phantom-red" | sudo tee /etc/sddm.conf.d/10-theme.conf
   ```

---

## Testing the Theme

You can test the installed theme in a window on your current desktop session (without logging out) by running:

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/phantom-red
```

---

## Configuration

You can customize the theme properties in `/usr/share/sddm/themes/phantom-red/theme.conf`:

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `background` | String | `assets/wallpaper.png` | Relative path or absolute path to the background wallpaper. |
| `blur` | Boolean | `true` | Toggles background wallpaper blur (`true` or `false`). |
| `recursiveBlurRadius` | Integer | `8` | Controls the radius/intensity of the blur effect. |
| `recursiveBlurLoops` | Integer | `4` | Controls the quality/passes of the recursive blur filter. |

---

## Troubleshooting

- **Black screen or missing graphics on startup**:
  This is typically caused by missing QML libraries. Ensure the Qt6 Graphical Effects compatibility module (`qt6-5compat` on Arch or `qt6-qt5compat` on Fedora) is correctly installed. Check logs using `journalctl -u sddm`.
- **Fonts look incorrect**:
  The theme loads fonts directly from the `fonts/` subdirectory. If they fail to load, install them locally by copying `fonts/*.ttf` to `/usr/share/fonts/TTF/` and running `fc-cache -fv`.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
