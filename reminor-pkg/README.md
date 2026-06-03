# re minor packager

One script, three package formats. Publish once, install everywhere.

## End-user install (one-liner)

```bash
curl -sL https://yourdomain.com/install.sh | bash
```

Then run `reminor` from anywhere.

## Build locally

```bash
cd reminor-pkg
chmod +x build.sh
./build.sh
```

## Debian / Ubuntu (APT)

**Build .deb:**
```bash
cd reminor-pkg
dpkg-buildpackage -us -uc -b
```

**Publish to Launchpad PPA (one-time setup):**
1. Create account at [launchpad.net](https://launchpad.net)
2. Create PPA: `ppa:yourname/reminor`
3. Sign .deb with GPG
4. Upload: `dput ppa:yourname/reminor ../reminor_1.0-1_amd64.changes`

**User install after PPA:**
```bash
sudo add-apt-repository ppa:yourname/reminor
sudo apt update
sudo apt install reminor
```

## RHEL / CentOS / AlmaLinux / Fedora (DNF)

**Build .rpm:**
```bash
cd reminor-pkg
rpmbuild -bb --build-inplace reminor.spec
```

**Publish to Fedora COPR (one-time setup):**
1. Create account at [copr.fedorainfracloud.org](https://copr.fedorainfracloud.org)
2. New project "reminor"
3. Upload spec + source archive
4. Build from SCM (GitHub repo URL)

**User install after COPR:**
```bash
sudo dnf copr enable yourname/reminor
sudo dnf install reminor
```

## Arch / Manjaro (Pacman)

**Publish to AUR (one-time setup):**
1. Create account at [aur.archlinux.org](https://aur.archlinux.org)
2. Clone AUR repo: `git clone ssh://aur@aur.archlinux.org/reminor.git`
3. Copy `PKGBUILD` from this directory
4. `makepkg --printsrcinfo > .SRCINFO`
5. `git add PKGBUILD .SRCINFO && git commit -m "release" && git push`

**User install from AUR:**
```bash
yay -S reminor        # or
paru -S reminor       # or
makepkg -si           # manual
```

## GitHub Actions CI/CD

Push a tag `v1.0` and GitHub automatically builds all three packages:

```bash
git tag v1.0
git push origin v1.0
```

Artifacts appear in GitHub Releases.

## Uninstall

```bash
sudo make uninstall         # from source
sudo apt remove reminor     # deb
sudo dnf remove reminor     # rpm
sudo pacman -R reminor      # arch
```
