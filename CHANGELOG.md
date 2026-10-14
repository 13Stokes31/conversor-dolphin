# Changelog

Todas las novedades relevantes de este proyecto se documentan aquí.
Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/).

## [1.3.2] — 2026-10-14

### Corregido
- «Convertir imagen» hereda un icono de imagen; los menús PDF tienen icono PDF.
- Todos los menús se restringen a archivos locales (`X-KDE-Protocol=file`).
- HEIC/HEIF a PDF utiliza ImageMagick como alternativa cuando img2pdf no lee la entrada.
- Ordenación de imágenes con delimitadores nulos y rutas literales en ImageMagick,
  incluidos `%d` y corchetes; división de PDF admite porcentajes en nombres y
  carpetas, extensiones mayúsculas y números con ceros iniciales.
- Perfiles MP4 con dimensiones pares y `yuv420p`; compresión de vídeo guarda la
  copia solo si reduce el tamaño.
- Publicación de archivos y carpetas sin reemplazo, incluidas ejecuciones
  simultáneas y destinos que sean enlaces simbólicos.
- Temporales privados y limpieza común ante errores, cancelación e interrupciones;
  errores de lote informan de los resultados ya completados.
- La instalación adapta las rutas Exec a PREFIX y respeta rutas con espacios.

### Mejorado
- Confirmación antes de reducir una imagen animada o multipágina a su primer fotograma.
- El diálogo de unión explica cómo excluir documentos y valida índices decimales.
- URI del perfil aislado de LibreOffice escapada para TMPDIR con caracteres especiales.
- Mensaje de instalación referido a todos los conversores, no solo a PDF.

### Añadido
- `comun.sh` para la lógica de validación, temporales, diálogos y publicación.
- Suite persistente con kdialog simulado, conversores reales y pruebas de concurrencia.
- Objetivos `make check`, `test`, `test-integration` y `test-package`.
- Comprobación opcional `make test-kde` de los menús instalados con la API nativa;
  `--output-dir` permite conservar el paquete local verificado para instalarlo.
- ROADMAP y TESTING; README y PACKAGING actualizados. Retirados la propuesta inicial
  y el informe anterior, sustituidos por documentación vigente y pruebas reproducibles.

## [1.3.1-2] — 2026-07-30

Solo empaquetado, sin cambios de código ni de uso.

### Cambiado
- **PKGBUILD**: pasa de fuentes locales autocontenidas a descargar el tarball
  de la etiqueta `v1.3.1` de GitHub (petición de un revisor de AUR: el repo de
  AUR no debe alojar copias del código fuente). El repo de AUR ahora solo
  lleva `PKGBUILD`, `.SRCINFO` y `conversor-dolphin.install`.

## [1.3.1] — 2026-06-21

Correcciones y mejoras de calidad, sin cambios de uso.

### Corregido
- **Office → PDF:** dos documentos con el mismo nombre base (p. ej. `informe.docx`
  e `informe.odt`, o el mismo nombre en carpetas distintas) colisionaban en el
  directorio temporal y solo se generaba uno. Ahora se convierte de uno en uno.
- **Imagen → otro formato:** una entrada con varios fotogramas/páginas (GIF
  animado, TIFF multipágina) generaba múltiples ficheros sueltos y se saltaba el
  control de sobrescritura. Ahora se toma solo el primer fotograma (`[0]`).

### Mejorado
- **Vídeo → GIF:** paleta optimizada en dos pasadas (`palettegen`/`paletteuse`),
  bastante mejor calidad sin bandeado.
- **PDF → imágenes:** el aviso final cuenta las imágenes realmente generadas.
- Todos los conversores blindan nombres que empiezan por «-» (no se confunden
  con opciones de la herramienta).

### Añadido
- `optdepends` `libheif` (HEIC/HEIF de entrada y escritura de AVIF en ImageMagick),
  documentado también en el README.

## [1.3.0] — 2026-06-18

Más formatos: SVG, perfiles de vídeo y libros electrónicos. Cada uno con su propio
submenú filtrado por tipo de archivo (no aparece donde no toca).

### Añadido
- **SVG** (`svg-convertir.sh`, librsvg): submenú «Convertir SVG» con «a PNG»
  (rasterizado) y «a PDF» (vectorial). Solo aparece sobre archivos `.svg`.
- **Vídeo** (`video-convertir.sh`): perfiles «a MP4 1080p» y «a MP4 720p» que
  reescalan sin agrandar (`scale=-2:'min(N,ih)'`).
- **Libros electrónicos** (`ebook-a-pdf.sh`, Calibre): submenú «Convertir libro»
  con «a PDF», para EPUB / MOBI / AZW / AZW3 / FB2.
- `optdepends` nuevas: `librsvg` (SVG) y `calibre` (libros).

## [1.2.0] — 2026-06-17

Conversores de imagen, audio y vídeo: conversor-dolphin pasa de «manejo de PDF» a
conversor general de archivos.

### Añadido
- **Imagen** (`img-convertir.sh`, ImageMagick): JPG ↔ PNG ↔ WebP ↔ AVIF ↔ TIFF, y
  lectura de **HEIC/HEIF** (fotos de móvil). Submenú «Convertir imagen» (con «a PDF»).
- **Audio** (`audio-convertir.sh`, ffmpeg): MP3 / FLAC / WAV / OGG / Opus / M4A.
- **Vídeo** (`video-convertir.sh`, ffmpeg): a MP4 (H.264), WebM (VP9), GIF animado,
  extraer audio (MP3) y comprimir.
- `optdepends` nuevas: `imagemagick` y `ffmpeg`.

### Cambiado
- Menús reorganizados en submenús por tipo: «Acciones PDF», «Convertir imagen»,
  «Convertir audio», «Convertir vídeo», «Convertir documento».
- Cada acción de menú es un formato destino (un clic, sin diálogo).

## [1.1.0] — 2026-06-17

Conversiones de documentos, manteniendo la base mínima.

### Añadido
- **PDF → imágenes** (PNG/JPG a 150/300 ppp, con `pdftoppm`).
- **Imágenes → PDF** sin pérdida (`img2pdf`), una o varias.
- **Office → PDF** (docx/odt/xlsx/pptx/rtf…) con LibreOffice headless y perfil aislado.
- **PDF → texto** (`pdftotext`) y **comprimir PDF** (`ghostscript`, avisa si no reduce).
- **OCR** para PDF escaneados (`ocrmypdf`, idioma español por defecto).
- `optdepends` para que la instalación base siga siendo mínima (poppler + kdialog);
  cada función avisa con el comando exacto si le falta su herramienta opcional.

### Cambiado
- El service menu de PDF único pasa a `conversor-dolphin-pdf.desktop` y agrupa
  dividir + convertir. Nuevos menús para imágenes y para documentos de oficina.

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
