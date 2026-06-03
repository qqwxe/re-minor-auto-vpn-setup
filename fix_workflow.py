new_workflow = """name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4

      - name: Build packages
        run: |
          # Build .deb
          sudo apt-get update && sudo apt-get install -y dpkg-dev
          mkdir -p pkg-deb/DEBIAN pkg-deb/usr/bin
          cp reminor-pkg/src/usr/bin/reminor pkg-deb/usr/bin/
          cat > pkg-deb/DEBIAN/control << 'EOF'
Package: reminor
Version: 1.0
Section: net
Priority: optional
Architecture: amd64
Depends: bash, curl, wget, jq, qrencode, openssl, uuid-runtime, net-tools, bc, iproute2
Maintainer: re minor <dev@reminor.local>
Description: re minor VPN auto-configurator
 One-click deployment of VLESS+Reality, Trojan, Hysteria2
 and AmneziaWG via sing-box.
EOF
          chmod 755 pkg-deb/DEBIAN
          dpkg-deb --build pkg-deb reminor_1.0-1_amd64.deb

          # Build .rpm
          sudo apt-get install -y rpm
          mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/RPMS/noarch
          cp reminor-pkg/src/usr/bin/reminor ~/rpmbuild/SOURCES/
          rpmbuild -bb --define "_topdir $HOME/rpmbuild" \
                   --define "_sourcedir $HOME/rpmbuild/SOURCES" \
                   reminor-pkg/reminor.spec || true
          cp ~/rpmbuild/RPMS/noarch/reminor-*.rpm . || true

      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            reminor_1.0-1_amd64.deb
            reminor-*.rpm
            reminor-pkg/install.sh
            reminor-pkg/PKGBUILD
            reminor-pkg/reminor.spec
          generate_release_notes: true
"""

f = open(r'c:\Users\ultra\Downloads\протокоыл\.github\workflows\release.yml', 'w', encoding='utf-8')
f.write(new_workflow)
f.close()
print('done')
