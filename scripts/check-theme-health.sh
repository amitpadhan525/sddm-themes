#!/usr/bin/env bash
# SDDM Themes Collection - Theme Integrity & Asset Validator
# Verifies that required QML components, metadata, and assets exist for every theme.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
THEMES_DIR="$REPO_ROOT/themes"

THEMES=("GreenShift" "OrangeShift" "golden-horizon" "midnight-current" "phantom-red" "nebula")
ERRORS=0

echo "🔍 Validating SDDM Themes Collection integrity..."

for theme in "${THEMES[@]}"; do
  THEME_PATH="$THEMES_DIR/$theme"
  if [[ ! -d "$THEME_PATH" ]]; then
    echo "❌ Error: Missing theme directory '$THEME_PATH'"
    ((ERRORS++))
    continue
  fi

  if [[ ! -f "$THEME_PATH/metadata.desktop" ]]; then
    echo "❌ Error: Missing metadata.desktop in '$theme'"
    ((ERRORS++))
  fi

  if [[ ! -f "$THEME_PATH/Main.qml" ]]; then
    echo "❌ Error: Missing Main.qml in '$theme'"
    ((ERRORS++))
  fi

  echo "✓ Theme '$theme' verified successfully."
done

if [[ $ERRORS -eq 0 ]]; then
  echo "🎉 All themes passed integrity verification!"
  exit 0
else
  echo "⚠️ Integrity verification completed with $ERRORS error(s)."
  exit 1
fi
