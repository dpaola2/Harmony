#!/usr/bin/env python3
from pathlib import Path
from io import BytesIO
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import Paragraph,Table,TableStyle
from reportlab.graphics import renderPDF
from svglib.svglib import svg2rlg
H=Path(__file__).resolve().parent;O=H/'output/pdf/design-review.pdf'
c=canvas.Canvas(str(O),pagesize=(612,792));c.setTitle('Harmony Mark-6 Rev A - design review')
ink=HexColor('#183246');blue=HexColor('#17698b');muted=HexColor('#566b77')
style=ParagraphStyle('body',fontName='Helvetica',fontSize=10,leading=14,textColor=ink)
def para(t,x,y,w=540,size=10):
 st=ParagraphStyle('p',parent=style,fontSize=size,leading=size*1.4);p=Paragraph(t,st);a,h=p.wrap(w,720);p.drawOn(c,x,y-h);return y-h

def head(title,n):
 c.setFillColor(blue);c.setFont('Helvetica-Bold',10);c.drawString(36,755,'HARMONY / MARK 6 / REV A')
 c.setFillColor(ink);c.setFont('Helvetica-Bold',23);c.drawString(36,720,title)
 c.setStrokeColor(HexColor('#d3dee4'));c.line(36,704,576,704)
 c.setFont('Helvetica',8);c.setFillColor(muted);c.drawString(36,24,'September 22, 2026 | Prototype review - not released for manufacture');c.drawRightString(576,24,str(n))
head('From size dummy to routed board',1)
para('Outside size accepted: <b>74 x 178 x 28 mm</b>. USB first; battery space reserved.',36,687)
c.drawImage(str(H/'output/mechanical/assembly-review.png'),51,235,width=510,height=425,mask='auto')
y=220
for t in ['<b>CAD checks passed.</b> Zero schematic ERC violations, zero PCB DRC violations and zero open connections. All 122 electrical PCB pads match the schematic; all 28 Feather mating positions match vendor CAD.', '<b>No hand soldering.</b> The supplier fits 36 carrier parts, including the sockets. The factory-headered Feather, EYESPI display and ANO controls plug in.', '<b>Remaining physical checks.</b> Exact display thickness, factory header insertion and cable/port access. Waveshare 29318 replaces #5846; US stock is listed. Physical module and cable fit remain unverified.']:
 y=para(t,36,y)-12
c.showPage()
head('Routed carrier and antenna cutout',2)
para('Four layers, 1.6 mm board. Top and back shown from the same top-view coordinates.',36,686)
for name,x in [('pcb-top.svg',45),('pcb-back.svg',325)]:
 raw=(H/'output'/name).read_text().replace('#F2EDA1','#183246').replace('#D0D2CD','#4B5563');d=svg2rlg(BytesIO(raw.encode()));scale=min(240/d.width,550/d.height);d.scale(scale,scale);renderPDF.draw(d,c,x,98)
c.setFillColor(ink);c.setFont('Helvetica-Bold',11);c.drawString(70,654,'TOP / COMPONENT SIDE');c.drawString(342,654,'BACK / THROUGH VIEW')
para('The antenna overhangs the carrier cutout. Ground pours stop outside its reserved halo; necessary header pads and traces remain nearby. Final in-case Bluetooth range still needs testing.',36,81,size=9)
c.showPage()
head('Assembly stack and release checks',3)
para('All heights below are measured from the rear outside surface toward the front.',36,686)
rows=[['Item','Height / Z range','Basis'],['Carrier PCB','6.5-8.1 mm','1.6 mm board'],['Socket body top','16.61 mm','Samtec SSW: 8.51 mm'],['Feather highest component','25.52 mm','Vendor STEP; nominal headers'],['ANO control front','27.47 mm','Vendor STEP; 12 mm spacers'],['Waveshare display','16.75-27.3 mm','Vendor STEP; 10.55 mm total'],['Future battery reservation','1.6-12.1 mm','Unconnected; no charger']]
t=Table(rows,colWidths=[185,120,235],rowHeights=27);t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),HexColor('#e3eef3')),('TEXTCOLOR',(0,0),(-1,-1),ink),('FONTNAME',(0,0),(-1,0),'Helvetica-Bold'),('FONTSIZE',(0,0),(-1,-1),9),('VALIGN',(0,0),(-1,-1),'MIDDLE'),('BOTTOMPADDING',(0,0),(-1,-1),8),('LINEBELOW',(0,0),(-1,-1),.4,HexColor('#d3dee4'))]));t.wrapOn(c,540,250);t.drawOn(c,36,464)
y=440
for title,body in [
 ('Power','TPS62162 with 2.2 uH and 22 uF / 16 V bulk capacitors. A 450 mA peripheral allowance plus the Feather gives about 618 mA from a 4.75 V source at assumed 85% converter efficiency. Use a known 5 V source with at least 1 A available for qualification. These are budgets, not measurements.'),
 ('Cables and case ports','100 mm EYESPI cable (#5239) and 50 mm QT-to-QT cable (#4399). The display FFC connector sits near the top, at X37/Y20.3. Reserve a loose cable loop above the future battery and use the upper ANO connector. Provide recessed USB plug access and a finger pocket for SD ejection.'),
 ('Before an order','Supplier DFM, exact part availability, header/socket fit and the display measurement remain. Vias inside SMT pads require resin filling and copper capping; the assembler must review U1 stencil coverage. Manufacturing files are supplied for review, with no order authorization.'),
 ('After assembly','Stage first power with current limiting and rail checks. Then test display refresh, SD and controls during A2DP playback, reconnect behavior, temperature and RF range. Complete the deferred full-album run before calling Mark 6 qualified.')]:
 y=para('<b>'+title+'</b><br/>'+body,36,y,size=9.5)-14
para('Detailed sources, exact BOM, tolerances and procedures are in the accompanying power-review.md and mechanical-review.md. The STEP assembly is a review model, not a finished hollow case.',36,75,size=8.5)
c.save();print(O)
