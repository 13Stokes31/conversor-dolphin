#!/usr/bin/env bash
#
# pdf-convertir.sh — Convierte un PDF a otros formatos (service menu de Dolphin).
#
# Uso: pdf-convertir.sh <modo> archivo.pdf
#   imagenes  -> una imagen (PNG/JPG) por página, en una subcarpeta
#   texto     -> extrae el texto a un .txt
#   comprimir -> reduce el tamaño con ghostscript
#   ocr       -> añade una capa de texto buscable (OCR) con ocrmypdf
#
# Errores: kdialog --error. Avisos de éxito con popup pasivo (no intrusivo).

set -Eeuo pipefail

TITULO="Convertir PDF"
# shellcheck source=comun.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/comun.sh"
(( $# == 2 )) || err "Uso interno incorrecto del script de conversión."
modo="$1"
validar_archivos "$2"
ruta_archivo "$2"; file="$f"; dir="$d"; stem="$s"
iniciar_temporales

case "$modo" in
    imagenes)
        total=$(pdfinfo "$file" 2>/dev/null | awk '/^Pages:/ {print $2}') || true
        [[ "$total" =~ ^[0-9]+$ ]] || err "No se pudo leer el PDF (¿dañado o cifrado?):\n$stem.pdf"
        sel=$(kdialog --title "$TITULO" --combobox "Formato y resolución de salida:" \
            "PNG · 150 ppp (calidad media)" \
            "PNG · 300 ppp (alta calidad)" \
            "JPG · 150 ppp (más ligero)" \
            "JPG · 300 ppp") || cancelar
        case "$sel" in
            PNG*150*) flag=-png;  fmt=png; dpi=150 ;;
            PNG*300*) flag=-png;  fmt=png; dpi=300 ;;
            JPG*150*) flag=-jpeg; fmt=jpg; dpi=150 ;;
            JPG*300*) flag=-jpeg; fmt=jpg; dpi=300 ;;
            *) exit 0 ;;
        esac
        nuevo_temporal "$dir"
        outdir="$trabajo/imagenes"
        mkdir -- "$outdir"
        if ! pdftoppm "$flag" -r "$dpi" "$file" "$outdir/$stem" 2>"$errf"; then
            err "No se pudo convertir a imágenes:\n$(cat "$errf" 2>/dev/null || echo 'error desconocido')"
        fi
        shopt -s nullglob
        imagenes=("$outdir"/*."$fmt")
        num="${#imagenes[@]}"
        (( num > 0 )) || err "No se generó ninguna imagen."
        publicar "$outdir" "$dir/$stem-imagenes"
        ok "$num imágenes ($fmt) creadas en:\n${resultado##*/}/"
        ;;

    texto)
        nuevo_temporal "$dir"
        out="$trabajo/salida.txt"
        if ! pdftotext "$file" "$out" 2>"$errf"; then
            err "No se pudo extraer el texto:\n$(cat "$errf" 2>/dev/null || echo 'error desconocido')"
        fi
        publicar "$out" "$dir/$stem" .txt
        ok "Texto extraído en:\n${resultado##*/}"
        ;;

    comprimir)
        need gs ghostscript
        sel=$(kdialog --title "$TITULO" --combobox "Nivel de compresión:" \
            "ebook · equilibrado (recomendado)" \
            "screen · máxima compresión" \
            "printer · alta calidad") || cancelar
        case "$sel" in
            ebook*)   nivel=/ebook ;;
            screen*)  nivel=/screen ;;
            printer*) nivel=/printer ;;
            *) exit 0 ;;
        esac
        nuevo_temporal "$dir"
        out="$trabajo/salida.pdf"
        if ! gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS="$nivel" \
                -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$out" "$file" 2>"$errf"; then
            err "No se pudo comprimir el PDF:\n$(cat "$errf" 2>/dev/null || echo 'error desconocido')"
        fi
        antes=$(stat -c%s -- "$file"); despues=$(stat -c%s -- "$out")
        if (( despues < antes )); then
            publicar "$out" "$dir/$stem-comprimido" .pdf
            ok "PDF comprimido ($(( 100 - despues * 100 / antes ))% más pequeño):\n${resultado##*/}"
        else
            ok "El PDF ya estaba optimizado; no se generó ninguna copia."
        fi
        ;;

    ocr)
        command -v ocrmypdf >/dev/null \
            || err "Falta «ocrmypdf» (está en AUR, no en los repos oficiales).\n\nInstálalo con:\n    yay -S ocrmypdf"
        # Idioma por defecto: español (tesseract-data-spa). Para otros idiomas,
        # instala tesseract-data-<idioma> y cambia «-l spa» abajo (p. ej. spa+eng).
        nuevo_temporal "$dir"
        out="$trabajo/salida.pdf"
        if ! ocrmypdf --skip-text -l spa "$file" "$out" 2>"$errf"; then
            err "No se pudo aplicar OCR:\n$(tail -3 "$errf" 2>/dev/null || echo 'error desconocido')"
        fi
        publicar "$out" "$dir/$stem-ocr" .pdf
        ok "OCR aplicado (texto buscable):\n${resultado##*/}"
        ;;

    *)
        err "Modo de conversión desconocido: $modo"
        ;;
esac

exit 0
