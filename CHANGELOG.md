# Changelog

Todas las novedades relevantes de este proyecto se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/).

## [1.0.0] — 2026-06-17

Primera versión empaquetada y lista para AUR.

### Añadido
- **Empaquetado AUR**: `PKGBUILD` + `.SRCINFO` autocontenidos y `*.install`
  con aviso para refrescar la caché de menús.
- **Makefile** con `install` / `uninstall` respetando `DESTDIR` y `PREFIX`
  (fuente única de la lógica de instalación, usada también por el PKGBUILD).
- **Licencia MIT**.
- **Avisos de éxito**: popup pasivo de `kdialog` indicando dónde quedó el resultado.
- **Menús bilingües** (español / inglés).

### Cambiado
- Scripts endurecidos: ficheros temporales con `mktemp` + `trap`, cancelación
  silenciosa al cerrar un diálogo, validación de entrada más robusta y uso
  seguro de `set -euo pipefail`.
- Iconos corregidos: `Icon=pdfunite` (no existía en el tema) → `merge` y `split`
  de Breeze.
- Los scripts se instalan en `/usr/share/conversor-dolphin/` y los *service menus*
  llevan nombre propio para no colisionar con otros paquetes.

### Eliminado
- `instalar.sh` y `desinstalar.sh`, reemplazados por el `Makefile`.

### Verificado
- `shellcheck` limpio en ambos scripts.
- 15 pruebas funcionales end-to-end (división por páginas/rango/bloques, unión con
  reordenación y casos de error) en verde.
- Construcción con `makepkg`, contenido y metadatos del paquete revisados.
