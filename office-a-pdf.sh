#!/usr/bin/env bash
#
# office-a-pdf.sh — Convierte documentos de oficina a PDF con LibreOffice.
#
# Uso: office-a-pdf.sh doc1 [doc2 ...]   (docx, doc, odt, xlsx, ods, pptx, odp, rtf…)
# Ejecuta LibreOffice en modo headless con un perfil aislado, así funciona
# aunque tengas LibreOffice abierto. El PDF se deja junto a cada original,
# sin sobrescribir (añade -2, -3… si ya existe).

set -euo pipefail

TITULO="Documentos a PDF"
err() { kdialog --title "$TITULO" --error "$1"; exit 1; }
ok()  { kdialog --title "$TITULO" --passivepopup "$1" 6 >/dev/null 2>&1 || true; }

# Binario de LibreOffice (soffice o libreoffice).
soffice_bin=""
for b in soffice libreoffice; do
    command -v "$b" >/dev/null && { soffice_bin="$b"; break; }
done
[[ -n "$soffice_bin" ]] \
    || err "Falta LibreOffice.\n\nInstálalo con:\n    sudo pacman -S libreoffice-still"

(( $# >= 1 )) || err "Selecciona al menos un documento."

tmpout=$(mktemp -d)
profile=$(mktemp -d)
trap 'rm -rf "$tmpout" "$profile"' EXIT

# Conversión (en bloque) a un directorio temporal: LibreOffice crea <nombre>.pdf.
if ! "$soffice_bin" --headless --norestore \
        -env:UserInstallation="file://$profile" \
        --convert-to pdf --outdir "$tmpout" "$@" >/dev/null 2>"$tmpout/.log"; then
    err "LibreOffice no pudo convertir:\n$(tail -3 "$tmpout/.log" 2>/dev/null || echo 'error desconocido')"
fi

# Mueve cada PDF generado junto a su original, sin colisiones.
hechos=0
for f in "$@"; do
    d=$(dirname -- "$f")
    s=$(basename -- "$f"); s="${s%.*}"
    [[ -f "$tmpout/$s.pdf" ]] || continue
    out="$d/$s.pdf"; n=2
    while [[ -e "$out" ]]; do out="$d/$s-$n.pdf"; n=$((n + 1)); done
    mv -- "$tmpout/$s.pdf" "$out"
    hechos=$((hechos + 1))
done

(( hechos > 0 )) || err "No se generó ningún PDF.\n¿Formato no soportado por LibreOffice?"
ok "$hechos documento(s) convertido(s) a PDF."
exit 0
