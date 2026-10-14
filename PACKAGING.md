# Empaquetado y publicación en AUR

`PKGBUILD` descarga el tarball de la etiqueta GitHub `v$pkgver`. El repositorio de
AUR contiene únicamente `PKGBUILD`, `.SRCINFO` y `conversor-dolphin.install`.
El código, Makefile y licencia se obtienen del tarball. El archivo `.install`
se lee del repositorio de AUR, por lo que debe mantenerse sincronizado.

Solo se mantiene `conversor-dolphin`. No existe ni hace falta una variante
`conversor-dolphin-bin`: los scripts y menús se instalan sin compilar.

El clon de preparación está en `aur/conversor-dolphin`, ignorado por el
repositorio principal. Tiene su propio historial en la rama `master`, utiliza
HTTPS para consultar AUR y SSH para publicar. Preparar y confirmar sus archivos
no publica la actualización: el último paso es el push a AUR.

## Actualización preparada: 1.3.2-1

La etiqueta `v1.3.2` ya está disponible en GitHub. El PKGBUILD de la raíz y el
del clon de AUR utilizan ese tarball con su SHA256 verificada; `.SRCINFO` está
regenerado y el paquete se ha construido e inspeccionado correctamente.
La actualización del clon contiene solo los tres archivos de empaquetado.
La evidencia y la suma completa están en TESTING.

Mientras no se suba el commit de ese clon a AUR, los helpers seguirán obteniendo
la versión anterior. La instalación local revisada sigue siendo el paquete
`1.3.1-2` registrado en TESTING; preparar esta actualización no lo reinstala.

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

Con el clon preparado, la publicación se realiza con:

```bash
git -C aur/conversor-dolphin push origin master
```

Requiere que la cuenta de AUR tenga autorizada la clave SSH del usuario.
La validación del tarball de una etiqueta nueva debe construir con el PKGBUILD
real de AUR, además de la comprobación local `make test-package`.

No uses `SKIP` como suma ni apuntes a una etiqueta que aún no exista.
Las pruebas locales no necesitan publicar, instalar o cambiar el sistema.
