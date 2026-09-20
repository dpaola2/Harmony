"""Assert edit scope and quantify native zone-fill changes. Requires shapely."""
from pathlib import Path
import re,json,hashlib,difflib
from shapely.geometry import Polygon,Point
from shapely.ops import unary_union
from sexpr_tools import spans
p=Path(__file__).resolve().parent;r=p.parents[3];src=r/'hardware/revisions/harmony-r3/tangara-faceplate/tangara-faceplate.kicad_pcb';before=(p/'faceplate-before.kicad_pcb').read_text();after=src.read_text()
def stripzones(s):
 for i,j in reversed(list(spans(s,'zone'))):s=s[:i]+s[j:]
 return s
normalized=after
assignments={'6f9ed1f2-c8a0-4a46-b920-bde52c578371':3,'2aeb4562-8b99-46f2-9004-79778bf86f52':15,'52a16c30-173a-482c-a962-efae53334f95':16,'601e80af-a3da-4105-8a70-8dd1c79e8432':22,'0c6880e3-6998-4b7b-bca0-d0df79940f38':20}
for u,n in assignments.items():
 x=f'(net {n})\n\t\t\t(uuid "{u}")';assert x in normalized;normalized=normalized.replace(x,f'(uuid "{u}")')
for i,j in spans(normalized,'footprint'):
 f=normalized[i:j]
 if '(property "Reference" "SW1"' in f:normalized=normalized[:i]+f.replace('(attr through_hole)','(attr smd)')+normalized[j:];break
assert stripzones(before)==stripzones(normalized),'Unexpected non-zone change'
def fills(s):
 out={}
 for i,j in spans(s,'filled_polygon'):
  f=s[i:j];layer=re.search(r'\(layer "([^"]+)"\)',f)[1];pts=[tuple(map(float,x)) for x in re.findall(r'\(xy ([\d.-]+) ([\d.-]+)\)',f)]
  poly=Polygon(pts)
  if not poly.is_valid:poly=poly.buffer(0)
  out.setdefault(layer,[]).append(poly)
 return {k:unary_union(v) for k,v in out.items()}
a,b=fills(before),fills(after);delta={}
for layer in a:
 added=b[layer].difference(a[layer]);removed=a[layer].difference(b[layer]);delta[layer]={'copper_added_mm2':added.area,'copper_removed_mm2':removed.area,'change_bounds_mm':a[layer].symmetric_difference(b[layer]).bounds}
report={'source':str(src.relative_to(r)),'before_sha256':hashlib.sha256(before.encode()).hexdigest(),'after_sha256':hashlib.sha256(after.encode()).hexdigest(),'non_zone_changes_exactly_five_net_assignments_and_SW1_attribute':True,'no_footprint_pad_track_via_outline_or_electrode_geometry_changes':True,'zone_delta':delta}
rows=json.loads((p/'native-electrodes.json').read_text());g=next(row for row in rows if row['ref']=='SW3')['graphics'][0];center=Point(g['center']);guard=center.buffer(g['radius_mm']+.5,quad_segs=32768).difference(center.buffer(g['radius_mm']-.5,quad_segs=32768))
report['guard_GND_FCu_clearance_mm']={'before':guard.distance(a['F.Cu']),'after':guard.distance(b['F.Cu'])}
(p/'source-delta.json').write_text(json.dumps(report,indent=2)+'\n');(p/'faceplate-correction.patch').write_text(''.join(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='harmony-r2/tangara-faceplate.kicad_pcb',tofile='harmony-r3/tangara-faceplate.kicad_pcb')));print(json.dumps(report,indent=2))
