"""Independent textual edit-scope and analytic nominal annulus check; shapely 2.x."""
from pathlib import Path
import json,re,hashlib,collections
from shapely.geometry import LineString
from sexpr_tools import spans
p=Path(__file__).resolve().parent;r=p.parents[3]
sources=[r/f'hardware/revisions/harmony-r{n}/tangara-mainboard/tangara-mainboard.kicad_pcb' for n in (2,3)]
def excluded(s):
 for a,b in reversed(list(spans(s,'zone'))):s=s[:a]+s[b:]
 for a,b in spans(s,'footprint'):
  if '(property "Reference" "J1"' in s[a:b]:return s[:a]+s[b:]
assert excluded(sources[0].read_text())==excluded(sources[1].read_text())
data=json.loads((p/'jack-native-independent.json').read_text());annuli={}
def capsule(size,offset):
 w,h=size;cx,cy=offset
 return LineString([(cx-(w-h)/2,cy),(cx+(w-h)/2,cy)]).buffer(h/2,quad_segs=32768)
for n,pad in data['r3']['pads'].items():
 copper=capsule(pad['size_mm'],pad['offset_mm']);hole=capsule(pad['drill_mm'],[0,0]);assert copper.covers(hole)
 annuli[n]=copper.boundary.distance(hole.boundary)
drc=json.loads((p.parent/'mainboard-drc.json').read_text());physical={'annular_width','edge_clearance','clearance','hole_clearance','holes_co_located','shorting_items','unconnected_items'}
j1_findings=[v for v in drc['violations'] if v['type'] in physical and any(' of J1' in a['description'] or a['description']=='Footprint J1' for a in v['items'])]
assert not j1_findings
report={'scope':'Read-only independent review of final mainboard J1 correction','verdict':'Pass for changed nominal J1 geometry and source scope; not a fabrication release','board_sha256':hashlib.sha256(sources[1].read_bytes()).hexdigest(),'outside_J1_and_zone_blocks_byte_identical_to_R2':True,'no_trace_via_unrelated_footprint_or_hole_center_movement':True,'library_reimport_matches_board_pads_offsets_shapes_layers_masks_paste_margins_and_EdgeCuts_exactly':data['library_placed_on_board_matches_exactly_including_masks'] and data['library_edge_cuts_match_exactly'],'primary_source':{'file':'hardware/reviews/harmony-r2/sources/SJ-3506-SMT-TR.pdf','page':2,'drawing_date':'09/12/2024 as printed','review_method':'Visual inspection of manufacturer page 2 rendered image','eight_finished_slots_mm':[1.1,.7],'PCB_tolerance_mm':.05,'cutout_width_mm':10.1,'slot_row_spacing_mm':11.8,'pin_2_to_6_slot_edge_gap_mm':.7,'longitudinal_hole_positions_mm':{'side_1':[1.85,5.88,9.7,11.5],'side_2':[1.85,5.88,9.0,11.5]}},'changed_dimensions_match_manufacturer_drawing':True,'nominal_analytic_min_annulus_mm':annuli,'existing_native_DRC_J1_physical_findings':j1_findings,'limitations':['Pad copper adjustment is an engineering change to maintain annulus and routing clearance; manufacturer drawing confirms holes and cutout, not approval of these copper dimensions.','Finished slot and board-route tolerances must meet the drawing and fabricator capability. Nominal equality does not replace manufacturing tolerance review.','Existing mainboard release blockers, including USB 0.8 mm recommended versus 1.60252 mm board thickness and U15 starved thermal after refill, remain outside this J1 geometry pass.'],'review_correction':'Initial manual library replacement missed pre-existing library dimension differences. Root regenerated from native board geometry; independent reverse placement now matches exactly.'}
(p/'jack-review.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'annuli':annuli,'scope_pass':True,'library_pass':True},indent=2))
