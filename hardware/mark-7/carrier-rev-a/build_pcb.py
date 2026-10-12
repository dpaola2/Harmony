"""Build routed two-layer passive carrier with vendor-derived socket positions."""
from design import *
import pcbnew as p,wx
import xml.etree.ElementTree as E
app=wx.App(False)
b=p.BOARD();b.SetCopperLayerCount(2);b.SetFileName(str(HERE/(NAME+'.kicad_pcb')))
def v(x,y):return p.VECTOR2I(p.FromMM(x),p.FromMM(y))
s=b.GetDesignSettings();s.SetBoardThickness(p.FromMM(1.6));s.m_MinClearance=p.FromMM(.2);s.m_TrackMinWidth=p.FromMM(.25);s.m_CopperEdgeClearance=p.FromMM(.3)
nets={}
for n in sorted(set(netmap.values())):
 ni=p.NETINFO_ITEM(b,n);b.Add(ni);nets[n]=ni
for a,z in zip(outline,outline[1:]+outline[:1]):
 e=p.PCB_SHAPE();e.SetShape(p.SHAPE_T_SEGMENT);e.SetStart(v(*a));e.SetEnd(v(*z));e.SetLayer(p.Edge_Cuts);e.SetWidth(p.FromMM(.05));b.Add(e)
lib=HERE/'Harmony.pretty';lib.mkdir(exist_ok=True)
fps={}
def footprint(ref,value,name,origin,pads):
 f=p.FOOTPRINT(b);f.SetReference(ref);f.SetValue(value);f.SetFPID(p.LIB_ID('Harmony',name));f.SetAttributes(p.FP_THROUGH_HOLE)
 for num,x,y,net,diam,drill,npth in pads:
  a=p.PAD(f);a.SetNumber(str(num));a.SetShape(p.PAD_SHAPE_CIRCLE);a.SetAttribute(p.PAD_ATTRIB_NPTH if npth else p.PAD_ATTRIB_PTH);a.SetSize(v(diam,diam));a.SetDrillSize(v(drill,drill));layers=p.LSET.AllCuMask();layers.AddLayer(p.F_Mask);layers.AddLayer(p.B_Mask);a.SetLayerSet(layers);a.SetPosition(v(x-origin[0],y-origin[1]));
  if net:a.SetNet(nets[net])
  f.Add(a)
 f.Reference().SetVisible(False);f.Value().SetVisible(False);f.SetPosition(v(*origin));b.Add(f);fps[ref]=f
 return f
for ref,head in [('J1','JP1'),('J2','JP3')]:
 hs=[h for h in headers if h['header']==head];origin=position(hs[0]);footprint(ref,head,'Feather_'+head,origin,[(h['pin'],*position(h),netmap.get((head,h['pin'])),1.8,1.0,False) for h in hs])
def track(a,z,net,layer=p.F_Cu,width=.3):
 t=p.PCB_TRACK(b);t.SetStart(v(*a));t.SetEnd(v(*z));t.SetWidth(p.FromMM(width));t.SetLayer(layer);t.SetNet(nets[net]);b.Add(t)
def text(txt,x,y,size=.8,angle=0):
 t=p.PCB_TEXT(b);t.SetText(txt);t.SetPosition(v(x,y));t.SetTextSize(v(size,size));t.SetTextThickness(p.FromMM(.15));t.SetLayer(p.F_SilkS);t.SetTextAngle(p.EDA_ANGLE(angle,p.DEGREES_T));b.Add(t)
for ref,label,net,head,num,y,gpio in wires:
 src=position(pin(head,num));dst=(src[0],y);footprint(ref,label,'WirePad',dst,[('1',*dst,net,2,1,False)]);track(src,dst,net,width=.5 if net in ('3V3','GND') else .3);text(label.replace('TFT_','').replace('ANO_','').replace('SD_CS','SDCS'),dst[0],y-3 if y>90 else y+1.9,.8,90 if y>90 else 0)
# Through-hole optional wake pull-up: 7.62 mm pitch, no extra assembly technology.
a=(position(pin('JP1',13))[0],87.5);z=(a[0]-7.62,a[1]);footprint('R1','10k optional','R_Axial_P7.62',a,[('1',*a,'3V3',1.8,.8,False),('2',*z,'ANO_INT',1.8,.8,False)])
track(z,(z[0],94.5),'ANO_INT');track(a,(position(pin('JP1',15))[0],87.5),'3V3',p.B_Cu,.5);track((position(pin('JP1',15))[0],87.5),(position(pin('JP1',15))[0],94.5),'3V3',p.B_Cu,.5)
for i,xy in enumerate(mounts,1):footprint('H'+str(i),'M2 mount','Mount',xy,[('',*xy,None,2.4,2.4,True)])
for i,xy in enumerate(ties,1):footprint('S'+str(i),'Cable tie','Tie',xy,[('',*xy,None,2,2,True)])
text('MARK 7 CARRIER A',35,82.8,1);text('10k / INT optional',40,85.8,.8);text('USB >',55,89,.8);text('3V3',57,94,.8,90)
# Two ground pours with an explicit substrate cutout beneath the vendor antenna.
for layer in (p.F_Cu,p.B_Cu):
 zone=p.ZONE(b);zone.SetLayer(layer);zone.SetNet(nets['GND']);zone.SetLocalClearance(p.FromMM(.25));zone.SetThermalReliefGap(p.FromMM(.25));zone.SetThermalReliefSpokeWidth(p.FromMM(.3));zone.SetMinThickness(p.FromMM(.2));poly=zone.Outline();poly.NewOutline()
 for x,y in outline:poly.Append(p.FromMM(x),p.FromMM(y))
 b.Add(zone)
for c in E.parse(HERE/'netlist.xml').findall('./components/comp'):
 f=fps[c.get('ref')]; f.SetPath(p.KIID_PATH(c.find('sheetpath').get('tstamps')+c.findtext('tstamps'))); f.SetValue(c.findtext('value'))
p.SaveBoard(str(HERE/(NAME+'.kicad_pcb')),b);b=p.LoadBoard(str(HERE/(NAME+'.kicad_pcb')));b.BuildConnectivity();p.ZONE_FILLER(b).Fill(b.Zones());p.SaveBoard(str(HERE/(NAME+'.kicad_pcb')),b)
(HERE/'fp-lib-table').write_text('(fp_lib_table (version 7) (lib (name "Harmony") (type "KiCad") (uri "${KIPRJMOD}/Harmony.pretty") (options "") (descr "Mark 7 carrier footprints")))\n')
print('Saved',len(list(b.GetFootprints())),'footprints',len(list(b.GetTracks())),'tracks')

plugin=p.PCB_IO_KICAD_SEXPR()
for f in b.GetFootprints():
 plugin.FootprintSave(str(lib),f)
