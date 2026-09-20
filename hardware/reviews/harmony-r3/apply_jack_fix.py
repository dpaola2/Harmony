"""Apply reviewed manufacturer slot/cutout dimensions; retain pin positions/routing."""
from pathlib import Path
import sys,re
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(HERE/'physical'))
from sexpr_tools import spans
rev=ROOT/'hardware/revisions/harmony-r3/tangara-mainboard'
p=rev/'tangara-mainboard.kicad_pcb';s=p.read_text()
a,b=next((a,b) for a,b in spans(s,'footprint') if '(property "Reference" "J1"' in s[a:b]);fp=s[a:b]
fp=fp.replace('5.125','5.05').replace('4.325','4.25').replace('4.725','4.65').replace('(attr smd)','(attr through_hole)')
for c,d in reversed(list(spans(fp,'pad'))):
 pad=fp[c:d];number=re.search(r'\(pad "([^"]+)"',pad).group(1)
 pad=pad.replace('(drill oval 1.2 0.7','(drill oval 1.1 0.7')
 if number in ('2','6'):
  pad=pad.replace('(size 1.8 1.2)','(size 1.6 1.25)').replace('(offset -0.15 0.1)','(offset -0.025 0.1)').replace('(offset 0.15 0.1)','(offset 0.025 0.1)')
 fp=fp[:c]+pad+fp[d:]
s=s[:a]+fp+s[b:]
# Only zone blocks from the independently refilled experiment; native serializer
# is deliberately not allowed to rewrite unrelated footprints/tracks.
refilled=(HERE/'mainboard-experiment/tangara-mainboard.kicad_pcb').read_text()
def uid(t):return re.search(r'\(uuid \"([^\"]+)\"\)',t).group(1)
zones={uid(refilled[a:b]):refilled[a:b] for a,b in spans(refilled,'zone')}
old=list(spans(s,'zone'));assert len(zones)==len(old)
for a,b in reversed(old):s=s[:a]+zones[uid(s[a:b])]+s[b:]
p.write_text(s)
print('Applied J1 board correction. Run sync_jack_library.py with KiCad Python next.')
