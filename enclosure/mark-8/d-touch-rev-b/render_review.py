"""Render actual CAD meshes. Exploded offsets are illustrative, not assembly dimensions."""
from pathlib import Path
import json, vtk, math
R=Path(__file__).resolve().parent
colors={'base':(.20,.23,.25),'lid':(.29,.32,.34),'display':(.10,.32,.48),'feather':(.08,.5,.34),'battery':(.55,.61,.66),'touch':(.78,.38,.14),'hardware':(.72,.57,.28),'cables':(.76,.42,.12),'usb':(.23,.25,.3)}
def label(r,s,x,y,size=28,color=(.12,.17,.2)):
 t=vtk.vtkTextActor();t.SetInput(s);t.SetPosition(x,y);t.GetTextProperty().SetFontSize(size);t.GetTextProperty().SetColor(*color);r.AddActor2D(t)
def off(n,g,exploded):
 if not exploded:return 0
 if n.startswith('closure-screw'):return 265
 if n.startswith('brass'):return 12
 if n.startswith('lcd-screw'):return 142
 if n.startswith('lcd-clip-spacer'):return 155
 if n.startswith('lcd-clip'):return 168
 if n=='waveshare-vendor-module':return 190
 if n.startswith('electrode'):return 237
 if n=='sloped-face':return 250
 if n.startswith('feather-front-screw'):return 130
 if n.startswith('display-socket'):return 76
 if n.startswith('wire-bend'):return 76
 if n.startswith(('battery-plug','qt-plug')):return 106
 if n.startswith('usb-'):return 106
 if n=='feather-vendor-board':return 106
 if n=='battery-cover' or n.startswith('cover-screw'):return 75 if n=='battery-cover' else 88
 if n=='battery-envelope':return 35
 if n.startswith('battery-cushion'):return 18
 if n.startswith('touch-screw'):return 82
 if n.startswith('touch-board-spacer'):return 73
 if n.startswith('mpr121'):return 65
 if n.startswith('guide-screw'):return 22
 if n.startswith('cable-clamp'):return 15
 return 0

def render(name,exploded):
 win=vtk.vtkRenderWindow();win.SetOffScreenRendering(1);win.SetSize(4800,4000);win.SetMultiSamples(8)
 r=vtk.vtkRenderer();r.SetBackground(.96,.96,.945);win.AddRenderer(r)
 groups=json.loads((R/'assembly-groups.json').read_text())
 for n,g in groups.items():
  if not exploded and n.startswith('usb-metal'):continue
  rd=vtk.vtkSTLReader();rd.SetFileName(str(R/'preview'/f'{n}.stl'));m=vtk.vtkPolyDataMapper();m.SetInputConnection(rd.GetOutputPort());ac=vtk.vtkActor();ac.SetMapper(m);ac.SetPosition(0,0,off(n,g,exploded));p=ac.GetProperty();p.SetColor(*colors[g]);p.SetInterpolationToPhong();p.SetSpecular(.12)
  if n=='sloped-face' and not exploded:p.SetOpacity(.13)
  if n=='base-tray' and not exploded:p.SetOpacity(.24)
  if 'reserve' in n:p.SetOpacity(.25)
  if n=='mpr121-populated-reserve':p.SetOpacity(.25)
  if n=='battery-cover' and not exploded:p.SetOpacity(.4)
  r.AddActor(ac)
 cam=r.GetActiveCamera();cam.SetFocalPoint(56,47,180 if exploded else 40);cam.SetPosition(330,-390,360 if exploded else 330);cam.SetViewUp(0,0,1);cam.ParallelProjectionOn();cam.SetParallelScale(220 if exploded else 110);cam.SetWindowCenter(.31,0)
 label(r,'HARMONY D / REVISION B',150,3800,80)
 label(r,'EXPLODED ASSEMBLY / DIRECT PLUG-IN DISPLAY' if exploded else 'ASSEMBLED CLEARANCE STUDY / TRANSPARENT SHELL',154,3710,42)
 label(r,'112 W x 94 D mm | 44 mm front / 80 mm rear | 20.96 degree face',154,3640,32)
 items=[
 ('10  CLOSE THE CASE','4 x M2 x 8 machine screws\n4 x M2 x 10 brass standoffs\nM2 clearance holes: diameter 2.6 mm'),
 ('6  FACE AND TOUCH PADS','1.2 mm skin; 2 mm elsewhere\n5 pads: 12 x 14 mm, 18 mm pitch\nCopper and wires are not printed'),
 ('7  WAVESHARE DISPLAY','Vendor geometry: 92.45 x 61.01\nThickness: 10.55 mm\nScreen window: 74.45 x 49.97 mm'),
 ('8  RETAIN THE DISPLAY','4 printed clips; 4 x 2 mm spacers\n4 x M2 x 6 self-tapping screws\nDo not tighten against the glass'),
 ('3  UPRIGHT FEATHER','PCB underside: 29 mm above base\n2 actual mounting holes secure it\n2 rear pads support USB insertion'),
 ('9  CONNECT THE HARNESS','10 female sockets plug onto pins\n18 mm measured socket drop\nWire bend allowance: 5.5 mm'),
 ('5  BATTERY COVER','Printed cover, 4 x M2 x 6 screws\nCover underside: z = 12.5 mm\n1.5 mm above reserved battery'),
 ('4  BATTERY','Reserve: 50.5 x 62.5 x 8.1 mm\n0.5 mm cushioning allowance\nActual cushioning remains to verify'),
 ('2  MPR121','Bare electrode holes; QT cable\n2 x 2 mm under-head spacers\n2 x M2 x 6 self-tapping screws'),
 ('1  NEW TRAY','Four integrated Feather supports\nUSB opening: 15 x 13 mm\nFloor: 2.4 mm; walls: 2.2 mm')]
 yy=3450
 for title,body in items:
  label(r,title,3300,yy,34);label(r,body,3300,yy-120,27);yy-=290
 label(r,'MODEL DIMENSIONS ARE IN MILLIMETERS. EXPLODED GAPS ARE ILLUSTRATIVE.',150,240,30)
 label(r,'Amber translucent parts reserve wire bends and unmeasured plugs. They are not printable pieces.',150,175,29)
 label(r,'CAD checks do not validate cable length, printed tolerances, cushioning or powered assembly.',150,110,29)
 win.Render()
 if exploded:
  markers=[('1',(100,5,44)),('2',(80,10,75)),('3',(12,45,136)),('4',(95,40,43)),('5',(95,78,89)),('6',(20,10,44+250)),('7',(95,65,65+190)),('8',(106,43,53+168)),('9',(12,55,98)),('10',(5,5,47+265))]
  for number,point in markers:
   r.SetWorldPoint(*point,1);r.WorldToDisplay();xx,yy,_=r.GetDisplayPoint()
   label(r,number,int(xx)-50,int(yy),46,(.65,.25,.05))
 win.Render();cap=vtk.vtkWindowToImageFilter();cap.SetInput(win);cap.Update();wr=vtk.vtkPNGWriter();wr.SetFileName(str(R/'preview'/name));wr.SetInputConnection(cap.GetOutputPort());wr.Write();win.Finalize()
render('rev-b-exploded-4800.png',True)
render('rev-b-assembled-4800.png',False)
