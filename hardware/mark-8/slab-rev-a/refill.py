"""Refill every zone with KiCad's zone filler and save, right before the final DRC (KiCad Python).

kicad-cli 8.0.9 has no --refill-zones option, so this step stands in for it: the DRC that follows
checks freshly filled zones.
"""
import pcbnew as p
import wx
from design import HERE, NAME

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
b = p.LoadBoard(str(PCB))
p.ZONE_FILLER(b).Fill(b.Zones())
p.SaveBoard(str(PCB), b)
print('refilled', len(list(b.Zones())), 'zones')
