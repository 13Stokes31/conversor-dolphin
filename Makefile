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

SCRIPTS := comun.sh pdf-unir.sh pdf-dividir.sh pdf-convertir.sh img-a-pdf.sh office-a-pdf.sh \
           img-convertir.sh audio-convertir.sh video-convertir.sh svg-convertir.sh \
           ebook-a-pdf.sh
MENUS   := conversor-dolphin-pdf.desktop conversor-dolphin-unir.desktop \
           conversor-dolphin-imagenes.desktop conversor-dolphin-oficina.desktop \
           conversor-dolphin-audio.desktop conversor-dolphin-video.desktop \
           conversor-dolphin-svg.desktop conversor-dolphin-ebook.desktop

.PHONY: install uninstall check test test-integration test-package test-kde

install:
	install -d "$(SCRIPTDIR)" "$(MENUDIR)" "$(LICENSEDIR)"
	install -m755 $(SCRIPTS) "$(SCRIPTDIR)/"
	@for menu in $(MENUS); do \
		sed -E 's@^Exec=/usr/share/$(NAME)/([^ ]+)@Exec="$(PREFIX)/share/$(NAME)/\1"@' \
			"$$menu" > "$(MENUDIR)/$$menu" || exit 1; \
		chmod 644 "$(MENUDIR)/$$menu" || exit 1; \
	done
	install -m644 LICENSE "$(LICENSEDIR)/"

uninstall:
	@for script in $(SCRIPTS); do rm -f -- "$(SCRIPTDIR)/$$script" || exit 1; done
	@for menu in $(MENUS); do rm -f -- "$(MENUDIR)/$$menu" || exit 1; done
	rm -f -- "$(LICENSEDIR)/LICENSE"
	rmdir -- "$(SCRIPTDIR)" "$(LICENSEDIR)" 2>/dev/null || true

check:
	@for script in $(SCRIPTS); do bash -n "$$script" || exit 1; done
	shellcheck -x $(SCRIPTS)

test:
	python3 -B -m unittest discover -s tests -v

test-integration:
	CONVERSOR_TEST_INTEGRATION=1 python3 -B -m unittest discover -s tests -v

test-package:
	python3 -B tests/paquete_local.py

# Opcional: requiere los menús instalados y los archivos de desarrollo de Qt/KF6.
test-kde:
	cmake -S tests/kde -B tests/.tmp/kde-build
	cmake --build tests/.tmp/kde-build
	QT_QPA_PLATFORM=offscreen tests/.tmp/kde-build/menu-probe
