#!/usr/bin/env python3
"""Check KiCad's exported netlist against connector and power requirements."""
import collections
import hashlib
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
LIB=REPO/'firmware/toolchains/kicad-8.0.9/KiCad.app/Contents/SharedSupport/footprints'
root=ET.parse(HERE/'netlist.xml')
pins={}
for net in root.findall('./nets/net'):
    for p in net.findall('node'):pins[p.get('ref'),p.get('pin')]=net.get('name').removeprefix('/')
def expect(ref,pad,net):
    actual=pins.get((ref,str(pad)))
    assert actual==net,(ref,pad,actual,net)
def unconnected(ref,pad):
    net=pins.get((ref,str(pad)))
    assert net is None or net.startswith('unconnected-'),(ref,pad,net)

# Physically significant assertions, independent of the generator manifest.
for pad,net in {4:'SD_MISO_MCU',5:'SD_MOSI_MCU',6:'SD_SCK_MCU',7:'TFT_LITE_MCU',10:'PERIPH_PG',11:'SD_CS_MCU',12:'TFT_CS_MCU',13:'GND',15:'MCU_3V3'}.items():expect('J1',pad,net)
for pad in [1,2,3,8,9,14,16]:unconnected('J1',pad)
for pad,net in {3:'USB_5V',6:'TFT_MOSI_MCU',7:'TFT_DC_MCU',9:'TFT_RST_MCU',10:'TFT_SCK_MCU',11:'I2C_SCL',12:'I2C_SDA'}.items():expect('J2',pad,net)
for pad in [1,2,4,5,8]:unconnected('J2',pad)
for pad,net in {1:'PERIPH_3V3',2:'TFT_LITE',3:'GND',4:'TFT_SCK',5:'TFT_MOSI',7:'TFT_DC',8:'TFT_RST',9:'TFT_CS',10:'DISPLAY_SD_CS','MP':'GND'}.items():expect('J3',pad,net)
for pad in [6,11,12,13,14,15,16,17,18]:unconnected('J3',pad)
for pad,net in {1:'SD_DAT2',2:'SD_CS',3:'SD_MOSI',4:'PERIPH_3V3',5:'SD_SCK',6:'GND',7:'SD_MISO',8:'SD_DAT1',11:'GND'}.items():expect('J4',pad,net)
unconnected('J4',9);unconnected('J4',10)
for pad,net in {1:'GND',2:'PERIPH_3V3',3:'I2C_SDA',4:'I2C_SCL','MP':'GND'}.items():expect('J5',pad,net)
for pad,net in {1:'GND',2:'USB_PROTECTED',3:'MCU_3V3',4:'GND',5:'GND',6:'PERIPH_3V3',7:'BUCK_SW',8:'PERIPH_PG',9:'GND'}.items():expect('U1',pad,net)
expect('L1',1,'BUCK_SW');expect('L1',2,'PERIPH_3V3')
expect('F1',1,'USB_5V');expect('F1',2,'USB_PROTECTED')
assert len({pins['J1','15'],pins['J3','1'],pins['J2','3'],pins['J1','13']})==4
assert all(pins['J3',str(p)]!=pins['J4',str(q)] for p,q in [(4,5),(5,3),(9,2)])

# Every electrical footprint pad must be represented in its schematic symbol.
defs={p.get('part'):{pin.get('num') for pin in p.findall('./pins/pin')} for p in root.findall('./libparts/libpart')}
footprints=[]
for c in root.findall('./components/comp'):
    ref=c.get('ref');fp=c.findtext('footprint')
    if not fp:continue
    library,name=fp.split(':',1);path=LIB/(library+'.pretty')/(name+'.kicad_mod')
    assert path.exists(),(ref,'missing footprint',str(path))
    numbers={p for p in re.findall(r'\(pad\s+"([^"]*)"',path.read_text()) if p}
    sp=defs[c.find('libsource').get('part')]
    assert numbers==sp,(ref,'pad mismatch',numbers^sp)
    footprints.append({'ref':ref,'footprint':fp,'unique_pad_count':len(numbers)})

erc=json.loads((HERE/'erc.json').read_text())
violations=[v for s in erc['sheets'] for v in s['violations']]
assert not violations,violations
report={'status':'PASS - schematic checks only','erc_violations':len(violations),'checks':['Feather header mapping and reserved pins','Separate storage/display signal nets','EYESPI pin numbering and unused pins','microSD card pins, detect contacts and shield','STEMMA QT power/SDA/SCL order','TPS62162 power/feedback/ground mapping','USB, MCU 3V3, peripheral 3V3 and GND are distinct nets','All selected footprint electrical pad sets match symbols'],'footprints':footprints,'limitations':['PCB routing/DRC covered separately by pcb-verification.json','No physical polarity, load, thermal, signal-integrity or RF qualification','Connector contact orientation and full mechanical fit require review','GPIO electrical types are not modeled by passive Feather socket symbols; vendor mapping is checked explicitly'],'hashes':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [HERE/'harmony-mark6-carrier.kicad_sch',HERE/'netlist.xml',HERE/'Harmony.kicad_sym']}}
(HERE/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS:',len(footprints),'footprints; connector, bus and power assertions; 0 ERC violations')
