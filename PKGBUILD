# Maintainer: Stokes <jesusmanuelgonzalezmeneses18@gmail.com>

pkgname=conversor-dolphin
pkgver=1.2.0
pkgrel=1
pkgdesc="Dolphin (KF6) service menu to manage PDF and convert PDF, images, audio, video and office files"
arch=('any')
url="https://github.com/Stokes/conversor-dolphin"
license=('MIT')
depends=('poppler' 'kdialog')
optdepends=('ghostscript: comprimir PDF'
            'img2pdf: convertir imágenes a PDF (sin pérdida)'
            'imagemagick: convertir entre formatos de imagen (JPG/PNG/WebP/AVIF/TIFF, HEIC…)'
            'ffmpeg: convertir audio y vídeo'
            'libreoffice-still: convertir documentos de oficina a PDF (o libreoffice-fresh)'
            'ocrmypdf: OCR, añadir capa de texto buscable a un PDF'
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
        "conversor-dolphin-pdf.desktop"
        "conversor-dolphin-unir.desktop"
        "conversor-dolphin-imagenes.desktop"
        "conversor-dolphin-oficina.desktop"
        "conversor-dolphin-audio.desktop"
        "conversor-dolphin-video.desktop"
        "Makefile"
        "LICENSE")
sha256sums=('99769f3853c4505662a0250b6866736d24c0af7f6b814a5bc4ba8b784a552e72'
            '27ba15d61802747f43c40eb576c6e3e892a9d5d9cf257af0947f7c0ed5a73765'
            'ced51ccb8edf7251c28596475b409c4f250156e9dd73460faab38b743e02a38a'
            '7ea4acf2a2961db3334e31aa17639b3fb21239242a6b0cc023cc4e301a150377'
            '79539e8645adcf66f196189906775e7a112ca3b2682270011dd2c7d74aedb759'
            'd4fdbbed1fea26b416570e3e1fed26559ef5304930cc3a98b3e808b01ea67953'
            '9817dbe692317b2f8c691e94ab18de7ca88310bb51567ab85e2397ecddae90d2'
            '5f22e53c992d66ceb214f794f7a57ec890fb505d179d35a8697def60516470e2'
            '8c4032e801097b457dd6d57ac6e88e9ed435a93d72dd1f496622a724d22efae9'
            '220c378200e1d9a5d7461a7acde059585979950537f9db3c142cec4f635bcaf1'
            'e95ee795fe1ee19801c9cdd4d892c0f65520af7bc2142b87c87113429969b79f'
            '3cd0feea11a5a5475059e9eef499885bf1ae8fe6d9474b89dcc0be1f119e2ec5'
            'c59e2797f5d0a55d283803a51643e16e7c3885a0c31246f5736a7a089d4a633d'
            '7134355c19f04e0ec20cdde2242c5faba17ea493a211aae05d34fcaa87ef7f15'
            '56a5cfa5a12d1d84750b55fb1d1998d16526c952d0fdfb3935e9fee24b0c4471'
            'b6b66ed3de09e5429cd6c6e7ebb2ad74f77ea2e9e15009063b0741668d2b45f8')

package() {
    make -C "$srcdir" DESTDIR="$pkgdir" PREFIX=/usr install
}
