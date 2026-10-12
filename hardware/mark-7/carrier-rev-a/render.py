from design import *
import vtk
M=HERE/'mechanical';O=HERE/'review';O.mkdir(exist_ok=True)
win=vtk.vtkRenderWindow();win.SetOffScreenRendering(1);win.SetSize(1600,1000)
views=[('REVISED REAR / 34 mm BODY','Carrier below Feather; higher USB opening',['tray','battery-cover','carrier','JP1-socket','JP3-socket','feather'],False),('REMOVABLE FEATHER ON CARRIER','Exploded view: Feather above two socket strips',['carrier','JP1-socket','JP3-socket','feather'],True)]
for i,(title,sub,names,exploded) in enumerate(views):
 r=vtk.vtkRenderer();r.SetViewport(i/2,0,(i+1)/2,1);r.SetBackground(.96,.97,.98);win.AddRenderer(r)
 for name in names:
  read=vtk.vtkSTLReader();read.SetFileName(str(M/(name+'.stl')));mapper=vtk.vtkPolyDataMapper();mapper.SetInputConnection(read.GetOutputPort());a=vtk.vtkActor();a.SetMapper(mapper)
  color=(.84,.8,.69) if name=='tray' else (.28,.54,.7) if name=='battery-cover' else (.12,.45,.32) if name=='carrier' else (.18,.19,.21) if 'socket' in name else (.25,.27,.29)
  a.GetProperty().SetColor(*color)
  if exploded and name=='feather':a.SetPosition(0,0,15)
  r.AddActor(a)
 cam=r.GetActiveCamera();cam.SetPosition(150,-145,255);cam.SetFocalPoint(32,86 if exploded else 53,9);cam.SetViewUp(0,1,0);cam.ParallelProjectionOn();cam.SetParallelScale(43 if exploded else 70)
 for y,txt,size in [(946,title,24),(910,sub,18),(30,'FIT REVIEW / wiring and connector fit remain to be tested',16)]:
  t=vtk.vtkTextActor();t.SetInput(txt);t.SetPosition(22,y);t.GetTextProperty().SetFontSize(size);t.GetTextProperty().SetColor(.12,.2,.25);r.AddViewProp(t)
win.Render();cap=vtk.vtkWindowToImageFilter();cap.SetInput(win);cap.Update();out=vtk.vtkPNGWriter();out.SetFileName(str(O/'assembly.png'));out.SetInputConnection(cap.GetOutputPort());out.Write();win.Finalize()
