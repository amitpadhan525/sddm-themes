#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sddm-greeter-qt6 --test-mode --theme "$SCRIPT_DIR"
