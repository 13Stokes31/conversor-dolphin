# Maintainer: Stokes <jesusmanuelgonzalezmeneses18@gmail.com>

pkgname=conversor-dolphin
pkgver=1.0.0
pkgrel=1
pkgdesc="Dolphin (KF6) service menu to merge and split PDF files — poppler + kdialog"
arch=('any')
url="https://github.com/Stokes/conversor-dolphin"
license=('MIT')
depends=('poppler' 'kdialog')
install="$pkgname.install"
source=("pdf-unir.sh"
        "pdf-dividir.sh"
        "conversor-dolphin-unir.desktop"
        "conversor-dolphin-dividir.desktop"
        "Makefile"
        "LICENSE")
sha256sums=('99769f3853c4505662a0250b6866736d24c0af7f6b814a5bc4ba8b784a552e72'
            '27ba15d61802747f43c40eb576c6e3e892a9d5d9cf257af0947f7c0ed5a73765'
            '220c378200e1d9a5d7461a7acde059585979950537f9db3c142cec4f635bcaf1'
            '486d2abbc25e4dc8a85eaff0dd6c81b368790a7feccfc7eedd1ff25604c75ca7'
            '57573ce9e24fecf99cf56bc82871744bcb27bc1fc3e084e8eecd15e0dc810e58'
            'b6b66ed3de09e5429cd6c6e7ebb2ad74f77ea2e9e15009063b0741668d2b45f8')

package() {
    make -C "$srcdir" DESTDIR="$pkgdir" PREFIX=/usr install
}
