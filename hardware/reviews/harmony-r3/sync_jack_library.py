"""Save authoritative routed J1 footprint in unflipped library coordinates."""
from pathlib import Path
import pcbnew,wx
app=wx.App(False)
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
p=ROOT/'hardware/revisions/harmony-r3/tangara-mainboard'
b=pcbnew.LoadBoard(str(p/'tangara-mainboard.kicad_pcb'))
f=pcbnew.FOOTPRINT(next(f for f in b.GetFootprints() if f.GetReference()=='J1'))
assert f.GetLayer()==pcbnew.B_Cu
f.Flip(f.GetPosition(),False)
f.SetOrientationDegrees(0)
f.SetPosition(pcbnew.VECTOR2I(0,0))
f.SetReference('REF**')
for pad in f.Pads():pad.SetNetCode(0)
assert f.GetLayer()==pcbnew.F_Cu
pcbnew.FootprintSave(str(p/'footprints.pretty'),f)
print('Saved J1 library from unflipped authoritative board footprint. Board unchanged.')
