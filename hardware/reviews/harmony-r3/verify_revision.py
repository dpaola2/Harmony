"""Independent native connectivity and geometry review. Run with KiCad 8 Python."""
import hashlib,json,xml.etree.ElementTree as ET,sys,re
from pathlib import Path
import pcbnew,wx
app=wx.App(False)
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
REV=ROOT/'hardware/revisions/harmony-r3';BASE=ROOT/'hardware/revisions/harmony-r2'
sys.path.insert(0,str(HERE/'physical'));from sexpr_tools import spans

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def nodes(p):
 out={}
 for net in ET.parse(p).getroot().findall('nets/net'):
  for n in net.findall('node'):
   k=(n.get('ref'),n.get('pin'));assert k not in out;out[k]=net.get('name')
 return out
def pads(board):
 out={}
 for f in board.GetFootprints():
  for p in f.Pads():
   if p.GetNumber() and p.GetNetname():
    k=(f.GetReference(),p.GetNumber());assert k not in out or out[k]==p.GetNetname();out[k]=p.GetNetname()
 return out
def geometry(board):
 out={}
 for f in board.GetFootprints():
  for p in f.Pads():
   out[p.m_Uuid.AsString()]={'reference':f.GetReference(),'pin':p.GetNumber(),'position':[p.GetPosition().x,p.GetPosition().y],'size':[p.GetSize().x,p.GetSize().y],'offset':[p.GetOffset().x,p.GetOffset().y],'drill':[p.GetDrillSize().x,p.GetDrillSize().y],'rotation':p.GetOrientationDegrees(),'net':p.GetNetname(),'layers':p.GetLayerSet().FmtHex()}
 return out
def strip_zones(s):
 for a,b in reversed(list(spans(s,'zone'))):s=s[:a]+'ZONE_FILL_REVIEWED_SEPARATELY'+s[b:]
 return s
result={'tool':pcbnew.GetBuildVersion(),'boards':[]}
for name in ('mainboard','faceplate'):
 file=f'tangara-{name}/tangara-{name}.kicad_pcb';old=pcbnew.LoadBoard(str(BASE/file));new=pcbnew.LoadBoard(str(REV/file))
 sch=nodes(HERE/f'{name}-netlist.xml');prior=nodes(ROOT/f'hardware/reviews/harmony-r2/{name}-netlist.xml');p=pads(new)
 assert sch==prior,'Logical netlist changed'
 assert p==pads(old),'PCB pad nets changed'
 assert p==sch,[(k,sch.get(k),p.get(k)) for k in set(sch)|set(p) if p.get(k)!=sch.get(k)]
 g0,g1=geometry(old),geometry(new);assert set(g0)==set(g1)
 changes=[]
 for k in g0:
  if g0[k]==g1[k]:continue
  a,b=g0[k],g1[k];assert name=='mainboard' and a['reference']=='J1'
  assert all(a[t]==b[t] for t in ['position','rotation','layers','net','pin','reference'])
  assert b['drill']==[1100000,700000]
  if b['pin'] in ('2','6'):
   assert b['size']==[1600000,1250000] and b['offset']==[(-25000 if b['pin']=='2' else 25000),100000]
  else:assert a['size']==b['size'] and a['offset']==b['offset']
  changes.append({'uuid':k,'before':a,'after':b})
 s0,s1=strip_zones((BASE/file).read_text()),strip_zones((REV/file).read_text())
 if name=='mainboard':
  for which,s in enumerate((s0,s1)):
   a,b=next((a,b) for a,b in spans(s,'footprint') if '(property "Reference" "J1"' in s[a:b])
   if which==0:s0=s[:a]+'J1_REVIEWED_SEPARATELY'+s[b:]
   else:s1=s[:a]+'J1_REVIEWED_SEPARATELY'+s[b:]
  assert len(changes)==8
 else:
  # Precisely reverse only the five new graphic net fields and SW1 attribute.
  for a,b in reversed(list(spans(s1,'footprint'))):
   fp=s1[a:b]
   if any('(property "Reference" "'+r+'"' in fp for r in ('SW1','SW2','SW3')):
    for c,d in reversed(sorted(list(spans(fp,'fp_poly'))+list(spans(fp,'fp_circle')))):
     block=fp[c:d];block=re.sub(r'\s*\(net \d+\)','',block);fp=fp[:c]+block+fp[d:]
    if '(property "Reference" "SW1"' in fp:fp=fp.replace('(attr through_hole)','(attr smd)')
   s1=s1[:a]+fp+s1[b:]
 assert re.sub(r'\s+',' ',s0)==re.sub(r'\s+',' ',s1),'Unexpected non-zone source geometry delta'
 result['boards'].append({'board':name,'pcb_sha256':sha(REV/file),'shared_pin_nets_checked':len(p),'logical_nets_identical_to_R2':True,'no_missing_pins':True,'pad_changes':changes,'all_nonzone_nonJ1_geometry_preserved':True})
result['result']='PASS_CONNECTIVITY_AND_BOUNDED_GEOMETRY_CHANGE'
(HERE/'independent-native-verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({**result,'boards':[{k:v for k,v in b.items() if k!='pad_changes'} for b in result['boards']]},indent=2))
