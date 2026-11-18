# Roadmap

## Estado actual

La revisión de octubre de 2026 corrige los iconos, limita los menús a archivos
locales, admite HEIC/HEIF a PDF mediante ImageMagick, normaliza los números de
páginas a decimal y mejora la compatibilidad de MP4. Las salidas se publican sin
reemplazo; hay pruebas de concurrencia, cancelación, limpieza y conversión real.

La propuesta inicial y el informe de auditoría se han retirado: el comportamiento
vigente está en README, los cambios en CHANGELOG y la evidencia en TESTING.

El código revisado se instaló y verificó en el equipo local mediante pacman.
La comprobación nativa de KIO confirmó el icono de imagen y los filtros de
archivos y protocolos. Después se retiró esa instalación y su dependencia
automática sin uso para permitir una instalación normal desde AUR.
La inspección visual en Dolphin sigue pendiente.

## Versión 1.4.0-1 publicada

Los tres modos de división de PDF usan qpdf y LibreOffice procesa los documentos
en lotes. La etiqueta `v1.4.0` está en GitHub y la receta `1.4.0-1` en AUR.
El paquete se ha construido con el tarball publicado y una suma SHA256 verificada.
Se mantiene un único paquete, `conversor-dolphin`.

## Para las siguientes versiones

1. Completar la comprobación visual de Dolphin descrita en TESTING: icono del
   submenú, traducciones, filtros MIME, selección múltiple y ausencia de acciones
   sobre URLs remotas.
2. Revisar los cambios y ejecutar `make check`, `make test-integration` y
   `make test-package` en el entorno de publicación. Con los menús instalados y
   las herramientas de desarrollo de KDE disponibles, ejecutar `make test-kde`.
3. Preparar y revisar el commit del clon de AUR y subirlo según PACKAGING.
   Preparar una actualización local o publicar la etiqueta en GitHub no cambia
   la versión que sirve AUR.

## Mejoras posteriores, si el uso las justifica

- Volver a evaluar ArtCraft a partir de febrero de 2027. Comparar WordCraft y
  DeckCraft con LibreOffice en documentos reales, con especial atención a la
  paginación, tablas, notas al pie, gráficos y diapositivas maestras. Considerar
  una integración si se conservan esos elementos en las versiones probadas.
- Progreso y cancelación durante vídeo, Calibre y OCR. Debe poder interrumpirse
  la herramienta hija y limpiarse la salida incompleta, conservando resultados
  anteriores del lote.
- Conversión que conserve animaciones y TIFF multipágina como opción explícita.
  La acción actual convierte solo el primer fotograma/página y avisa antes.
- Automatizar las comprobaciones existentes en CI cuando se disponga de un
  entorno con los conversores necesarios. Las herramientas ausentes deben
  contabilizarse como pruebas omitidas, nunca como conversiones verificadas.

No se prevé cambiar Bash, añadir un servicio residente ni implementar acceso
remoto propio: las utilidades actuales resuelven el alcance del proyecto.
