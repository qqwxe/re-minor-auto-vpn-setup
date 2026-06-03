PREFIX ?= /usr
BINDIR = $(PREFIX)/bin
DESTDIR ?=

.PHONY: all install uninstall clean deb rpm pkg

all:

install:
	install -Dm755 src/usr/bin/reminor $(DESTDIR)$(BINDIR)/reminor

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/reminor

clean:
	rm -rf debian/reminor debian/.debhelper debian/files debian/*.debhelper.log debian/*.substvars

deb:
	dpkg-buildpackage -us -uc -b

rpm: reminor.spec
	rpmbuild -bb --build-inplace reminor.spec

pkg: PKGBUILD
	makepkg -si
