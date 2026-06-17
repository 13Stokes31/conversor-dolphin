# conversor-dolphin

Menú contextual de **Dolphin** (KDE Plasma 6 / KF6) para **unir**, **dividir** y
**convertir** archivos PDF, imágenes y documentos de oficina. Scripts de shell
ligeros sobre poppler, ghostscript, img2pdf, LibreOffice y ocrmypdf, con `kdialog`.

## Acciones

Submenú **«Acciones PDF» / «PDF Actions»** (bilingüe ES/EN) al hacer clic derecho,
según lo que selecciones:

**Sobre un PDF:**
- **Dividir**: cada página · extraer un rango (`3-7`) · en bloques de N páginas.
- **Convertir a imágenes** (PNG/JPG, 150/300 ppp) · **a texto** plano.
- **Comprimir** (reduce el tamaño con ghostscript).
- **OCR**: añade una capa de texto buscable (ocrmypdf).

**Sobre 2 o más PDF:** **Unir** (con diálogo para reordenar; 2 → `a_b.pdf`, 3+ → `a_y_otros.pdf`).

**Sobre imágenes** (PNG/JPG/WebP/TIFF/BMP): **Unir en un PDF** sin pérdida (img2pdf).

**Sobre documentos de oficina** (docx, odt, xlsx, pptx, rtf…): **Convertir a PDF** (LibreOffice).

Convenciones: las divisiones y las imágenes van a una subcarpeta junto al original;
el resto se deja al lado sin sobrescribir (añade `-2`, `-3`…). Aviso pasivo al terminar;
diálogo de error (y limpieza de lo dejado a medias) si algo falla.

## Dependencias

**Obligatorias:** `poppler` y `kdialog`.

**Opcionales** (cada función avisa con el comando exacto si le falta su herramienta):
`ghostscript` (comprimir), `img2pdf` (imágenes→PDF), `libreoffice-still` (oficina→PDF),
`ocrmypdf` + `tesseract-data-spa` (OCR). Todas en los repos oficiales de Arch.

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
pdf-unir.sh / pdf-dividir.sh          → lógica (instalados en /usr/share/conversor-dolphin/)
conversor-dolphin-*.desktop           → service menus (en /usr/share/kio/servicemenus/)
Makefile                              → install / uninstall (DESTDIR + PREFIX)
PKGBUILD + .SRCINFO + *.install       → empaquetado para AUR
```

## Licencia

MIT — ver [LICENSE](LICENSE).
