#!/usr/bin/env bash
# Uso: img-a-pdf.sh imagen1 [imagen2 ...]. Orden natural por ruta.
# JPEG se incrusta sin recodificar. Los formatos que img2pdf no puede leer se
# decodifican con ImageMagick a PNG, conservando todos sus fotogramas/páginas.
set -Eeuo pipefail
TITULO="Imágenes a PDF"
# shellcheck source=comun.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/comun.sh"
need img2pdf img2pdf
(( $# >= 1 )) || err "Selecciona al menos una imagen."
validar_archivos "$@"
iniciar_temporales
mapfile -d '' -t imgs < <(printf '%s\0' "$@" | sort -zV)
ruta_archivo "${imgs[0]}"
dir="$d"; base="$s"
(( ${#imgs[@]} == 1 )) || base+="_y_otras"
nuevo_temporal "$dir"
stage="$trabajo"
partes=()
i=0
for imagen in "${imgs[@]}"; do
    ruta_archivo "$imagen"
    i=$((i + 1)); parte="$stage/parte-$i.pdf"
    if ! img2pdf "$f" -o "$parte" 2>"$errf"; then
        IM=$(command -v magick || command -v convert || true)
        [[ -n "$IM" ]] || err "img2pdf no pudo leer «${f##*/}»:\n$(tail -3 "$errf")\n\nPara HEIC/HEIF instala ImageMagick y libheif:\n    sudo pacman -S imagemagick libheif"
        mkdir -- "$stage/imagen-$i"
        # Solo el patrón controlado llega a ImageMagick; las rutas de usuario
        # se utilizan en cd y la redirección, sin expansión propia del conversor.
        if ! (cd -- "$stage/imagen-$i" && "$IM" - -auto-orient 'pagina-%d.png' <"$f") 2>"$errf"; then
            err "No se pudo leer «${f##*/}»:\n$(tail -3 "$errf")"
        fi
        mapfile -d '' -t pngs < <(find "$stage/imagen-$i" -maxdepth 1 -type f -name '*.png' -print0 | sort -zV)
        (( ${#pngs[@]} > 0 )) || err "No se generó ninguna imagen para «${f##*/}»."
        if ! img2pdf "${pngs[@]}" -o "$parte" 2>"$errf"; then
            err "No se pudo crear el PDF de «${f##*/}»:\n$(tail -3 "$errf")"
        fi
    fi
    partes+=("$parte")
done
if ! pdfunite "${partes[@]}" "$stage/salida.pdf" 2>"$errf"; then
    err "No se pudieron combinar las imágenes:\n$(tail -3 "$errf")"
fi
publicar "$stage/salida.pdf" "$dir/$base" .pdf
ok "PDF creado a partir de ${#imgs[@]} imagen(es):\n${resultado##*/}"
