#!/usr/bin/env bash
export QML_XHR_ALLOW_FILE_READ=1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sddm-greeter-qt6 --test-mode --theme "$SCRIPT_DIR"

