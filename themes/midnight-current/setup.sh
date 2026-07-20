#!/usr/bin/env bash

# SDDM Theme Setup Script
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="$(basename "$SCRIPT_DIR")"
TARGET_DIR="/usr/share/sddm/themes/$THEME_NAME"

echo "=========================================="
echo " Installing SDDM Theme: $THEME_NAME"
echo "=========================================="

# Require root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Privileged access required to install SDDM theme."
    echo "Re-running script with sudo..."
    exec sudo bash "$0" "$@"
fi

echo "[1/3] Copying theme files to $TARGET_DIR..."
mkdir -p "$TARGET_DIR"
cp -r "$SCRIPT_DIR"/* "$TARGET_DIR"/

echo "[2/3] Setting correct permissions..."
find "$TARGET_DIR" -type d -exec chmod 755 {} \;
find "$TARGET_DIR" -type f -exec chmod 644 {} \;
if [ -f "$TARGET_DIR/setup.sh" ]; then
    chmod 755 "$TARGET_DIR/setup.sh"
fi

echo "[3/3] Setting active SDDM theme to '$THEME_NAME' in /etc/sddm.conf.d/theme.conf..."
mkdir -p /etc/sddm.conf.d

if [ -d /etc/sddm.conf.d ]; then
    for conf_file in /etc/sddm.conf.d/*.conf; do
        if [ -f "$conf_file" ]; then
            echo "Renaming existing config $conf_file to ${conf_file}.bak..."
            mv -f "$conf_file" "${conf_file}.bak"
        fi
    done
fi

cat <<EOF > /etc/sddm.conf.d/theme.conf
[Theme]
Current=$THEME_NAME
EOF

echo "=========================================="
echo " SUCCESS! Theme '$THEME_NAME' successfully installed and activated!"
echo "=========================================="
echo ""
echo "To test the theme in a window without logging out, run:"
echo "  sddm-greeter-qt6 --test-mode --theme $TARGET_DIR"
echo ""
