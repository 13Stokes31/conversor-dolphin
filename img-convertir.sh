#!/usr/bin/env bash
#
# img-convertir.sh — Convierte imágenes a otro formato (service menu de Dolphin).
#
# Uso: img-convertir.sh <formato> imagen1 [imagen2 ...]
#   formato: jpg | png | webp | avif | tiff
# Convierte cada imagen seleccionada y deja el resultado junto al original sin
# sobrescribir (añade -2, -3…). Admite HEIC/HEIF de entrada (fotos de móvil;
# requiere el delegado libheif en ImageMagick).

set -Eeuo pipefail

TITULO="Convertir imagen"
# shellcheck source=comun.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/comun.sh"

IM=$(command -v magick || command -v convert || true)
[[ -n "$IM" ]] || err "Falta ImageMagick.\n\nInstálalo con:\n    sudo pacman -S imagemagick"

(( $# >= 2 )) || err "Uso interno incorrecto del conversor de imágenes."
fmt="$1"; shift
case "$fmt" in
    jpg)  ext=jpg;  opts=(-background white -flatten -quality 92) ;;
    png)  ext=png;  opts=() ;;
    webp) ext=webp; opts=(-quality 90) ;;
    avif) ext=avif; opts=(-quality 55) ;;
    tiff) ext=tiff; opts=(-compress zip) ;;
    *) err "Formato de imagen desconocido: $fmt" ;;
esac

validar_archivos "$@"
iniciar_temporales
for f in "$@"; do
    ruta_archivo "$f"
    nuevo_temporal "$d"
    out="$trabajo/salida.$ext"
    if [[ "${IM##*/}" == magick ]]; then identificar=("$IM" identify); else identificar=(identify); fi
    if ! fotogramas=$("${identificar[@]}" -ping -format '%n\n' - <"$f" 2>"$errf"); then
        err "No se pudo leer «${f##*/}»:\n$(tail -2 "$errf")"
    fi
    fotogramas="${fotogramas%%$'\n'*}"
    if [[ "$fotogramas" =~ ^[0-9]+$ ]] && (( fotogramas > 1 )); then
        kdialog --title "$TITULO" --yesno "«${f##*/}» contiene $fotogramas fotogramas/páginas.\nSolo se convertirá el primero. ¿Continuar?" || cancelar
    fi
    # stdin/stdout evitan que ImageMagick interprete %, [] o glob en las rutas.
    # «[0]» limita la entrada a su primer fotograma/página.
    if ! "$IM" '-[0]' "${opts[@]}" "$fmt:-" <"$f" >"$out" 2>"$errf"; then
        err "No se pudo convertir «$(basename -- "$f")»:\n$(tail -2 "$errf" 2>/dev/null || echo 'error desconocido')"
    fi
    publicar "$out" "$d/$s" ".$ext"
    hechos=$((hechos + 1))
done

ok "$hechos imagen(es) convertida(s) a $fmt."
exit 0
