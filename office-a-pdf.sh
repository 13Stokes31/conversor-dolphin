#!/usr/bin/env bash
# Uso: office-a-pdf.sh documento1 [documento2 ...]. Perfil de LibreOffice aislado.
set -Eeuo pipefail
TITULO="Documentos a PDF"
# shellcheck source=comun.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/comun.sh"
soffice_bin=$(command -v soffice || command -v libreoffice || true)
[[ -n "$soffice_bin" ]] || err "Falta LibreOffice.\n\nInstálalo con:\n    sudo pacman -S libreoffice-still"
(( $# >= 1 )) || err "Selecciona al menos un documento."
validar_archivos "$@"
iniciar_temporales
mkdir -- "$tmp/perfil"
# URI escapada, incluso si TMPDIR contiene espacios, porcentajes o Unicode.
profile_uri=$(printf '%s' "$tmp/perfil" | od -An -v -tx1 | tr -s '[:space:]' '\n' | sed '/^$/d; s/^/%/' | tr -d '\n')
profile_uri="${profile_uri//%2f/\/}"
for documento in "$@"; do
    ruta_archivo "$documento"
    nuevo_temporal "$d"
    if ! "$soffice_bin" --headless --norestore \
            -env:UserInstallation="file://$profile_uri" \
            --convert-to pdf --outdir "$trabajo" "$f" >"$tmp/office.log" 2>&1 \
            || [[ ! -f "$trabajo/$s.pdf" ]]; then
        err "LibreOffice no pudo convertir «${f##*/}»:\n$(tail -3 "$tmp/office.log")"
    fi
    publicar "$trabajo/$s.pdf" "$d/$s" .pdf
    hechos=$((hechos + 1))
done
ok "$hechos documento(s) convertido(s) a PDF."
