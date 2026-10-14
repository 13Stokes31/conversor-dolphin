// Verifica los menús instalados con la misma API de KIO que utiliza Dolphin.
// No ejecuta acciones, abre ventanas ni accede a servidores remotos.
#include <KFileItemActions>
#include <KFileItemListProperties>
#include <QApplication>
#include <QDir>
#include <QFile>
#include <QImage>
#include <QMenu>
#include <QTemporaryDir>
#include <iostream>
#include <stdexcept>
#include <sys/stat.h>

static QMenu *submenu(QMenu &menu, const QString &english, const QString &spanish)
{
    for (QAction *action : menu.actions()) {
        if (action->menu() && (action->text() == english || action->text() == spanish)) {
            return action->menu();
        }
    }
    return nullptr;
}

static void check(const KFileItemList &items, const QString &english, const QString &spanish,
                  int count, const QString &icon = {})
{
    KFileItemActions actions;
    actions.setItemListProperties(KFileItemListProperties(items));
    QMenu menu;
    actions.addActionsTo(&menu, KFileItemActions::MenuActionSource::Services);
    QMenu *found = submenu(menu, english, spanish);
    if ((count == 0 && found) || (count > 0 && (!found || found->actions().size() != count))) {
        throw std::runtime_error("Filtro o número de acciones incorrecto: " + english.toStdString());
    }
    if (found && !icon.isEmpty() && (found->icon().name() != icon || found->icon().isNull())) {
        throw std::runtime_error("Icono incorrecto: " + english.toStdString());
    }
    std::cout << english.toStdString() << ": " << count << " acciones";
    if (found && !icon.isEmpty()) std::cout << ", icono " << found->icon().name().toStdString();
    std::cout << '\n';
}

int main(int argc, char **argv)
{
    QApplication app(argc, argv);
    QIcon::setThemeName("breeze");
    try {
        QTemporaryDir temporary(QDir::currentPath() + "/tests/.tmp/kde-XXXXXX");
        if (!temporary.isValid()) throw std::runtime_error("No se pudo crear la carpeta de prueba");
        const QString imagePath = temporary.filePath("foto.png");
        QImage image(16, 16, QImage::Format_RGB32);
        image.fill(Qt::blue);
        if (!image.save(imagePath)) throw std::runtime_error("No se pudo crear la imagen de prueba");
        const KFileItem localImage(QUrl::fromLocalFile(imagePath), "image/png", S_IFREG);
        check({localImage}, "Convert image", "Convertir imagen", 6, "image-png");
        for (const QString &scheme : {QString("sftp"), QString("smb")}) {
            const KFileItem remote(QUrl(scheme + "://example.invalid/foto.png"), "image/png", S_IFREG);
            check({remote}, "Convert image", "Convertir imagen", 0);
        }
        const QString pdfPath = temporary.filePath("documento.pdf");
        QFile pdf(pdfPath);
        if (!pdf.open(QIODevice::WriteOnly)) throw std::runtime_error("No se pudo crear el PDF de prueba");
        pdf.write("%PDF-1.4\n");
        pdf.close();
        const KFileItem localPdf(QUrl::fromLocalFile(pdfPath), "application/pdf", S_IFREG);
        check({localPdf}, "PDF Actions", "Acciones PDF", 7, "application-pdf");
        check({localPdf, localPdf}, "PDF Actions", "Acciones PDF", 1, "application-pdf");
        check({localImage, localPdf}, "Convert image", "Convertir imagen", 0);
        check({localImage, localPdf}, "PDF Actions", "Acciones PDF", 0);
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
