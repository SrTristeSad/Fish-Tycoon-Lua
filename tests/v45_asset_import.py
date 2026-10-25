"""V45: importação de PNGs originais, opcionais e validação de dimensões."""
import importlib.util
import tempfile
import zipfile
from pathlib import Path

module_path = Path(__file__).resolve().parents[1] / 'scripts' / 'import_j2me_assets.py'
spec = importlib.util.spec_from_file_location('j2me_assets', module_path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

def fake_png(w=240, h=320):
    return module.PNG_SIGNATURE + b'\x00' * 8 + w.to_bytes(4, 'big') + h.to_bytes(4, 'big')

with tempfile.TemporaryDirectory() as temp:
    root = Path(temp)
    jar = root / 'test.jar'
    with zipfile.ZipFile(jar, 'w') as z:
        z.writestr('assets.png', fake_png())
        z.writestr('store.png', fake_png(113, 123))
        z.writestr('menutank.png', fake_png(240, 256))
    imported, missing = module.import_assets(jar, root / 'out')
    assert set(imported) == {'assets.png', 'store.png', 'menutank.png'}
    assert 'trhopy_ball.png' in missing and 'splash.png' in missing
    assert (root / 'out' / 'store.png').read_bytes() == fake_png(113, 123)
    assert (root / 'out' / 'menutank.png').read_bytes() == fake_png(240, 256)

    invalid = root / 'invalid.jar'
    with zipfile.ZipFile(invalid, 'w') as z:
        z.writestr('assets.png', b'not a png')
    try:
        module.import_assets(invalid, root / 'bad-out')
        raise AssertionError('Invalid PNG was accepted')
    except ValueError:
        assert not (root / 'bad-out').exists()

print('OK v45: sprites store/menutank, missing resources and invalid PNG')
