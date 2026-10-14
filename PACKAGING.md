# Empaquetado y publicación en AUR

`PKGBUILD` descarga el tarball de la etiqueta GitHub `v$pkgver`. El repositorio de
AUR contiene únicamente `PKGBUILD`, `.SRCINFO` y `conversor-dolphin.install`.
El código, Makefile y licencia se obtienen del tarball. El archivo `.install`
se lee del repositorio de AUR, por lo que debe mantenerse sincronizado.

## Probar el código local

```bash
make check
make test-integration
make test-package
```

`test-package` genera un tarball del código actual en `tests/.tmp`, copia el
PKGBUILD y sustituye **solo en esa copia** la fuente remota por el archivo local
y su SHA256. Ejecuta makepkg sin instalar ni descargar dependencias, verifica
los once scripts (incluido `comun.sh`), ocho menús, licencia, dependencias,
propietario root y ausencia de archivos inesperados en el paquete.
Si namcap está instalado también lo ejecuta. Al terminar limpia todos
los artefactos de esa construcción.

Requiere Arch o un entorno compatible con makepkg, pacman y bsdtar, ejecutado
como usuario sin privilegios. `poppler` y `kdialog` deben estar instalados.
La versión del paquete de prueba es la del PKGBUILD vigente; es un artefacto
local de validación, no una versión publicable.

## Instalar el código revisado en el equipo local

Si la aplicación ya está gestionada por pacman, conserva el paquete verificado:

```bash
python3 -B tests/paquete_local.py --output-dir tests/.tmp/paquetes-locales
```

Instala la ruta exacta mostrada por el comando con `sudo pacman -U` y refresca
KDE con `kbuildsycoca6`. La construcción no instala por sí misma ni sobrescribe
paquetes conservados previamente. Esta reinstalación local mantiene la versión
del PKGBUILD vigente y el registro de archivos de pacman; no publica en AUR.
Evita superponer `make install` a una instalación gestionada por pacman.

Después se puede ejecutar `make test-kde`, si están disponibles CMake, un
compilador C++ y los archivos de desarrollo de Qt 6 Widgets y KF6 KIO.
Comprueba los menús instalados con la API de KIO sin abrir ventanas ni lanzar
conversiones. Tras instalar y verificar, se pueden retirar los paquetes y
la construcción de pruebas de `tests/.tmp`.

## Probar la versión publicada

```bash
makepkg -f
namcap PKGBUILD              # opcional
namcap *.pkg.tar.zst         # opcional
```

Estos comandos usan la etiqueta publicada y no verifican los cambios locales.
`makepkg -si` además instala el paquete; no es necesario para la revisión.

## Publicar una versión

1. Completa las comprobaciones automáticas y manuales de TESTING.
2. Elige `X.Y.Z`, mueve «Sin publicar» a esa versión en CHANGELOG y crea la
   etiqueta `vX.Y.Z` sobre el código final. Publica los commits y la etiqueta.
3. Cambia `pkgver=X.Y.Z` y `pkgrel=1` en PKGBUILD. Si solo cambia el
   empaquetado de una versión existente, incrementa `pkgrel`.
4. Con la etiqueta ya accesible:

   ```bash
   updpkgsums
   makepkg --printsrcinfo > .SRCINFO
   makepkg -f
   ```

5. Revisa el paquete, la fuente descargada y sus metadatos. Copia únicamente
   PKGBUILD, `.SRCINFO` y `conversor-dolphin.install` al clon de AUR.
6. Revisa el diff, confirma los tres archivos y publica en la rama `master`
   que requiere AUR. No incluyas fuentes, `src/`, `pkg/` ni paquetes binarios.

No uses `SKIP` como suma ni apuntes a una etiqueta que aún no exista.
Las pruebas locales no necesitan publicar, instalar o cambiar el sistema.
