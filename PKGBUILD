# Maintainer: Stokes <jesusmanuelgonzalezmeneses18@gmail.com>

pkgname=conversor-dolphin
pkgver=1.1.0
pkgrel=1
pkgdesc="Dolphin (KF6) service menu to merge, split and convert PDF, image and office files"
arch=('any')
url="https://github.com/Stokes/conversor-dolphin"
license=('MIT')
depends=('poppler' 'kdialog')
optdepends=('ghostscript: comprimir PDF'
            'img2pdf: convertir imágenes a PDF (sin pérdida)'
            'libreoffice-still: convertir documentos de oficina a PDF (o libreoffice-fresh)'
            'ocrmypdf: OCR, añadir capa de texto buscable a un PDF'
            'tesseract-data-spa: datos de OCR en español')
install="$pkgname.install"
source=("pdf-unir.sh"
        "pdf-dividir.sh"
        "pdf-convertir.sh"
        "img-a-pdf.sh"
        "office-a-pdf.sh"
        "conversor-dolphin-pdf.desktop"
        "conversor-dolphin-unir.desktop"
        "conversor-dolphin-imagenes.desktop"
        "conversor-dolphin-oficina.desktop"
        "Makefile"
        "LICENSE")
sha256sums=('99769f3853c4505662a0250b6866736d24c0af7f6b814a5bc4ba8b784a552e72'
            '27ba15d61802747f43c40eb576c6e3e892a9d5d9cf257af0947f7c0ed5a73765'
            'ced51ccb8edf7251c28596475b409c4f250156e9dd73460faab38b743e02a38a'
            '7ea4acf2a2961db3334e31aa17639b3fb21239242a6b0cc023cc4e301a150377'
            '79539e8645adcf66f196189906775e7a112ca3b2682270011dd2c7d74aedb759'
            '8c4032e801097b457dd6d57ac6e88e9ed435a93d72dd1f496622a724d22efae9'
            '220c378200e1d9a5d7461a7acde059585979950537f9db3c142cec4f635bcaf1'
            '1c04c7c1430824ac964ca77bf0160b9e30d36be042d0fb13534abadd5c0bfe54'
            'b2aa0b69cc9f5fbe59bfed419428d7b1b10c250db5f0ab09de1d01448bc734dc'
            '66ccfb47ec8c05e7c32dae8b467c78c5628c2826d26aac2ad7bfc16a31035112'
            'b6b66ed3de09e5429cd6c6e7ebb2ad74f77ea2e9e15009063b0741668d2b45f8')

package() {
    make -C "$srcdir" DESTDIR="$pkgdir" PREFIX=/usr install
}
