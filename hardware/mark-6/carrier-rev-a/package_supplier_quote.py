#!/usr/bin/env python3
"""Build an allowlisted, unreleased supplier quote package with fresh CAD exports."""
from pathlib import Path
import collections
import csv
import hashlib
import json
import re
import shutil
import subprocess
import tempfile
import zipfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
CLI = REPO / 'firmware/toolchains/kicad-8.0.9/KiCad.app/Contents/MacOS/kicad-cli'
OUT = HERE / 'output/supplier-quote'
ZIP = HERE / 'output/harmony-mark6-rev-a-supplier-quote.zip'
BOARD = HERE / 'harmony-mark6-carrier.kicad_pcb'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def run(*args):
    subprocess.run([str(CLI), *map(str, args)], check=True)

# Refuse stale electrical or placement evidence before creating shareable files.
for name in ['pcb-verification.json', 'assembly-audit.json']:
    audit = json.loads((HERE / name).read_text())
    for source, expected in audit['sha256'].items():
        assert digest(HERE / source) == expected, (name, source, 'stale audit')

with tempfile.TemporaryDirectory(prefix='harmony-supplier-') as temp:
    root = Path(temp) / 'harmony-mark6-rev-a-supplier-quote'
    root.mkdir()
    (root / "gerbers").mkdir()
    (root / "drill").mkdir()
    for name in ['harmony-mark6-carrier.kicad_pcb', 'harmony-mark6-carrier.kicad_sch',
                 'harmony-mark6-carrier.kicad_pro', 'Harmony.kicad_sym', 'sym-lib-table',
                 'supplier-request-draft.md']:
        shutil.copyfile(HERE / name, root / name)
    for name in ['assembly-top.svg', 'via-in-pad.csv']:
        shutil.copyfile(HERE / 'output' / name, root / name)
    shutil.copyfile(HERE / 'output/pdf/schematic-draft.pdf', root / 'schematic.pdf')
    rows = [r for r in csv.DictReader((HERE / 'bom-draft.csv').open()) if r['mpn']]
    assert len(rows) == 36
    grouped = collections.defaultdict(list)
    for row in rows:
        grouped[row['mpn']].append(row)
    with (root / 'assembly-bom.csv').open('w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['References', 'Quantity', 'MPN', 'Value', 'Footprint', 'Method', 'Assembly'])
        for mpn, parts in sorted(grouped.items()):
            writer.writerow([','.join(r['ref'] for r in parts), len(parts), mpn,
                             parts[0]['value'], parts[0]['footprint'],
                             'Through-hole' if parts[0]['ref'] in ['J1', 'J2'] else 'SMT',
                             'Factory install; no customer soldering'])
    refs = {r['ref'] for r in rows}
    positions = list(csv.DictReader((HERE / 'output/all-positions.csv').open()))
    selected = [r for r in positions if r['Ref'] in refs]
    assert len(selected) == 36 and {r['Ref'] for r in selected} == refs
    with (root / 'assembly-positions.csv').open('w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=positions[0].keys())
        writer.writeheader()
        writer.writerows(selected)
    run('pcb', 'export', 'gerbers', '-l', 'F.Cu,In1.Cu,In2.Cu,B.Cu,F.Paste,B.Paste,F.Silkscreen,B.Silkscreen,F.Mask,B.Mask,Edge.Cuts', '-o', str(root / 'gerbers') + '/', BOARD)
    run('pcb', 'export', 'drill', '--excellon-separate-th', '--generate-map', '--map-format', 'svg', '-o', str(root / 'drill') + '/', BOARD)
    run('pcb', 'drc', '--format', 'json', '--exit-code-violations', '-o', root / 'drc.json', BOARD)
    run('sch', 'erc', '--format', 'json', '--exit-code-violations', '-o', root / 'erc.json', HERE / 'harmony-mark6-carrier.kicad_sch')
    # Enable the suppressed type rule in a disposable copy, preserving production CAD.
    strict_dir = Path(temp) / 'strict'
    strict_dir.mkdir()
    strict_board = strict_dir / BOARD.name
    shutil.copyfile(BOARD, strict_board)
    project = json.loads((HERE / 'harmony-mark6-carrier.kicad_pro').read_text())
    project['board']['design_settings']['rule_severities']['footprint_type_mismatch'] = 'warning'
    (strict_dir / 'harmony-mark6-carrier.kicad_pro').write_text(json.dumps(project))
    run('pcb', 'drc', '--format', 'json', '-o', root / 'strict-drc.json', strict_board)
    strict = json.loads((root / 'strict-drc.json').read_text())
    assert not strict['unconnected_items'] and len(strict['violations']) == 1, strict
    assert strict['violations'][0]['type'] == 'footprint_type_mismatch'
    assert strict['violations'][0]['severity'] == 'warning'
    assert [r['description'] for r in strict['violations'][0]['items']] == ['Footprint U1']
    job = json.loads((root / 'gerbers/harmony-mark6-carrier-job.gbrjob').read_text())
    assert job['GeneralSpecs']['Finish'] == 'ENIG' and job['GeneralSpecs']['LayerNumber'] == 4
    assert len(list((root / 'gerbers').iterdir())) == 12
    assert len(list((root / 'drill').glob('*.drl'))) == 2
    assert len(list(csv.DictReader((root / 'via-in-pad.csv').open()))) == 9
    (root / 'README.md').write_text((HERE / 'supplier-package-readme.md').read_text())
    verification = {
        'date': '2026-09-26', 'purpose': 'DFM and quote only; production not released',
        'installed_parts': 36, 'unique_mpns': len(grouped), 'smt': 34, 'through_hole': 2,
        'via_in_pad_locations': 9, 'saved_audit_source_hashes': 'matched current sources',
        'fresh_erc': 'passed', 'fresh_saved_rule_drc': 'passed',
        'fresh_strict_drc': 'one documented U1 footprint_type_mismatch warning, zero opens',
        'source_sha256': {p.name: digest(p) for p in [BOARD, HERE / 'harmony-mark6-carrier.kicad_sch', HERE / 'bom-draft.csv', HERE / 'output/all-positions.csv']},
    }
    (root / 'package-verification.json').write_text(json.dumps(verification, indent=2) + '\n')
    # Source/report metadata must not leak machine paths. Board content stays exact.
    for p in root.rglob('*'):
        if p.is_file() and p.suffix == '.json':
            value = p.read_text().replace(str(HERE) + '/', '').replace(str(strict_dir) + '/', '')
            p.write_text(value)
    for p in root.rglob('*'):
        if p.is_file() and p.suffix != '.pdf':
            text = p.read_text(errors='replace')
            assert not re.search(r'/Users/|mail\.google\.com|dpaola2|AGENTMAIL_API_KEY', text), p
    files = sorted(p for p in root.rglob('*') if p.is_file())
    (root / 'SHA256SUMS.txt').write_text(''.join(digest(p) + '  ' + str(p.relative_to(root)) + '\n' for p in files))
    # Replace only this script's generated output after all checks pass.
    if OUT.exists():
        shutil.rmtree(OUT)
    shutil.copytree(root, OUT)
    with zipfile.ZipFile(ZIP, 'w', zipfile.ZIP_DEFLATED) as archive:
        for p in sorted(root.rglob('*')):
            if p.is_file():
                archive.write(p, str(Path(root.name) / p.relative_to(root)))
    with zipfile.ZipFile(ZIP) as archive:
        assert archive.testzip() is None
        prefix = root.name + '/'
        for line in archive.read(prefix + 'SHA256SUMS.txt').decode().splitlines():
            sha, name = line.split('  ', 1)
            assert hashlib.sha256(archive.read(prefix + name)).hexdigest() == sha
    print(json.dumps({'zip': str(ZIP), 'files': len(files) + 1, 'bytes': ZIP.stat().st_size, 'sha256': digest(ZIP)}, indent=2))
