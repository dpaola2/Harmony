#!/usr/bin/env python3
"""Create an explicitly unreleased manufacturer review bundle from checked outputs."""
from pathlib import Path
import csv,json,collections,shutil,hashlib,zipfile
H=Path(__file__).resolve().parent;O=H/'output/manufacturing-review';O.mkdir(exist_ok=True)
r=json.loads((H/'final-drc.json').read_text());assert not r['violations'] and not r['unconnected_items']
rows=list(csv.DictReader((H/'bom-draft.csv').open()));real=[r for r in rows if r['mpn']];assert len(real)==36
parts=collections.defaultdict(list)
for r in real:parts[r['mpn']].append(r)
with (O/'assembly-bom.csv').open('w',newline='') as f:
 w=csv.writer(f);w.writerow(['References','Quantity','MPN','Value','Footprint','Method','Assembly'])
 for mpn,rs in sorted(parts.items()):w.writerow([','.join(r['ref'] for r in rs),len(rs),mpn,rs[0]['value'],rs[0]['footprint'],'Through-hole' if rs[0]['ref'] in ['J1','J2'] else 'SMT','Factory install; no customer soldering'])
positions=list(csv.DictReader((H/'output/all-positions.csv').open()));wanted={r['ref'] for r in real};pos=[r for r in positions if r['Ref'] in wanted];assert {r['Ref'] for r in pos}==wanted
with (O/'assembly-positions.csv').open('w',newline='') as f:
 w=csv.DictWriter(f,fieldnames=positions[0].keys());w.writeheader();w.writerows(pos)
with (O/'external-parts.csv').open('w',newline='') as f:
 w=csv.writer(f);w.writerow(['Quantity','Part','Source','Note'])
 for row in [(1,'Adafruit 5900 factory-headered ESP32 Feather V2','https://www.adafruit.com/product/5900','Classic Bluetooth required; cart quantity four is separate from per-device BOM'),(1,'Waveshare 29318 3.5-inch ST7796S IPS display','https://www.pishop.us/product/3-5inch-capacitive-touch-display-320-480-ips-2tpd/','Ordered by customer; shipment reported; physical fit and cable checks remain'),(1,'Adafruit 6310 assembled ANO controls','https://www.adafruit.com/product/6310','Customer order shipped Sept 21; use upper QT connector'),(1,'Adafruit 5239 EYESPI 100mm cable','https://www.adafruit.com/product/5239','Optional if included Waveshare FPC fails length/contact/pin-mapping checks'),(1,'Adafruit 4399 QT-to-QT 50mm cable','https://www.adafruit.com/product/4399','50mm preferred; customer 4210 100mm QT-to-QT shipped, case slack unverified'),(4,'12mm M2.5 insulating spacers','Printed parts received by customer','Final screw lengths depend on physical fit')]:w.writerow(row)
for n in ['harmony-mark6-carrier.kicad_pcb','harmony-mark6-carrier.kicad_sch','harmony-mark6-carrier.kicad_pro','Harmony.kicad_sym','sym-lib-table','netlist.xml','erc.json','final-drc.json','pcb-verification.json','power-review.md','mechanical-review.md','display-sourcing.md','assembly-readiness.md','assembly-audit.json','arrival-checklist.md','supplier-request-draft.md']:
 shutil.copy2(H/n,O/n)
for n in ['via-in-pad.csv','assembly-top.svg']:
 shutil.copy2(H/'output'/n,O/n)
shutil.copy2(H/'output/assembly-audit/strict-drc.json',O/'strict-drc.json')
assert json.loads((O/'gerbers/harmony-mark6-carrier-job.gbrjob').read_text())['GeneralSpecs']['Finish']=='ENIG'
for n in ['schematic-draft.pdf','design-review.pdf']:
 if (H/'output/pdf'/n).exists():shutil.copy2(H/'output/pdf'/n,O/n)
(O/'README.md').write_text('''# Harmony Mark-6 Rev A - prototype manufacturing review

NOT RELEASED FOR FABRICATION OR ASSEMBLY. This package is for design/DFM review.
No order, quantity commitment or supplier communication accompanies it.

## Included

Four copper layers, mask, paste, silk and outline Gerbers; separate plated and
non-plated Excellon drills; exact 36-part carrier BOM; placement CSV including
through-hole sockets; schematic netlist; editable KiCad files; ERC/DRC reports;
power/mechanical notes, assembly-readiness.md, assembly audit, top fabrication
drawing, strict DRC and nine via-in-pad locations. SHA256SUMS.txt identifies this set.
The five test pads, eight mounting holes and three fiducials are bare-board
features, not items to purchase or place. Module/cable purchases are separate.

## Fabrication and assembly requirements

Use four-layer FR-4, 1.6 mm finished nominal thickness, 35 um nominal outer
copper, ENIG, solder mask both sides and white top silkscreen. Copper order:
F.Cu signals/components, In1.Cu ground, In2.Cu ground with two routed nets,
B.Cu signals/ground. No controlled impedance is specified. The fabricator
must return its stackup and thickness tolerance for review.

Minimum routed width/clearance: 0.20/0.20 mm. Copper-to-edge minimum: 0.30 mm.
Minimum plated drill: 0.25 mm at U1 thermal pads; ordinary vias 0.30 mm.
The U1 exposed-pad holes and any vias in SMT pads require resin filling and
copper capping (IPC-4761 Type VII or an agreed equivalent). Tenting alone is
insufficient. Review stencil apertures and exposed-pad voiding with the
assembler. Do not silently omit fill/cap or replace footprints to reduce cost.

The board's antenna cutout is functional. Preserve its profile and the ground
pour exclusion. Do not add copper thieving, rails or assembly tabs beneath the
antenna. Panel tooling and depanelization must be proposed before production.
The concave fork and 6 mm prongs need the fabricator's routing review.

Factory-install every BOM component, including J1/J2 through-hole sockets.
Dave must receive an assembled carrier requiring no soldering. Confirm Samtec
socket mating, tail/drill tolerance, connector part orientation and U1 pin 1
against the drawings. Position CSV uses KiCad millimeters: positive X right,
negative Y downward from the shared absolute origin. Angles are KiCad angles,
not a guarantee of any machine's tape orientation. Review every polarized
part and connector in the supplier's assembly preview.

## Release conditions

CAD presently passes zero ERC violations, zero PCB DRC violations and zero
unconnected nets. Every electrical PCB pad matches the exported schematic.
The strict DRC audit reports one documented U1 component-type warning caused
by its thermal holes; U1 is SMT. See assembly-readiness.md. These checks do
not establish hardware performance or physical assembly fit.

Before authorizing a prototype order, complete assembler DFM/part availability
review, confirm the header/socket mating and resolve procurement/measurement
of Waveshare 29318. The display uses vendor STEP geometry, and USB/SD access
and both cables need a hollow fit check before final housing release. If a
bare carrier is ordered first for learning, that is an explicit prototype
risk decision, not completion of these checks.

No battery is connected. Use the staged current-limited first-power procedure
in power-review.md. Then qualify display/SD/controls during A2DP playback,
reconnection, RF range, supply/thermal behavior and the deferred full album.
''')
files=sorted(p for p in O.rglob('*') if p.is_file() and p.name!='SHA256SUMS.txt')
assert len(list((O/'gerbers').glob('*')))==12 # 11 plots plus job file
assert len(list((O/'drill').glob('*.drl')))==2
(O/'SHA256SUMS.txt').write_text(''.join(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+str(p.relative_to(O))+'\n' for p in files))
with zipfile.ZipFile(H/'output/harmony-mark6-rev-a-review.zip','w',zipfile.ZIP_DEFLATED) as z:
 for p in sorted(O.rglob('*')):
  if p.is_file():z.write(p,'harmony-mark6-rev-a-review/'+str(p.relative_to(O)))
print('Packaged',len(files)+1,'files;',len(real),'assembled parts;',len(pos),'positions')
