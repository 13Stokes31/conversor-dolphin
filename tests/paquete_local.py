#!/usr/bin/env python3
"""Construye y verifica un paquete del árbol actual sin red ni instalación.

El PKGBUILD del repositorio sigue apuntando a la última versión publicada.
Solo la copia temporal sustituye el source por un tarball local y su SHA256.
"""
import argparse
import hashlib
import os
from pathlib import Path
import re
import shutil
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, help="Conservar el paquete verificado para instalarlo después")
    args = parser.parse_args()
    scratch = ROOT / "tests" / ".tmp"
    scratch.mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="paquete-", dir=scratch) as directory:
        work = Path(directory)
        pkgbuild = (ROOT / "PKGBUILD").read_text()
        version = re.search(r"^pkgver=(.+)$", pkgbuild, re.M).group(1)
        prefix = f"conversor-dolphin-{version}"
        archive = work / f"{prefix}.tar.gz"
        sources = sorted(ROOT.glob("*.sh")) + sorted(ROOT.glob("*.desktop")) + [ROOT / "Makefile", ROOT / "LICENSE"]
        with tarfile.open(archive, "w:gz") as tar:
            for path in sources:
                tar.add(path, arcname=f"{prefix}/{path.name}")
        checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
        pkgbuild = re.sub(r"^source=.*$", f"source=('{archive.name}')", pkgbuild, flags=re.M)
        pkgbuild = re.sub(r"^sha256sums=.*$", f"sha256sums=('{checksum}')", pkgbuild, flags=re.M)
        (work / "PKGBUILD").write_text(pkgbuild)
        shutil.copy2(ROOT / "conversor-dolphin.install", work)
        env = dict(os.environ, SRCDEST=str(work), PKGDEST=str(work), BUILDDIR=str(work), TMPDIR=str(work))
        subprocess.run(["makepkg", "--force", "--noconfirm", "--nosign"], cwd=work, env=env, check=True)
        packages = list(work.glob("*.pkg.tar.*"))
        if len(packages) != 1:
            raise RuntimeError(f"Se esperaba un paquete, encontrados: {packages}")
        package = packages[0]
        names = subprocess.check_output(["bsdtar", "-tf", str(package)], text=True).splitlines()
        listing = subprocess.check_output(["bsdtar", "--numeric-owner", "-tvf", str(package)], text=True)
        for line in listing.splitlines():
            fields = line.split()
            if fields[2:4] != ["0", "0"]:
                raise RuntimeError(f"El paquete no tiene propietario root: {line}")
        expected = {f"usr/share/conversor-dolphin/{p.name}" for p in ROOT.glob("*.sh")}
        expected |= {f"usr/share/kio/servicemenus/{p.name}" for p in ROOT.glob("*.desktop")}
        expected.add("usr/share/licenses/conversor-dolphin/LICENSE")
        missing = expected - set(names)
        if missing:
            raise RuntimeError(f"Faltan archivos en el paquete: {sorted(missing)}")
        unexpected = {name for name in names if name.startswith("usr/") and not name.endswith("/")} - expected
        if unexpected:
            raise RuntimeError(f"Archivos inesperados en el paquete: {sorted(unexpected)}")
        for name in names:
            if name.endswith(".desktop"):
                content = subprocess.check_output(["bsdtar", "-xOf", str(package), name], text=True)
                if "X-KDE-Protocol=file" not in content or 'Exec="/usr/share/conversor-dolphin/' not in content:
                    raise RuntimeError(f"Menú instalado incorrecto: {name}")
        metadata = subprocess.check_output(["bsdtar", "-xOf", str(package), ".PKGINFO"], text=True)
        if "depend = poppler" not in metadata or "depend = kdialog" not in metadata:
            raise RuntimeError("Dependencias obligatorias incorrectas")
        if shutil.which("namcap"):
            subprocess.run(["namcap", str(package)], cwd=work, env=env, check=True)
        else:
            print("namcap no está instalado; se verifican contenido, menús y metadatos con bsdtar.")
        if args.output_dir is not None:
            args.output_dir.mkdir(parents=True, exist_ok=True)
            destination = args.output_dir / package.name
            # No reemplazar otro paquete conservado anteriormente.
            with destination.open("xb") as output, package.open("rb") as source:
                shutil.copyfileobj(source, output)
            print(f"Paquete conservado: {destination.resolve()}")
        print(f"Paquete local correcto: {len(expected)} archivos de aplicación. No se ha instalado ni publicado.")


if __name__ == "__main__":
    main()
