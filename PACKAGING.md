# Empaquetado y publicación en AUR

El `PKGBUILD` descarga las fuentes del *release* etiquetado en GitHub (no usa
copias locales): `source` apunta al tarball de la etiqueta `v$pkgver`. Por eso
el repo de AUR solo debe llevar `PKGBUILD`, `.SRCINFO` y `conversor-dolphin.install`
— nada de `.sh`, `.desktop`, `Makefile` ni `LICENSE` (esos viven únicamente
aquí y en GitHub).

> El `conversor-dolphin.install`, al referenciarse con `install=`, AUR lo toma
> del propio repo de AUR, no del tarball: por eso debe seguir presente junto
> al `PKGBUILD` en ambos sitios.

## Construir y probar en local

```bash
makepkg -f                 # descarga el tarball del tag y construye el paquete
namcap PKGBUILD            # (opcional) lint del PKGBUILD
namcap *.pkg.tar.zst       # (opcional) lint del paquete construido
makepkg -si                # construye e instala con pacman
```

> Tras publicar una etiqueta nueva en GitHub, regenera sumas y `.SRCINFO`:
> ```bash
> updpkgsums
> makepkg --printsrcinfo > .SRCINFO
> ```

## Publicar en AUR

1. **Sube tu clave SSH** a tu cuenta de AUR (Mi Cuenta → SSH Public Key).

2. **Clona el repo de AUR y copia solo los tres ficheros de empaquetado:**

   ```bash
   git clone ssh://aur@aur.archlinux.org/conversor-dolphin.git aur-conversor
   cd aur-conversor
   cp ../conversor-dolphin/{PKGBUILD,.SRCINFO,conversor-dolphin.install} .
   git add -A
   git commit -m "conversor-dolphin 1.3.1-2: fuentes desde el tag de GitHub"
   git branch -m master   # AUR exige que la rama se llame «master», no «main»
   git push
   ```

   El repo de AUR lleva **siempre y solo** `PKGBUILD`, `.SRCINFO` y
   `conversor-dolphin.install` en la raíz. Nada de `pkg/`, `src/`,
   `*.pkg.tar.zst` (ya están en `.gitignore`) ni copias del código fuente.

## Actualizar a una versión nueva

1. Crea la etiqueta `vX.Y.Z` en GitHub y haz push del tag.
2. Sube `pkgver` (y reinicia `pkgrel=1`) en `PKGBUILD`. Si solo cambia el
   empaquetado sin nueva versión de código, sube `pkgrel`.
3. Anota los cambios en `CHANGELOG.md`.
4. `updpkgsums && makepkg --printsrcinfo > .SRCINFO`
5. Copia `PKGBUILD` y `.SRCINFO` (y `conversor-dolphin.install` si cambió) al
   clon del repo de AUR, `git commit` y `git push`.
