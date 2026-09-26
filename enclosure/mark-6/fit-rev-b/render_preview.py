from pathlib import Path
import vtk
H=Path(__file__).resolve().parent
w=vtk.vtkRenderWindow(); w.SetOffScreenRendering(1);w.SetSize(1600,1050);w.SetMultiSamples(8)
for i in range(3):
 r=vtk.vtkRenderer();r.SetViewport(i/3,0,(i+1)/3,1);r.SetBackground(.96,.97,.98);w.AddRenderer(r)
 def mesh(path,color,opacity=1):
  reader=vtk.vtkSTLReader();reader.SetFileName(str(path));mapper=vtk.vtkPolyDataMapper();mapper.SetInputConnection(reader.GetOutputPort());a=vtk.vtkActor();a.SetMapper(mapper);a.GetProperty().SetColor(*color);a.GetProperty().SetOpacity(opacity);r.AddActor(a)
 if i<2:
  mesh(H/'preview/assembled-front.stl',(.80,.86,.91))
  mesh(H/'preview/assembled-ano.stl',(.10,.12,.15))
  mesh(H/'preview/assembled-display.stl',(.15,.35,.48),.3 if i==1 else 1)
  if i==1:
   for j in range(4):mesh(H/f'preview/assembled-retainer{j}.stl',(.9,.5,.12))
  cam=r.GetActiveCamera();cam.SetPosition((100,-240,430) if i==0 else (-100,-220,-400));cam.SetFocalPoint(37,-89,20);cam.SetViewUp(0,1,0);cam.ParallelProjectionOn();cam.SetParallelScale(115)
 else:
  mesh(H/'print/harmony-m6-b-wheel-coupon.stl',(.35,.6,.75))
  cam=r.GetActiveCamera();cam.SetPosition(100,-80,120);cam.SetFocalPoint(25,25,2);cam.SetViewUp(0,1,0);cam.ParallelProjectionOn();cam.SetParallelScale(76)
 for y,t,size in [(990,['REVISED FRONT','DISPLAY SUPPORTS','FIRST PRINT: WHEEL COUPON'][i],22),(950,['33 mm opening / 14 mm spacers','Four removable padded retainers','Four feet locate it on the control board'][i],15),(35,'Mechanical trial / physical fit unverified',15)]:
  a=vtk.vtkTextActor();a.SetInput(t);a.SetPosition(18,y);a.GetTextProperty().SetFontSize(size);a.GetTextProperty().SetColor(.1,.2,.3);r.AddActor2D(a)
w.Render();c=vtk.vtkWindowToImageFilter();c.SetInput(w);c.Update();p=vtk.vtkPNGWriter();p.SetFileName(str(H/'preview/revision-b.png'));p.SetInputConnection(c.GetOutputPort());p.Write();w.Finalize()
