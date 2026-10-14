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

## Versión 1.3.2-1 publicada

La etiqueta de código `v1.3.2` está publicada en GitHub. La receta de AUR está
publicada como `1.3.2-1`, utilizando su tarball descargado y una suma SHA256
verificada. El paquete se ha construido e inspeccionado con esa receta real.
Solo se mantiene `conversor-dolphin`: no hay compilación que justifique una
variante `-bin`. El clon de publicación está en `aur/conversor-dolphin`,
sincronizado con AUR, separado del historial principal e ignorado por Git.

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
