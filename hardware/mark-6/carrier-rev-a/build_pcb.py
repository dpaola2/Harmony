#!/usr/bin/env python3
"""Place carrier using vendor header coordinates; pre-route the regulator loop.
Run with KiCad's bundled Python. Remaining routing is imported from Specctra.
"""
from pathlib import Path
import json, xml.etree.ElementTree as ET, uuid
import pcbnew as p
import wx
app=wx.App(False)
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
LIB=REPO/'firmware/toolchains/kicad-8.0.9/KiCad.app/Contents/SharedSupport/footprints'
NAME='harmony-mark6-carrier'
b=p.BOARD();b.SetCopperLayerCount(4)
b.SetFileName(str(HERE/(NAME+'.kicad_pcb')))
def v(x,y):return p.VECTOR2I(p.FromMM(float(x)),p.FromMM(float(y)))
def mm(z):return p.ToMM(z)
settings=b.GetDesignSettings()
settings.SetBoardThickness(p.FromMM(1.6))
settings.m_MinClearance=p.FromMM(.2)
settings.m_TrackMinWidth=p.FromMM(.2)
settings.m_ViasMinSize=p.FromMM(.6)
settings.m_MinThroughDrill=p.FromMM(.25)
settings.m_CopperEdgeClearance=p.FromMM(.3)
# Shape leaves the upper left battery volume empty and the antenna overhanging.
outline=[(40,6),(70,6),(70,138.5),(32,138.5),(32,148),(51.5,148),(51.5,154),
         (47.5,154),(47.5,169.5),(51.5,169.5),(51.5,175),(4,175),(4,94),(40,94)]
for a,z in zip(outline,outline[1:]+outline[:1]):
 e=p.PCB_SHAPE();e.SetShape(p.SHAPE_T_SEGMENT);e.SetStart(v(*a));e.SetEnd(v(*z));e.SetLayer(p.Edge_Cuts);e.SetWidth(p.FromMM(.05));b.Add(e)
root=ET.parse(HERE/'netlist.xml')
nets={};pin_nets={}
for n in root.findall('./nets/net'):
 name=n.get('name').removeprefix('/')
 if name.startswith('unconnected-'):continue
 net=p.NETINFO_ITEM(b,name);b.Add(net);nets[name]=net
 for node in n.findall('node'):pin_nets[node.get('ref'),node.get('pin')]=name
manifest={c['ref']:c for c in json.loads((HERE/'connections.json').read_text())['components']}
placements={
 'J4':(61,24,90),'J3':(54,52,180),'J5':(34,98,180),
 'U1':(52,72,0),'L1':(57,71.75,0),'C1':(48,70.5,90),'C2':(61,76,0),'C3':(48,75,90),
 'F1':(46,86,90),'R20':(16,164,0),'R21':(16,160,0),
 'R1':(24,164,0),'R2':(24,161,0),'R3':(49,34,0),'R4':(24,158,0),'R16':(16,157,0),
 'R5':(30,146,0),'R6':(30,143,0),'R7':(26,146,0),'R8':(26,143,0),'R9':(22,146,0),'R10':(22,143,0),
 'R11':(49,19,0),'R12':(49,22,0),'R13':(49,25,0),'R14':(49,28,0),'R15':(49,31,0),
 'C4':(58,36,0),'C5':(62,36,0),'C6':(62,57,0),'C7':(62,61,0),
 'R17':(44,59,90),'R18':(48,59,90),'R19':(52,59,90),
 'TP1':(44,105,0),'TP2':(44,110,0),'TP3':(44,115,0),'TP4':(44,120,0),'TP5':(44,125,0)
}
# Top-facing socket coordinates match top-view Feather pads, never mirror.
headers=json.loads((HERE/'reference/feather-v2-header-pins.json').read_text())['pins']
for ref,head,ang in [('J1','JP1',-90),('J2','JP3',90)]:
 pin=next(x for x in headers if x['header']==head and x['pin']==1)
 placements[ref]=(5.5+pin['eagle_x_mm'],150.73+22.86-pin['eagle_y_mm'],ang)
fps={}
for c in root.findall('./components/comp'):
 ref=c.get('ref');fpname=c.findtext('footprint')
 if not fpname:continue
 lib,name=fpname.split(':',1)
 fp=p.FootprintLoad(str(LIB/(lib+'.pretty')),name)
 fp.SetReference(ref);fp.SetValue(c.findtext('value'));fp.SetFPID(p.LIB_ID(lib,name))
 # Match schematic UUID so subsequent KiCad updates preserve placements.
 sheet=c.find('sheetpath');stamp=c.findtext('tstamps')
 if stamp and sheet is not None:fp.SetPath(p.KIID_PATH(sheet.get('tstamps')+stamp))
 x,y,angle=placements[ref]
 fp.SetPosition(v(x,y));fp.SetOrientationDegrees(angle)
 fp.Reference().SetTextSize(v(.85,.85));fp.Reference().SetTextThickness(p.FromMM(.13))
 fp.Value().SetVisible(False)
 for pad in fp.Pads():
  name=pin_nets.get((ref,pad.GetNumber()))
  if name:pad.SetNet(nets[name])
 b.Add(fp);fps[ref]=fp
# Independent physical pin mapping checks catch rotated/mirrored socket errors.
for h in headers:
 ref='J1' if h['header']=='JP1' else 'J2'
 pad=fps[ref].FindPadByNumber(str(h['pin']));pos=pad.GetPosition()
 expected=v(5.5+h['eagle_x_mm'],150.73+22.86-h['eagle_y_mm'])
 assert abs(pos.x-expected.x)<5 and abs(pos.y-expected.y)<5,(ref,h['pin'],pos,expected)
# Mounting holes: four carrier-to-shell and four 12mm ANO standoffs.
holes=[(44,10,2.7),(66,90,2.7),(8,98,2.7),(8,144,2.7),
       (19.22,105.54,2.7),(54.78,105.54,2.7),(19.22,136.02,2.7),(54.78,136.02,2.7)]
for i,(x,y,d) in enumerate(holes,1):
 fp=p.FootprintLoad(str(LIB/'MountingHole.pretty'),'MountingHole_2.7mm_M2.5')
 fp.SetReference('H'+str(i));fp.SetPosition(v(x,y));fp.Value().SetVisible(False)
 fp.Reference().SetTextSize(v(.8,.8));fp.Reference().SetPosition(v(x+4,y));b.Add(fp)
# Factory fiducials on exposed upper and lower portions.
for i,(x,y) in enumerate([(43,15),(66,83),(8,138)],1):
 fp=p.FootprintLoad(str(LIB/'Fiducial.pretty'),'Fiducial_1mm_Mask2mm')
 fp.SetReference('FID'+str(i));fp.SetPosition(v(x,y));fp.Value().SetVisible(False);b.Add(fp)
def text(s,x,y,size=1.2,layer=p.F_SilkS):
 t=p.PCB_TEXT(b);t.SetText(s);t.SetPosition(v(x,y));t.SetTextSize(v(size,size));t.SetTextThickness(p.FromMM(.15));t.SetLayer(layer);b.Add(t)
text('HARMONY M6 / A',55,42)
text('USB ONLY',53,45)
text('SD >',65,14,1)
text('TFT / BLUE UP',54,64,1)
text('QT / ANO',34,102,1)
text('Feather #5900\nUSB <',15,151,1)
text('ANTENNA\nNO METAL',60,162,1,p.Dwgs_User)
for ref,label in [('TP1','5V'),('TP2','MCU'),('TP3','3V3'),('TP4','GND'),('TP5','PG')]:
 x,y,_=placements[ref];text(label,x+4,y,.85)
# Show module envelopes on an assembly-only layer.
for x,y,w,h in [(5.5,150.73,50.8,22.86),(6.5,4,61.0111908,92.4468164),(16.68,103,40.64,35.56)]:
 e=p.PCB_SHAPE();e.SetShape(p.SHAPE_T_RECT);e.SetStart(v(x,y));e.SetEnd(v(x+w,y+h));e.SetLayer(p.Dwgs_User);e.SetWidth(p.FromMM(.1));b.Add(e)

def padpos(ref,num):return fps[ref].FindPadByNumber(str(num)).GetPosition()
def xy(pt):return (mm(pt.x),mm(pt.y))
def track(net,points,width=.3,layer=p.F_Cu):
 for a,z in zip(points,points[1:]):
  t=p.PCB_TRACK(b);t.SetStart(v(*a));t.SetEnd(v(*z));t.SetWidth(p.FromMM(width));t.SetLayer(layer);t.SetNet(nets[net]);t.SetLocked(True);b.Add(t)
# Local converter conductors: very short SW loop and separate output sense.
track('BUCK_SW',[xy(padpos('U1',7)),xy(padpos('L1',1))],.35)
track('PERIPH_3V3',[xy(padpos('L1',2)),(59.8,71.75),(59.8,76),xy(padpos('C2',1))],.6)
track('PERIPH_3V3',[xy(padpos('U1',6)),(54,72.25),(54,76),xy(padpos('C2',1))],.2)
track('USB_PROTECTED',[xy(padpos('C1',1)),(48,71.75),xy(padpos('U1',2))],.25)
track('GND',[xy(padpos('U1',1)),(50.4,71.25),(50.4,69.025),xy(padpos('C1',2))],.3)
track('GND',[xy(padpos('U1',4)),(51.05,73.35),(52.95,73.35),xy(padpos('U1',5))],.2)
# Planes are added after routing; retain geometry and exact pin audit now.
p.SaveBoard(str(HERE/(NAME+'.kicad_pcb')),b)
# Fabrication finish metadata; dimensions/stackup remain supplier-reviewed.
board_path=HERE/(NAME+'.kicad_pcb')
board_text=board_path.read_text()
if '(stackup' not in board_text:
 board_path.write_text(board_text.replace('\t(setup\n','\t(setup\n\t\t(stackup (copper_finish \"ENIG\"))\n',1))
(HERE/'pcb-placement.json').write_text(json.dumps({'case':[74,178,28],'pcb_outline':outline,'board_z':[6.5,8.1],'placements':placements,'holes':holes,'header_coordinate_check':'28 of 28 vendor coordinates matched','status':'placed with locked local power routes; global routing pending'},indent=2)+'\n')
print('Placed',len(list(b.GetFootprints())),'footprints; verified all 28 Feather mating coordinates')
print('DSN export',p.ExportSpecctraDSN(b,str(HERE/'routing.dsn')))
