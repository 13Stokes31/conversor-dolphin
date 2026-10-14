#!/usr/bin/env bash
# Funciones compartidas: diálogos, temporales y publicación sin reemplazo.
# Se carga desde los conversores; no se ejecuta directamente.

err() {
    local mensaje="$1"
    if (( ${hechos:-0} > 0 )); then
        mensaje+="\n\nSe conservan los $hechos resultado(s) completado(s) antes del error."
    fi
    kdialog --title "$TITULO" --error "$mensaje" || true
    exit 1
}

ok() { kdialog --title "$TITULO" --passivepopup "$1" 6 >/dev/null 2>&1 || true; }
need() { command -v "$1" >/dev/null || err "Falta «$1».\n\nInstálalo con:\n    sudo pacman -S $2"; }
cancelar() {
    (( ${hechos:-0} == 0 )) || ok "Operación cancelada. Se conservan $hechos resultado(s) completado(s)."
    exit 0
}

validar_archivos() {
    local archivo
    for archivo in "$@"; do
        [[ -f "$archivo" && -r "$archivo" ]] || err "El archivo no existe o no se puede leer:\n$archivo"
    done
}

# Evita interpretar rutas relativas como opciones o protocolos; conserva saltos
# de línea incluso al final del nombre (sin sustituciones de órdenes).
ruta_archivo() {
    f="$1"
    [[ "$f" == /* ]] || f="$PWD/$f"
    d="${f%/*}"; d="${d:-/}"
    s="${f##*/}"; s="${s%.*}"
    [[ -n "$s" ]] || s="${f##*/}"
}

limpiar_temporales() {
    local directorio
    for directorio in "${temporales[@]}"; do rm -rf -- "$directorio"; done
}

nuevo_temporal() {
    trabajo=$(mktemp -d -- "$1/.conversor-dolphin.XXXXXXXX") \
        || err "No se puede crear un temporal en:\n$1\nComprueba los permisos y el espacio libre."
    temporales+=("$trabajo")
}

iniciar_temporales() {
    temporales=()
    trap limpiar_temporales EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    trap 'err "No se pudo completar la operación. Comprueba los permisos y el espacio libre."' ERR
    nuevo_temporal "${TMPDIR:-/tmp}"
    tmp="$trabajo"
    errf="$tmp/error"
    hechos=0
}

# El temporal se crea junto al original: mv no tiene que copiar entre sistemas
# de archivos. GNU mv utiliza la operación de renombrado sin reemplazo de Linux.
# Comprobamos también el origen: mv -n puede devolver éxito aunque haya omitido
# un destino existente. -T impide introducir la salida en una carpeta existente.
publicar() {
    local origen="$1" base="$2" extension="${3:-}" destino sufijo="" n=1
    [[ -e "$origen" ]] || err "La herramienta no ha generado el resultado esperado."
    while :; do
        destino="$base$sufijo$extension"
        if mv --no-clobber -T -- "$origen" "$destino" 2>"$errf"; then
            if [[ ! -e "$origen" && ! -L "$origen" ]]; then
                # La ruta se utiliza en los mensajes de los conversores.
                # shellcheck disable=SC2034
                resultado="$destino"
                return 0
            fi
        fi
        [[ -e "$destino" || -L "$destino" ]] \
            || err "No se pudo guardar el resultado:\n$(tail -3 "$errf")"
        n=$((n + 1)); sufijo="-$n"
    done
}

# Convierte entrada decimal de usuario, acotándola antes de hacer aritmética
# para impedir tanto la interpretación octal como el desbordamiento.
numero_decimal() {
    local valor="$1" maximo="$2"
    [[ "$valor" =~ ^[0-9]+$ ]] || return 1
    valor="${valor#"${valor%%[!0]*}"}"; valor="${valor:-0}"
    (( ${#valor} <= ${#maximo} )) || return 1
    numero=$((10#$valor))
    (( numero >= 1 && numero <= maximo ))
}
