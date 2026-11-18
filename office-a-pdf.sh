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
log="$tmp/office.log"
shopt -s nullglob dotglob

convertir() {
    local directorio="$1" documento f d s
    shift
    nuevo_temporal "$directorio"
    "$soffice_bin" --headless --norestore -env:UserInstallation="file://$profile_uri" \
        --convert-to pdf --outdir "$trabajo" "$@" >"$log" 2>&1 || return 1

    # LibreOffice puede terminar con éxito sin generar todos los documentos.
    local -a salidas=("$trabajo"/*.pdf)
    (( ${#salidas[@]} == $# )) || return 1
    for documento in "$@"; do
        ruta_archivo "$documento"
        [[ -f "$trabajo/$s.pdf" ]] || return 1
    done
}

procesar_lote() {
    local directorio="$1" documento f d s
    shift
    if ! convertir "$directorio" "$@"; then
        if (( $# == 1 )); then
            err "LibreOffice no pudo convertir «${1##*/}»:\n$(tail -3 "$log")"
        fi
        rm -rf -- "$trabajo"
        unset 'temporales[-1]'
        # Individualmente podemos publicar en orden hasta el primer fallo.
        for documento in "$@"; do
            procesar_lote "$directorio" "$documento"
        done
        return
    fi
    for documento in "$@"; do
        ruta_archivo "$documento"
        publicar "$trabajo/$s.pdf" "$d/$s" .pdf
        hechos=$((hechos + 1))
    done
}

# Cada lote usa un temporal junto a sus originales. Los nombres base deben
# ser distintos porque LibreOffice usa el mismo directorio para todo el lote.
lote=()
declare -A nombres=()
directorio_lote=""
for documento in "$@"; do
    ruta_archivo "$documento"
    if (( ${#lote[@]} > 0 )) && [[ "$d" != "$directorio_lote" || ${nombres["$s"]+x} ]]; then
        procesar_lote "$directorio_lote" "${lote[@]}"
        lote=()
        nombres=()
    fi
    directorio_lote="$d"
    lote+=("$f")
    nombres["$s"]=1
done
procesar_lote "$directorio_lote" "${lote[@]}"
ok "$hechos documento(s) convertido(s) a PDF."
