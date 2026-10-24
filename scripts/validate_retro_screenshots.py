#!/usr/bin/env python3
"""Validate the 240x320 retro UI screenshot run with actual LOVE 11.x."""
from pathlib import Path
import os, struct, zlib
folder=Path(os.path.expanduser('~/.local/share/love/mar_de_isola_lua/retro-smoke'))
assert (folder/'ok.txt').exists(), f'LOVE retro smoke was not completed: {folder}'
for n in ['01-menu','02-tanque','03-peixe','04-acoes','05-menu-pausa','06-suprimentos','07-suprimentos-pagina2','08-pesquisas','09-configuracoes','10-vendas','11-vendas-peixe','12-menu-original','13-estatisticas','14-ajuda','15-trofeu','16-acoes-peixe','17-transferir-peixe','18-tratar-peixe','19-selecao-superior','20-nado-livre','21-isolamento-dois','22-isolamento-selecao','23-referencia-vendas','24-selecao-barbatana-alta','25-trofeus']:
 p=folder/(n+'.png');data=p.read_bytes()
 assert data[:8]==b'\x89PNG\r\n\x1a\n'
 width,height=struct.unpack_from('>II',data,16)
 assert (width,height)==(480,640), f'{n}: {width}x{height}'
 chunks=[];i=8
 while i<len(data):
  length=struct.unpack_from('>I',data,i)[0]
  kind=data[i+4:i+8];block=data[i+8:i+8+length]
  if kind==b'IDAT':chunks.append(block)
  i+=length+12
 pixels=zlib.decompress(b''.join(chunks))
 assert len(data)>4000 and len(set(pixels[:200000]))>12,f'{n} image appears blank'
 print('OK',n,width,height,len(data))
print('25 retro LÖVE screenshots passed')
