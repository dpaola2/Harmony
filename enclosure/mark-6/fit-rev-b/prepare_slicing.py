#!/usr/bin/env python3
"""Prepare and slice locally with installed Bambu profiles; never send a job."""
from pathlib import Path
import json, subprocess, tempfile, hashlib

ROOT = Path(__file__).resolve().parent
APP = Path('/Applications/BambuStudio.app/Contents')
PROFILES = APP / 'Resources/profiles/BBL'
OUT = ROOT / 'slicing'
OUT.mkdir(exist_ok=True)
SETTINGS = OUT / 'settings'
SETTINGS.mkdir(exist_ok=True)
sources = {}

def profile(kind, name):
    path = PROFILES / kind / (name + '.json')
    data = json.loads(path.read_text())
    sources[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
    merged = profile(kind, data['inherits']) if data.get('inherits') else {}
    for include in data.get('include', []):
        merged.update(profile(kind, include))
    merged.update(data)
    merged.pop('inherits', None)
    merged.pop('include', None)
    return merged

machine = profile('machine', 'Bambu Lab A1 0.4 nozzle')
process = profile('process', '0.20mm Standard @BBL A1')
filament = profile('filament', 'Bambu PLA Basic @BBL A1')
process.update(name='Harmony M6 revision B - 0.20mm A1', wall_loops='4',
               sparse_infill_density='15%', sparse_infill_pattern='gyroid',
               top_shell_layers='5', bottom_shell_layers='5',
               enable_support='0', brim_type='no_brim',
               curr_bed_type='Textured PEI Plate', print_sequence='by layer')
for name, data in [('machine', machine), ('process', process), ('filament', filament)]:
    (SETTINGS / (name + '.json')).write_text(json.dumps(data, indent=2) + '\n')
(SETTINGS / 'profile-sources.json').write_text(json.dumps(sources, indent=2) + '\n')

# Shells share one plate; the optional gauge and four spacers share another.
plates = {'wheel-check': [('wheel-coupon', 1), ('ano-spacer-14mm', 4), ('pilot-coupon', 1)],
          'shells': [('tray', 1), ('front', 1)],
          'retainers': [('display-retainer-left', 2), ('display-retainer-right', 2)]}
with tempfile.TemporaryDirectory(prefix='harmony-m6-slicer-') as datadir:
    for name, parts in plates.items():
        dest = OUT / name
        dest.mkdir(exist_ok=True)
        args = [str(APP/'MacOS/BambuStudio'), '--datadir', datadir, '--debug', '2',
                '--load-settings', str(SETTINGS/'machine.json')+';'+str(SETTINGS/'process.json'),
                '--load-filaments', str(SETTINGS/'filament.json'),
                '--arrange', '1', '--orient', '0', '--ensure-on-bed',
                '--clone-objects', ','.join(str(n) for _, n in parts),
                '--slice', '0', '--export-3mf', 'harmony-m6-b-'+name+'-a1.3mf',
                '--export-slicedata', str(dest/'data'), '--outputdir', str(dest)]
        args += [str(ROOT/'print'/('harmony-m6-b-'+part+'.stl')) for part, _ in parts]
        inputs = {str(ROOT/'print'/('harmony-m6-b-'+part+'.stl')): {'quantity':qty, 'sha256':hashlib.sha256((ROOT/'print'/('harmony-m6-b-'+part+'.stl')).read_bytes()).hexdigest()} for part,qty in parts}
        (dest/'input-sha256.json').write_text(json.dumps(inputs, indent=2)+'\n')
        result = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        (dest/'slice.log').write_text(result.stdout)
        print(name, 'exit', result.returncode, flush=True)
        if result.returncode:
            print(result.stdout[-6000:])
            raise SystemExit(result.returncode)
