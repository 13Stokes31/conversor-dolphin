#!/usr/bin/env bash
#
# ebook-a-pdf.sh — Convierte libros electrónicos a PDF (service menu de Dolphin).
#
# Uso: ebook-a-pdf.sh ebook1 [ebook2 ...]
#   Acepta EPUB, MOBI, AZW/AZW3, FB2… (lo que admita Calibre).
# Usa «ebook-convert» de Calibre. Resultado junto al original, sin sobrescribir.
# Los libros grandes pueden tardar.

set -Eeuo pipefail

TITULO="Convertir libro a PDF"
# shellcheck source=comun.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/comun.sh"

command -v ebook-convert >/dev/null \
    || err "Falta «ebook-convert» (Calibre).\n\nInstálalo con:\n    sudo pacman -S calibre"

(( $# >= 1 )) || err "Selecciona al menos un libro electrónico."

validar_archivos "$@"
iniciar_temporales
ok "Convirtiendo a PDF… los libros grandes pueden tardar."
for f in "$@"; do
    ruta_archivo "$f"
    nuevo_temporal "$d"
    out="$trabajo/salida.pdf"
    if ! ebook-convert "$f" "$out" >/dev/null 2>"$errf"; then
        err "No se pudo convertir «$(basename -- "$f")»:\n$(tail -3 "$errf" 2>/dev/null || echo 'error desconocido')"
    fi
    publicar "$out" "$d/$s" ".pdf"
    hechos=$((hechos + 1))
done

ok "$hechos libro(s) convertido(s) a PDF."
exit 0
