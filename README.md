# conversor-dolphin

Menú contextual de **Dolphin** (KDE Plasma 6 / KF6) para **unir** y **dividir**
archivos PDF, usando poppler (`pdfunite`, `pdfseparate`, `pdfinfo`) y `kdialog`.
Sin dependencias pesadas: son dos scripts de shell y dos *service menus*.

## Acciones

Al hacer clic derecho sobre archivos `application/pdf` aparece el submenú
**«Acciones PDF» / «PDF Actions»** (menús bilingües ES/EN):

| Acción | Cuándo aparece | Resultado |
|--------|----------------|-----------|
| **Unir los PDF seleccionados…** | con ≥ 2 PDF | Diálogo para reordenar y fusiona. Nombre: 2 archivos → `a_b.pdf`; 3 o más → `a_y_otros.pdf`. Si existe, añade `-2`. |
| **Dividir: cada página en un archivo** | con 1 PDF | `original-1.pdf`, `original-2.pdf`, … |
| **Dividir: extraer un rango…** | con 1 PDF | Pide `3-7` (o un número) y genera solo ese rango: `original-3_a_7.pdf`. |
| **Dividir: en bloques de N páginas…** | con 1 PDF | Pide N y parte en trozos de N páginas. |

Los resultados de **dividir** van a una subcarpeta `original-dividido/` junto al
original. Al terminar se muestra un aviso pasivo (no intrusivo) con el resultado;
si algo falla, un diálogo de error y se limpia lo dejado a medias.

## Dependencias

`poppler` y `kdialog`, ambos en los repos oficiales de Arch. (Lo demás —`bash`,
`coreutils`, `gawk`, `grep`— forma parte del sistema base.)

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
