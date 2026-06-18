# Maintainer: Stokes <jesusmanuelgonzalezmeneses18@gmail.com>

pkgname=conversor-dolphin
pkgver=1.3.0
pkgrel=1
pkgdesc="Dolphin (KF6) service menu to manage PDF and convert PDF, images, SVG, audio, video, e-books and office files"
arch=('any')
url="https://github.com/13Stokes31/conversor-dolphin"
license=('MIT')
depends=('poppler' 'kdialog')
optdepends=('ghostscript: comprimir PDF'
            'img2pdf: convertir imágenes a PDF (sin pérdida)'
            'imagemagick: convertir entre formatos de imagen (JPG/PNG/WebP/AVIF/TIFF, HEIC…)'
            'ffmpeg: convertir audio y vídeo'
            'librsvg: convertir SVG a PNG/PDF'
            'calibre: convertir libros electrónicos (EPUB/MOBI/AZW…) a PDF'
            'libreoffice-still: convertir documentos de oficina a PDF (o libreoffice-fresh)'
            'ocrmypdf: OCR, añadir capa de texto buscable a un PDF (AUR)'
            'tesseract-data-spa: datos de OCR en español')
install="$pkgname.install"
source=("pdf-unir.sh"
        "pdf-dividir.sh"
        "pdf-convertir.sh"
        "img-a-pdf.sh"
        "office-a-pdf.sh"
        "img-convertir.sh"
        "audio-convertir.sh"
        "video-convertir.sh"
        "svg-convertir.sh"
        "ebook-a-pdf.sh"
        "conversor-dolphin-pdf.desktop"
        "conversor-dolphin-unir.desktop"
        "conversor-dolphin-imagenes.desktop"
        "conversor-dolphin-oficina.desktop"
        "conversor-dolphin-audio.desktop"
        "conversor-dolphin-video.desktop"
        "conversor-dolphin-svg.desktop"
        "conversor-dolphin-ebook.desktop"
        "Makefile"
        "LICENSE")
sha256sums=('99769f3853c4505662a0250b6866736d24c0af7f6b814a5bc4ba8b784a552e72'
            '27ba15d61802747f43c40eb576c6e3e892a9d5d9cf257af0947f7c0ed5a73765'
            '88b7d872c73ab9f5cc4e27fb33a469c8cbbd964fb2980bd8427040ca61157b28'
            '7ea4acf2a2961db3334e31aa17639b3fb21239242a6b0cc023cc4e301a150377'
            '79539e8645adcf66f196189906775e7a112ca3b2682270011dd2c7d74aedb759'
            'd4fdbbed1fea26b416570e3e1fed26559ef5304930cc3a98b3e808b01ea67953'
            '9817dbe692317b2f8c691e94ab18de7ca88310bb51567ab85e2397ecddae90d2'
            'fa2e4f952a5c62abfaff623fd65c14631d4b71a27eec3c033897011e39aa50e1'
            'd50325e1090043dabb5d6989ac001f22c22865232c7bdb382d0218547e98bed7'
            '84c1661c58425896646395045b57b6d4d4fce56db5ccbe6cb18eee3dfdf6867c'
            '338067a69134ce47784d1dcb48b26963c236c871ee0ae9df67402bae9a00a99b'
            '8dd67cc4008f86254ff6a93732ec9c7138d1e8f75324d880663f5a9a87abe5d0'
            '8e3a51f2a8e6a6598f134c4d22f8a6308deecf63a37cc1265fe8b81baf0bc4a8'
            '7cc95ce2fea51f303510590e98451b4c39203234a8773aca4ed3517867ab7e5d'
            '68c627abd580aa3a303ba507a1c3b988593e2da5c9a69719f91db58c28a0c566'
            '38e592858052c5213f104d3d956de7a12f71b9dcb802786f534073868091f22b'
            'dcbc0e56a803d93d8789111172f4c84617b8db5ef341d89c028d12b8805effd3'
            '2fd4ef78aec46462df2cfe72f580dee227e1706676d8ae9443ac990300a6e427'
            '15d049b7c6267ade3114f711448da99d9ef2972deedce9ae5d515f5bb8a6baa0'
            'b6b66ed3de09e5429cd6c6e7ebb2ad74f77ea2e9e15009063b0741668d2b45f8')

package() {
    make -C "$srcdir" DESTDIR="$pkgdir" PREFIX=/usr install
}
