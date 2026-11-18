"""Import a Freerouting session into the board, lock every track and via, save.

Usage: import_ses.py routing-a.ses   (KiCad's bundled Python)
KiCad replaces all tracks and vias with the session's wiring, which includes the earlier fixed
routes, so locking after every import keeps them fixed for the next phase.
"""
import sys
import pcbnew as p
import wx
from design import HERE, NAME

app = wx.App(False)
PCB = HERE / (NAME + '.kicad_pcb')
b = p.LoadBoard(str(PCB))
assert p.ImportSpecctraSES(b, str(HERE / sys.argv[1])), 'SES import failed'
n = 0
for t in b.GetTracks():
    t.SetLocked(True); n += 1
p.SaveBoard(str(PCB), b)
print('imported', sys.argv[1], '-', n, 'tracks and vias, all locked')
