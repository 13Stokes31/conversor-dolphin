#!/usr/bin/env bash
# Uso: pdf-dividir.sh <paginas|rango|bloques> archivo.pdf.
set -Eeuo pipefail
TITULO="Dividir PDF"
# shellcheck source=comun.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/comun.sh"
(( $# == 2 )) || err "Uso interno incorrecto del script de división."
need qpdf qpdf
modo="$1"
validar_archivos "$2"
ruta_archivo "$2"; file="$f"; dir="$d"; stem="$s"
iniciar_temporales
if ! total=$(qpdf --warning-exit-0 --show-npages "$file" 2>"$errf") || [[ ! "$total" =~ ^[1-9][0-9]*$ ]]; then
    err "No se pudo leer el PDF (¿dañado o cifrado?):\n${file##*/}"
fi
case "$modo" in
    paginas) bloque=1 ;;
    rango)
        r=$(kdialog --title "$TITULO" --inputbox "Páginas a extraer (1-$total).\nEjemplos: 3-7 o 5" "") || cancelar
        r="${r//[[:space:]]/}"
        if [[ "$r" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            inicio="${BASH_REMATCH[1]}"; final="${BASH_REMATCH[2]}"
        elif [[ "$r" =~ ^[0-9]+$ ]]; then
            inicio="$r"; final="$r"
        else
            err "Rango no válido: «$r».\nUsa 3-7 o un solo número."
        fi
        numero_decimal "$inicio" "$total" || err "Página inicial fuera de los límites (1-$total): $inicio"
        ini="$numero"
        numero_decimal "$final" "$total" || err "Página final fuera de los límites (1-$total): $final"
        fin="$numero"
        (( ini <= fin )) || err "La página inicial no puede ser posterior a la final."
        ;;
    bloques)
        nstr=$(kdialog --title "$TITULO" --inputbox "Número de páginas por bloque (1-$total):" "") || cancelar
        nstr="${nstr//[[:space:]]/}"
        numero_decimal "$nstr" "$total" || err "Número de páginas por bloque no válido: «$nstr»."
        bloque="$numero"
        ;;
    *) err "Modo de división desconocido: $modo" ;;
esac
nuevo_temporal "$dir"
outdir="$trabajo/documentos"
mkdir -- "$outdir"
# Copia el cifrado si lo hay. qpdf lo elimina por defecto al dividir.
opciones=(--warning-exit-0 --copy-encryption="$file")
if [[ "$modo" == rango ]]; then
    salida="$outdir/$stem-${ini}_a_${fin}.pdf"
    if ! qpdf "${opciones[@]}" --empty --pages "$file" "$ini-$fin" -- "$salida" 2>"$errf" \
        || [[ ! -s "$salida" ]]; then
        err "No se pudo extraer el rango:\n$(tail -3 "$errf")"
    fi
    cantidad=1
else
    # El patrón relativo evita que qpdf interprete un «%d» de la ruta original.
    if ! (cd -- "$trabajo" && qpdf "${opciones[@]}" "$file" --split-pages="$bloque" 'parte-%d.pdf') 2>"$errf"; then
        err "No se pudo dividir el PDF:\n$(tail -3 "$errf")"
    fi
    # qpdf rellena con ceros los números de página. La expansión los ordena.
    shopt -s nullglob
    unset GLOBSORT
    partes=("$trabajo"/parte-*.pdf)
    cantidad=$(( (total + bloque - 1) / bloque ))
    (( ${#partes[@]} == cantidad )) || err "qpdf no generó todos los PDF esperados."
    for i in "${!partes[@]}"; do
        [[ -s "${partes[i]}" ]] || err "qpdf generó un PDF vacío."
        mv -- "${partes[i]}" "$outdir/$stem-$((i + 1)).pdf"
    done
fi
publicar "$outdir" "$dir/$stem-dividido"
ok "$cantidad archivo(s) creado(s) en:\n${resultado##*/}/"
