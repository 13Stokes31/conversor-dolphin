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
            '8c4032e801097b457dd6d57ac6e88e9ed435a93d72dd1f496622a724d22efae9'
            '220c378200e1d9a5d7461a7acde059585979950537f9db3c142cec4f635bcaf1'
            'e95ee795fe1ee19801c9cdd4d892c0f65520af7bc2142b87c87113429969b79f'
            '3cd0feea11a5a5475059e9eef499885bf1ae8fe6d9474b89dcc0be1f119e2ec5'
            'c59e2797f5d0a55d283803a51643e16e7c3885a0c31246f5736a7a089d4a633d'
            '401acccf0fee163eeffc0f986d925a7cc6194d8f6a54be7629087ade1345c131'
            'd542d83a7eda2b0148894c566e681c5d4e1c7d61e36a978549b8ee1d423d775e'
            'e864222ecd2c85b71d92a71946c445822a7d721b934e9fcbd3d5ed2cc3e075f4'
            '15d049b7c6267ade3114f711448da99d9ef2972deedce9ae5d515f5bb8a6baa0'
            'b6b66ed3de09e5429cd6c6e7ebb2ad74f77ea2e9e15009063b0741668d2b45f8')

package() {
    make -C "$srcdir" DESTDIR="$pkgdir" PREFIX=/usr install
}
