import json, sys
from pathlib import Path
import pcbnew, wx
app=wx.App(False)
p=Path(__file__).resolve().parent
b=pcbnew.LoadBoard(str(p.parents[2]/'revisions/harmony-r3/tangara-faceplate/tangara-faceplate.kicad_pcb'))
out=[]
for f in b.GetFootprints():
 if f.GetReference() not in ('SW1','SW2','SW3','TP7'):continue
 row={'ref':f.GetReference(),'position':[pcbnew.ToMM(f.GetPosition().x),pcbnew.ToMM(f.GetPosition().y)],'rotation':f.GetOrientationDegrees(),'pads':[],'graphics':[]}
 for pad in f.Pads():row['pads'].append({'number':pad.GetNumber(),'net':pad.GetNetname(),'pos':[pcbnew.ToMM(pad.GetPosition().x),pcbnew.ToMM(pad.GetPosition().y)],'size':[pcbnew.ToMM(pad.GetSize().x),pcbnew.ToMM(pad.GetSize().y)],'drill':[pcbnew.ToMM(pad.GetDrillSize().x),pcbnew.ToMM(pad.GetDrillSize().y)],'layers':pad.GetLayerSet().FmtBin(),'copper_polygon':[[pcbnew.ToMM(pad.GetEffectivePolygon().CVertex(i).x),pcbnew.ToMM(pad.GetEffectivePolygon().CVertex(i).y)] for i in range(pad.GetEffectivePolygon().TotalVertices())]})
 for g in f.GraphicalItems():
  if g.GetLayer()!=pcbnew.F_Cu:continue
  z={'uuid':g.m_Uuid.AsString(),'net':g.GetNetname(),'shape':g.GetShapeStr(),'width_mm':pcbnew.ToMM(g.GetWidth())}
  if g.GetShape()==pcbnew.SHAPE_T_POLY:
   poly=g.GetPolyShape();z['points']=[[pcbnew.ToMM(poly.CVertex(i).x),pcbnew.ToMM(poly.CVertex(i).y)] for i in range(poly.TotalVertices())]
  else:z.update(center=[pcbnew.ToMM(g.GetCenter().x),pcbnew.ToMM(g.GetCenter().y)],radius_mm=pcbnew.ToMM(g.GetRadius()))
  row['graphics'].append(z)
 out.append(row)
(p/'native-electrodes.json').write_text(json.dumps(out,indent=2)+'\n')
if '--fill' in sys.argv:
 pcbnew.ZONE_FILLER(b).Fill(b.Zones())
 pcbnew.SaveBoard(str(p/'faceplate-refilled-native.kicad_pcb'),b)
