#!/usr/bin/env python3
"""Independent quote reconciliation against native pcbnew inventory.

Does not import the package generator or its validator. Run from any directory.
An assertion failure is a failed check, not a fabrication disposition.
"""
import csv
import hashlib
import json
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
QUOTE = ROOT / 'hardware/procurement/assembly-quote-r3'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def rows(name):
    with (QUOTE / name).open(newline='') as handle:
        return list(csv.DictReader(handle))

def same_angle(a, b):
    return abs((float(a) - float(b) + 180) % 360 - 180) < 0.000002

inventory = json.loads((ROOT / 'hardware/procurement/assembly-verification/native-inventory.json').read_text())
manifest = json.loads((QUOTE / 'manifest.json').read_text())
report = {'result': 'PASS_PACKAGE_RECONCILIATION_ONLY', 'boards': [], 'limits': [
    'Native DRC/ERC and schematic parity findings remain unresolved.',
    'No supplier rotation preview, CAM sign-off, physical fit, or hardware qualification.',
]}
for f in manifest['source_files']:
    path = ROOT / f['path']
    assert sha(path) == f['sha256'] and path.stat().st_size == f['bytes'], path
for f in manifest['outputs']:
    path = QUOTE / f['path']
    assert sha(path) == f['sha256'] and path.stat().st_size == f['bytes'], path
report['manifest_outputs_verified'] = len(manifest['outputs'])

face_features = {f'H{i}' for i in range(1,5)} | {f'TP{i}' for i in range(1,10)} | {'J1','J2','SW1','SW2','SW3'}
exclusions = rows('dnp-and-non-purchased-structures.csv')
for board in inventory['boards']:
    name = board['board'].replace('tangara-', '')
    source = ROOT / 'hardware/tangara-reference' / board['board'] / (board['board'] + '.kicad_pcb')
    assert sha(source) == board['source_sha256']
    fitted, excluded = [], []
    for fp in board['footprints']:
        target = excluded if (fp['dnp'] or fp['exclude_bom'] or (name == 'faceplate' and fp['reference'] in face_features)) else fitted
        target.append(fp)
    expected = {f['reference']: f for f in fitted}
    assert len(expected) == len(fitted), 'Duplicate fitted references'
    bom = rows(name + '-bom.csv')
    covered = []
    for row in bom:
        refs = row['references'].split()
        covered.extend(refs)
        assert int(row['qty_per_board']) == len(refs)
        for n in (1, 2, 5):
            assert int(row[f'qty_for_{n}_board' + ('s' if n > 1 else '')]) == len(refs) * n
        for ref in refs:
            fp = expected[ref]
            assert row['footprint'].split(':')[-1] == fp['footprint'], ref
            assert row['value'] == fp['value'], ref
            if name == 'faceplate' and ref == 'LCD1':
                assert row['mpn'] == 'ER-TFT018-4' and 'CANDIDATE' in row['identity_status']
            else:
                assert row['mpn'].strip() == fp['mpn'], ref
    assert Counter(covered) == Counter(expected.keys())
    def key(f):
        return f['reference'], f['value'], f['footprint'].split(':')[-1]
    assert Counter(map(key, excluded)) == Counter(key(r) for r in exclusions if r['board'] == name)
    review = rows(name + '-placement-review.csv')
    assert Counter(r['reference'] for r in review) == Counter(expected.keys())
    for r in review:
        fp = expected[r['reference']]
        assert abs(float(r['x_mm']) - fp['x_board_mm']) < 0.000002
        assert abs(float(r['y_mm']) - fp['y_board_mm']) < 0.000002
        assert same_angle(r['rotation_deg'], fp['rotation_deg'])
        assert r['side'].lower() == ('top' if fp['side'] == 'F.Cu' else 'bottom')
    raw = rows(name + '-placement-kicad-raw.csv')
    supplier = rows(name + '-placement-supplier.csv')
    assert supplier == [r for r in raw if r['Ref'] in expected]
    assert Counter(r['Ref'] for r in supplier) == Counter(expected.keys())
    for r in supplier:
        fp = expected[r['Ref']]
        assert r['Val'] == fp['value'] and r['Package'] == fp['footprint']
        assert abs(float(r['PosX']) - fp['x_board_mm']) < 0.000002
        assert abs(float(r['PosY']) + fp['y_board_mm']) < 0.000002
        assert same_angle(r['Rot'], fp['rotation_deg'])
        assert r['Side'] == ('top' if fp['side'] == 'F.Cu' else 'bottom')
    gerbers = list((QUOTE / 'fabrication' / name).glob('*'))
    copper = [f for f in gerbers if 'TF.FileFunction,Copper,' in f.read_text()]
    assert len(copper) == board['copper_layers']
    assert any(f.suffix == '.drl' and 'METRIC' in f.read_text() for f in gerbers)
    report['boards'].append({'board': name, 'native_footprints': len(board['footprints']),
        'bom_groups': len(bom), 'fitted_references': len(fitted), 'excluded': len(excluded),
        'raw_placements': len(raw), 'supplier_placements': len(supplier), 'copper_layers': len(copper)})

for row in rows('external-parts-addendum.csv'):
    for n in (1,2,5):
        assert int(row[f'qty_for_{n}_set' + ('s' if n > 1 else '')]) == int(row['qty_per_set']) * n
programming = json.loads((QUOTE / 'programming/programming-manifest.json').read_text())
prior_images = {}
for folder in ('esp32-validation', 'samd-validation'):
    for path in (ROOT / 'firmware' / folder / 'artifacts').rglob('*'):
        if path.is_file():
            prior_images.setdefault(sha(path), []).append(str(path.relative_to(ROOT)))
verified_images = []
for f in programming['images']:
    path = QUOTE / 'programming' / f['file']
    assert sha(path) == f['sha256'] and path.stat().st_size == f['bytes']
    assert f['sha256'] in prior_images, 'Image not in preserved build: ' + f['file']
    verified_images.append({'file': f['file'], 'matches': prior_images[f['sha256']]})
esp = sorted((int(f['address'],16), f['bytes']) for f in programming['images'] if f['processor'] == 'ESP32')
baseline_layout = json.loads((ROOT / 'firmware/esp32-validation/artifacts/flash-layout.json').read_text())
assert {(int(f['address'],16), f['sha256']) for f in programming['images'] if f['processor'] == 'ESP32'} == {(int(f['offset'],16), f['sha256']) for f in baseline_layout['images']}
assert len(esp) == 7 and all(a + size <= b for (a,size),(b,_) in zip(esp,esp[1:]))
assert esp[-1][0] + esp[-1][1] <= 16 * 1024 * 1024
report['programming_images_matching_existing_build'] = verified_images
(HERE / 'independent-verification.json').write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({k:v for k,v in report.items() if k != 'programming_images_matching_existing_build'}, indent=2))
