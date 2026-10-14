# conversor-dolphin

Menús contextuales para **Dolphin / KDE Frameworks 6** que convierten archivos
locales con herramientas del sistema y diálogos de `kdialog`.

| Selección | Operaciones |
| --- | --- |
| Un PDF | Dividir por páginas, rango o bloques; PNG/JPG a 150/300 ppp; texto; compresión; OCR en español |
| Dos o más PDF | Unir, reordenar y excluir documentos antes de confirmar |
| Imágenes | PDF combinado; JPG, PNG, WebP, AVIF y TIFF |
| SVG / SVGZ | PNG al tamaño original o PDF vectorial |
| Audio | MP3, FLAC, WAV, OGG Vorbis, Opus y M4A AAC |
| Vídeo | MP4 H.264, MP4 720p/1080p, WebM VP9, GIF animado, extraer MP3 y comprimir |
| Libros electrónicos | PDF mediante Calibre |
| Documentos de oficina | PDF mediante LibreOffice |

Los nombres del menú están disponibles en español e inglés. Los diálogos están
en español. Las acciones solo aparecen sobre archivos locales del tipo apropiado;
no se ofrecen sobre URLs remotas de KIO. Un recurso montado como sistema de
archivos local se trata como cualquier otra carpeta.

## Resultados y límites

- Cada resultado queda junto al original. Si el nombre está ocupado, se añade
  `-2`, `-3`… También se respetan carpetas y enlaces simbólicos existentes.
  Las ejecuciones simultáneas publican resultados sin reemplazarse entre sí.
- Las páginas divididas y las imágenes de un PDF se agrupan en una subcarpeta.
  Se admiten espacios, porcentajes, saltos de línea y nombres que empiezan por `-`.
- La conversión se realiza en temporales privados. Solo se publica el resultado
  terminado; se limpian los temporales al cancelar, fallar o recibir SIGINT/SIGTERM.
  Un cierre forzoso (SIGKILL) o un apagado puede dejar carpetas ocultas
  `.conversor-dolphin.*`; no se eliminan automáticamente temporales de otra ejecución.
- En un lote, los resultados ya completados se conservan si falla un archivo
  posterior. El diálogo de error indica cuántos se completaron. Una entrada
  inexistente o ilegible se detecta antes de iniciar la conversión.
- **Imágenes a PDF:** orden natural por ruta (`foto1`, `foto2`, `foto10`). JPEG
  se incrusta sin recodificar. Si `img2pdf` no entiende un formato, se utiliza
  ImageMagick para decodificarlo a PNG; por ejemplo, HEIC/HEIF. No se añade
  compresión con pérdida, aunque el PDF puede ser grande. Se conservan las
  páginas/fotogramas que la herramienta decodifique.
- **Imagen a otro formato:** solo se utiliza el primer fotograma/página. Si hay
  varios, se pide confirmación. Esta acción no conserva animaciones. JPG compone
  la transparencia sobre blanco; JPG, WebP y AVIF usan compresión con pérdida.
- **MP4:** H.264 con color `yuv420p` y dimensiones pares. 720p/1080p limitan la
  altura sin agrandarla; el perfil general puede añadir un píxel de borde para
  admitir dimensiones impares. No se garantiza compatibilidad con todos los equipos.
- **Comprimir PDF/vídeo:** solo se guarda la copia si ocupa menos que el original.
  La recodificación puede perder calidad y no garantiza conservar todos los
  metadatos, pistas o características del documento.
- Calibre no elimina DRM. LibreOffice depende de las fuentes disponibles para
  reproducir la maquetación. OCR utiliza español y omite páginas que ya tienen texto.
- Las tareas pesadas se ejecutan fuera del proceso de Dolphin. Hay avisos al
  empezar vídeo/libros y al terminar, pero aún no hay progreso ni cancelación
  durante la conversión. Los conversores no aíslan las herramientas externas.

## Dependencias

**Obligatorias:** Bash, utilidades GNU habituales de Linux, `poppler` y `kdialog`.
En Arch, Bash/coreutils forman parte del sistema base.

| Función | Paquetes opcionales en Arch |
| --- | --- |
| Comprimir PDF | `ghostscript` |
| Imágenes a PDF | `img2pdf` |
| Convertir imágenes; alternativa para HEIC/HEIF a PDF | `imagemagick`; `libheif` para HEIC/HEIF y AVIF |
| Audio y vídeo | `ffmpeg` |
| SVG | `librsvg` |
| Libros | `calibre` |
| Oficina | `libreoffice-still` o `libreoffice-fresh` |
| OCR | `ocrmypdf` (AUR), `tesseract-data-spa` |

Cada acción informa de la herramienta que falta. En otras distribuciones hay
que adaptar el nombre del paquete y el gestor indicado en el diálogo.

## Instalación

En Arch / EndeavourOS, la última **versión publicada** está en AUR:

```bash
paru -S conversor-dolphin             # o: yay -S conversor-dolphin
```

La instalación desde AUR no necesita conservar una copia local del repositorio
de desarrollo.

Para instalar el **código de este directorio** manteniendo una instalación
gestionada por pacman:

```bash
python3 -B tests/paquete_local.py --output-dir tests/.tmp/paquetes-locales
```

El comando construye, verifica y conserva el paquete; muestra su ruta exacta.
Instala ese archivo con `sudo pacman -U` y después ejecuta `kbuildsycoca6`.
No reemplaza un paquete que ya exista en la carpeta de salida. El paquete local
conserva el número de versión del PKGBUILD vigente, aunque incluye los cambios
de desarrollo. No equivale a publicar una versión nueva en AUR.

Para una instalación **manual, sin pacman**:

```bash
make check
sudo make install
kbuildsycoca6
```

Cierra todas las ventanas de Dolphin y vuelve a abrirlo si no actualiza los menús.
`make install` admite `PREFIX` (por defecto `/usr`) y `DESTDIR` para instalaciones
en una raíz temporal. Las rutas `Exec` se ajustan al prefijo, sin incluir `DESTDIR`.

`makepkg -si` utiliza el tarball de la etiqueta publicada que indica `PKGBUILD`,
**no los cambios locales**. Para comprobar el árbol actual sin instalarlo:

```bash
make test-package
```

Cada nueva versión llega a AUR cuando se actualiza allí el PKGBUILD con su
etiqueta y suma de comprobación. Subir código a GitHub no actualiza por sí mismo
el paquete de AUR. Consulta PACKAGING para preparar esa actualización.

El paquete se llama `conversor-dolphin`. No necesita una variante `-bin`: contiene
scripts Bash y archivos de menú, sin un ejecutable que haya que compilar.

Si quedan menús de instalaciones antiguas, localiza `pdf-unir.desktop` y
`pdf-dividir.desktop` en `/usr/share/kio/servicemenus/` y retira únicamente esos
archivos y sus scripts antiguos. No borres la carpeta de menús ni archivos de
otros paquetes.

## Desinstalación

```bash
sudo pacman -R conversor-dolphin       # instalación como paquete
sudo make uninstall                  # instalación manual, mismo PREFIX
```

Después ejecuta `kbuildsycoca6`. La desinstalación manual conserva archivos ajenos
al proyecto y no elimina las conversiones realizadas.

## Desarrollo

Para obtener de nuevo las fuentes:

```bash
git clone https://github.com/13Stokes31/conversor-dolphin.git
cd conversor-dolphin
```

```bash
make check             # sintaxis Bash y ShellCheck
make test              # pruebas de comportamiento y conversores disponibles
make test-integration  # incluye LibreOffice, Calibre y OCR
make test-package      # construir e inspeccionar un paquete local en Arch
make test-kde          # opcional: verificar los menús ya instalados con KIO
```

`test-kde` requiere CMake, un compilador C++ y los archivos de desarrollo de
Qt 6 Widgets y KF6 KIO. Comprueba iconos y filtros mediante la API nativa,
sin abrir ventanas ni ejecutar acciones. No son dependencias de la aplicación.

Consulta [TESTING.md](TESTING.md) para cobertura y comprobaciones manuales,
[ROADMAP.md](ROADMAP.md) para trabajo pendiente, [PACKAGING.md](PACKAGING.md) para
publicar y [CHANGELOG.md](CHANGELOG.md) para el historial.

Los diez conversores cargan `comun.sh`, que gestiona diálogos, validación,
temporales y publicación. Los ocho `.desktop` definen las acciones por MIME.
`Makefile` centraliza la instalación y `PKGBUILD` la utiliza para AUR.

MIT — [LICENSE](LICENSE).
