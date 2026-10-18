#!/usr/bin/env bash
# ==============================================================================
# SDDM Themes - Interactive Nested Test Runner
# Allows live preview of any theme in a window without logging out or rebooting.
# ==============================================================================

set -euo pipefail

THEMES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../themes" && pwd)"

echo "=== SDDM Themes Nested Preview Runner ==="

# Check available preview tools
PREVIEW_BIN=""
if command -v sddm-greeter-kcm >/dev/null 2>&1; then
    PREVIEW_BIN="sddm-greeter-kcm"
elif command -v sddm-greeter >/dev/null 2>&1; then
    PREVIEW_BIN="sddm-greeter --test-mode --theme"
fi

if [[ -z "$PREVIEW_BIN" ]]; then
    echo "Notice: Neither 'sddm-greeter-kcm' nor 'sddm-greeter' was found in PATH."
    echo "To test SDDM themes in a nested window on Arch/Fedora/Debian:"
    echo "  Arch Linux: sudo pacman -S sddm-kcm"
    echo "  Debian/Ubuntu: sudo apt install sddm-theme-dialog"
    echo ""
    echo "Available local themes in this repository:"
    for theme in "$THEMES_DIR"/*; do
        if [[ -d "$theme" ]]; then
            echo "  - $(basename "$theme")"
        fi
    done
    exit 0
fi

THEME_NAME="${1:-}"

if [[ -z "$THEME_NAME" ]]; then
    echo "Usage: ./test-theme-nesting.sh <theme-name>"
    echo "Available themes:"
    for theme in "$THEMES_DIR"/*; do
        if [[ -d "$theme" ]]; then
            echo "  - $(basename "$theme")"
        fi
    done
    exit 1
fi

TARGET_PATH="$THEMES_DIR/$THEME_NAME"

if [[ ! -d "$TARGET_PATH" ]]; then
    echo "Error: Theme directory not found at $TARGET_PATH"
    exit 1
fi

echo "Launching nested preview for: $THEME_NAME"
if [[ "$PREVIEW_BIN" == "sddm-greeter-kcm" ]]; then
    sddm-greeter-kcm --test --theme "$TARGET_PATH"
else
    sddm-greeter --test-mode --theme "$TARGET_PATH"
fi
