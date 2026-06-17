# Makefile — instala/desinstala el service menu «conversor-dolphin» (KDE / KF6).
#
#   sudo make install                  # instalación normal del sistema (en /usr)
#   make install DESTDIR=/ruta/pkg     # para empaquetado (lo usa el PKGBUILD)
#   sudo make uninstall
#
# Tras instalar/desinstalar, refresca el menú de Dolphin con:
#   kbuildsycoca6  &&  (killall dolphin 2>/dev/null; true)

PREFIX  ?= /usr
DESTDIR ?=

NAME       := conversor-dolphin
SHAREDIR   := $(DESTDIR)$(PREFIX)/share
SCRIPTDIR  := $(SHAREDIR)/$(NAME)
MENUDIR    := $(SHAREDIR)/kio/servicemenus
LICENSEDIR := $(SHAREDIR)/licenses/$(NAME)

.PHONY: install uninstall

install:
	install -Dm755 pdf-unir.sh                       $(SCRIPTDIR)/pdf-unir.sh
	install -Dm755 pdf-dividir.sh                    $(SCRIPTDIR)/pdf-dividir.sh
	install -Dm644 conversor-dolphin-unir.desktop    $(MENUDIR)/conversor-dolphin-unir.desktop
	install -Dm644 conversor-dolphin-dividir.desktop $(MENUDIR)/conversor-dolphin-dividir.desktop
	install -Dm644 LICENSE                           $(LICENSEDIR)/LICENSE

uninstall:
	rm -f $(SCRIPTDIR)/pdf-unir.sh $(SCRIPTDIR)/pdf-dividir.sh
	rm -f $(MENUDIR)/conversor-dolphin-unir.desktop
	rm -f $(MENUDIR)/conversor-dolphin-dividir.desktop
	rm -f $(LICENSEDIR)/LICENSE
	rmdir $(SCRIPTDIR) $(LICENSEDIR) 2>/dev/null || true
