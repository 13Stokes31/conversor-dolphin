#!/usr/bin/env bash
# Uso: wordcraft-a-pdf.sh reporte.docx [otro.docx ...].
set -Eeuo pipefail
TITULO="DOCX a PDF con WordCraft"
# shellcheck source=comun.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/comun.sh"

command -v wordcraft-cli >/dev/null \
    || err "Falta «wordcraft-cli».\n\nEn Arch, puedes instalarlo desde AUR con:\n    paru -S wordcraft-bin\n\n«a PDF» utiliza LibreOffice."
(( $# >= 1 )) || err "Selecciona al menos un documento DOCX."
validar_archivos "$@"
iniciar_temporales
for documento in "$@"; do
    ruta_archivo "$documento"
    nuevo_temporal "$d"
    out="$trabajo/salida.pdf"
    if ! wordcraft-cli convert "$f" "$out" --strict > /dev/null 2>"$errf" || [[ ! -s "$out" ]]; then
        err "WordCraft no pudo exportar «${f##*/}»:\n$(tail -3 "$errf")\n\nPuedes usar «a PDF» con LibreOffice."
    fi
    publicar "$out" "$d/$s" .pdf
    hechos=$((hechos + 1))
done
ok "$hechos documento(s) convertido(s) a PDF con WordCraft."
