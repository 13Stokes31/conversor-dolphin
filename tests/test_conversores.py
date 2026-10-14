"""Pruebas de comportamiento con kdialog simulado y conversores reales.

Todas las entradas, salidas, perfiles y paquetes se crean en tests/.tmp.
No se toca la instalación del sistema ni se necesita una sesión gráfica.
"""
import configparser
import hashlib
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
INTEGRATION = os.environ.get("CONVERSOR_TEST_INTEGRATION") == "1"


def requires(*commands):
    missing = [command for command in commands if not shutil.which(command)]
    return unittest.skipIf(bool(missing), "Faltan herramientas: " + ", ".join(missing))


def write_pdf(path, texts):
    """PDF mínimo válido, con texto por página y xref calculada."""
    objects = [b"<< /Type /Catalog /Pages 2 0 R >>", b"", b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>"]
    pages = []
    for text in texts:
        page = len(objects) + 1
        pages.append(page)
        objects.append(f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 200 200] /Resources << /Font << /F1 3 0 R >> >> /Contents {page + 1} 0 R >>".encode())
        escaped = text.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")
        content = f"BT /F1 12 Tf 20 100 Td ({escaped}) Tj ET".encode("latin1")
        objects.append(f"<< /Length {len(content)} >>\nstream\n".encode() + content + b"\nendstream")
    objects[1] = f"<< /Type /Pages /Kids [{' '.join(f'{p} 0 R' for p in pages)}] /Count {len(pages)} >>".encode()
    data = bytearray(b"%PDF-1.4\n")
    offsets = []
    for i, obj in enumerate(objects, 1):
        offsets.append(len(data))
        data.extend(f"{i} 0 obj\n".encode() + obj + b"\nendobj\n")
    xref = len(data)
    data.extend(f"xref\n0 {len(objects) + 1}\n0000000000 65535 f \n".encode())
    for offset in offsets:
        data.extend(f"{offset:010d} 00000 n \n".encode())
    data.extend(f"trailer\n<< /Size {len(objects) + 1} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode())
    path.write_bytes(data)


class ConverterTests(unittest.TestCase):
    def setUp(self):
        scratch = ROOT / "tests" / ".tmp"
        scratch.mkdir(exist_ok=True)
        self.temporary = tempfile.TemporaryDirectory(prefix="prueba-", dir=scratch)
        self.addCleanup(self.temporary.cleanup)
        self.work = Path(self.temporary.name)
        self.bin = self.work / "bin"
        self.bin.mkdir()
        self.log = self.work / "dialogos.jsonl"
        self.env = dict(os.environ, PATH=f"{self.bin}:{os.environ['PATH']}", TMPDIR=str(self.work),
                        DIALOG_LOG=str(self.log), QT_QPA_PLATFORM="offscreen", PYTHONDONTWRITEBYTECODE="1",
                        XDG_CONFIG_HOME=str(self.work / "config"), XDG_CACHE_HOME=str(self.work / "cache"),
                        XDG_DATA_HOME=str(self.work / "data"), CALIBRE_CONFIG_DIRECTORY=str(self.work / "calibre"))
        for key in ("DIALOG_ANSWER", "DIALOG_CANCEL"):
            self.env.pop(key, None)
        self.stub("kdialog", '''#!/usr/bin/env python3
import json, os, sys
a = sys.argv[1:]
with open(os.environ["DIALOG_LOG"], "a") as f:
    f.write(json.dumps(a) + "\\n")
for option in ("--textinputbox", "--inputbox", "--combobox", "--yesno"):
    if option in a:
        if os.environ.get("DIALOG_CANCEL") == "1":
            sys.exit(1)
        i = a.index(option)
        if option != "--yesno":
            print(os.environ.get("DIALOG_ANSWER", a[i + 2]))
        break
''')

    def stub(self, name, script):
        target = self.bin / name
        target.write_text(script)
        target.chmod(0o755)
        return target

    def command(self, *args, **kwargs):
        result = subprocess.run(args, cwd=self.work, env=self.env, capture_output=True, text=True,
                                timeout=180, **kwargs)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def run_script(self, name, *args, answer=None, cancel=False, success=True, cwd=None):
        env = dict(self.env)
        if answer is not None:
            env["DIALOG_ANSWER"] = answer
        if cancel:
            env["DIALOG_CANCEL"] = "1"
        result = subprocess.run(["bash", str(ROOT / name), *map(str, args)], cwd=cwd or self.work,
                                env=env, capture_output=True, text=True, timeout=180)
        dialogs = self.dialogs()
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr + str(dialogs))
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertTrue(any("--error" in dialog for dialog in dialogs), dialogs)
        self.assertFalse(list(self.work.rglob(".conversor-dolphin.*")), "Temporales sin limpiar")
        return result

    def dialogs(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def pages(self, pdf):
        info = self.command("pdfinfo", str(pdf)).stdout
        return int(next(line.split(":", 1)[1] for line in info.splitlines() if line.startswith("Pages:")))

    def pdf(self, name="documento.pdf", count=12):
        path = self.work / name
        write_pdf(path, [f"Pagina {i}" for i in range(1, count + 1)])
        return path

    def image(self, name="foto.png", color="red"):
        path = self.work / name
        self.command("magick", "-size", "32x24", f"xc:{color}", str(path))
        return path

    def video(self, name="video.mkv", size="322x239", codec="ffv1"):
        path = self.work / name
        self.command("ffmpeg", "-nostdin", "-loglevel", "error", "-f", "lavfi", "-i",
                     f"testsrc=size={size}:rate=4:duration=0.5", "-f", "lavfi", "-i",
                     "sine=duration=0.5:sample_rate=48000", "-c:v", codec, "-c:a", "pcm_s16le", str(path))
        return path

    def probe(self, path):
        return json.loads(self.command("ffprobe", "-v", "error", "-show_streams", "-of", "json", str(path)).stdout)["streams"]

    def test_service_menus_local_and_image_icon(self):
        for path in ROOT.glob("*.desktop"):
            config = configparser.ConfigParser(interpolation=None)
            config.read(path)
            entry = config["Desktop Entry"]
            self.assertEqual(entry["X-KDE-Protocol"], "file")
            for action in entry["Actions"].split(";"):
                self.assertIn("Desktop Action " + action, config)
                command = shlex.split(config["Desktop Action " + action]["Exec"])
                self.assertTrue((ROOT / Path(command[0]).name).exists())
            if path.name == "conversor-dolphin-imagenes.desktop":
                first = entry["Actions"].split(";")[0]
                self.assertTrue(config["Desktop Action " + first]["Icon"].startswith("image-"))
                self.assertEqual(config["Desktop Action imgToPdf"]["Icon"], "application-pdf")

    @requires("makepkg")
    def test_srcinfo_matches_pkgbuild(self):
        result = subprocess.run(["makepkg", "--printsrcinfo"], cwd=ROOT, capture_output=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, (ROOT / ".SRCINFO").read_bytes())

    def test_install_custom_prefix_and_uninstall(self):
        for prefix in ("/usr", "/usr/local", "/opt/conversor con espacios"):
            with self.subTest(prefix=prefix):
                stage = self.work / "paquete"
                result = subprocess.run(["make", "install", f"DESTDIR={stage}", f"PREFIX={prefix}"],
                                        cwd=ROOT, capture_output=True, text=True, timeout=30)
                self.assertEqual(result.returncode, 0, result.stderr)
                share = stage / prefix.lstrip("/") / "share"
                scripts = share / "conversor-dolphin"
                self.assertEqual(len(list(scripts.glob("*.sh"))), 11)
                for menu in (share / "kio/servicemenus").glob("*.desktop"):
                    config = configparser.ConfigParser(interpolation=None)
                    config.read(menu)
                    for section in config.sections():
                        if "Exec" in config[section]:
                            executable = shlex.split(config[section]["Exec"])[0]
                            self.assertTrue((stage / executable.lstrip("/")).is_file())
                unrelated = scripts / "archivo-ajeno"
                unrelated.touch()
                result = subprocess.run(["make", "uninstall", f"DESTDIR={stage}", f"PREFIX={prefix}"],
                                        cwd=ROOT, capture_output=True, text=True, timeout=30)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertTrue(unrelated.exists())
                self.assertFalse(list(scripts.glob("*.sh")))
                unrelated.unlink()

    def test_concurrent_publication_preserves_all_results(self):
        script = f'''set -Eeuo pipefail
TITULO=Prueba
source {shlex.quote(str(ROOT / 'comun.sh'))}
iniciar_temporales
nuevo_temporal "$PWD"
printf '%s' "$1" > "$trabajo/salida.txt"
publicar "$trabajo/salida.txt" "$PWD/resultado" .txt
'''
        processes = [subprocess.Popen(["bash", "-c", script, "prueba", str(i)], cwd=self.work,
                                      env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE) for i in range(12)]
        for process in processes:
            stdout, stderr = process.communicate(timeout=30)
            self.assertEqual(process.returncode, 0, stdout + stderr)
        results = list(self.work.glob("resultado*.txt"))
        self.assertEqual({path.read_text() for path in results}, {str(i) for i in range(12)})
        self.assertEqual(len(results), 12)
        self.assertFalse(list(self.work.rglob(".conversor-dolphin.*")))

    def test_concurrent_directory_publication(self):
        existing = self.work / "resultado"
        existing.mkdir()
        script = f'''set -Eeuo pipefail
TITULO=Prueba
source {shlex.quote(str(ROOT / 'comun.sh'))}
iniciar_temporales
nuevo_temporal "$PWD"
mkdir "$trabajo/carpeta"
printf '%s' "$1" > "$trabajo/carpeta/contenido"
publicar "$trabajo/carpeta" "$PWD/resultado"
'''
        processes = [subprocess.Popen(["bash", "-c", script, "prueba", str(i)], cwd=self.work,
                                      env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE) for i in range(6)]
        for process in processes:
            stdout, stderr = process.communicate(timeout=30)
            self.assertEqual(process.returncode, 0, stdout + stderr)
        self.assertEqual(list(existing.iterdir()), [])
        self.assertEqual({p.read_text() for p in self.work.glob("resultado-*/contenido")}, {str(i) for i in range(6)})

    @requires("pdfinfo", "pdfseparate", "pdfunite")
    def test_split_pages_special_names(self):
        folder = self.work / "100% con espacios\n"
        folder.mkdir()
        pdf = folder / "-informe 100%\n.PDF"
        write_pdf(pdf, ["Uno", "Dos", "Tres"])
        before = hashlib.sha256(pdf.read_bytes()).digest()
        self.run_script("pdf-dividir.sh", "paginas", pdf)
        outputs = list((folder / "-informe 100%\n-dividido").glob("*.pdf"))
        self.assertEqual(len(outputs), 3)
        self.assertTrue(all(self.pages(path) == 1 for path in outputs))
        self.assertEqual(hashlib.sha256(pdf.read_bytes()).digest(), before)

    @requires("pdfinfo", "pdfseparate", "pdfunite")
    def test_range_decimal_and_single_page(self):
        pdf = self.pdf()
        self.run_script("pdf-dividir.sh", "rango", pdf, answer="008-010")
        output = self.work / "documento-dividido/documento-8_a_10.pdf"
        self.assertEqual(self.pages(output), 3)
        text = self.command("pdftotext", str(output), "-").stdout
        self.assertIn("Pagina 8", text)
        self.assertIn("Pagina 10", text)
        self.run_script("pdf-dividir.sh", "rango", pdf, answer="08")
        self.assertEqual(self.pages(self.work / "documento-dividido-2/documento-8_a_8.pdf"), 1)

    @requires("pdfinfo", "pdfseparate", "pdfunite")
    def test_blocks_decimal(self):
        self.run_script("pdf-dividir.sh", "bloques", self.pdf(count=20), answer="010")
        self.assertEqual([self.pages(path) for path in sorted((self.work / "documento-dividido").glob("*.pdf"))], [10, 10])

    @requires("pdfinfo")
    def test_invalid_numbers_and_ranges(self):
        pdf = self.pdf()
        for mode, answer in (("rango", "0"), ("rango", "5-3"), ("rango", "13"), ("rango", "a"),
                             ("bloques", "0"), ("bloques", "999999999999999999999999999999")):
            with self.subTest(mode=mode, answer=answer):
                self.run_script("pdf-dividir.sh", mode, pdf, answer=answer, success=False)
                self.assertFalse(list(self.work.glob("*-dividido*")))

    @requires("pdfinfo")
    def test_cancel_split_leaves_no_output(self):
        self.run_script("pdf-dividir.sh", "rango", self.pdf(), cancel=True)
        self.assertFalse(list(self.work.glob("*-dividido*")))

    @requires("pdfinfo")
    def test_split_failure_cleans_partial_output(self):
        self.stub("pdfseparate", '#!/usr/bin/env bash\npattern="${@: -1}"\nprintf -v output "$pattern" 1\nprintf partial > "$output"\nexit 1\n')
        self.run_script("pdf-dividir.sh", "paginas", self.pdf(), success=False)
        self.assertFalse(list(self.work.glob("*-dividido*")))

    @requires("pdfunite", "pdfinfo", "pdftotext")
    def test_merge_reorder_and_exclusion(self):
        files = [self.pdf(f"archivo{i}.pdf", 1) for i in range(1, 4)]
        for i, path in enumerate(files):
            write_pdf(path, [f"Documento {i + 1}"])
        self.run_script("pdf-unir.sh", *files, answer="03. archivo3.pdf\n01. archivo1.pdf")
        output = self.work / "archivo3_archivo1.pdf"
        self.assertEqual(self.pages(output), 2)
        text = self.command("pdftotext", str(output), "-").stdout
        self.assertLess(text.index("Documento 3"), text.index("Documento 1"))
        self.assertNotIn("Documento 2", text)

    @requires("pdfunite")
    def test_merge_rejects_duplicates(self):
        self.run_script("pdf-unir.sh", self.pdf("a.pdf", 1), self.pdf("b.pdf", 1),
                        answer="1. a\n01. a", success=False)
        self.assertFalse((self.work / "a_a.pdf").exists())

    def test_merge_cancel(self):
        self.run_script("pdf-unir.sh", self.pdf("a.pdf", 1), self.pdf("b.pdf", 1), cancel=True)
        self.assertFalse((self.work / "a_b.pdf").exists())

    def test_merge_failure_cleans_partial_output(self):
        self.stub("pdfunite", '#!/usr/bin/env bash\nprintf partial > "${@: -1}"\nexit 1\n')
        self.run_script("pdf-unir.sh", self.pdf("a.pdf", 1), self.pdf("b.pdf", 1), success=False)
        self.assertFalse((self.work / "a_b.pdf").exists())

    @requires("pdftotext")
    def test_pdf_text_preserves_existing_file_and_dangling_symlink(self):
        pdf = self.pdf("texto.pdf", 1)
        original = self.work / "texto.txt"
        original.write_text("No reemplazar")
        link = self.work / "texto-2.txt"
        target = self.work / "destino-inexistente"
        link.symlink_to(target)
        self.run_script("pdf-convertir.sh", "texto", pdf)
        self.assertEqual(original.read_text(), "No reemplazar")
        self.assertTrue(link.is_symlink())
        self.assertFalse(target.exists())
        self.assertIn("Pagina 1", (self.work / "texto-3.txt").read_text())

    def test_text_failure_cleans_partial_output(self):
        self.stub("pdftotext", '#!/usr/bin/env bash\nprintf partial > "$2"\nexit 1\n')
        self.run_script("pdf-convertir.sh", "texto", self.pdf(), success=False)
        self.assertFalse((self.work / "documento.txt").exists())

    @requires("pdfinfo", "pdftoppm")
    def test_pdf_images_all_profiles(self):
        pdf = self.pdf("paginas.pdf", 2)
        for profile, suffix in (("PNG · 150 ppp", "png"), ("PNG · 300 ppp", "png"),
                                ("JPG · 150 ppp", "jpg"), ("JPG · 300 ppp", "jpg")):
            with self.subTest(profile=profile):
                self.run_script("pdf-convertir.sh", "imagenes", pdf, answer=profile)
        folders = list(self.work.glob("paginas-imagenes*"))
        self.assertEqual(len(folders), 4)
        self.assertTrue(all(len(list(folder.iterdir())) == 2 for folder in folders))

    @requires("pdfinfo")
    def test_pdf_images_failure_cleans_partial_directory(self):
        self.stub("pdftoppm", '#!/usr/bin/env bash\nprintf partial > "${@: -1}-1.png"\nexit 1\n')
        self.run_script("pdf-convertir.sh", "imagenes", self.pdf(), success=False)
        self.assertFalse(list(self.work.glob("*-imagenes*")))

    @requires("gs", "pdfinfo")
    def test_pdf_compression_discards_larger_output(self):
        pdf = self.pdf(count=1)
        self.run_script("pdf-convertir.sh", "comprimir", pdf)
        self.assertFalse((self.work / "documento-comprimido.pdf").exists())

    @requires("gs", "pdfinfo")
    def test_pdf_compression_saves_smaller_valid_output(self):
        pdf = self.pdf(count=1)
        # Comentarios tras EOF: válidos e innecesarios para representar la página.
        with pdf.open("ab") as file:
            file.write(b"% comentario prescindible\n" * 20000)
        self.run_script("pdf-convertir.sh", "comprimir", pdf)
        output = self.work / "documento-comprimido.pdf"
        self.assertLess(output.stat().st_size, pdf.stat().st_size)
        self.assertEqual(self.pages(output), 1)

    @requires("magick", "img2pdf", "pdfinfo", "pdfunite")
    def test_images_to_pdf_natural_order_and_newlines(self):
        images = [self.image(f"foto{i}\n.png") for i in (10, 2, 1)]
        self.run_script("img-a-pdf.sh", *images)
        output = self.work / "foto1\n_y_otras.pdf"
        self.assertEqual(self.pages(output), 3)

    @requires("magick", "img2pdf", "pdfinfo", "pdfunite")
    def test_heic_to_pdf(self):
        image = self.work / "foto.heic"
        result = subprocess.run(["magick", "-size", "32x24", "xc:red", str(image)], env=self.env,
                                capture_output=True, timeout=30)
        if result.returncode:
            self.skipTest("ImageMagick no dispone del delegado HEIC")
        self.run_script("img-a-pdf.sh", image)
        self.assertEqual(self.pages(self.work / "foto.pdf"), 1)

    @requires("magick", "img2pdf", "pdfimages", "pdfunite")
    def test_jpeg_pdf_preserves_original_encoded_image(self):
        image = self.image("original.jpg")
        self.run_script("img-a-pdf.sh", image)
        self.command("pdfimages", "-j", str(self.work / "original.pdf"), str(self.work / "extraida"))
        extracted = list(self.work.glob("extraida*.jpg"))
        self.assertEqual(len(extracted), 1)
        self.assertEqual(extracted[0].read_bytes(), image.read_bytes())

    @requires("magick", "img2pdf", "pdfinfo", "pdfunite")
    def test_image_paths_are_literal_for_imagemagick(self):
        folder = self.work / "carpeta %d [1]"
        folder.mkdir()
        image = self.image().rename(folder / "foto%03d[2].png")
        self.run_script("img-convertir.sh", "jpg", image)
        self.assertTrue((folder / "foto%03d[2].jpg").exists())
        # Crear HEIC en una ruta sencilla y renombrarlo evita expansión en la
        # propia preparación del caso de prueba.
        heic = self.work / "entrada.heic"
        self.command("magick", "-size", "32x24", "xc:red", str(heic))
        heic = heic.rename(folder / "entrada%03d[2].heic")
        self.run_script("img-a-pdf.sh", heic)
        self.assertEqual(self.pages(folder / "entrada%03d[2].pdf"), 1)

    @requires("magick", "img2pdf")
    def test_images_to_pdf_damaged_input_leaves_no_pdf(self):
        bad = self.work / "danada.heic"
        bad.write_text("No es una imagen")
        self.run_script("img-a-pdf.sh", self.image(), bad, success=False)
        self.assertFalse(list(self.work.glob("*.pdf")))

    @requires("magick")
    def test_image_all_formats(self):
        image = self.image("-foto con espacios.png")
        for fmt in ("jpg", "png", "webp", "avif", "tiff"):
            with self.subTest(fmt=fmt):
                self.run_script("img-convertir.sh", fmt, image.name)
                output = self.work / f"-foto con espacios{'-2' if fmt == 'png' else ''}.{fmt}"
                self.assertEqual(self.command("magick", "identify", "-format", "%wx%h", str(output)).stdout, "32x24")

    @requires("magick")
    def test_multiframe_warning_and_cancel(self):
        image = self.work / "animacion.gif"
        self.command("magick", "-size", "32x24", "xc:red", "xc:blue", "-delay", "10", "-loop", "0", str(image))
        self.run_script("img-convertir.sh", "png", image, cancel=True)
        self.assertFalse((self.work / "animacion.png").exists())
        self.assertTrue(any("--yesno" in dialog for dialog in self.dialogs()))
        self.run_script("img-convertir.sh", "png", image)
        self.assertEqual(self.command("magick", "identify", "-format", "%n", str(self.work / "animacion.png")).stdout, "1")

    @requires("magick")
    def test_invalid_batch_preserves_completed_results_and_reports_count(self):
        good = self.image("buena.png")
        bad = self.work / "danada.png"
        bad.write_bytes(b"imagen danada")
        self.run_script("img-convertir.sh", "jpg", good, bad, success=False)
        self.assertTrue((self.work / "buena.jpg").exists())
        self.assertFalse((self.work / "danada.jpg").exists())
        errors = [dialog[-1] for dialog in self.dialogs() if "--error" in dialog]
        self.assertIn("1 resultado", errors[-1])

    @requires("magick")
    def test_missing_batch_file_fails_before_conversion(self):
        image = self.image()
        self.run_script("img-convertir.sh", "jpg", image, self.work / "no-existe.png", success=False)
        self.assertFalse((self.work / "foto.jpg").exists())

    def test_missing_dependency_reports_install_command(self):
        for name in ("bash", "dirname", "python3"):
            (self.bin / name).symlink_to(shutil.which(name))
        self.env["PATH"] = str(self.bin)
        self.run_script("img-a-pdf.sh", self.pdf(), success=False)
        self.assertTrue(any("sudo pacman -S img2pdf" in dialog[-1] for dialog in self.dialogs() if "--error" in dialog))

    @requires("magick")
    def test_unwritable_output_reports_error(self):
        folder = self.work / "solo-lectura"
        folder.mkdir()
        image = self.image()
        image = image.rename(folder / image.name)
        folder.chmod(0o555)
        try:
            self.run_script("img-convertir.sh", "jpg", image, success=False)
            self.assertFalse((folder / "foto.jpg").exists())
        finally:
            folder.chmod(0o755)

    @requires("ffmpeg", "ffprobe")
    def test_audio_all_formats(self):
        audio = self.work / "-audio.wav"
        self.command("ffmpeg", "-nostdin", "-loglevel", "error", "-f", "lavfi", "-i", "sine=duration=0.2", str(audio))
        for fmt, codec in (("mp3", "mp3"), ("flac", "flac"), ("wav", "pcm_s16le"),
                           ("ogg", "vorbis"), ("opus", "opus"), ("m4a", "aac")):
            with self.subTest(fmt=fmt):
                self.run_script("audio-convertir.sh", fmt, audio.name)
                output = self.work / f"-audio{'-2' if fmt == 'wav' else ''}.{fmt}"
                self.assertEqual(self.probe(output)[0]["codec_name"], codec)

    @requires("ffmpeg", "ffprobe")
    def test_video_mp4_profiles_odd_dimensions_and_color(self):
        video = self.video()
        for mode, suffix in (("mp4", ""), ("mp4-720", "-720p"), ("mp4-1080", "-1080p")):
            with self.subTest(mode=mode):
                self.run_script("video-convertir.sh", mode, video)
                streams = self.probe(self.work / f"video{suffix}.mp4")
                stream = next(stream for stream in streams if stream["codec_type"] == "video")
                self.assertEqual(stream["pix_fmt"], "yuv420p")
                self.assertEqual(stream["codec_name"], "h264")
                self.assertEqual(stream["width"] % 2, 0)
                self.assertEqual(stream["height"] % 2, 0)
                if mode != "mp4":
                    self.assertLessEqual(stream["height"], 239)

    @requires("ffmpeg", "ffprobe")
    def test_video_webm_gif_and_audio(self):
        video = self.video()
        for mode, extension, codec in (("webm", "webm", "vp9"), ("gif", "gif", "gif"), ("audio", "mp3", "mp3")):
            with self.subTest(mode=mode):
                self.run_script("video-convertir.sh", mode, video)
                self.assertEqual(self.probe(self.work / f"video.{extension}")[0]["codec_name"], codec)

    @requires("ffmpeg")
    def test_video_compression_discards_larger_output(self):
        video = self.work / "pequeno.webm"
        self.command("ffmpeg", "-nostdin", "-loglevel", "error", "-f", "lavfi", "-i",
                     "color=black:size=64x64:rate=2:duration=1", "-c:v", "libvpx-vp9", "-crf", "40", "-b:v", "0", str(video))
        self.run_script("video-convertir.sh", "comprimir", video)
        self.assertFalse((self.work / "pequeno-comprimido.mp4").exists())

    @requires("ffmpeg", "ffprobe")
    def test_video_compression_saves_smaller_valid_output(self):
        video = self.video()
        self.run_script("video-convertir.sh", "comprimir", video)
        output = self.work / "video-comprimido.mp4"
        self.assertLess(output.stat().st_size, video.stat().st_size)
        self.assertEqual(self.probe(output)[0]["codec_name"], "h264")

    @requires("rsvg-convert", "pdfinfo", "magick")
    def test_svg_png_pdf_and_compressed(self):
        import gzip
        svg = self.work / "dibujo.svg"
        svg.write_text('<svg xmlns="http://www.w3.org/2000/svg" width="40" height="30"><rect width="40" height="30" fill="red"/></svg>')
        self.run_script("svg-convertir.sh", "png", svg)
        self.assertEqual(self.command("magick", "identify", "-format", "%wx%h", str(self.work / "dibujo.png")).stdout, "40x30")
        self.run_script("svg-convertir.sh", "pdf", svg)
        self.assertEqual(self.pages(self.work / "dibujo.pdf"), 1)
        compressed = self.work / "comprimido.svgz"
        compressed.write_bytes(gzip.compress(svg.read_bytes()))
        self.run_script("svg-convertir.sh", "png", compressed)
        self.assertTrue((self.work / "comprimido.png").exists())

    def test_unexpected_tool_failure_shows_dialog_and_cleans(self):
        self.stub("ebook-convert", '#!/usr/bin/env bash\nprintf partial > "$2"\nexit 2\n')
        ebook = self.work / "libro.epub"
        ebook.touch()
        self.run_script("ebook-a-pdf.sh", ebook, success=False)
        self.assertFalse((self.work / "libro.pdf").exists())

    def test_signal_cleans_temporaries(self):
        script = f'''set -Eeuo pipefail
TITULO=Prueba
source {shlex.quote(str(ROOT / 'comun.sh'))}
iniciar_temporales
nuevo_temporal "$PWD"
kill -TERM $$
'''
        result = subprocess.run(["bash", "-c", script], cwd=self.work, env=self.env, capture_output=True, timeout=30)
        self.assertEqual(result.returncode, 143)
        self.assertFalse(list(self.work.rglob(".conversor-dolphin.*")))

    @unittest.skipUnless(INTEGRATION, "Activar con make test-integration")
    @requires("soffice", "pdfinfo")
    def test_office_same_stem_and_special_tmpdir(self):
        tempdir = self.work / "temporales con espacio % y ñ"
        tempdir.mkdir()
        self.env["TMPDIR"] = str(tempdir)
        for name in ("informe.txt", "informe.rtf"):
            (self.work / name).write_text("{\\rtf1 Documento de prueba}" if name.endswith("rtf") else "Documento de prueba")
        self.run_script("office-a-pdf.sh", self.work / "informe.txt", self.work / "informe.rtf")
        self.assertEqual(self.pages(self.work / "informe.pdf"), 1)
        self.assertEqual(self.pages(self.work / "informe-2.pdf"), 1)

    @unittest.skipUnless(INTEGRATION, "Activar con make test-integration")
    @requires("ebook-convert", "pdfinfo")
    def test_ebook_real_epub(self):
        ebook = self.work / "libro.epub"
        with zipfile.ZipFile(ebook, "w") as z:
            z.writestr("mimetype", "application/epub+zip")
            z.writestr("META-INF/container.xml", '<?xml version="1.0"?><container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0"><rootfiles><rootfile full-path="content.opf" media-type="application/oebps-package+xml"/></rootfiles></container>')
            z.writestr("content.opf", '<?xml version="1.0"?><package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="id"><metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:title>Libro de prueba</dc:title><dc:language>es</dc:language><dc:identifier id="id">prueba</dc:identifier></metadata><manifest><item id="p" href="pagina.xhtml" media-type="application/xhtml+xml"/></manifest><spine><itemref idref="p"/></spine></package>')
            z.writestr("pagina.xhtml", '<html xmlns="http://www.w3.org/1999/xhtml"><head><title>Prueba</title></head><body><h1>Libro de prueba</h1><p>Conversor Dolphin.</p></body></html>')
        self.run_script("ebook-a-pdf.sh", ebook)
        self.assertGreaterEqual(self.pages(self.work / "libro.pdf"), 1)

    @unittest.skipUnless(INTEGRATION, "Activar con make test-integration")
    @requires("ocrmypdf", "tesseract", "magick", "img2pdf", "pdftotext", "pdfinfo")
    def test_ocr_real_scan_in_spanish(self):
        if "spa" not in self.command("tesseract", "--list-langs").stdout.split():
            self.skipTest("Falta tesseract-data-spa")
        image = self.work / "escaneo.png"
        self.command("magick", "-size", "1000x300", "xc:white", "-font", "DejaVu-Sans", "-pointsize", "48",
                     "-fill", "black", "-annotate", "+40+140", "Documento de prueba 123", str(image))
        pdf = self.work / "escaneo.pdf"
        self.command("img2pdf", str(image), "-o", str(pdf))
        self.run_script("pdf-convertir.sh", "ocr", pdf)
        output = self.work / "escaneo-ocr.pdf"
        self.assertEqual(self.pages(output), 1)
        self.assertIn("Documento", self.command("pdftotext", str(output), "-").stdout)


if __name__ == "__main__":
    unittest.main()
