# Propuesta de Proyecto: Conversor de Archivos Inteligente para Dolphin (KDE Plasma 6)

## Contexto del Proyecto
Desarrollo de una extensión nativa para **KDE Plasma 6 (entorno Wayland)** en **Arch Linux** inspirada en la herramienta *File Converter* de Windows. El objetivo es añadir un menú flotante en cascada al hacer clic derecho sobre los archivos en el gestor de archivos **Dolphin** para convertirlos de formato de manera instantánea y masiva sin abrir aplicaciones pesadas. El proyecto final se estructurará para ser distribuido e instalado de forma global a nivel de sistema mediante un paquete comunitario en **AUR**.

## El Problema del Filtrado Dinámico y Procesamiento en Lotes
Para que la herramienta sea realmente productiva, no puede saturar el menú contextual mostrando opciones irrelevantes (por ejemplo, ofrecer convertir a MP3 cuando se selecciona una imagen PNG). 

Para solucionar esto, la aplicación debe:
1. Segmentar estrictamente las acciones utilizando los identificadores de sistema (**MimeTypes**), obligando a Dolphin a mostrar dinámicamente solo el submenú correspondiente al tipo de archivo seleccionado.
2. Aplicar lógica de exclusión para no ofrecer el mismo formato de origen (ocultar "Convertir a PNG" si el archivo ya es un PNG).
3. Resolver el procesamiento masivo de archivos de forma segura por comandos de terminal, blindando los scripts contra rutas con espacios o caracteres especiales y evitando fallos de dobles extensiones erróneas del tipo `foto.jpg.webp`.

## Requisitos Core del Sistema
* **Disparador:** Menú en cascada (`X-KDE-Submenu`) en el clic derecho de Dolphin denominado `🔄 Convertir a...` (o clasificado por tipo como `🔄 Acciones PDF...`), evitando saturar la interfaz principal.
* **Filtrado por Categorías Estrictas:**
  * **Imágenes (`image/*`):** Conversión rápida a `.webp`, `.jpg` y `.png` mediante *ImageMagick*.
  * **Multimedia (`video/*`, `audio/*`):** Conversión a `.mp4` y extracción/conversión directa a `.mp3` de alta calidad mediante *FFmpeg*.
  * **Documentos (`application/pdf`):** Acciones avanzadas de compresión de tamaño (*Ghostscript*), conversión de páginas a imágenes (*pdftoppm*), extracción de gráficos internos (*pdfimages*) y fusión/unión de múltiples archivos seleccionados (*pdfunite*).
* **Procesamiento por Lotes:** Capacidad para recibir múltiples archivos seleccionados simultáneamente (`%F`) y procesarlos en segundo plano de forma eficiente.
* **Notificaciones Nativas:** Integración con el sistema de alertas pasivas de KDE Plasma mediante `kdialog` para avisar al usuario en la esquina de la pantalla cuando la conversión haya finalizado con éxito.
* **Indicador de Progreso Nativo (Kuiserver):** Para tareas pesadas (especialmente FFmpeg), el sistema NO debe congelar la interfaz. Debe lanzar un indicador de progreso nativo en la bandeja del sistema de KDE Plasma (widget de notificaciones/Kuiserver) simulando el comportamiento de copia de archivos de Dolphin.
* **Ámbito Global:** Instalación centralizada en la ruta `/usr/share/kio/servicemenus/` para garantizar que la herramienta esté disponible para todas las cuentas de usuario del sistema operativo.

## Stack Tecnológico Propuesto
* **Configuración del Entorno:** *KIO Service Menus* mediante archivos estructurados `.desktop`.
* **Lenguaje de Automatización:** *Bash* (para el control de flujos, bucles de archivos y llamada a los binarios del sistema).
* **Integración KDE:** `kdialog --progressbar` y `qdbus` para la barra de progreso nativa.
* **Motores de Conversión Nativos:** `imagemagick`, `ffmpeg`, `ghostscript` y `poppler` (herramientas estándar y optimizadas por terminal en los repositorios oficiales de Arch Linux).

---

## Preguntas para la IA Asistente

1. **Optimización de Procesos en Lote:** ¿Cómo se deberían estructurar los comandos internos de Bash dentro del bloque `Exec` del `.desktop` para procesar múltiples archivos multimedia pesados de forma eficiente en segundo plano (evitando por completo congelar o bloquear la interfaz de Dolphin durante la conversión)?
2. **Tratamiento Seguro de Rutas y Extensiones:** ¿Cuál es la sintaxis más limpia y robusta en Bash para iterar sobre la variable de archivos de KDE (`%F`) garantizando que se manejen correctamente los espacios en los nombres de archivo y realizando la sustitución de la extensión antigua limpiamente (evitando dobles extensiones)?
3. **Estructura del Service Menu Dinámico:** Proporciona el diseño y la división de los archivos `.desktop` finales (sea un archivo unificado o segmentados) que implementen el filtrado estricto por `MimeType` para imágenes, multimedia y documentos PDF, incluyendo la propiedad `X-KDE-Submenu` en español.
4. **Empaquetado AUR:** Proporciona un ejemplo de archivo `PKGBUILD` limpio y listo para producción que declare de forma explícita todas las dependencias requeridas en tiempo de ejecución (`dolphin`, `imagemagick`, `ffmpeg`, `ghostscript`, `poppler`) y automatice la copia segura del menú contextual en las rutas globales del sistema.
