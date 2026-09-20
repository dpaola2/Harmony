#!/usr/bin/env python3
"""Rerun independent native checks without saving any source design."""
import argparse,hashlib,json,os,shutil,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
REV=ROOT/'hardware/revisions/harmony-r3'
p=argparse.ArgumentParser();p.add_argument('--kicad-cli',type=Path,required=True);a=p.parse_args()
cli=a.kicad_cli.resolve();support=cli.parent.parent/'SharedSupport'
config=HERE/'tool-config'
if not config.exists():shutil.copytree(ROOT/'hardware/procurement/assembly-quote/tool-config',config)
env=dict(os.environ,KICAD_CONFIG_HOME=str(config),KICAD8_SYMBOL_DIR=str(support/'symbols'),KICAD8_FOOTPRINT_DIR=str(support/'footprints'))
source=[f for f in REV.rglob('*') if f.is_file() and 'verification' not in f.parts]
before={str(f.relative_to(ROOT)):hashlib.sha256(f.read_bytes()).hexdigest() for f in source}
logs=[]
for name in ('mainboard','faceplate'):
    base=REV/f'tangara-{name}'/f'tangara-{name}'
    commands=[
      [str(cli),'pcb','drc','--format','json','--schematic-parity','--severity-all','--exit-code-violations','--output',str(HERE/f'{name}-drc.json'),str(base.with_suffix('.kicad_pcb'))],
      [str(cli),'sch','erc','--format','json','--severity-all','--exit-code-violations','--output',str(HERE/f'{name}-erc.json'),str(base.with_suffix('.kicad_sch'))],
      [str(cli),'sch','export','netlist','--format','kicadxml','--output',str(HERE/f'{name}-netlist.xml'),str(base.with_suffix('.kicad_sch'))],
    ]
    for cmd in commands:
        proc=subprocess.run(cmd,env=env,capture_output=True,text=True)
        logs.append({'command':cmd,'exit_code':proc.returncode,'stdout':proc.stdout,'stderr':proc.stderr})
        assert proc.returncode in (0,5) and (proc.returncode==0 or cmd[2] in ('drc','erc')),logs[-1]
after={str(f.relative_to(ROOT)):hashlib.sha256(f.read_bytes()).hexdigest() for f in source}
assert before==after,'Native checks mutated source files'
(HERE/'native-check-run.json').write_text(json.dumps({'kicad_version':subprocess.check_output([str(cli),'--version'],text=True).strip(),'source_hashes':before,'sources_unchanged':True,'commands':logs},indent=2)+'\n')
print('Native DRC/ERC and netlist export complete; design findings remain in reports.')
