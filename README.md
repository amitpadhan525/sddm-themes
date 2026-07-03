# SDDM Themes Collection

A collection of modern, beautiful, and highly polished SDDM login themes.

---

## Themes

### Nebula

![Nebula SDDM Theme Preview](screenshots/nebula.png)

**Nebula** is a modern, futuristic, dark glassmorphic SDDM login theme inspired by Hyprlock. It features sleek neon accents, frosted glass effects, an elegant centered card layout, fluid micro-animations, and custom QML components.

- **Theme Directory**: [themes/nebula](file:///home/amit/github/sddm-themes/themes/nebula)
- **Read More**: [themes/nebula/README.md](file:///home/amit/github/sddm-themes/themes/nebula/README.md)

---

### Phantom Red

![Phantom Red SDDM Theme Preview](screenshots/phantom-red.png)

**Phantom Red** is a dark, tactical, gaming-inspired SDDM login theme. It features a symmetric layout with hooded skull soldiers with glowing red eyes, set against a dark smoky background with floating red embers. The UI highlights a glowing massive digital clock, dynamic user greetings, and a bottom control dock.

- **Theme Directory**: [themes/phantom-red](file:///home/amit/github/sddm-themes/themes/phantom-red)
- **Read More**: [themes/phantom-red/README.md](file:///home/amit/github/sddm-themes/themes/phantom-red/README.md)

---

## Installation & Setup

To install any of the themes, follow these steps:

1. **Copy the Theme Folder**
   Copy the desired theme folder to the system SDDM themes directory:
   ```bash
   # For Nebula
   sudo cp -r themes/nebula /usr/share/sddm/themes/

   # For Phantom Red
   sudo cp -r themes/phantom-red /usr/share/sddm/themes/
   ```

2. **Activate the Theme**
   Update your SDDM configuration to select the new theme. We recommend creating/editing `/etc/sddm.conf.d/10-theme.conf`:
   ```ini
   [Theme]
   Current=nebula # or phantom-red
   ```

For detailed pre-requisites, automatic installation, and manual configuration details, please refer to the specific documentation:
- [Nebula Installation Guide](file:///home/amit/github/sddm-themes/themes/nebula/setup.txt)
- [Phantom Red Installation Guide](file:///home/amit/github/sddm-themes/themes/phantom-red/setup.txt)
