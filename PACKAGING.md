# Empaquetado y publicación en AUR

El repositorio ya es un paquete listo: contiene `PKGBUILD`, `.SRCINFO` y todas
las fuentes (los `.sh`, los `.desktop`, el `Makefile`, `LICENSE` y el `.install`).
El `PKGBUILD` es **autocontenido**: usa las fuentes locales, así que construye y
se publica sin necesidad de alojar nada en otro sitio.

## Construir y probar en local

```bash
makepkg -f                 # construye el paquete
namcap PKGBUILD            # (opcional) lint del PKGBUILD
namcap *.pkg.tar.zst       # (opcional) lint del paquete construido
makepkg -si                # construye e instala con pacman
```

> Si tocas cualquier fuente, regenera sumas y `.SRCINFO`:
> ```bash
> updpkgsums
> makepkg --printsrcinfo > .SRCINFO
> ```

## Publicar en AUR

1. **Comprueba que el nombre está libre** en <https://aur.archlinux.org/packages?K=conversor-dolphin>.
   Si lo prefieres más descubrible, podrías renombrarlo (p. ej. `dolphin-pdf-servicemenu`):
   habría que cambiar `pkgname`, el nombre de los `.desktop`/`.install` y la variable
   `NAME` del `Makefile`.

2. **Sube tu clave SSH** a tu cuenta de AUR (Mi Cuenta → SSH Public Key).

3. **Clona el repo AUR vacío y copia los ficheros del paquete:**

   ```bash
   git clone ssh://aur@aur.archlinux.org/conversor-dolphin.git aur-conversor
   cd aur-conversor
   cp ../conversor-dolphin/{PKGBUILD,.SRCINFO,conversor-dolphin.install,Makefile,LICENSE} .
   cp ../conversor-dolphin/*.sh .
   cp ../conversor-dolphin/conversor-dolphin-*.desktop .
   git add -A
   git commit -m "Initial import: conversor-dolphin 1.0.0-1"
   git push
   ```

   El repo de AUR debe llevar **siempre** `PKGBUILD` y `.SRCINFO` en la raíz, más
   las fuentes que el `PKGBUILD` referencia. No subas `pkg/`, `src/` ni los
   `*.pkg.tar.zst` (ya están en `.gitignore`).

## Alternativa: fuentes desde un *release* de GitHub

Si prefieres el flujo «clásico» (el AUR descarga un tarball publicado, y el repo
AUR solo lleva `PKGBUILD`, `.SRCINFO` y `conversor-dolphin.install`), sube primero
este proyecto a GitHub y crea una etiqueta `v1.0.0`. Luego usa este `source`:

```bash
url="https://github.com/TUUSUARIO/conversor-dolphin"
source=("$pkgname-$pkgver.tar.gz::$url/archive/refs/tags/v$pkgver.tar.gz")
sha256sums=('SKIP')   # después: updpkgsums

package() {
    make -C "$srcdir/$pkgname-$pkgver" DESTDIR="$pkgdir" PREFIX=/usr install
}
```

(El `conversor-dolphin.install`, al referenciarse con `install=`, se toma del
propio repo AUR, no del tarball: por eso debe seguir presente junto al PKGBUILD.)

## Actualizar a una versión nueva

1. Sube `pkgver` (y reinicia `pkgrel=1`) en `PKGBUILD`. Si solo cambia el
   empaquetado, sube `pkgrel`.
2. Anota los cambios en `CHANGELOG.md`.
3. `updpkgsums && makepkg --printsrcinfo > .SRCINFO`
4. `git commit` y `git push` al remoto de AUR.
