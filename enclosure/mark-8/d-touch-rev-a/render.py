"""High resolution views of exported CAD, with component envelopes clearly identified."""
from pathlib import Path
import json,math
import vtk
R=Path(__file__).resolve().parent
W,D,F,B=112,94,28,64
angle=math.atan2(36,94)
colors={'base':(.24,.28,.27),'lid':(.77,.78,.69),'display':(.13,.19,.20),'carrier':(.15,.48,.36),'battery':(.46,.52,.59),'touch':(.86,.51,.22),'hardware':(.72,.56,.28)}
def text(r,txt,x,y,size=28,color=(.14,.19,.19)):
 t=vtk.vtkTextActor();t.SetInput(txt);t.SetPosition(x,y);t.GetTextProperty().SetFontSize(size);t.GetTextProperty().SetColor(*color);r.AddActor2D(t)
def render(filename,exploded=False):
 win=vtk.vtkRenderWindow();win.SetOffScreenRendering(1);win.SetSize(3600,2600);win.SetMultiSamples(8)
 r=vtk.vtkRenderer();r.SetBackground(.955,.955,.935);win.AddRenderer(r)
 groups=json.loads((R/'assembly-groups.json').read_text())
 offsets={'base':0,'carrier':70,'battery':70,'touch':110,'display':165,'lid':215,'hardware':215} if exploded else {g:0 for g in colors}
 for name,g in groups.items():
  reader=vtk.vtkSTLReader();reader.SetFileName(str(R/'preview'/f'{name}.stl'));m=vtk.vtkPolyDataMapper();m.SetInputConnection(reader.GetOutputPort());actor=vtk.vtkActor();actor.SetMapper(m);actor.SetPosition(0,0,offsets[g]);p=actor.GetProperty();p.SetColor(*colors[g]);p.SetInterpolationToPhong();p.SetSpecular(.16);p.SetSpecularPower(20)
  if 'spacer' in name or 'clip' in name or 'clamp' in name:p.SetColor(.80,.72,.48)
  if 'envelope' in name or 'reserve' in name:p.SetOpacity(.62)
  if name=='battery-cover':actor.SetPosition(0,0,offsets[g]+(18 if exploded else 0));p.SetOpacity(.75)
  if name=='waveshare-vendor-module':p.SetColor(.1,.16,.18)
  r.AddActor(actor)
 # Surface labels are aligned to the sloped face; these are cosmetic marking suggestions.
 for x,label in zip([20,38,56,74,92],['BACK','UP','OK','DOWN','PLAY']):
  v=vtk.vtkVectorText();v.SetText(label);m=vtk.vtkPolyDataMapper();m.SetInputConnection(v.GetOutputPort());actor=vtk.vtkActor();actor.SetMapper(m);actor.SetScale(1.7,1.7,1.7);actor.RotateX(math.degrees(angle));actor.SetPosition(x-len(label)*.65,13*math.cos(angle),F+13*math.sin(angle)+.08+offsets['lid']);actor.GetProperty().SetColor(.18,.22,.21);r.AddActor(actor)
 cam=r.GetActiveCamera();focus=(56,47,140 if exploded else 27);cam.SetFocalPoint(*focus);cam.SetPosition(300,-360,340 if exploded else 355);cam.SetViewUp(0,0,1);cam.ParallelProjectionOn();cam.SetParallelScale(195 if exploded else 94)
 text(r,'HARMONY / D TOUCH',140,2440,68)
 text(r,'Exploded assembly study' if exploded else 'Owned-parts enclosure proposal',142,2360,40)
 text(r,'112 x 94 mm footprint  /  28 mm front  /  64 mm rear  /  21 degree face',142,2290,28)
 if exploded:
  legend=[('6  CLOSE THE FACE','Four M2 x 8 machine screws into 10 mm brass standoffs.'),('5  MOUNT THE DISPLAY','Vendor LCD model; four clips and four 2 mm spacers.'),('4  ADD TOUCH INPUT','Five copper pads behind the face; MPR121 below.'),('3  RETAIN THE BATTERY','Reserved pouch envelope and removable raised cover.'),('2  INSTALL THE CARRIER','Feather/socket envelope; four under-head spacers.'),('1  START WITH THE TRAY','Printed posts, battery rails and cable guides.')]
  for i,(title,desc) in enumerate(legend):
   yy=2100-i*280;text(r,title,2440,yy,30);text(r,desc.replace('; ',';\n').replace(' into ','\ninto '),2440,yy-85,23)
  # Camera model shifted within full view so legend occupies right margin.
  cam.SetWindowCenter(.25,.03)
 else:
  text(r,'3.5-inch landscape display',140,440,36);text(r,'Five capacitive buttons. No wheel. No touchscreen interaction.',140,380,28)
 text(r,'REV A / UNPOWERED FIT CANDIDATE',140,170,30)
 text(r,'CAD geometry, not a photograph. Translucent blocks reserve populated boards. Cables and internal screws are omitted.',140,110,25)
 text(r,'Physical fit, touch sensitivity, cable exits and powered operation remain to be qualified.',140,65,25)
 win.Render();cap=vtk.vtkWindowToImageFilter();cap.SetInput(win);cap.Update();out=vtk.vtkPNGWriter();out.SetFileName(str(R/'preview'/filename));out.SetInputConnection(cap.GetOutputPort());out.Write();win.Finalize()
render('d-touch-rev-a-assembled.png');render('d-touch-rev-a-exploded.png',True)
