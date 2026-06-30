#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# ANSI Color Codes for premium terminal styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Banner
clear
echo -e "${CYAN}${BOLD}"
echo "██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗"
echo "██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║"
echo "██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║"
echo "██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║"
echo "██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║"
echo "╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝"
echo -e "                 SDDM Theme Installer Script${NC}\n"

# Verify we can elevate or are already root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}This script requires administrative privileges to install the theme.${NC}"
    echo -e "Elevating privileges using sudo..."
    exec sudo bash "$0" "$@"
fi

# Detect Distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_NAME=$NAME
    else
        DISTRO="unknown"
        DISTRO_NAME="Unknown Linux Distribution"
    fi
}
detect_distro

echo -e "Detected System: ${GREEN}${BOLD}${DISTRO_NAME}${NC}\n"

# Install Dependencies
install_dependencies() {
    echo -e "${CYAN}${BOLD}[1/3] Checking dependencies...${NC}"
    
    case "$DISTRO" in
        arch|manjaro|artix|endeavouros)
            DEPS=("sddm" "qt6-5compat" "qt6-declarative" "qt6-svg")
            PM="pacman"
            INSTALL_CMD="pacman -S --needed --noconfirm"
            ;;
        fedora|nobara)
            DEPS=("sddm" "qt6-qt5compat" "qt6-qtdeclarative" "qt6-qtsvg")
            PM="dnf"
            INSTALL_CMD="dnf install -y"
            ;;
        ubuntu|debian|pop|mint)
            DEPS=("sddm" "qml6-module-qt5compat-graphicaleffects" "qml6-module-qtqml" "qml6-module-qtquick-layouts" "qml6-module-qtquick-controls")
            PM="apt"
            INSTALL_CMD="apt-get install -y"
            ;;
        *)
            DEPS=()
            PM="unknown"
            ;;
    esac

    if [ "$PM" != "unknown" ]; then
        echo -e "Required packages for ${DISTRO_NAME}: ${YELLOW}${DEPS[*]}${NC}"
        read -rp "Would you like to install/verify these dependencies? (y/n): " install_deps
        if [[ "$install_deps" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Running dependency installation...${NC}"
            if [ "$PM" = "pacman" ]; then
                $INSTALL_CMD "${DEPS[@]}"
            else
                $INSTALL_CMD "${DEPS[@]}"
            fi
            echo -e "${GREEN}Dependencies checked successfully.${NC}\n"
        else
            echo -e "${YELLOW}Skipping dependency installation. Ensure packages are installed manually.${NC}\n"
        fi
    else
        echo -e "${YELLOW}Automatic dependency installation is not supported for your distribution: ${DISTRO_NAME}.${NC}"
        echo -e "Please ensure you have SDDM, Qt6 Declarative, and Qt6 5Compat Graphical Effects installed manually.\n"
    fi
}

install_dependencies

# Install the theme files
install_theme() {
    echo -e "${CYAN}${BOLD}[2/3] Installing theme files...${NC}"
    
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    THEME_DIR="/usr/share/sddm/themes/phantom-sddm"
    
    # Check if target directory already exists
    if [ -d "$THEME_DIR" ]; then
        echo -e "${YELLOW}Existing installation found at ${THEME_DIR}.${NC}"
        read -rp "Overwrite existing installation? (y/n): " overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            echo -e "${RED}Installation cancelled by user.${NC}"
            exit 0
        fi
        echo -e "${BLUE}Removing old theme files...${NC}"
        rm -rf "$THEME_DIR"
    fi
    
    echo -e "${BLUE}Creating directory: ${THEME_DIR}${NC}"
    mkdir -p "$THEME_DIR"
    
    echo -e "${BLUE}Copying theme files...${NC}"
    # Copy essential QML/config files and directories
    cp -r "$SCRIPT_DIR/CustomComboBox.qml" \
          "$SCRIPT_DIR/Main.qml" \
          "$SCRIPT_DIR/metadata.desktop" \
          "$SCRIPT_DIR/theme.conf" \
          "$SCRIPT_DIR/assets" \
          "$SCRIPT_DIR/fonts" \
          "$THEME_DIR/"
          
    # Optionally copy LICENSE and png if present
    [ -f "$SCRIPT_DIR/LICENSE" ] && cp "$SCRIPT_DIR/LICENSE" "$THEME_DIR/"
    [ -f "$SCRIPT_DIR/phantom-sddm.png" ] && cp "$SCRIPT_DIR/phantom-sddm.png" "$THEME_DIR/"
    
    echo -e "${BLUE}Setting correct system permissions...${NC}"
    find "$THEME_DIR" -type d -exec chmod 755 {} \;
    find "$THEME_DIR" -type f -exec chmod 644 {} \;
    
    echo -e "${GREEN}Theme successfully installed to: ${THEME_DIR}${NC}\n"
}

install_theme

# Configure Theme
configure_theme() {
    echo -e "${CYAN}${BOLD}[3/3] Configuring SDDM theme...${NC}"
    
    read -rp "Would you like to set 'phantom-sddm' as the active SDDM theme? (y/n): " set_active
    if [[ "$set_active" =~ ^[Yy]$ ]]; then
        CONFIG_DIR="/etc/sddm.conf.d"
        CONFIG_FILE="${CONFIG_DIR}/10-theme.conf"
        
        echo -e "${BLUE}Ensuring directory exists: ${CONFIG_DIR}${NC}"
        mkdir -p "$CONFIG_DIR"
        
        if [ -f "$CONFIG_FILE" ]; then
            echo -e "${YELLOW}Backing up existing ${CONFIG_FILE} to ${CONFIG_FILE}.bak${NC}"
            cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
        fi
        
        echo -e "${BLUE}Writing new configuration to ${CONFIG_FILE}...${NC}"
        cat <<EOF > "$CONFIG_FILE"
[Theme]
Current=phantom-sddm
EOF
        echo -e "${GREEN}SDDM theme configuration updated successfully!${NC}\n"
    else
        echo -e "${YELLOW}Configuration skipped. To manually enable the theme, set Current=phantom-sddm in your SDDM configuration.${NC}\n"
    fi
}

configure_theme

# Test Theme
test_theme() {
    echo -e "${CYAN}${BOLD}Testing the theme...${NC}"
    read -rp "Would you like to test the installed theme in a window? (y/n): " run_test
    if [[ "$run_test" =~ ^[Yy]$ ]]; then
        # Check if sddm-greeter exists
        GREETER_BIN=""
        if command -v sddm-greeter-qt6 >/dev/null 2>&1; then
            GREETER_BIN="sddm-greeter-qt6"
        elif command -v sddm-greeter >/dev/null 2>&1; then
            GREETER_BIN="sddm-greeter"
        fi
        
        if [ -z "$GREETER_BIN" ]; then
            echo -e "${RED}Error: Could not find sddm-greeter or sddm-greeter-qt6 binary.${NC}"
            echo -e "Make sure SDDM is properly installed."
            return 1
        fi
        
        echo -e "${BLUE}Launching ${GREETER_BIN} in test-mode...${NC}"
        echo -e "${YELLOW}Note: If the window is black or fails to launch, ensure your X/Wayland display server is running and accessible.${NC}"
        
        # If running via sudo, we need to pass display variables to run greeter as the non-root user
        if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
            sudo -u "$SUDO_USER" DISPLAY="$DISPLAY" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" XAUTHORITY="$XAUTHORITY" "$GREETER_BIN" --test-mode --theme /usr/share/sddm/themes/phantom-sddm &
        else
            "$GREETER_BIN" --test-mode --theme /usr/share/sddm/themes/phantom-sddm &
        fi
        
        echo -e "${GREEN}Greeter window launched in background. Close the window when done testing.${NC}\n"
    fi
}

test_theme

echo -e "${GREEN}${BOLD}Installation process completed! Enjoy your Phantom SDDM Theme!${NC}"
