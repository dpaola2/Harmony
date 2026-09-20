#!/usr/bin/env python3
"""Retain every native finding with a specific disposition; never waive it."""
import json,hashlib
from pathlib import Path
from collections import Counter
HERE=Path(__file__).resolve().parent
A={
'annular_width':('OPEN_CONNECTOR_DFM','J1 slotted-hole copper rings are below the configured 0.15 mm rule; two are 0.1034 mm. Compare actual oblong drill/pad geometry with the manufacturer drawing and assembler capability before changing copper or accepting a deviation.'),
'copper_edge_clearance':('OPEN_CONNECTOR_DFM','Review per-item geometry: twelve USB J6 pads meet the connector cutout; eight J1 pads have 0.275 mm clearance; four SW2/SW3 arc clearances differ from 0.3 mm by less than 0.00003 mm. Obtain fabrication disposition; no global clearance relaxation.'),
'footprint_type_mismatch':('REVIEWED_MIXED_PAD_METADATA_NOT_WAIVED','SMD-labelled footprints contain plated pads, including thermal vias, connector anchors, or a touch electrode. The purchasing inventory separately handles these structures. Confirm assembly process per footprint; do not relabel every part through-hole merely to clear DRC.'),
'lib_footprint_mismatch':('OPEN_LIBRARY_RECONCILIATION','Embedded board footprint differs from library copy. Preserve routed geometry; compare deliberate edits before any library update.'),
'lib_footprint_issues':('OPEN_LIBRARY_RECONCILIATION','Missing footprint library or library item does not erase the embedded board geometry. Restore a reproducible project-local mapping and compare geometry before updates.'),
'silk_edge_clearance':('OPEN_SILK_DFM','Review clipped legend at routed edges in assembler CAM preview. Move nonessential artwork only in a separate PCB revision.'),
'silk_over_copper':('OPEN_SILK_DFM','Review legend against solder-mask openings; keep pads clear and retain readable polarity/assembly markings.'),
'silk_overlap':('OPEN_SILK_DFM','Resolve overlapping markings or accept the specific cosmetic overlap in CAM review.'),
'text_height':('OPEN_SILK_DFM','Check actual text heights against selected supplier minimum; preserve useful assembly/programming labels.'),
'clearance':('OPEN_TOUCH_ELECTRODE_MODEL','Five touch electrodes use netless copper graphics contacting their own pads. Confirm each shape belongs to the intended electrode, check isolation between electrodes, and model net-aware copper without changing the sensing geometry before clearance acceptance.'),
'via_dangling':('OPEN_FACEPLATE_CONNECTIVITY_REVIEW','Inspect the LED_ENABLE via and its connected layers; establish whether the stub is intentional before removal.'),
'copper_sliver':('OPEN_FACEPLATE_CAM_REVIEW','Native DRC does not provide an item location for this sliver. Locate it in copper/CAM review and assess etching reliability; do not claim it resolved.'),
'duplicate_footprints':('OPEN_NONCOMPONENT_ANNOTATION','Anonymous REF** footprint identity conflicts are separate from component nets. Match UUIDs to graphic structures and set explicit board-only identity before cleanup.'),
'extra_footprint':('OPEN_NONCOMPONENT_ANNOTATION','Anonymous board graphic footprint lacks a matching schematic component. Match UUID to the non-purchased inventory before annotating; do not delete it automatically.'),
'footprint_symbol_mismatch':('OPEN_LABEL_RECONCILIATION','Mainboard J2 uses FP Connector on PCB and MB Connector in schematic. Pin nets agree; choose consistent perspective for value text before synchronization.'),
'lib_symbol_issues':('OPEN_SYMBOL_LIBRARY_RECONCILIATION','Cached schematic symbol differs from configured library. U1/U9 EP and WM8523 types were independently checked; other symbol differences still need comparison. No blanket library refresh or waiver.'),
'power_pin_not_driven':('OPEN_POWER_MODEL_REVIEW','Trace actual source and symbol type for this rail. Mainboard includes external supply/ground paths, INA1620 EN mistakenly power-in, and TPS65133 output type issues. Add power flags only after proving the physical source; absence of a flag alone is not proof of hardware failure.'),
'pin_to_pin':('OPEN_POWER_MODEL_REVIEW','Remaining mainboard reports involve TPS65133 GND typed output and AVIN/PVIN typed bidirectional. Check TI pin definitions in cache and library before correction; no wiring change implied.'),
'multiple_net_names':('REVIEWED_ALIAS_NET_PARITY_PASSES','All 567 populated and non-populated electrical pin assignments reconcile between native netlists and PCB. Record the specific aliases and preserve intended connectivity during any label cleanup; this is not a general hidden-pin waiver.'),
'wire_dangling':('OPEN_SCHEMATIC_BUS_ENTRY_CLEANUP','Reported objects are three bus-to-wire entries. Electrical pin coverage reconciles; inspect bus intent before deleting or connecting drawing elements.'),
}
items=[];counts={}
for b in ('mainboard','faceplate'):
 d=json.loads((HERE/f'{b}-drc.json').read_text());e=json.loads((HERE/f'{b}-erc.json').read_text())
 for check,vs in [('DRC',d['violations']),('parity',d['schematic_parity']),('ERC',[v for s in e['sheets'] for v in s['violations']])]:
  counts[b+' '+check]=dict(Counter(v['severity'] for v in vs))
  for n,v in enumerate(vs):
   assert v['type'] in A,v['type']
   status,action=A[v['type']]
   identity=json.dumps([b,check,v],sort_keys=True)
   items.append({'id':hashlib.sha256(identity.encode()).hexdigest()[:16],'board':b,'check':check,'native_finding':v,'disposition':status,'required_action':action,'waived':False})
(HERE/'finding-dispositions.json').write_text(json.dumps({'status':'ALL_FINDINGS_RETAINED_NO_FABRICATION_RELEASE','counts':counts,'finding_count':len(items),'items':items},indent=2)+'\n')
print(json.dumps({'counts':counts,'findings_with_disposition':len(items)},indent=2))
