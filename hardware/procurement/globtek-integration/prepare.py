#!/usr/bin/env python3
"""Prepare local U10 substitution, preserving submitted R4 and its routed PCBs."""
from pathlib import Path
import csv,json,hashlib,shutil,difflib,subprocess,os,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[3]; OUT=Path(__file__).resolve().parent
SRC=ROOT/'hardware/revisions/harmony-r4'; DST=ROOT/'hardware/revisions/harmony-r5-globtek-draft'
old,new='MCP73871-2CCI/ML','MCP73871-1CCI/ML'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
source={str(p.relative_to(SRC)):sha(p) for p in SRC.rglob('*') if p.is_file()}
if not DST.exists():shutil.copytree(SRC,DST)
p=DST/'tangara-mainboard/power.kicad_sch';before=(SRC/'tangara-mainboard/power.kicad_sch').read_text();assert before.count(old)==1
p.write_text(before.replace(old,new))
# Also update the PCB footprint's purchasing property, without changing geometry.
p=DST/'tangara-mainboard/tangara-mainboard.kicad_pcb';pcb_before=(SRC/'tangara-mainboard/tangara-mainboard.kicad_pcb').read_text();assert pcb_before.count(old)==1
p.write_text(pcb_before.replace(old,new))
assert p.read_text().replace(new,old)==pcb_before
quote=ROOT/'hardware/procurement/assembly-quote-r4/mainboard-bom.csv'
with quote.open() as f: rows=list(csv.DictReader(f)); fields=list(rows[0])
changed=[]
for row in rows:
 if row['references']=='U10':
  assert row['mpn']==old;row['mpn']=new;row['identity_status']='GLOBTEK_INTEGRATION_DRAFT';changed.append('U10')
assert changed==['U10']
with (OUT/'mainboard-bom-DRAFT.csv').open('w') as f:
 w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(rows)
patch=''.join(difflib.unified_diff(before.splitlines(True),before.replace(old,new).splitlines(True),fromfile='R4/power.kicad_sch',tofile='R5-draft/power.kicad_sch'))
(OUT/'charger-substitution.patch').write_text(patch)
cli=ROOT/'firmware/toolchains/kicad-8.0.9/KiCad.app/Contents/MacOS/kicad-cli'
support=cli.parent.parent/'SharedSupport'
env=dict(os.environ,KICAD_CONFIG_HOME=str(ROOT/'hardware/reviews/harmony-r4/tool-config'),KICAD8_SYMBOL_DIR=str(support/'symbols'),KICAD8_FOOTPRINT_DIR=str(support/'footprints'))
subprocess.run([str(cli),'sch','export','netlist','--format','kicadxml','--output',str(OUT/'mainboard-netlist.xml'),str(DST/'tangara-mainboard/tangara-mainboard.kicad_sch')],env=env,check=True)
def nets(p):
 return {(x.get('ref'),x.get('pin')):n.get('name') for n in ET.parse(p).getroot().findall('nets/net') for x in n.findall('node')}
prior=ROOT/'hardware/reviews/harmony-r4/mainboard-netlist.xml'
assert nets(prior)==nets(OUT/'mainboard-netlist.xml')
components={c.get('ref'):c for c in ET.parse(OUT/'mainboard-netlist.xml').getroot().findall('components/comp')}
assert components['U10'].find("fields/field[@name='MPN']").text==new
for ref,value in [('R39','1kΩ'),('R35','10kΩ')]:assert components[ref].findtext('value')==value
assert source=={str(p.relative_to(SRC)):sha(p) for p in SRC.rglob('*') if p.is_file()}
# Replace inherited revision metadata so the draft cannot masquerade as R4.
(DST/'README.md').write_text('# Harmony R5 GlobTek draft\n\nU10 changed to MCP73871-1CCI/ML in schematic and PCB MPN property. Routed geometry and connectivity unchanged from R4. Local integration draft; not submitted or released. Temperature-sensor qualification remains open. See ../../procurement/globtek-integration/README.md.\n')
(DST/'source-lock.json').write_text(json.dumps({'basis':'../harmony-r4','source_sha256':source,'changes':{'U10':{'old':old,'new':new}},'release':'DRAFT'},indent=2)+'\n')
# The inherited summary BOM is historical; replace only the exact ordering code.
p=DST/'BOM.md';p.write_text(p.read_text().replace(old,new))
report={'status':'PASS_LOCAL_CHANGE_CHECKS_NOT_HARDWARE_QUALIFICATION','R4_sources_unchanged':True,'mainboard_pin_nets_unchanged':len(nets(prior)),'faceplate_sources_unchanged':True,'pcb_delta':'one MPN string; reversing it restores byte-identical R4 PCB','changed_reference':'U10','charger_voltage_v':[4.1*.995,4.1*1.005],'pack_max_charge_v':4.2,'R39_charge_mA_5percent_resistor_screen':[1000*.9/1.05,1000*1.1/.95],'R39_note':'Conservative 5% resistor bound used; original RC0603DR tolerance is tighter. MCP73871 +/-10% current bound at 1 kOhm.','R35_termination_mA':[100*.75/1.05,100*1.25/.95],'termination_disposition':'Earlier than pack recommended 22 mA; retains conservative early termination with reduced usable capacity. Measure actual full-cycle behavior.','timer_h':[5.4,6.6],'timer_disposition':'Retained as backup; not equivalent to pack recommended 5 h standard / 2.5 h rapid completion. Validate cycle time before portable charging.','thermal_status':'BLOCKED: exact pack NTC curve/tolerances or physical characterization needed. 10 kOhm alone cannot prove 0–45 C cutoff.','sources':{'r4_bom_sha256':sha(quote),'prior_netlist_sha256':sha(prior),'new_netlist_sha256':sha(OUT/'mainboard-netlist.xml')}}
assert report['charger_voltage_v'][1]<4.2
assert report['R39_charge_mA_5percent_resistor_screen'][1]<1500
(OUT/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
