# Phantom SDDM Theme

![Phantom SDDM Theme Preview](phantom-sddm.png)

**Phantom** is a modern, futuristic, dark glassmorphic SDDM login theme inspired by Hyprlock. It features sleek neon accents, frosted glass effects, an elegant centered card layout, fluid micro-animations, and custom QML components. It is built to run on modern Qt6-based SDDM environments.

---

## Features

- **Glassmorphism Card**: Frosted glass card styled in a rich, dark emerald hue (`#cc061a12`) with elegant borders that glow vibrant neon green (`#00ff8f`) when the password field is focused.
- **Massive Digital Clock**: A prominent, bold digital clock using the Bebas Neue typeface.
- **Dynamic Greetings**: Greets the selected user with context-sensitive greetings ("Good Morning", "Good Afternoon", "Good Evening") and shows the formatted local date.
- **Custom Password Input**: Uses expanding neon dot indicators and a custom pulsing cursor line for a premium lockscreen aesthetic.
- **Fluid Animations**: Smooth parallel entry animations on startup and a physical "shake" feedback animation on failed login attempts.
- **Control Dock**: A sleek floating bar at the bottom containing session selection, user selection (visible when multiple users exist), and a system power menu (Shutdown, Reboot).
- **Customizable**: Background wallpaper, blur activation, and blur strength are configurable via a configuration file.

---

## File Structure

The project has a clean, QML-only structure (no compilation required):

```text
phantom-sddm/
├── assets/               # Wallpapers and graphical assets
│   └── wallpaper.png
├── fonts/                # Theme typography
│   ├── BebasNeue.ttf
│   └── Outfit.ttf
├── CustomComboBox.qml    # Custom-styled combo boxes
├── LICENSE               # MIT License
├── Main.qml              # Main theme layout and behavior
├── metadata.desktop      # SDDM theme metadata
├── phantom-sddm.png      # Preview screenshot
├── README.md             # This documentation
├── setup.sh              # Interactive setup script
├── setup.txt             # Manual setup text instructions
└── theme.conf            # User configuration variables
```

---

## Installation

### Method 1: Automatic Installation (Recommended)

You can run the interactive installation script to automatically check dependencies, copy theme files with correct permissions, and activate the theme.

1. **Clone the repository and run the setup script**:
   ```bash
   git clone https://github.com/amitpadhan525/phantom-sddm.git
   cd phantom-sddm
   chmod +x setup.sh
   ./setup.sh
   ```
2. Follow the on-screen prompts. The installer will offer to check/install dependencies, copy files to `/usr/share/sddm/themes/phantom-sddm`, configure the theme in `/etc/sddm.conf.d/10-theme.conf`, and launch a test window.

---

### Method 2: Manual Installation

If you prefer manual configuration, please refer to the detailed instructions in [setup.txt](setup.txt) or follow these steps:

1. **Install Prerequisites**:
   Ensure you have the required Qt6 QML modules installed for your distribution:
   - **Arch Linux**: `sudo pacman -S sddm qt6-5compat qt6-declarative qt6-svg`
   - **Fedora**: `sudo dnf install sddm qt6-qt5compat qt6-qtdeclarative qt6-qtsvg`
   - **Ubuntu/Debian**: `sudo apt install sddm qml6-module-qt5compat-graphicaleffects qml6-module-qtqml qml6-module-qtquick-layouts qml6-module-qtquick-controls`

2. **Copy Theme Files**:
   Create the theme folder and copy the repository contents:
   ```bash
   sudo mkdir -p /usr/share/sddm/themes/phantom-sddm
   sudo cp -r CustomComboBox.qml Main.qml metadata.desktop theme.conf assets fonts /usr/share/sddm/themes/phantom-sddm/
   ```

3. **Set Permissions**:
   Ensure the files are readable by the system `sddm` user:
   ```bash
   sudo find /usr/share/sddm/themes/phantom-sddm -type d -exec chmod 755 {} \;
   sudo find /usr/share/sddm/themes/phantom-sddm -type f -exec chmod 644 {} \;
   ```

4. **Activate the Theme**:
   Add or update the current theme configuration. We recommend using a separate config file under `/etc/sddm.conf.d/`:
   ```bash
   sudo mkdir -p /etc/sddm.conf.d
   echo -e "[Theme]\nCurrent=phantom-sddm" | sudo tee /etc/sddm.conf.d/10-theme.conf
   ```

---

## Testing the Theme

You can test the installed theme in a window on your current desktop session (without logging out). Run:

```bash
# On systems running Qt6 SDDM (Recommended)
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/phantom-sddm

# On older systems running Qt5 SDDM
sddm-greeter --test-mode --theme /usr/share/sddm/themes/phantom-sddm
```

---

## Configuration

You can customize the theme properties in `/usr/share/sddm/themes/phantom-sddm/theme.conf`:

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
