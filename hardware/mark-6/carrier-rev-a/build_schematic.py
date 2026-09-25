#!/usr/bin/env python3
"""Generate the editable USB-first carrier schematic and its connection manifest.

Custom connector symbols preserve vendor pin numbering. This is a schematic
draft, not a released PCB or firmware pin map. Run verify_schematic.py after
KiCad netlist export to check actual connectivity independently of rendering.
"""
import csv
import json
import uuid
from pathlib import Path

HERE = Path(__file__).resolve().parent
NAME = 'harmony-mark6-carrier'
ROOT = str(uuid.uuid5(uuid.NAMESPACE_URL, 'harmony/mark6/carrier/a'))
def uid(text): return str(uuid.uuid5(uuid.UUID(ROOT), text))
def q(text): return json.dumps(str(text))
def n(value): return f'{value:.4f}'.rstrip('0').rstrip('.')
def effect(size=1.0, extra=''): return f'(effects (font (size {size} {size})) {extra})'

symbols, items, components = {}, [], []

def block(name, pins):
    """pins: (pad, readable name, KiCad electrical type)."""
    half = (len(pins)-1)*1.27
    h = half+2.54
    body = f'(rectangle (start -7.62 {n(h)}) (end 17.78 {n(-h)}) (stroke (width 0.254) (type default)) (fill (type background)))'
    pp = []
    coords = {}
    for index, (pad, label, electrical) in enumerate(pins):
        y = half-index*2.54
        coords[str(pad)] = (-12.7, y, 0)
        pp.append(f'(pin {electrical} line (at -12.7 {n(y)} 0) (length 5.08) (name {q(label)} {effect()}) (number {q(pad)} {effect()}))')
    define(name, body, ''.join(pp), coords, h)

def define(name, graphics, pins, coords, height):
    definition = f'''(symbol {q(name)} (pin_names (offset 0.635)) (in_bom yes) (on_board yes)
      (property "Reference" "J" (at 0 {n(height+4)} 0) {effect()})
      (property "Value" {q(name)} (at 0 {n(height+2)} 0) {effect()})
      (symbol {q(name+'_0_1')} {graphics})
      (symbol {q(name+'_1_1')} {pins}))'''
    symbols[name] = (definition, coords, height)

def passive(name, kind):
    if kind == 'C':
        g = '(polyline (pts (xy -2.54 0.635) (xy 2.54 0.635)) (stroke (width 0.4) (type default)) (fill (type none))) (polyline (pts (xy -2.54 -0.635) (xy 2.54 -0.635)) (stroke (width 0.4) (type default)) (fill (type none)))'
        length = 4.445
    else:
        g = '(rectangle (start -1.27 2.54) (end 1.27 -2.54) (stroke (width 0.254) (type default)) (fill (type none)))'
        if kind == 'L':
            g += '(text "L" (at 0 0 0) (effects (font (size 1 1))))'
        if kind == 'F':
            g += '(polyline (pts (xy 0 2.54) (xy 0 -2.54)) (stroke (width 0.254) (type default)) (fill (type none)))'
        length = 2.54
    pins = ''.join(f'(pin passive line (at 0 {y} {angle}) (length {length}) (name "~" {effect()}) (number "{pad}" {effect()}))' for pad,y,angle in [(1,5.08,270),(2,-5.08,90)])
    define(name,g,pins,{'1':(0,5.08,270),'2':(0,-5.08,90)},5.08)

def add(ref, name, value, x, y, nets, footprint='', mpn='', note=''):
    definition, coords, height = symbols[name]
    x,y = round(x/2.54)*2.54, round(y/2.54)*2.54
    identifier=uid(ref)
    is_passive = name in ('R','C','L','Fuse')
    px,py = (x+5.08,y-1.27) if is_passive else (x+3,y-height-5.08)
    props = f'(property "Reference" {q(ref)} (at {n(px)} {n(py)} 0) {effect(1.27)}) (property "Value" {q(value)} (at {n(px)} {n(py+2.54)} 0) {effect(1.0)})'
    props += f'(property "Footprint" {q(footprint)} (at {n(x)} {n(y)} 0) {effect(1,"(hide yes)")}) (property "MPN" {q(mpn)} (at {n(x)} {n(y)} 0) {effect(1,"(hide yes)")})'
    items.append(f'(symbol (lib_id {q("Harmony:"+name)}) (at {n(x)} {n(y)} 0) (unit 1) (in_bom yes) (on_board yes) (dnp no) (uuid {q(identifier)}) {props} (instances (project {q(NAME)} (path {q("/"+ROOT)} (reference {q(ref)}) (unit 1)))))')
    assert set(nets) == set(coords), (ref, set(nets)^set(coords))
    for pad,(dx,dy,angle) in coords.items():
        net=nets[pad]; sx,sy=x+dx,y-dy
        if net is None:
            items.append(f'(no_connect (at {n(sx)} {n(sy)}) (uuid {q(uid(ref+pad+"NC"))}))')
            continue
        ex,ey = (sx-7.62,sy) if angle==0 else (sx,sy-5.08 if angle==270 else sy+5.08)
        items.append(f'(wire (pts (xy {n(sx)} {n(sy)}) (xy {n(ex)} {n(ey)})) (stroke (width 0) (type default)) (uuid {q(uid(ref+pad+"wire"))}))')
        justify='right bottom' if angle==0 else 'left bottom'
        items.append(f'(label {q(net)} (at {n(ex)} {n(ey)} 0) {effect(1.0,"(justify "+justify+")")} (uuid {q(uid(ref+pad+"label"))}))')
    components.append(dict(ref=ref,symbol=name,value=value,nets=nets,footprint=footprint,mpn=mpn,note=note))

def text(content,x,y,size=1.27):
    items.append(f'(text {q(content)} (at {n(x)} {n(y)} 0) {effect(size,"(justify left top)")} (uuid {q(uid(content))}))')

def resistor(ref,value,x,y,a,b):
    add(ref,'R',value,x,y,{'1':a,'2':b},'Resistor_SMD:R_0603_1608Metric',mpn={'100R':'RC0603FR-07100RL','47k':'RC0603FR-0747KL','10k':'RC0603FR-0710KL','100k':'RC0603FR-07100KL'}[value],note='Yageo RC series, 1%, 0.1W, 0603')
def cap(ref,value,x,y,rail):
    add(ref,'C',value,x,y,{'1':rail,'2':'GND'},'Capacitor_SMD:C_1210_3225Metric' if ref in ('C1','C2') else 'Capacitor_SMD:C_0805_2012Metric',mpn=('C3225X7R1C226M250AC' if ref in ('C1','C2') else 'C2012X7R1A106K125AC' if value=='10uF' else 'C0805C104K5RACTU'),note='X7R; C1/C2 22uF 16V +/-20% 1210, C4/C6 10uF 10V, 100nF 50V. See power-review.md for bias/temperature budget')

feather_a=['I37','TX_GPIO8','RX_GPIO7','MISO_GPIO21','MOSI_GPIO19','SCK_GPIO5','A5_GPIO4','A4_I36','A3_I39','A2_I34','A1_GPIO25','A0_GPIO26','GND','NC','3V3_OUT','RESET']
feather_b=['BAT','EN','USB_VBUS','GPIO13_LED','GPIO12_STRAP','GPIO27','GPIO33','GPIO15_STRAP','GPIO32','GPIO14','SCL_GPIO20','SDA_GPIO22']
block('Feather_16',[(str(i+1),s,'passive') for i,s in enumerate(feather_a)])
block('Feather_12',[(str(i+1),s,'passive') for i,s in enumerate(feather_b)])
block('EYESPI_18',[(str(i+1),s,'passive') for i,s in enumerate(['VIN','LITE','GND','SCK','MOSI','MISO','DC','RST','TFT_CS','SD_CS','MEM_CS','TS_CS','SCL','SDA','INT','BUSY','GPIO1','GPIO2'])] + [('MP','SHIELD','passive')])
block('MicroSD',[(str(i+1),s,'passive') for i,s in enumerate(['DAT2','DAT3_CS','CMD_MOSI','VDD','CLK','VSS','DAT0_MISO','DAT1','CD1','CD2','SHIELD'])])
block('STEMMA_QT',[(str(i+1),s,'passive') for i,s in enumerate(['GND','VCC','SDA','SCL'])]+[('MP','SHIELD','passive')])
block('TPS62162', [('2','VIN','power_in'),('3','EN','input'),('7','SW','power_out'),('6','VOS','input'),('5','FB','input'),('8','PG','open_collector'),('1','PGND','power_in'),('4','AGND','power_in'),('9','EP','power_in')])
for kind in ('R','C','L','Fuse'):passive(kind,kind[0])

text('HARMONY MARK-6 | USB-FIRST CARRIER | REV A DRAFT',15,12,2.54)
text('Review schematic. No battery connected. Separate SPI hosts. All carrier components and sockets to be factory assembled.',15,20)
text('FEATHER V2 #5900\nNumbering follows Adafruit vendor JP1 / JP3.',20,35,1.5)
aa={str(i):None for i in range(1,17)}
aa.update({'4':'SD_MISO_MCU','5':'SD_MOSI_MCU','6':'SD_SCK_MCU','7':'TFT_LITE_MCU','10':'PERIPH_PG','11':'SD_CS_MCU','12':'TFT_CS_MCU','13':'GND','15':'MCU_3V3'})
bb={str(i):None for i in range(1,13)}
bb.update({'3':'USB_5V','6':'TFT_MOSI_MCU','7':'TFT_DC_MCU','9':'TFT_RST_MCU','10':'TFT_SCK_MCU','11':'I2C_SCL','12':'I2C_SDA'})
add('J1','Feather_16','Feather JP1 socket',75,80,aa,'Connector_PinSocket_2.54mm:PinSocket_1x16_P2.54mm_Vertical',mpn='SSW-116-01-G-S',note='Factory-installed Samtec socket: 8.51mm body, 2.64mm solder tails; vendor top-view coordinates')
add('J2','Feather_12','Feather JP3 socket',75,155,bb,'Connector_PinSocket_2.54mm:PinSocket_1x12_P2.54mm_Vertical',mpn='SSW-112-01-G-S',note='Factory-installed Samtec socket: 8.51mm body, 2.64mm solder tails; vendor top-view coordinates')
text('JP1.14 is NOT a power pin. Leave open.\nBAT and EN are not connected on this USB-first carrier.\nGPIO5 keeps its normal high boot strap; SD CLK is an input.',20,190)

text('MICROSD | SPI3_HOST',180,35,1.5)
sd={'1':'SD_DAT2','2':'SD_CS','3':'SD_MOSI','4':'PERIPH_3V3','5':'SD_SCK','6':'GND','7':'SD_MISO','8':'SD_DAT1','9':None,'10':None,'11':'GND'}
add('J4','MicroSD','Dedicated microSD',235,80,sd,'Connector_Card:microSD_HC_Hirose_DM3AT-SF-PEJM5','DM3AT-SF-PEJM5',note='Pins 9/10 are unused card-detect contacts. Pin 11 is shield, including all four mounting tabs.')
for i,(signal,x) in enumerate([('SCK',185),('MOSI',220),('MISO',255),('CS',290)],1):
    resistor('R'+str(i),'100R',x,130,'SD_'+signal+'_MCU','SD_'+signal)
for i,(net,x) in enumerate([('SD_MOSI',185),('SD_MISO',220),('SD_CS',255),('SD_DAT1',290),('SD_DAT2',325)],11):
    resistor('R'+str(i),'47k',x,185,'PERIPH_3V3',net)
resistor('R16','47k',185,235,'MCU_3V3','SD_SCK_MCU')
cap('C4','10uF',225,235,'PERIPH_3V3');cap('C5','100nF',270,235,'PERIPH_3V3')
text('Pull up CMD and DAT0..3 in SPI mode.\nC4/C5 close to the socket; shield to ground.\nInitial SD clock: 4 MHz. Card-specific transients need measurement.',175,265)

text('3.5-INCH WAVESHARE 29318 / ST7796S | SPI2_HOST',365,35,1.5)
ee={str(i):None for i in range(1,19)}
ee.update({'1':'PERIPH_3V3','2':'TFT_LITE','3':'GND','4':'TFT_SCK','5':'TFT_MOSI','7':'TFT_DC','8':'TFT_RST','9':'TFT_CS','10':'DISPLAY_SD_CS','MP':'GND'})
add('J3','EYESPI_18','EYESPI ribbon',445,85,ee,'Connector_FFC-FPC:Hirose_FH12-18S-0.5SH_1x18-1MP_P0.50mm_Horizontal','FH12-18S-0.5SH(55)',note='Bottom contact, 0.3mm FPC, 0.5mm pitch; Adafruit #5239 A-B cable maps 1 to 1. Copper faces board; blue stiffener outward')
for i,(signal,x,y) in enumerate([('SCK',385,145),('MOSI',430,145),('CS',475,145),('DC',385,200),('RST',430,200),('LITE',475,200)],5):
    resistor('R'+str(i),'100R',x,y,'TFT_'+signal+'_MCU','TFT_'+signal)
resistor('R17','10k',385,255,'PERIPH_3V3','TFT_CS')
resistor('R18','10k',430,255,'PERIPH_3V3','TFT_RST')
resistor('R19','10k',475,255,'PERIPH_3V3','DISPLAY_SD_CS')
cap('C6','10uF',385,310,'PERIPH_3V3');cap('C7','100nF',430,310,'PERIPH_3V3')
text('Display SD slot stays empty and deselected. Touch unused.\nDisplay uses SPI; no jumper soldering required.\nEYESPI VIN = 3.3 V; leave display 15-pin connector unused.\nInitial display clock: 4 MHz; bounded refresh transfers.\nFPC: 0.5mm pitch, 18-way, 0.3mm, A-B pin1-to-pin1.',365,342)

text('USB POWER | SEPARATE PERIPHERAL REGULATOR',20,225,1.5)
add('F1','Fuse','0.75A hold PTC',35,250,{'1':'USB_5V','2':'USB_PROTECTED'},'Fuse:Fuse_1206_3216Metric',mpn='MF-NSMF075-2',note='Bourns 1206, 6V, 0.75A hold at 23C; 0.52A at 60C; 1.5A trip at 23C. Peripheral branch only; not GPIO protection')
add('U1','TPS62162','TPS62162DSGR / 3.3V',85,295,{'1':'GND','2':'USB_PROTECTED','3':'MCU_3V3','4':'GND','5':'GND','6':'PERIPH_3V3','7':'BUCK_SW','8':'PERIPH_PG','9':'GND'},'Package_SON:WSON-8-1EP_2x2mm_P0.5mm_EP0.9x1.6mm_ThermalVias','TPS62162DSGR')
add('L1','L','2.2uH',130,270,{'1':'BUCK_SW','2':'PERIPH_3V3'},'Inductor_SMD:L_Coilcraft_XxL4020','XFL4020-222MEC',note='2.2uH shielded; Coilcraft XFL4020 series. 4.0 x 4.0mm body, 2.2mm maximum height; shielded')
cap('C1','22uF',25,320,'USB_PROTECTED');cap('C2','22uF',130,320,'PERIPH_3V3');cap('C3','100nF',165,320,'USB_PROTECTED')
resistor('R20','100k',25,370,'MCU_3V3','PERIPH_PG')
resistor('R21','100k',80,370,'MCU_3V3','GND')
text('U1 EN follows Feather 3V3. PG goes to input-only GPIO34.\nKeep Feather 3V3 and PERIPH_3V3 separate. Common ground.\nF1 limits sustained faults; it cannot guarantee device survival.\nDesign allowance: 450mA peripheral load, pending measurement.\nUse a 5V USB source with >=1A available for full-load tests.',175,295)

text('CONTROLS | I2C',175,350,1.5)
add('J5','STEMMA_QT','ANO #6310 cable',235,380,{'1':'GND','2':'PERIPH_3V3','3':'I2C_SDA','4':'I2C_SCL','MP':'GND'},'Connector_JST:JST_SH_SM04B-SRSS-TB_1x04-1MP_P1.00mm_Horizontal','SM04B-SRSS-TB(LF)(SN)')
text('ANO has onboard I2C pullups. Poll buttons/encoder.\nUse a QT-to-QT cable; not the loose-wire cable.\nDo not connect the Feather QT power rail in parallel.',270,365)

# Accessible probe pads allow factory power checks without soldering wires.
block('TestPoint',[('1','PROBE','passive')])
for i,(net,x) in enumerate([('USB_5V',50),('MCU_3V3',135),('PERIPH_3V3',220),('GND',305),('PERIPH_PG',390)],1):
    add('TP'+str(i),'TestPoint',net,x,400,{'1':net},'TestPoint:TestPoint_Pad_D2.0mm',note='Bare PCB probe pad; no assembly component')

# Power flags describe external module supplies and the buck output after L1.
define('PowerFlag','(polyline (pts (xy 0 0) (xy 0 2.54) (xy -1.27 1.27) (xy 0 0) (xy 1.27 1.27) (xy 0 2.54)) (stroke (width 0.254) (type default)) (fill (type none)))',f'(pin power_out line (at 0 0 90) (length 0) (name "pwr" {effect()}) (number "1" {effect()}))',{'1':(0,0,90)},2.54)
for i,net in enumerate(['USB_5V','USB_PROTECTED','MCU_3V3','PERIPH_3V3','GND'],1):
    add('#FLG0'+str(i),'PowerFlag','PWR_FLAG',365+i*35,23,{'1':net})

lib='\n'.join(s[0] for s in symbols.values())
(HERE/'Harmony.kicad_sym').write_text('(kicad_symbol_lib (version 20231120) (generator "kicad_symbol_editor")\n'+lib+'\n)\n')
if not (HERE/(NAME+'.kicad_pro')).exists(): (HERE/(NAME+'.kicad_pro')).write_text('{}\n')
(HERE/'sym-lib-table').write_text('(sym_lib_table (version 7) (lib (name "Harmony") (type "KiCad") (uri "${KIPRJMOD}/Harmony.kicad_sym") (options "") (descr "Harmony Mark-6 draft symbols")))\n')
cache='\n'.join(s[0].replace('(symbol '+q(name), '(symbol '+q('Harmony:'+name),1) for name,s in symbols.items())
(HERE/(NAME+'.kicad_sch')).write_text(f'(kicad_sch (version 20231120) (generator "eeschema") (uuid {q(ROOT)}) (paper "A2") (title_block (title "Harmony Mark-6 USB carrier") (date "2026-09-21") (rev "A-DRAFT") (comment 1 "HARMONY-17 - schematic review only, not for manufacture")) (lib_symbols {cache})\n'+ '\n'.join(items)+'\n)\n')
(HERE/'connections.json').write_text(json.dumps({'status':'draft','power':'USB only; battery not connected','components':components},indent=2)+'\n')
with (HERE/'bom-draft.csv').open('w') as f:
    w=csv.DictWriter(f,fieldnames=['ref','value','mpn','footprint','note']);w.writeheader()
    for c in components:
        if not c['ref'].startswith('#'):w.writerow({k:c[k] for k in w.fieldnames})
print('Generated',len(components),'symbols in',HERE/(NAME+'.kicad_sch'))
