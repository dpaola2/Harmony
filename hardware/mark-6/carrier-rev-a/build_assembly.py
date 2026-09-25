#!/usr/bin/env python3
"""Mechanical review assembly. Display/battery/header blocks are reserved envelopes."""
from pathlib import Path
from display_model import load_display, DISPLAY_Z, FFC_CENTER
import json,hashlib
import cadquery as cq
H=Path(__file__).resolve().parent;O=H/'output/mechanical';O.mkdir(parents=True,exist_ok=True)
a=cq.Assembly(name='Harmony_M6_review')
parts=[]
def add(name,shape,color):
 a.add(shape,name=name,color=cq.Color(*color));parts.append((name,shape,color))
def box(x,y,z,w,h,t):return cq.Workplane('XY').box(w,h,t,centered=False).translate((x,-y-h,z)).val()
poly=[(40,6),(70.2,6),(70.2,138.5),(32.2,138.5),(32.2,148),(51.5,148),(51.5,154),(47.5,154),(47.5,169.5),(51.5,169.5),(51.5,175),(4,175),(4,93.8),(40,93.8)]
carrier=cq.Workplane('XY').polyline([(x,-y) for x,y in poly]).close().extrude(1.6).translate((0,0,6.5))
holes=json.loads((H/'pcb-placement.json').read_text())['holes']
for x,y,d in holes:carrier=carrier.cut(cq.Workplane('XY').center(x,-y).circle(d/2).extrude(12))
add('Carrier_1p6mm',carrier.val(),(.1,.45,.28))
feather=cq.importers.importStep(str(H/'reference/5400 ESP32 Feather V2.step')).val().translate((5.5,-173.59,19.15))
ano=cq.importers.importStep(str(H/'reference/5740 ANO Rotary Encoder QT.step')).val().rotate((0,0,0),(1,1,0),180).translate((37,-120.78,21.67))
add('Feather_vendor_model_no_headers',feather,(.15,.2,.25));add('ANO_vendor_model',ano,(.25,.3,.35))
add('Display_Waveshare_29318_vendor',load_display(),(.18,.48,.68))
add('Future_battery_reservation_NOT_CONNECTED',box(4,8,1.6,32,79,10.5),(.8,.65,.2))
add('JP1_socket_and_header_envelope',box(10.58,171.05,8.1,40.64,2.54,11.05),(.1,.1,.12))
add('JP3_socket_and_header_envelope',box(20.74,150.73,8.1,30.48,2.54,11.05),(.1,.1,.12))
for i,(x,y,d) in enumerate(holes[4:],1):
 s=cq.Workplane('XY').center(x,-y).circle(2.5).circle(1.35).extrude(12).translate((0,0,8.1)).val()
 add('ANO_standoff_'+str(i),s,(.75,.75,.7))
a.save(str(O/'harmony-mark6-assembly-review.step'))
# Test meaningful independent clearances using vendor solids; reserved envelopes are not certified dimensions.
checks={}
for n1,n2 in [('Carrier_1p6mm','Feather_vendor_model_no_headers'),('Carrier_1p6mm','ANO_vendor_model'),('Future_battery_reservation_NOT_CONNECTED','Display_Waveshare_29318_vendor'),('ANO_vendor_model','Feather_vendor_model_no_headers')]:
 s1=next(s for n,s,c in parts if n==n1);s2=next(s for n,s,c in parts if n==n2)
 checks[n1+' / '+n2]=s1.intersect(s2).Volume()
assert all(x<1e-5 for x in checks.values())
report={'status':'nominal stack review; physical fit unverified','case_mm':[74,178,28],'carrier_z_mm':[6.5,8.1],'feather_z_mm':[19.15,25.52],'ano_board_z_mm':[20.1,21.67],'ano_front_max_z_mm':27.47,'display_envelope_z_mm':DISPLAY_Z,'display_vendor_step_thickness_mm':10.55048,'battery_reserved_z_mm':[1.6,12.1],'feather_front_wall_nominal_gap_mm':.88,'display_battery_nominal_gap_mm':4.64952,'intersection_volume_mm3':checks,'eyespi_display_center_case_xy_mm':FFC_CENTER,'eyespi_carrier_center_case_xy_mm':[54,52],'eyespi_cable':'Adafruit 5239 100mm; reserve loop above battery; no sharp crease','qt_cable':'Adafruit 4399 50mm to upper ANO connector','limits':['Waveshare STEP thickness 10.55048mm exceeds published 10.31mm drawing; physical tolerance/fit still required','Factory header body height assumed 2.54mm; insertion fit/tolerance must be checked','STEP does not model actual cable bending or a final hollow shell','Antenna has carrier cutout; unavoidable socket copper remains inside 15mm halo']}
(O/'mechanical-checks.json').write_text(json.dumps(report,indent=2)+'\n')
for n,s,c in parts:cq.exporters.export(s,str(O/(n+'.stl')),tolerance=.15,angularTolerance=.2)
# Render real tessellated solids, plus a transparent display envelope.
import vtk
ren=vtk.vtkRenderer();ren.SetBackground(.96,.97,.985)
for n,s,c in parts:
 r=vtk.vtkSTLReader();r.SetFileName(str(O/(n+'.stl')));m=vtk.vtkPolyDataMapper();m.SetInputConnection(r.GetOutputPort());act=vtk.vtkActor();act.SetMapper(m);act.GetProperty().SetColor(*c)
 if n.startswith('Display'):act.GetProperty().SetOpacity(.23)
 ren.AddActor(act)
cam=ren.GetActiveCamera();cam.SetPosition(245,-325,330);cam.SetFocalPoint(37,-90,14);cam.SetViewUp(0,1,0);cam.ParallelProjectionOn();cam.SetParallelScale(108)
for x,y,t,size in [(45,945,'HARMONY / MARK 6',22),(45,908,'Component stack review',30),(45,874,'74 x 178 x 28 mm | Waveshare 29318 vendor model',17),(45,30,'Actual vendor Feather, display and ANO models. Cable paths and final housing need physical fit checks.',16)]:
 t1=vtk.vtkTextActor();t1.SetInput(t);t1.SetPosition(x,y);t1.GetTextProperty().SetFontSize(size);t1.GetTextProperty().SetColor(.1,.2,.3);ren.AddActor2D(t1)
w=vtk.vtkRenderWindow();w.SetOffScreenRendering(1);w.AddRenderer(ren);w.SetSize(1200,1000);w.SetMultiSamples(8);w.Render();cap=vtk.vtkWindowToImageFilter();cap.SetInput(w);cap.Update();wr=vtk.vtkPNGWriter();wr.SetFileName(str(O/'assembly-review.png'));wr.SetInputConnection(cap.GetOutputPort());wr.Write();w.Finalize()
print(json.dumps(report,indent=2))
