#!/usr/bin/env python3
"""Import routed SES, complete two escapes, add RF-limited ground planes."""
import json
from pathlib import Path
import pcbnew as p,wx
app=wx.App(False)
H=Path(__file__).resolve().parent
b=p.LoadBoard(str(H/'routed-base.kicad_pcb'))
def v(x,y):return p.VECTOR2I(p.FromMM(x),p.FromMM(y))
nets={n.GetNetname():n for n in b.GetNetInfo().NetsByNetcode().values()}
fps={f.GetReference():f for f in b.GetFootprints()}
def xy(v):return (p.ToMM(v.x),p.ToMM(v.y))
def tr(net,points,w=.2,layer=p.In2_Cu):
 for a,z in zip(points,points[1:]):
  t=p.PCB_TRACK(b);t.SetStart(v(*a));t.SetEnd(v(*z));t.SetWidth(p.FromMM(w));t.SetNet(nets[net]);t.SetLayer(layer);b.Add(t)
def via(net,x,y):
 t=p.PCB_VIA(b);t.SetPosition(v(x,y));t.SetWidth(p.FromMM(.6));t.SetDrill(p.FromMM(.3));t.SetViaType(p.VIATYPE_THROUGH);t.SetLayerPair(p.F_Cu,p.B_Cu);t.SetNet(nets[net]);b.Add(t)
# Expand three edges by 0.2 mm instead of weakening the 0.3 mm clearance rule.
for d in b.GetDrawings():
 if d.GetLayer()==p.Edge_Cuts:
  for getter,setter in [(d.GetStart,d.SetStart),(d.GetEnd,d.SetEnd)]:
   x,y=xy(getter())
   if abs(x-70)<.001:x=70.2
   if abs(x-32)<.001 and 138<y<149:x=32.2
   if abs(y-94)<.001:y=93.8
   setter(v(x,y))
 if isinstance(d,p.PCB_TEXT) and d.GetText()=='QT / ANO':d.SetPosition(v(34,104))
# The SD select is the only long signal on In2. Keep its return plane on In1.
a=xy(fps['R4'].FindPadByNumber('2').GetPosition());z=xy(fps['R13'].FindPadByNumber('2').GetPosition())
assert fps['R13'].FindPadByNumber('2').GetNetname()=='SD_CS'
via('SD_CS',*a);via('SD_CS',*z)
tr('SD_CS',[a,(25.82,157.005),(25.82,149),(31.3,149),(31.3,137.8),(34,137.8),(43.8,128),(43.8,31.025),z])
# Fine-pitch connector neck-down followed by a wider power connection.
tr('PERIPH_3V3',[(58.25,53.85),(59,54.6),(59,54.9)],.2,p.F_Cu)
via('PERIPH_3V3',59,54.9)
z=(59.8,57);via('PERIPH_3V3',*z);tr('PERIPH_3V3',[z,(61.05,57)],.5,p.F_Cu)
tr('PERIPH_3V3',[(59,54.9),(59,56.2),z],.5)
# Stitch exposed-pad ground and capacitor returns to both inner ground layers.
for ref,pad in [('C2','2'),('C4','2'),('C5','2'),('C6','2'),('C7','2')]:
 via('GND',*xy(fps[ref].FindPadByNumber(pad).GetPosition()))
via('GND',50,69.025);tr('GND',[(48,69.025),(50,69.025)],.3,p.F_Cu)
fps['H2'].Reference().SetPosition(v(64,94))
# Zone contour stops before antenna halo: no copper pour within 15 mm of antenna.
poly=[(40,6),(70.2,6),(70.2,138.5),(35.47,138.5),(35.47,175),(4,175),(4,93.8),(40,93.8)]
for layer in [p.In1_Cu,p.In2_Cu,p.B_Cu]:
 z=p.ZONE(b);z.SetLayer(layer);z.SetNet(nets['GND']);z.SetLocalClearance(p.FromMM(.25));z.SetThermalReliefGap(p.FromMM(.25));z.SetThermalReliefSpokeWidth(p.FromMM(.25));z.SetMinThickness(p.FromMM(.2));z.SetPadConnection(p.ZONE_CONNECTION_FULL)
 o=z.Outline();o.NewOutline()
 for x,y in poly:o.Append(int(p.FromMM(x)),int(p.FromMM(y)))
 b.Add(z)
b.BuildConnectivity();p.ZONE_FILLER(b).Fill(b.Zones());p.SaveBoard(str(H/'harmony-mark6-carrier.kicad_pcb'),b)
print('Final routes and planes added')
