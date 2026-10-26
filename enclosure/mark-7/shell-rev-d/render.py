from pathlib import Path
import vtk
R=Path(__file__).resolve().parent

def render(filename,views):
 win=vtk.vtkRenderWindow();win.SetOffScreenRendering(1);win.SetSize(1700,1000)
 for i,(title,subtitle,names,rear) in enumerate(views):
  r=vtk.vtkRenderer();r.SetViewport(i/2,0,(i+1)/2,1);r.SetBackground(.965,.97,.975);win.AddRenderer(r)
  for name in names:
   path=R/'preview'/f'{name}.stl'
   reader=vtk.vtkSTLReader();reader.SetFileName(str(path));mapper=vtk.vtkPolyDataMapper();mapper.SetInputConnection(reader.GetOutputPort());a=vtk.vtkActor();a.SetMapper(mapper)
   color=(.87,.82,.68) if name in ['tray','front'] else (.24,.54,.77) if name=='battery-cover' else (.17,.36,.26) if name=='feather' else (.46,.49,.52) if name=='battery' else (.93,.52,.15) if 'reservation' in name else (.45,.22,.7) if 'snap' in name else (.2,.22,.24)
   a.GetProperty().SetColor(*color)
   if 'reservation' in name:a.GetProperty().SetOpacity(.5)
   if 'snap' in name:a.GetProperty().SetOpacity(.35)
   r.AddActor(a)
  cam=r.GetActiveCamera();cam.SetPosition(150,-160,-250 if rear else 260);cam.SetFocalPoint(32,52,8);cam.SetViewUp(0,1,0);cam.ParallelProjectionOn();cam.SetParallelScale(75)
  for y,txt,size in [(948,title,24),(908,subtitle,17),(28,'64 x 105 x 34 mm body | Revision D | Unpowered fit candidate',16)]:
   t=vtk.vtkTextActor();t.SetInput(txt);t.SetPosition(24,y);t.GetTextProperty().SetFontSize(size);t.GetTextProperty().SetColor(.13,.2,.26);r.AddViewProp(t)
 win.Render();cap=vtk.vtkWindowToImageFilter();cap.SetInput(win);cap.Update();out=vtk.vtkPNGWriter();out.SetFileName(str(R/'preview'/filename));out.SetInputConnection(cap.GetOutputPort());out.Write();win.Finalize()
render('overview.png',[
 ('MATCHED FRONT AND REAR','Rounded perimeter; accepted screen and ANO positions',['tray','front','display','ano'],False),
 ('INSIDE THE REAR TRAY','Measured carrier stack; USB opening on the right',['tray','battery-cover','carrier','feather','JP1-socket','JP3-socket'],False)])
render('closure.png',[
 ('BACK OF CASE','Four recessed M2 x 6 closure screws',['tray'],True),
 ('INSIDE THE NEW FACEPLATE','Closure columns, locating lip, wider screen supports',['front'],True)])
