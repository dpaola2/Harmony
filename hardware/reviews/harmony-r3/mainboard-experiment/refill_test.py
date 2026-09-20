from pathlib import Path
import pcbnew,wx
app=wx.App(False)
p=Path(__file__).parent/'tangara-mainboard.kicad_pcb'
b=pcbnew.LoadBoard(str(p))
f=next(f for f in b.GetFootprints() if f.GetReference()=='J1')
for pad in f.Pads():
 if pad.GetNumber() in ('2','6'):
  pad.SetSize(pcbnew.VECTOR2I(pcbnew.FromMM(1.6),pcbnew.FromMM(1.25)))
  pad.SetOffset(pcbnew.VECTOR2I(pcbnew.FromMM(-.025 if pad.GetNumber()=='2' else .025),pcbnew.FromMM(.1)))
pcbnew.ZONE_FILLER(b).Fill(b.Zones())
pcbnew.SaveBoard(str(p),b)
