#!/bin/bash
set -e

REPO_URL="https://github.com/qqwxe/re-minor-VPN-AUTO-INSTALL-/releases/latest/download"

MINT='\033[38;5;121m'
PURPLE='\033[38;5;141m'
PINK='\033[38;5;211m'
CYAN='\033[38;5;117m'
RESET='\033[0m'

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian) echo "deb" ;;
            fedora|rhel|centos|almalinux|rocky) echo "rpm" ;;
            arch|manjaro) echo "arch" ;;
            *) echo "unknown" ;;
        esac
    else
        echo "unknown"
    fi
}

echo -e "${PINK}re minor ${CYAN}installer${RESET}"
echo "------------------------------"

OS=$(detect_os)
case "$OS" in
    deb)
        echo -e "${CYAN}[*] Debian/Ubuntu detected${RESET}"
        curl -sL -o /tmp/reminor.deb "${REPO_URL}/reminor_1.0-1_amd64.deb"
        sudo dpkg -i /tmp/reminor.deb || sudo apt-get install -f -y
        rm -f /tmp/reminor.deb
        ;;
    rpm)
        echo -e "${CYAN}[*] RHEL/Fedora detected${RESET}"
        curl -sL -o /tmp/reminor.rpm "${REPO_URL}/reminor-1.0-1.noarch.rpm"
        sudo rpm -i /tmp/reminor.rpm || sudo dnf install -y /tmp/reminor.rpm
        rm -f /tmp/reminor.rpm
        ;;
    arch)
        echo -e "${CYAN}[*] Arch/Manjaro detected${RESET}"
        TMPDIR=$(mktemp -d)
        cd "$TMPDIR"
        curl -sL -o PKGBUILD "${REPO_URL}/PKGBUILD"
        curl -sL -o reminor "${REPO_URL}/reminor"
        makepkg -si --noconfirm
        cd -
        rm -rf "$TMPDIR"
        ;;
    *)
        echo -e "${PINK}[!] Unknown distro, falling back to direct install${RESET}"
        sudo curl -sL -o /usr/local/bin/reminor "${REPO_URL}/reminor"
        sudo chmod +x /usr/local/bin/reminor
        ;;
esac

echo -e "${MINT}[+] Done. Run: reminor${RESET}"
