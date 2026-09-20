from pathlib import Path
import sys
import cadquery as cq
import vtk
import numpy as np
from vtk.util.numpy_support import numpy_to_vtk
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parent
for mode in ['inside','outside']:
 renderer=vtk.vtkRenderer();renderer.SetBackground(.95,.95,.94)
 names=['back','battery-cage','battery-envelope'] if mode=='inside' else ['back']
 for name in names:
  s=cq.importers.importStep(str(ROOT/'cad'/f'{name}.step')).val()
  verts,faces=s.tessellate(.05,.15)
  points=vtk.vtkPoints();points.SetData(numpy_to_vtk(np.array([v.toTuple() for v in verts]),deep=True))
  polys=vtk.vtkCellArray()
  for f in faces:
   polys.InsertNextCell(3)
   for i in f:polys.InsertCellPoint(i)
  poly=vtk.vtkPolyData();poly.SetPoints(points);poly.SetPolys(polys)
  normals=vtk.vtkPolyDataNormals();normals.SetInputData(poly);normals.SetFeatureAngle(35);normals.Update()
  mapper=vtk.vtkPolyDataMapper();mapper.SetInputConnection(normals.GetOutputPort())
  actor=vtk.vtkActor();actor.SetMapper(mapper)
  actor.GetProperty().SetColor(*{'back':(.36,.43,.47),'battery-cage':(.76,.69,.43),'battery-envelope':(.23,.58,.39)}[name]);actor.GetProperty().SetAmbient(.25)
  renderer.AddActor(actor)
 camera=renderer.GetActiveCamera();camera.SetPosition(100,-145,220 if mode=='inside' else -220);camera.SetFocalPoint(0,0,-6);camera.SetViewUp(0,1,0);camera.ParallelProjectionOn();camera.SetParallelScale(66)
 window=vtk.vtkRenderWindow();window.SetOffScreenRendering(1);window.SetSize(800,900);window.AddRenderer(renderer);window.SetMultiSamples(8);window.Render()
 cap=vtk.vtkWindowToImageFilter();cap.SetInput(window);cap.SetInputBufferTypeToRGB();cap.ReadFrontBufferOff();cap.Update()
 writer=vtk.vtkPNGWriter();writer.SetFileName(str(ROOT/'preview'/f'{mode}.png'));writer.SetInputConnection(cap.GetOutputPort());writer.Write();window.Finalize()
canvas=Image.new('RGB',(1600,1050),(242,242,240));draw=ImageDraw.Draw(canvas)
font=lambda n:ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf',n)
draw.text((45,22),'Harmony / GlobTek battery fit prototype',font=font(38),fill='#273d45')
for i,name in enumerate(['inside','outside']):
 canvas.paste(Image.open(ROOT/'preview'/f'{name}.png'),(i*800,100))
 draw.text((45+i*800,78),'Battery envelope and tray' if i==0 else 'Rear exterior: 6 mm deeper',font=font(23),fill='#273d45')
draw.text((45,1000),'CAD model only. Electronics, cable route and retention still need physical fit checks.',font=font(22),fill='#273d45')
canvas.save(ROOT/'preview/globtek-fit.png')
