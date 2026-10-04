#!/usr/bin/env python3
"""Render exported CAD meshes; cylinders and battery are space reservations."""
from pathlib import Path
import vtk
from PIL import Image, ImageDraw, ImageFont
R=Path(__file__).resolve().parent
window=vtk.vtkRenderWindow();window.SetOffScreenRendering(1);window.SetSize(1500,1000);window.SetMultiSamples(8)
for index in range(2):
    renderer=vtk.vtkRenderer();renderer.SetViewport(index/2,0,(index+1)/2,1);renderer.SetBackground(.97,.97,.95);window.AddRenderer(renderer)
    def mesh(name,color,opacity=1):
        reader=vtk.vtkSTLReader();reader.SetFileName(str(R/'preview'/f'{name}.stl'))
        mapper=vtk.vtkPolyDataMapper();mapper.SetInputConnection(reader.GetOutputPort())
        actor=vtk.vtkActor();actor.SetMapper(mapper);actor.GetProperty().SetColor(*color);actor.GetProperty().SetOpacity(opacity);renderer.AddActor(actor)
    mesh('tray',(.86,.83,.72));mesh('feather',(.06,.23,.32));mesh('battery',(.56,.61,.66));mesh('adapter-reservation',(.65,.49,.24))
    if index==0:
        mesh('front',(.94,.91,.81));mesh('display',(.06,.24,.15));mesh('wheel-reservation',(.28,.31,.24))
    camera=renderer.GetActiveCamera();camera.SetPosition(150,-160,340);camera.SetFocalPoint(32,52.5,12);camera.SetViewUp(0,1,0);camera.ParallelProjectionOn();camera.SetParallelScale(83)
    lines=[(925,'HARMONY / MARK 7' if index==0 else 'INSIDE THE FIT SHELL',26),
        (888,'105 x 64 x 26 mm  |  Parametric fit prototype' if index==0 else 'Front, display and wheel reservation removed',18),
        (80,'Screen and wheel openings are provisional' if index==0 else '2500 mAh battery below the wheel',18),
        (48,'Wheel shown as a space reservation' if index==0 else 'Feather beneath the upper display; headers omitted',18),
        (16,'UNPOWERED FIT ONLY  /  No final mounts or USB cutout',16)]
    for y,value,size in lines:
        text=vtk.vtkTextActor();text.SetInput(value);text.SetPosition(25,y);text.GetTextProperty().SetFontSize(size);text.GetTextProperty().SetColor(.13,.22,.18);renderer.AddViewProp(text)
window.Render();capture=vtk.vtkWindowToImageFilter();capture.SetInput(window);capture.Update()
writer=vtk.vtkPNGWriter();writer.SetFileName(str(R/'preview/pocket-rev-b.png'));writer.SetInputConnection(capture.GetOutputPort());writer.Write();window.Finalize()
# Actual frame-buffer output, scaled with nearest-neighbour to keep pixel fidelity.
ui=R.parents[2]/'firmware/mark-7/pocket-player/preview'
out=Image.new('RGB',(1000,510),'#eeeee8');draw=ImageDraw.Draw(out)
font=ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc',22)
for i,name in enumerate(['now-playing','music']):
    frame=Image.open(ui/(name+'.ppm'));frame.save(ui/(name+'.png'));out.paste(frame.resize((480,360),Image.Resampling.NEAREST),(10+i*500,74))
    draw.text((20+i*500,29),'NOW PLAYING' if i==0 else 'MUSIC MENU',fill='#243225',font=font)
draw.text((20,465),'Mark-7 firmware render  /  320 x 240 pixels',fill='#243225',font=font)
out.save(ui/'compact-ui.png')
