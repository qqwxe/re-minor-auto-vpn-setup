#!/bin/bash
set -e

cd "$(dirname "$0")"

MINT='\033[38;5;121m'
PURPLE='\033[38;5;141m'
PINK='\033[38;5;211m'
CYAN='\033[38;5;117m'
RESET='\033[0m'

echo -e "${PINK}re minor ${CYAN}packager${RESET}"
echo "------------------------------"

mkdir -p dist

if command -v dpkg-buildpackage >/dev/null 2>&1; then
    echo -e "${CYAN}[*] Building .deb...${RESET}"
    dpkg-buildpackage -us -uc -b
    cp ../reminor_*.deb dist/
else
    echo -e "${PINK}[!] dpkg-buildpackage not found, skipping .deb${RESET}"
fi

if command -v rpmbuild >/dev/null 2>&1; then
    echo -e "${CYAN}[*] Building .rpm...${RESET}"
    mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/RPMS/noarch
    cp src/usr/bin/reminor ~/rpmbuild/SOURCES/
    rpmbuild -bb --define "_topdir $HOME/rpmbuild" \
             --define "_sourcedir $HOME/rpmbuild/SOURCES" \
             reminor.spec
    cp ~/rpmbuild/RPMS/noarch/reminor-*.rpm dist/
else
    echo -e "${PINK}[!] rpmbuild not found, skipping .rpm${RESET}"
fi

if command -v makepkg >/dev/null 2>&1; then
    echo -e "${CYAN}[*] Building .pkg.tar.zst...${RESET}"
    makepkg -s
    cp reminor-*.pkg.tar.zst dist/
else
    echo -e "${PINK}[!] makepkg not found, skipping .pkg.tar.zst${RESET}"
fi

echo -e "${MINT}[+] Packages in ./dist/${RESET}"
ls -la dist/
