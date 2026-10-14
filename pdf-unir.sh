#!/usr/bin/env bash
# Uso: pdf-unir.sh archivo1.pdf archivo2.pdf [archivo3.pdf ...].
set -Eeuo pipefail
TITULO="Unir PDF"
# shellcheck source=comun.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/comun.sh"
(( $# >= 2 )) || err "Selecciona al menos dos archivos PDF para unir."
validar_archivos "$@"
iniciar_temporales
files=()
for archivo in "$@"; do ruta_archivo "$archivo"; files+=("$f"); done
dir="${files[0]%/*}"; dir="${dir:-/}"
listado=""
for i in "${!files[@]}"; do
    nombre="${files[i]##*/}"
    nombre="${nombre//$'\n'/⏎}"; nombre="${nombre//$'\r'/⏎}"
    listado+="$((i + 1)). $nombre"$'\n'
done
orden=$(kdialog --title "$TITULO" --textinputbox \
    "Reordena las líneas para cambiar el orden de unión.\nPuedes eliminar líneas para excluir documentos; deben quedar al menos dos.\nConserva los números: identifican los archivos originales." "$listado") || cancelar
ordered=(); seen=","
while IFS= read -r line; do
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" =~ ^[[:space:]]*([0-9]+)\. ]] || err "Línea sin número de orden válido:\n$line"
    num="${BASH_REMATCH[1]}"
    numero_decimal "$num" "${#files[@]}" || err "Número fuera de rango: $num"
    idx=$((numero - 1))
    [[ "$seen" != *",$idx,"* ]] || err "Has repetido el archivo número $num."
    seen+="$idx,"
    ordered+=("${files[idx]}")
done <<<"$orden"
(( ${#ordered[@]} >= 2 )) || err "Necesitas al menos dos archivos en el orden final."
ruta_archivo "${ordered[0]}"; base="$s"
if (( ${#ordered[@]} == 2 )); then
    ruta_archivo "${ordered[1]}"; base+="_$s"
else
    base+="_y_otros"
fi
nuevo_temporal "$dir"
if ! pdfunite "${ordered[@]}" "$trabajo/salida.pdf" 2>"$errf"; then
    err "No se pudieron unir los PDF:\n$(tail -3 "$errf")"
fi
publicar "$trabajo/salida.pdf" "$dir/$base" .pdf
ok "PDF creado:\n${resultado##*/}"
