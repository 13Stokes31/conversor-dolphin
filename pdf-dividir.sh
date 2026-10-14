#!/usr/bin/env bash
# Uso: pdf-dividir.sh <paginas|rango|bloques> archivo.pdf.
set -Eeuo pipefail
TITULO="Dividir PDF"
# shellcheck source=comun.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/comun.sh"
(( $# == 2 )) || err "Uso interno incorrecto del script de división."
modo="$1"
validar_archivos "$2"
ruta_archivo "$2"; file="$f"; dir="$d"; stem="$s"
iniciar_temporales
total=$(LC_ALL=C pdfinfo "$file" 2>/dev/null | awk '/^Pages:/ {print $2}') || true
[[ "$total" =~ ^[1-9][0-9]*$ ]] || err "No se pudo leer el PDF (¿dañado o cifrado?):\n${file##*/}"
case "$modo" in
    paginas) ;;
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
# pdfseparate interpreta el patrón COMPLETO como printf, incluida la carpeta.
patron="$outdir/tmp-pg"; patron="${patron//%/%%}%d.pdf"
extraer() {
    pdfseparate -f "$1" -l "$2" "$file" "$patron" 2>"$errf" \
        || err "No se pudo dividir el PDF:\n$(tail -3 "$errf")"
}
unir_rango() {
    local destino="$1" inicio="$2" final="$3" pagina partes=()
    for ((pagina = inicio; pagina <= final; pagina++)); do partes+=("$outdir/tmp-pg$pagina.pdf"); done
    pdfunite "${partes[@]}" "$destino" 2>"$errf" \
        || err "No se pudo componer el resultado:\n$(tail -3 "$errf")"
    rm -f -- "${partes[@]}"
}
case "$modo" in
    paginas)
        extraer 1 "$total"
        for ((p = 1; p <= total; p++)); do mv -- "$outdir/tmp-pg$p.pdf" "$outdir/$stem-$p.pdf"; done
        cantidad="$total"
        ;;
    rango)
        extraer "$ini" "$fin"
        unir_rango "$outdir/$stem-${ini}_a_${fin}.pdf" "$ini" "$fin"
        cantidad=1
        ;;
    bloques)
        parte=1
        for ((ini = 1; ini <= total; ini += bloque)); do
            fin=$((ini + bloque - 1)); (( fin <= total )) || fin="$total"
            extraer "$ini" "$fin"
            unir_rango "$outdir/$stem-$parte.pdf" "$ini" "$fin"
            parte=$((parte + 1))
        done
        cantidad=$((parte - 1))
        ;;
esac
publicar "$outdir" "$dir/$stem-dividido"
ok "$cantidad archivo(s) creado(s) en:\n${resultado##*/}/"
