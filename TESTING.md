# Pruebas

## Ejecución

```bash
make check
make test
make test-integration
make test-package
make test-kde          # opcional, después de instalar
```

- `check` valida individualmente la sintaxis de los once archivos Bash y ejecuta
  ShellCheck con las funciones compartidas cargadas.
- `test` utiliza `unittest` de la biblioteca estándar de Python 3. No requiere
  frameworks, conexión a Internet, instalación del paquete ni sesión gráfica.
  Ejecuta las pruebas de cada conversor disponible; informa como omitidas las
  herramientas ausentes. LibreOffice, Calibre y OCR se reservan para integración.
- `test-integration` añade conversiones reales con LibreOffice, Calibre y OCR.
  Para la última es necesario el idioma español de Tesseract y la fuente
  DejaVu Sans usada en la imagen de prueba.
- `test-package` construye e inspecciona el código local con makepkg y bsdtar.
  No modifica el PKGBUILD original, no descarga fuentes ni instala el paquete.
  Véase PACKAGING para la diferencia respecto a construir la etiqueta publicada.
- `test-kde` utiliza la API nativa de KIO sobre los menús instalados. Requiere
  CMake, compilador C++ y archivos de desarrollo de Qt 6 Widgets/KF6 KIO.
  Comprueba seis acciones de imagen con icono `image-png`, siete acciones sobre
  un PDF con icono PDF, una acción para unir varios PDF, exclusión de selecciones
  mezcladas y ausencia del menú de imágenes en URLs sftp/smb simuladas.
  Usa Breeze y Qt offscreen; no abre ventanas, lanza conversiones ni contacta
  con servidores. La configuración del usuario debe tener habilitadas estas
  acciones de servicio para que las comprobaciones de recuento pasen.

La suite de Python crea sus archivos de prueba, perfiles y cachés bajo `tests/.tmp`,
ignorado por Git. Se borran al terminar cada prueba. `kdialog` se sustituye por
un ejecutable que registra sus argumentos y simula respuestas y cancelaciones;
las herramientas de conversión se ejecutan realmente, excepto cuando se inyecta
un fallo para comprobar la limpieza de una salida parcial.

Las pruebas usan tiempos máximos de ejecución. Un proceso abortado o un fallo
del sistema puede dejar artefactos en `tests/.tmp`; pueden retirarse cuando no
haya pruebas en marcha. Ninguna prueba toca la instalación de `/usr`.

## Cobertura

| Área | Comprobaciones |
| --- | --- |
| Menús | Protocolo local, acciones y scripts existentes, icono de imágenes y acción PDF |
| Publicación | Doce archivos y seis carpetas concurrentes; sufijos; destinos existentes y enlaces simbólicos rotos |
| Limpieza | Fallos con salidas parciales de PDF y libros; cancelación; SIGTERM; ausencia de temporales |
| Entradas | Nombres con espacios, porcentajes (incluido `%d`), corchetes, saltos de línea, extensión mayúscula y guion inicial; archivos ausentes, dañados y directorios sin permiso de escritura |
| PDF | Páginas, rango, página única, bloques, ceros iniciales, límites y desbordamiento; unión reordenada con exclusión; duplicados; texto; cuatro perfiles de imágenes; compresión útil e inútil |
| Imágenes | Orden natural, PDF combinado, HEIC real, JPEG incrustado con sus bytes originales, cinco formatos de salida; confirmación y cancelación de una imagen animada; lote con fallo parcial |
| Audio | Seis formatos reales, verificados con ffprobe |
| Vídeo | Tres perfiles MP4 desde dimensiones impares y RGB; códec, dimensiones pares y yuv420p; WebM, GIF, audio; compresión útil e inútil |
| SVG | PNG, PDF y SVGZ reales |
| Oficina | Dos documentos con el mismo nombre base y TMPDIR con espacios, porcentaje y Unicode |
| Libros | EPUB mínimo convertido por Calibre a un PDF válido |
| OCR | Imagen escaneada sintética, OCR español y comprobación del texto extraído |
| Instalación | PREFIX `/usr`, `/usr/local` y ruta con espacios; DESTDIR; desinstalación que conserva archivos ajenos; PKGBUILD y .SRCINFO sincronizados |
| Paquete | Tarball local y SHA256; once scripts, ocho menús, licencia, rutas Exec, dependencias, propietario root y ausencia de archivos inesperados |

Las pruebas no constituyen una validación exhaustiva de todos los formatos de
entrada, codecs, idiomas, DRM, fuentes o sistemas de archivos. Las colisiones
se comprueban en el sistema de archivos Linux del entorno de prueba. La limpieza
por SIGTERM se prueba en el script; no se verifica una interfaz de cancelación
de procesos hijos durante una conversión larga.

## Comprobación manual de Dolphin

Después de instalar una versión revisada y volver a abrir Dolphin:

1. Sobre una imagen local, comprobar que «Convertir imagen» muestra un icono de
   imagen y «a PDF» conserva el icono PDF. Revisar también el submenú PDF.
2. Comprobar los filtros al seleccionar imágenes, PDF, SVG, audio, vídeo,
   documentos y libros. Con un PDF aparecen división/conversión; con dos o más,
   unión. Revisar una selección de tipos mezclados.
3. En una URL `sftp://` o `smb://`, comprobar que no aparecen estas acciones.
   Una carpeta montada localmente puede ofrecerlas, según su MIME y permisos.
4. Revisar los nombres en español e inglés, la legibilidad de errores y avisos,
   y la confirmación antes de convertir una imagen animada.
5. Cancelar los diálogos de rango, bloques y unión. Comprobar que no aparecen
   resultados incompletos ni ventanas de error por una cancelación normal.

La suite automatizada no abre Dolphin ni verifica visualmente iconos, diálogos,
traducciones o notificaciones. Esta comprobación queda pendiente antes de publicar.

## Resultado de la revisión de 2026-10-13

- `make check`: correcto; once archivos Bash sin errores de sintaxis ni avisos
  de ShellCheck.
- `make test-integration`: **43 pruebas correctas, sin fallos ni omisiones**
  (197,544 segundos). Cada prueba puede incluir varios perfiles o subcasos.
- `make test-package`: construcción e inspección correctas de los veinte archivos
  de aplicación, junto a los metadatos del paquete. No se ha instalado el paquete.
- `git diff --check`: correcto.

Entorno comprobado: Bash 5.3.20, GNU coreutils 9.12, Python 3.14.8, ShellCheck
0.11.0, Poppler 26.08.0, FFmpeg 9.0.2 e ImageMagick 7.1.2.33. El equipo tiene
KIO 6.31.0 y Dolphin 26.08.2; la interfaz de Dolphin no se ha probado visualmente.

La primera ejecución en el sandbox del agente bloqueó Calibre (Chromium) y
LibreOffice. Se repitió la verificación final con autorización fuera del sandbox,
manteniendo entradas, salidas, perfiles y cachés de prueba dentro del proyecto.
No se desactivó la seguridad de estas aplicaciones ni se cambió su código para
acomodar el entorno de pruebas.

`namcap` no está instalado: se verificaron el contenido, propietario y metadatos
del paquete con bsdtar. La comprobación manual de Dolphin sigue pendiente; también
queda pendiente la publicación de una nueva versión en AUR.

## Instalación local de 2026-10-14

- Construido un paquete del árbol revisado con `--output-dir` y reinstalado
  mediante pacman. Se mantiene el identificador `1.3.1-2`, con el código local
  actualizado; no se ha publicado una versión nueva en AUR.
- Comparados los once scripts y la licencia con el repositorio; comprobados
  también los ocho menús, sus rutas Exec, permisos y propietario root.
- `pacman -Qk conversor-dolphin`: 27 archivos registrados, ninguno ausente.
- Ejecutado `kbuildsycoca6` para refrescar la caché del usuario.
- `make test-kde`: correctas las siete comprobaciones de menús mediante KIO.
  Confirmados el icono de imagen y los filtros de selección y protocolo.

La verificación con la API de KDE no sustituye la inspección visual en una
ventana de Dolphin. Si estaba abierto y mantiene un menú anterior, cierra sus
ventanas y vuelve a abrirlo. No se han cerrado automáticamente ventanas del usuario.
