# conversor-dolphin

Menú contextual de **Dolphin** (KDE Plasma 6 / KF6) para **gestionar** y **convertir**
archivos: PDF, imágenes, audio, vídeo y documentos de oficina. Scripts de shell ligeros
sobre poppler, ghostscript, img2pdf, ImageMagick, ffmpeg, LibreOffice y ocrmypdf, con `kdialog`.

## Acciones

Distintos submenús de clic derecho según el tipo de archivo (menús bilingües ES/EN):

### «Acciones PDF»
- **Sobre un PDF:** dividir (cada página · rango `3-7` · bloques de N) · convertir a
  imágenes (PNG/JPG, 150/300 ppp) · a texto · comprimir · **OCR** (texto buscable).
- **Sobre 2 o más PDF:** unir (con diálogo para reordenar; 2 → `a_b.pdf`, 3+ → `a_y_otros.pdf`).

### «Convertir imagen»
Sobre imágenes (JPG/PNG/WebP/AVIF/TIFF/BMP/GIF/**HEIC**): a PDF (une varias sin pérdida)
o a otro formato (JPG/PNG/WebP/AVIF/TIFF).

### «Convertir SVG»
Sobre archivos `.svg`: a PNG (rasterizado) o a PDF (vectorial, sin pérdida).

### «Convertir audio»
Sobre audio: a MP3 / FLAC / WAV / OGG / Opus / M4A.

### «Convertir vídeo»
Sobre vídeo: a MP4 (H.264) · a MP4 1080p · a MP4 720p (reescalan sin agrandar) ·
WebM (VP9) · GIF animado · extraer audio (MP3) · comprimir.

### «Convertir libro»
Sobre libros electrónicos (EPUB, MOBI, AZW, AZW3, FB2): a PDF (Calibre).

### «Convertir documento»
Sobre documentos de oficina (docx, odt, xlsx, pptx, rtf…): a PDF (LibreOffice).

Convenciones: cada resultado se deja junto al original sin sobrescribir (añade `-2`,
`-3`…); las divisiones y las imágenes de un PDF van a una subcarpeta. Aviso pasivo al
terminar; diálogo de error (y limpieza de lo dejado a medias) si algo falla.

## Dependencias

**Obligatorias:** `poppler` y `kdialog`.

**Opcionales** (cada función avisa con el comando exacto si le falta su herramienta):
`ghostscript` (comprimir PDF), `img2pdf` (imágenes→PDF), `imagemagick` (convertir imágenes),
`ffmpeg` (audio y vídeo), `librsvg` (SVG→PNG/PDF), `calibre` (libros→PDF),
`libreoffice-still` (oficina→PDF), `ocrmypdf` + `tesseract-data-spa`
(OCR). Casi todas en los repos oficiales de Arch; **`ocrmypdf` está en AUR**
(`yay -S ocrmypdf`).

> Para **HEIC/HEIF** (fotos de móvil) y para **escribir AVIF**, ImageMagick necesita
> además el delegado `libheif` (`sudo pacman -S libheif`).

## Instalación

### Desde AUR  *(recomendado en Arch / EndeavourOS)*

Una vez publicado el paquete (ver [PACKAGING.md](PACKAGING.md)):

```bash
yay -S conversor-dolphin      # o: paru -S conversor-dolphin
```

### Compilando el paquete aquí mismo (makepkg)

```bash
makepkg -si        # construye e instala con pacman
kbuildsycoca6      # refresca la caché de menús de KDE
```

### Manual, sin paquete *(cualquier distro con KF6)*

```bash
sudo make install
kbuildsycoca6
```

Tras instalar, **reinicia Dolphin** (cierra todas sus ventanas) si estaba abierto.

### ⚠️ Si ya lo tenías instalado «a mano» (versiones anteriores)

Las versiones antiguas se copiaban con un `instalar.sh` a otras rutas. Para que
no aparezcan **menús duplicados**, elimina una sola vez los ficheros antiguos:

```bash
sudo rm -f /usr/share/kio/servicemenus/pdf-unir.desktop \
           /usr/share/kio/servicemenus/pdf-dividir.desktop \
           /usr/share/kio/servicemenus/scripts/pdf-unir.sh \
           /usr/share/kio/servicemenus/scripts/pdf-dividir.sh
sudo rmdir /usr/share/kio/servicemenus/scripts 2>/dev/null
kbuildsycoca6
```

## Desinstalar

```bash
sudo pacman -R conversor-dolphin     # si se instaló como paquete
sudo make uninstall                   # si se instaló con «make install»
```

## Estructura

```
*.sh                                  → lógica de cada conversión (en /usr/share/conversor-dolphin/)
conversor-dolphin-*.desktop           → service menus (en /usr/share/kio/servicemenus/)
Makefile                              → install / uninstall (DESTDIR + PREFIX)
PKGBUILD + .SRCINFO + *.install       → empaquetado para AUR
```

## Licencia

MIT — ver [LICENSE](LICENSE).
