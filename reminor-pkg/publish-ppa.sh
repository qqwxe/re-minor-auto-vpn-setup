#!/bin/bash
set -e

echo "=== re minor PPA Publisher ==="
echo ""
echo "This script builds and uploads the .deb to Launchpad PPA."
echo "Prerequisites:"
echo "  1. GPG key created and uploaded to Launchpad"
echo "  2. PPA activated: ppa:qqwxe/reminor"
echo ""

# Install build deps
sudo apt-get update
sudo apt-get install -y build-essential debhelper devscripts dput

# Build source package
cd "$(dirname "$0")"
dpkg-buildpackage -S -sa -d

# Upload to PPA
cd ..
dput ppa:qqwxe/reminor reminor_1.0-1_source.changes

echo ""
echo "=== Done! Package uploaded to ppa:qqwxe/reminor ==="
echo "It will be available in a few minutes."
