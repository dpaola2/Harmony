"""Check exported schematic, board, vendor header positions and firmware mapping."""
from design import *
import xml.etree.ElementTree as E,re,hashlib
import pcbnew as p,wx
app=wx.App(False)
b=p.LoadBoard(str(HERE/(NAME+'.kicad_pcb')));fps={f.GetReference():f for f in b.GetFootprints()}
nets={}
for n in E.parse(HERE/'netlist.xml').findall('./nets/net'):
 name=n.get('name').removeprefix('/')
 if name.startswith('unconnected-'):continue
 for node in n.findall('node'):nets[node.get('ref'),node.get('pin')]=name
for f in b.GetFootprints():
 for a in f.Pads():assert a.GetNetname()==nets.get((f.GetReference(),a.GetNumber()),''),(f.GetReference(),a.GetNumber(),a.GetNetname())
for h in headers:
 a=fps['J1' if h['header']=='JP1' else 'J2'].FindPadByNumber(str(h['pin']));xy=a.GetPosition();expected=position(h)
 assert max(abs(p.ToMM(xy.x)-expected[0]),abs(p.ToMM(xy.y)-expected[1]))<.00001
# Independent physical pad-to-firmware signal expectations.
expected={'CARRIER_SD_MISO':('J1','4','MISO'),'CARRIER_SD_CS':('J1','11','SD_CS'),'CARRIER_TFT_SCK':('J2','10','SCK'),'CARRIER_TFT_MOSI':('J2','6','MOSI'),'CARRIER_TFT_CS':('J1','12','TFT_CS'),'CARRIER_TFT_DC':('J2','7','DC'),'CARRIER_TFT_RST':('J2','9','TFT_RST'),'CARRIER_TFT_LITE':('J1','7','LITE')}
fw=(REPO/'firmware/mark-7/pocket-player/components/carrier_board/carrier_pins.h').read_text();gpio_by_net={net:g for _,_,net,_,_,_,g in wires}
for symbol,(ref,pin_num,net) in expected.items():
 assert fps[ref].FindPadByNumber(pin_num).GetNetname()==net
 assert int(re.search(r'#define '+symbol+r' (\d+)',fw).group(1))==gpio_by_net[net]
assert fps['J1'].FindPadByNumber('15').GetNetname()=='3V3';assert fps['J1'].FindPadByNumber('13').GetNetname()=='GND'
assert fps['J1'].FindPadByNumber('16').GetNetname()=='' # Do not reset the Feather with display reset.
for pin_num in ('5','6'):assert fps['J1'].FindPadByNumber(pin_num).GetNetname()=='' # Native SPI unused.
drc=json.loads((HERE/'drc.json').read_text());assert not drc['violations'] and not drc['unconnected_items']
erc=json.loads((HERE/'erc.json').read_text());assert all(not s['violations'] for s in erc['sheets'])
report={'status':'CAD electrical verification passes; not a manufacturing release','header_positions_checked':28,'matched_net_pads':len(nets),'drc_violations':0,'unconnected':0,'erc_violations':0,'firmware_gpio_routes_checked':8,'footprints':len(fps),'layers':b.GetCopperLayerCount(),'limits':['Physical socket/header fit pending','Signal integrity and RF range not qualified','Unpowered dummy test required before PCB purchase'],'sha256':{f:hashlib.sha256((HERE/f).read_bytes()).hexdigest() for f in [NAME+'.kicad_pcb',NAME+'.kicad_sch','netlist.xml']}}
(HERE/'verification.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
