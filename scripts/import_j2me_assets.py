#!/usr/bin/env python3
"""Extrai recursos gráficos opcionais somente do JAR possuído pelo jogador.
Não baixa nem redistribui arquivos comerciais. Uso: python3 scripts/import_j2me_assets.py <arquivo.jar>
"""
import sys
from pathlib import Path
from zipfile import ZipFile

if len(sys.argv)!=2:
    sys.exit('Uso: python3 scripts/import_j2me_assets.py /caminho/para/fish.jar')
jar=Path(sys.argv[1]);root=Path(__file__).resolve().parents[1]/'assets'/'original'
with ZipFile(jar) as z:
    for name in ('assets.png','splash.png','gameMenuTank.png','trhopy_ball.png'):
        data=z.read(name)
        if not data.startswith(b'\x89PNG\r\n\x1a\n'):
            raise ValueError('PNG inválido: '+name)
        root.mkdir(parents=True,exist_ok=True)
        (root/name).write_bytes(data)
        print('Extraído:',root/name)
