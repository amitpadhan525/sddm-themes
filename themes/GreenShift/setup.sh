#!/usr/bin/env bash

# SDDM Theme Setup & Installer Script
# Works across all major Linux distributions (Arch, Fedora, Debian, Ubuntu, OpenSUSE, Void, etc.)

set -e

# Styling & Colors
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Determine script & theme directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
THEME_NAME="$(basename "$SCRIPT_DIR")"
TARGET_DIR="/usr/share/sddm/themes/$THEME_NAME"

# Display Help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo -e "${BOLD}Usage:${NC} $0 [OPTION]"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo -e "  ${CYAN}(no args)${NC}      Install and activate the '${THEME_NAME}' theme"
    echo -e "  ${CYAN}-p, --preview${NC}  Preview the theme locally without installing (no root needed)"
    echo -e "  ${CYAN}-u, --uninstall${NC} Uninstall the theme and clean active theme config"
    echo -e "  ${CYAN}-h, --help${NC}     Show this help message"
    exit 0
fi

# Preview Mode
if [[ "$1" == "--preview" || "$1" == "-p" ]]; then
    echo -e "${BLUE}==>${NC} ${BOLD}Launching SDDM Greeter preview for:${NC} ${GREEN}$THEME_NAME${NC}"
    if [ -f "$SCRIPT_DIR/preview.sh" ]; then
        exec "$SCRIPT_DIR/preview.sh"
    else
        export QML_XHR_ALLOW_FILE_READ=1
        exec sddm-greeter-qt6 --test-mode --theme "$SCRIPT_DIR"
    fi
fi

# Require root privileges for installation/uninstallation
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[!] Privileged access required. Re-running with sudo...${NC}"
    exec sudo bash "$0" "$@"
fi

# Uninstall Mode
if [[ "$1" == "--uninstall" || "$1" == "-u" ]]; then
    echo -e "${BOLD}====================================================${NC}"
    echo -e " ${RED}Uninstalling SDDM Theme:${NC} ${BOLD}$THEME_NAME${NC}"
    echo -e "${BOLD}====================================================${NC}"

    if [ -d "$TARGET_DIR" ]; then
        echo -e "${BLUE}[1/2]${NC} Removing theme files from $TARGET_DIR..."
        rm -rf "$TARGET_DIR"
    else
        echo -e "${YELLOW}[1/2]${NC} Theme directory $TARGET_DIR does not exist."
    fi

    echo -e "${BLUE}[2/2]${NC} Cleaning active SDDM configuration..."
    if [ -f /etc/sddm.conf.d/theme.conf ]; then
        if grep -q "Current=$THEME_NAME" /etc/sddm.conf.d/theme.conf; then
            rm -f /etc/sddm.conf.d/theme.conf
            echo "      Removed /etc/sddm.conf.d/theme.conf."
        fi
    fi

    echo -e "${GREEN}==>${NC} ${BOLD}Theme '$THEME_NAME' successfully uninstalled.${NC}"
    exit 0
fi

# Normal Install Mode
echo -e "${BOLD}====================================================${NC}"
echo -e " ${GREEN}Installing SDDM Theme:${NC} ${BOLD}$THEME_NAME${NC}"
echo -e "${BOLD}====================================================${NC}"

# 1. Dependency / Environment Check (informative, non-fatal)
echo -e "${BLUE}[1/4]${NC} Checking system environment..."
if ! command -v sddm >/dev/null 2>&1 && ! command -v sddm-greeter-qt6 >/dev/null 2>&1; then
    echo -e "      ${YELLOW}[NOTE]${NC} SDDM does not appear to be in PATH."
    echo -e "      Make sure SDDM and Qt6 QML dependencies are installed:"
    echo -e "        - Arch:   ${CYAN}sudo pacman -S sddm qt6-5compat qt6-declarative qt6-svg${NC}"
    echo -e "        - Fedora: ${CYAN}sudo dnf install sddm qt6-qt5compat qt6-qtdeclarative qt6-qtsvg${NC}"
    echo -e "        - Ubuntu: ${CYAN}sudo apt install sddm qml6-module-qt5compat-graphicaleffects qml6-module-qtqml qml6-module-qtquick-layouts qml6-module-qtquick-controls${NC}"
fi

# 2. Copy Theme Files
echo -e "${BLUE}[2/4]${NC} Copying theme files to ${BOLD}$TARGET_DIR${NC}..."
mkdir -p "$TARGET_DIR"
rm -rf "${TARGET_DIR:?}"/*
cp -r "$SCRIPT_DIR"/* "$TARGET_DIR"/

# 3. Set Permissions
echo -e "${BLUE}[3/4]${NC} Setting secure and readable permissions..."
find "$TARGET_DIR" -type d -exec chmod 755 {} +
find "$TARGET_DIR" -type f -exec chmod 644 {} +
find "$TARGET_DIR" -type f -name "*.sh" -exec chmod 755 {} +

# 4. Configure SDDM to use this theme (guaranteed override)
echo -e "${BLUE}[4/4]${NC} Setting active theme to '${BOLD}$THEME_NAME${NC}' in /etc/sddm.conf.d/theme.conf..."
mkdir -p /etc/sddm.conf.d

# Override / comment out any conflicting Current= lines in legacy /etc/sddm.conf
if [ -f /etc/sddm.conf ]; then
    sed -i -E 's/^[[:space:]]*Current=.*/# & # overridden by '"$THEME_NAME"' setup/' /etc/sddm.conf
fi

# Override / comment out any conflicting Current= lines in other /etc/sddm.conf.d/*.conf files
for conf_file in /etc/sddm.conf.d/*.conf; do
    if [ -f "$conf_file" ] && [ "$(basename "$conf_file")" != "theme.conf" ]; then
        sed -i -E 's/^[[:space:]]*Current=.*/# & # overridden by '"$THEME_NAME"' setup/' "$conf_file"
    fi
done

# Write authoritative theme configuration
cat <<EOF > /etc/sddm.conf.d/theme.conf
[Theme]
Current=$THEME_NAME
EOF

echo ""
echo -e "${BOLD}====================================================${NC}"
echo -e " ${GREEN}SUCCESS!${NC} Theme '${BOLD}$THEME_NAME${NC}' installed and activated!"
echo -e "${BOLD}====================================================${NC}"
echo ""
echo -e "${BOLD}Preview installed theme without logging out:${NC}"
echo -e "  ${CYAN}sddm-greeter-qt6 --test-mode --theme $TARGET_DIR${NC}"
echo ""
echo -e "${BOLD}Or run directly from this directory:${NC}"
echo -e "  ${CYAN}./preview.sh${NC}"
echo ""
