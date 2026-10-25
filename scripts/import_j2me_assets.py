#!/usr/bin/env python3
"""Importa PNGs do JAR local do usuário para comparação visual no LÖVE.

Não baixa arquivos e não altera o JAR. Recursos ausentes são relatados,
sem impedir a importação dos que estiverem presentes.
Uso: python3 scripts/import_j2me_assets.py /caminho/Fish_Tycoon.jar
"""
import sys
from pathlib import Path
from zipfile import ZipFile, BadZipFile

PNG_SIGNATURE = b'\x89PNG\r\n\x1a\n'
REQUIRED = ('assets.png', 'splash.png', 'gameMenuTank.png')
OPTIONAL = ('trhopy_ball.png', 'store.png', 'menutank.png')

def import_assets(jar: Path, root: Path):
    imported, missing = [], []
    with ZipFile(jar) as archive:
        names = set(archive.namelist())
        # Validate all present files before writing any output.
        pending = {}
        for filename in REQUIRED + OPTIONAL:
            if filename not in names:
                missing.append(filename)
                continue
            data = archive.read(filename)
            if len(data) < 24 or not data.startswith(PNG_SIGNATURE):
                raise ValueError('PNG inválido: ' + filename)
            width = int.from_bytes(data[16:20], 'big')
            height = int.from_bytes(data[20:24], 'big')
            if width == 0 or height == 0:
                raise ValueError('Dimensões inválidas: ' + filename)
            pending[filename] = (data, width, height)
        if not pending:
            raise ValueError('Nenhum dos recursos gráficos esperados foi encontrado no JAR')
        root.mkdir(parents=True, exist_ok=True)
        for filename, (data, width, height) in pending.items():
            destination = root / filename
            destination.write_bytes(data)
            imported.append(filename)
            print(f'Extraído: {destination} ({width}x{height})')
    if missing:
        print('Ausentes no JAR:', ', '.join(missing))
    return imported, missing

if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit('Uso: python3 scripts/import_j2me_assets.py /caminho/para/fish.jar')
    try:
        import_assets(Path(sys.argv[1]), Path(__file__).resolve().parents[1] / 'assets' / 'original')
    except (OSError, BadZipFile, ValueError) as exc:
        sys.exit(str(exc))
