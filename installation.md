# SDDM Themes Installation Guide

This guide explains how to install and activate SDDM themes from this repository.

---

## Prerequisites

Ensure you have the required Qt6 QML modules installed for your Linux distribution:

* **Arch Linux**:
  ```bash
  sudo pacman -S sddm qt6-5compat qt6-declarative qt6-svg
  ```
* **Fedora**:
  ```bash
  sudo dnf install sddm qt6-qt5compat qt6-qtdeclarative qt6-qtsvg
  ```
* **Ubuntu / Debian**:
  ```bash
  sudo apt install sddm qml6-module-qt5compat-graphicaleffects qml6-module-qtqml qml6-module-qtquick-layouts qml6-module-qtquick-controls
  ```

---

## Installation Steps (from ZIP file)

### 1. Download & Extract the ZIP
Download the release `.zip` file for your chosen theme (e.g., `nebula.zip` or `phantom-red.zip`) and extract it:
```bash
unzip theme-name.zip
```
*(This will extract a folder named after the theme, e.g., `nebula/` or `phantom-red/`)*

### 2. Copy the Theme Directory
Copy the extracted folder to the system SDDM themes directory:
```bash
sudo cp -r theme-name /usr/share/sddm/themes/
```
*(Replace `theme-name` with the actual name, e.g., `nebula` or `phantom-red`)*

### 3. Set Proper Permissions
Make sure the files are readable by the system `sddm` user:
```bash
sudo find /usr/share/sddm/themes/theme-name -type d -exec chmod 755 {} \;
sudo find /usr/share/sddm/themes/theme-name -type f -exec chmod 644 {} \;
```

---

## Activation

To activate the theme, create or update your SDDM configuration. We recommend using a separate configuration file under `/etc/sddm.conf.d/`:

1. Create the directory if it doesn't exist:
   ```bash
   sudo mkdir -p /etc/sddm.conf.d
   ```
2. Enable the theme:
   ```bash
   echo -e "[Theme]\nCurrent=theme-name" | sudo tee /etc/sddm.conf.d/10-theme.conf
   ```
   *(Replace `theme-name` with the theme folder name, e.g., `nebula` or `phantom-red`)*

---

## Testing the Theme

You can test the installed theme in a window on your current desktop session (without logging out) by running:
```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/theme-name
```
