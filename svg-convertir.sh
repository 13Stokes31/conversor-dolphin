#!/usr/bin/env bash
#
# svg-convertir.sh — Rasteriza/convierte SVG (service menu de Dolphin).
#
# Uso: svg-convertir.sh <formato> svg1 [svg2 ...]
#   png  -> PNG (rasterizado al tamaño intrínseco del SVG)
#   pdf  -> PDF (vectorial, sin pérdida)
# Usa rsvg-convert (librsvg). Resultado junto al original, sin sobrescribir.

set -Eeuo pipefail

TITULO="Convertir SVG"
# shellcheck source=comun.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/comun.sh"

command -v rsvg-convert >/dev/null \
    || err "Falta «rsvg-convert».\n\nInstálalo con:\n    sudo pacman -S librsvg"

(( $# >= 2 )) || err "Uso interno incorrecto del conversor de SVG."
fmt="$1"; shift
case "$fmt" in
    png) ext=png ;;
    pdf) ext=pdf ;;
    *) err "Formato de SVG desconocido: $fmt" ;;
esac

validar_archivos "$@"
iniciar_temporales
for f in "$@"; do
    ruta_archivo "$f"
    nuevo_temporal "$d"
    out="$trabajo/salida.$ext"
    if ! rsvg-convert -f "$fmt" -o "$out" "$f" 2>"$errf"; then
        err "No se pudo convertir «$(basename -- "$f")»:\n$(tail -2 "$errf" 2>/dev/null || echo 'error desconocido')"
    fi
    publicar "$out" "$d/$s" ".$ext"
    hechos=$((hechos + 1))
done

ok "$hechos SVG convertido(s) a $fmt."
exit 0
