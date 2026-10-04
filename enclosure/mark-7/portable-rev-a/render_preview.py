#!/usr/bin/env python3
"""Render the actual exported CAD meshes, with the battery at its maximum size."""
from pathlib import Path
import vtk
ROOT=Path(__file__).resolve().parent
window=vtk.vtkRenderWindow(); window.SetOffScreenRendering(1); window.SetSize(1700,1100); window.SetMultiSamples(8)
for index in range(2):
    renderer=vtk.vtkRenderer(); renderer.SetViewport(index/2,0,(index+1)/2,1); renderer.SetBackground(.97,.97,.95); window.AddRenderer(renderer)
    def mesh(name,color,opacity=1):
        reader=vtk.vtkSTLReader(); reader.SetFileName(str(ROOT/'preview'/f'{name}.stl'))
        mapper=vtk.vtkPolyDataMapper(); mapper.SetInputConnection(reader.GetOutputPort())
        actor=vtk.vtkActor(); actor.SetMapper(mapper); actor.GetProperty().SetColor(*color); actor.GetProperty().SetOpacity(opacity); renderer.AddActor(actor)
    cream=(.86,.83,.72)
    mesh('tray',cream); mesh('ano',(.14,.14,.15)); mesh('feather',(.07,.22,.33))
    if index==0:
        mesh('front',cream); mesh('display',(.06,.23,.17))
    else:
        mesh('battery',(.57,.62,.68)); mesh('perfboard',(.43,.27,.12))
        for i in range(2): mesh(f'perf-clamp-{i}',(.80,.49,.18))
    camera=renderer.GetActiveCamera(); camera.SetPosition(170,-245,430) if index==0 else camera.SetPosition(100,-170,470)
    camera.SetFocalPoint(37,-89,12); camera.SetViewUp(0,1,0); camera.ParallelProjectionOn(); camera.SetParallelScale(112)
    lines=[(1030,'HARMONY / MARK 7' if index==0 else 'BATTERY AND ELECTRONICS',28),
           (988,'74 x 178 x 28 mm  |  Screw-removable front' if index==0 else 'Front, LCD and battery cover removed',21),
           (77,'USB-C charging  /  No battery switch' if index==0 else '2500 mAh pack above  /  Feather below',21),
           (38,'CAD fit candidate  /  Bambu A1 0.4 mm nozzle' if index==0 else 'Separate battery cover protects the pouch',19)]
    for y,text,size in lines:
        actor=vtk.vtkTextActor(); actor.SetInput(text); actor.SetPosition(30,y); actor.GetTextProperty().SetFontSize(size); actor.GetTextProperty().SetColor(.13,.22,.18); renderer.AddActor2D(actor)
window.Render(); capture=vtk.vtkWindowToImageFilter(); capture.SetInput(window); capture.Update()
writer=vtk.vtkPNGWriter(); writer.SetFileName(str(ROOT/'preview/portable-rev-a.png')); writer.SetInputConnection(capture.GetOutputPort()); writer.Write(); window.Finalize()
