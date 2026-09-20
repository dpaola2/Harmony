"""Independent copper geometry check; requires shapely 2.x, native-electrodes.json."""
import json,itertools
from pathlib import Path
from shapely.geometry import Point,Polygon
p=Path(__file__).resolve().parent
rows=json.loads((p/'native-electrodes.json').read_text());electrodes=[];contacts=[]
for row in rows:
 for g in row['graphics']:
  if g['shape']=='Polygon': geom=Polygon(g['points'])
  else:
   c=Point(g['center']);r=g['radius_mm'];w=g['width_mm']
   geom=c.buffer(r+w/2,quad_segs=32768).difference(c.buffer(r-w/2,quad_segs=32768)) if w else c.buffer(r,quad_segs=32768)
  assert geom.is_valid,(row['ref'],g['uuid'])
  electrodes.append((g['net'],geom))
  for pad in row['pads']:
   # Contact at pad centre proves nonzero overlap for circular through-hole pads;
   # guard's off-ring SMD anchor contacts through its extended rectangle.
   point=Point(pad['pos']);contact=geom.distance(point)
   contacts.append({'electrode':g['net'],'pad':row['ref']+'.'+pad['number'],'pad_net':pad['net'],'centre_distance_mm':contact,'centre_inside':geom.covers(point),'pad_copper_overlap_mm2':geom.intersection(Polygon(pad['copper_polygon'])).area})
assert all((x['pad_copper_overlap_mm2']>0)==(x['electrode']==x['pad_net']) for x in contacts)
pairs=[{'a':a,'b':b,'clearance_mm':ga.distance(gb),'overlap_mm2':ga.intersection(gb).area} for (a,ga),(b,gb) in itertools.combinations(electrodes,2)]
assert all(x['clearance_mm']>0 and x['overlap_mm2']==0 for x in pairs)
(p/'electrode-isolation.json').write_text(json.dumps({'circle_approximation_radial_error_bound_mm':0.000000007,'pairs':pairs,'contacts':contacts},indent=2)+'\n')
print(json.dumps(pairs,indent=2))
