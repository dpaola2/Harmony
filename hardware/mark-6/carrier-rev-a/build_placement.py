#!/usr/bin/env python3
"""Print-scale mechanical study, not an enclosure or PCB fabrication drawing."""
from pathlib import Path
import json
import math
import xml.etree.ElementTree as ET
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import mm
from reportlab.lib.colors import HexColor, white
from mechanical_layout import layout
D = layout()

HERE=Path(__file__).resolve().parent
OUT=HERE/'output/pdf';OUT.mkdir(parents=True,exist_ok=True)
W,H=letter
C=canvas.Canvas(str(OUT/'placement-study.pdf'),pagesize=letter)
C.setTitle('Harmony Mark-6 - full-size placement study')
C.setAuthor('Harmony')
INK=HexColor('#172b3a');MUTED=HexColor('#566777');BLUE=HexColor('#146aa3')
TEAL=HexColor('#d9eee9');PALE=HexColor('#e5eff8');ORANGE=HexColor('#b75b18')

def label(x,y,s,size=8,color=INK):
    C.setFillColor(color);C.setFont('Helvetica',size);C.drawString(x*mm,H-y*mm,s)
def center(x,y,s,size=8,color=INK):
    C.setFillColor(color);C.setFont('Helvetica',size);C.drawCentredString(x*mm,H-y*mm,s)
def rect(x,y,w,h,fill=None,stroke=INK,r=0,dash=None):
    C.setStrokeColor(stroke);C.setFillColor(fill or white);C.setLineWidth(.6)
    C.setDash(dash or [])
    args=(x*mm,H-(y+h)*mm,w*mm,h*mm)
    if r:C.roundRect(*args,r*mm,stroke=1,fill=int(fill is not None))
    else:C.rect(*args,stroke=1,fill=int(fill is not None))
    C.setDash([])
def line(x1,y1,x2,y2,color=INK):
    C.setStrokeColor(color);C.setLineWidth(.5);C.line(x1*mm,H-y1*mm,x2*mm,H-y2*mm)
def circle(x,y,r,fill=None,stroke=INK):
    C.setFillColor(fill or white);C.setStrokeColor(stroke);C.circle(x*mm,H-y*mm,r*mm,stroke=1,fill=int(fill is not None))
def title(num,headline,sub):
    label(16,16,'HARMONY / MARK 6',10,BLUE);label(16,25,headline,17)
    label(16,32,sub,8.5,MUTED)
    label(16,269,'Placement B  |  21 September 2026  |  Print at Actual Size / 100%; disable Fit.',8,MUTED)
    label(195,269,str(num),8,MUTED)
def scale(x,y):
    line(x,y,x+50,y)
    for k in range(6):line(x+10*k,y-1,x+10*k,y+1)
    center(x+25,y+5,'50 mm: check with a ruler',8,MUTED)
def display(x,y,annotate=True):
    # Mechanical outline comes directly from Adafruit's board, including tabs.
    root=ET.parse(HERE/'reference/Adafruit 3.5 inch 480x320 Capacitive Touch Display.brd')
    C.setStrokeColor(BLUE);C.setLineWidth(.6)
    for e in root.findall('.//board/plain/wire'):
        if e.get('layer')!='20':continue
        ax,ay,bx,by=[float(e.get(k)) for k in ['x1','y1','x2','y2']]
        pts=[(ax,ay),(bx,by)]
        angle=float(e.get('curve','0'))
        if angle:
            theta=math.radians(angle);dx,dy=bx-ax,by-ay
            mx,my=(ax+bx)/2,(ay+by)/2
            cx,cy=mx-dy/(2*math.tan(theta/2)),my+dx/(2*math.tan(theta/2))
            rad=math.hypot(ax-cx,ay-cy);start=math.atan2(ay-cy,ax-cx)
            pts=[(cx+rad*math.cos(start+theta*i/12),cy+rad*math.sin(start+theta*i/12)) for i in range(13)]
        p=C.beginPath()
        for i,(xx,yy) in enumerate(pts):
            px=(x+xx+33.02)*mm;py=H-(y+53.34-yy)*mm
            if i==0:p.moveTo(px,py)
            else:p.lineTo(px,py)
        C.drawPath(p)
    # Dashed active-area guide from the panel package in vendor CAD.
    rect(x+8.54,y+8.9,48.96,72.82,PALE,BLUE,r=.7)
    if annotate:
        center(x+33.02,y+44,'3.5-inch display',10,BLUE)
        center(x+33.02,y+50,'320 x 480, portrait',8,BLUE)
    center(x+33.02,y+90,'66.04 x 96.52 mm board',7.5,MUTED)
def controls(x,y):
    rect(x,y,40.64,35.56,None,BLUE,r=2.54)
    for radius in (17.2,16,11.45,4.05):circle(x+20.32,y+17.78,radius,white if radius==17.2 else None,BLUE)

def notes(x,y,heading,lines,color=BLUE):
    label(x,y,heading,9,color)
    for i,s in enumerate(lines):label(x,y+9+i*5.5,s,8)

title(1,'Smaller layout: full-size hand check','3.5-inch display, rotated ANO controls, and the selected factory-headered Feather.')
fx,fy=24,47
rect(fx,fy,74,178,None,INK,r=5)
display(fx+3.98,fy+4)
controls(fx+16.68,fy+103)
center(fx+37,fy+151,'HARMONY',10,BLUE)
center(fx+37,fy+166,'74 x 178 mm',8,MUTED)
line(fx,fy-5,fx+74,fy-5);center(fx+37,fy-7,'74 mm',9)
notes(116,52,'12 mm SHORTER',[
    'Previous complete study: 190 mm.',
    'This arrangement: 178 mm.',
    'Width remains 74 mm.',
    'Still a large player; try it in hand.'])
notes(116,91,'WHAT CHANGED',[
    'ANO board rotated 90 degrees.',
    'Antenna location taken from CAD.',
    'Feather moved closer to controls.',
    'USB connector faces the left side.'])
notes(116,130,'PRINTABLE SIZE DUMMY',[
    '74 x 178 x 28 mm overall.',
    'Print STL at 100%, flat back down.',
    'Screen and wheel are recessed cues.',
    'It has no electronics cavity.',
    'Depth and button feel are assumed.'])
notes(116,175,'CHECK BEFORE ROUTING',[
    'Pocket fit and thumb reach.',
    'Real socket and display heights.',
    'Cable bends and plug clearances.',
    'Carrier antenna cutout and RF.'],ORANGE)
scale(25,237)
label(24,254,'Paper and solid dummy check size only. Neither is a finished electronics enclosure.',8.5)
C.showPage()

title(2,'Planar placement and radio reservation','Front view; rear reservations overlap the display in projection. Z-stack is not validated.')
fx,fy=23,45
rect(fx,fy,74,178,None,INK,r=5)
display(fx+3.98,fy+4,False);controls(fx+16.68,fy+103)
rect(fx+4,fy+8,32,79,TEAL,HexColor('#377d6a'),r=1,dash=[3,2])
center(fx+20,fy+40,'BATTERY',9);center(fx+20,fy+46,'space behind',7.5);center(fx+20,fy+52,'the display',7.5)
for name,(x,y,w,h) in D['rear_reservations'].items():
    rect(fx+x,fy+y,w,h,TEAL,BLUE,dash=[2,2]);center(fx+x+w/2,fy+y+h/2+2,name,7,BLUE)
x,y,w,h=D['feather_board']
rect(fx+x,fy+y,w,h,TEAL,HexColor('#377d6a'),r=1)
center(fx+x+21,fy+y+12,'Feather V2',8)
# Only the actual vendor restrict rectangle and its full 15 mm halo are drawn.
ax,ay,bx,by=D['antenna_case_bounds']
rect(fx+ax,fy+ay,bx-ax,by-ay,PALE,ORANGE)
hx,hy,hr,hb=D['antenna_15mm_halo_bounds']
rect(fx+hx,fy+hy,hr-hx,hb-hy,None,ORANGE,dash=[4,2])
rect(fx+x-1.5,fy+y+7.5,3,7,None,INK,r=.5)
label(fx+1,fy+y-2,'USB-C faces left',6)
notes(112,51,'74 x 178 mm proposal',[
    'Feather board: 50.8 x 22.86 mm.',
    'Bottom margin: 4.41 mm.',
    'Controls-to-orange-zone gap: 2 mm.'])
notes(112,87,'ORANGE: 15 mm HALO',[
    'Based on vendor antenna rectangle:',
    '5.4 x 13.2 mm on the Feather.',
    'Other module boxes stay outside.',
    'Feather socket pads enter this zone.',
    'Carrier cutout/copper review remains.'],ORANGE)
notes(112,139,'THIS IS NOT AN RF PASS',[
    'Halo extends 5.76 mm below shell.',
    'Plastic and hand effects untested.',
    'The full 3-D clearance is unverified.',
    'Final range/throughput tests remain.'],ORANGE)
notes(112,184,'CABLE AND BATTERY SPACE',[
    'Use upper ANO QT connector;',
    'plug/bend volume still unmodeled.',
    'Reserve 32 x 79 x 10.5 mm for pack.',
    'USB first; no battery connection.'])
scale(112,237)
label(23,254,'Espressif recommends antenna overhang/clearance and testing in the final housing. See page 3.',8)
C.showPage()

title(3,'Dimensions, changes and limits','Placement B supersedes the earlier 74 x 190 mm conservative arrangement.')
rows=[('Display board','66.04 x 96.52 mm','Adafruit #5846 Eagle board outline'),('Display active-area guide','48.96 x 72.82 mm','Vendor package drawing; aperture not finalized'),('ANO board, rotated','40.64 x 35.56 mm','Same board turned 90 degrees; firmware directions must follow'),('ANO outer wheel guide','34.4 mm diameter','ENCODER_ANO vendor package circle; printed cue only'),('Feather board','50.8 x 22.86 mm','USB adds 1.5 mm on the left; port opening not designed'),('Antenna restrict rectangle','5.4 x 13.2 mm','Vendor X3 package, layer 41, transformed by R270'),('GlobTek battery body','31 x 78 x 9.3 mm','Reserved 32 x 79 x 10.5 mm; swelling allowance unqualified'),('Complete size dummy','74 x 178 x 28 mm','Proposed width/height; depth is provisional'),('Earlier complete study','74 x 190 mm','12 mm longer; oversized antenna proxy replaced')]
yy=47
for i,(name,dim,source) in enumerate(rows):
    if i%2==0:rect(16,yy-4,184,16,HexColor('#f0f5f8'),HexColor('#f0f5f8'))
    label(19,yy,name,9);label(108,yy,dim,9)
    label(19,yy+6,source,8,MUTED);yy+=18
label(16,216,'Source CAD and hashes: carrier-rev-a/reference/design-sources.json.',8.5)
label(16,225,'RF reference: Espressif ESP32 Hardware Design Guidelines, PCB Layout Design.',8.5)
C.linkURL('https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32/pcb-layout-design.html',(16*mm,H-229*mm,200*mm,H-218*mm),relative=0)
label(16,234,'Planar checks do not validate assembly depth, sockets, ribbon bends, thermal behavior or RF.',8)
label(16,243,'Carrier assembly still includes all sockets/connectors. No hand soldering is added.',8.5)
label(16,252,'Do not use this study as a drill, wiring, battery-harness or PCB manufacturing drawing.',8.5)
C.save()
(HERE/'placement.json').write_text(json.dumps(D,indent=2)+'\n')
print(OUT/'placement-study.pdf')
