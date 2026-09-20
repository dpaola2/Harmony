import json
from pathlib import Path
import pcbnew,wx
app=wx.App(False)
p=Path(__file__).resolve().parent;r=p.parents[2]
out={}
for n,refs in [('mainboard',('J1','J6','U7','U9','U10','U15')),('faceplate',('SW1','SW2','SW3'))]:
 b=pcbnew.LoadBoard(str(r/f'hardware/tangara-reference/tangara-{n}/tangara-{n}.kicad_pcb'))
 rows=[]
 for f in b.GetFootprints():
  if f.GetReference() not in refs:continue
  rows.append({'reference':f.GetReference(),'footprint':str(f.GetFPID().GetLibNickname())+':'+str(f.GetFPID().GetLibItemName()),'attributes':f.GetAttributes(),'pads':[{'number':x.GetNumber(),'net':x.GetNetname(),'type':x.GetAttribute(),'size_mm':[pcbnew.ToMM(x.GetSize().x),pcbnew.ToMM(x.GetSize().y)],'drill_mm':[pcbnew.ToMM(x.GetDrillSize().x),pcbnew.ToMM(x.GetDrillSize().y)],'rotation_deg':x.GetOrientationDegrees()} for x in f.Pads()]})
 out[n]=rows
(p/'physical-details.json').write_text(json.dumps(out,indent=2)+'\n')
print('Physical pad and drill details preserved.')
