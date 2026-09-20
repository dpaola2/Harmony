"""Opaque, depth-buffered CAD preview; never an AI-generated product image."""
from pathlib import Path
import numpy as np
import vtk
from vtk.util.numpy_support import numpy_to_vtk
from PIL import Image, ImageDraw, ImageFont


def render(parts, lens, root):
    colors = {"front":(.88,.86,.81),"back":(.36,.43,.47),"touch-cover":(.16,.19,.21),
              "button-upper":(.18,.22,.25),"button-lower":(.18,.22,.25),
              "hold-switch":(.18,.22,.25),"sd-caddy":(.18,.22,.25),
              "battery-cage":(.65,.70,.72),"lens":(.10,.20,.24)}
    outputs=[]
    for mode in ['assembled','exploded']:
        renderer=vtk.vtkRenderer(); renderer.SetBackground(.956,.949,.925)
        for name, original in dict(parts,lens=lens).items():
            if name.startswith('fit-'):continue
            if mode=='assembled' and name=='battery-cage':continue
            dz={'front':31,'touch-cover':22,'lens':22,'battery-cage':-14,'back':-25}.get(name,0) if mode=='exploded' else 0
            s=original.translate((0,0,dz)); verts, faces=s.tessellate(.04,.12)
            points=vtk.vtkPoints();points.SetData(numpy_to_vtk(np.array([v.toTuple() for v in verts]),deep=True))
            polys=vtk.vtkCellArray()
            for f in faces:
                polys.InsertNextCell(3)
                for i in f:polys.InsertCellPoint(i)
            poly=vtk.vtkPolyData();poly.SetPoints(points);poly.SetPolys(polys)
            normals=vtk.vtkPolyDataNormals();normals.SetInputData(poly);normals.SetFeatureAngle(35);normals.SplittingOn();normals.Update()
            mapper=vtk.vtkPolyDataMapper();mapper.SetInputConnection(normals.GetOutputPort())
            actor=vtk.vtkActor();actor.SetMapper(mapper);p=actor.GetProperty();p.SetColor(*colors[name]);p.SetInterpolationToPhong();p.SetAmbient(.28);p.SetDiffuse(.72);p.SetSpecular(.2);p.SetSpecularPower(30)
            renderer.AddActor(actor)
        camera=renderer.GetActiveCamera();camera.SetPosition(110,-160,270);camera.SetFocalPoint(0,0,5);camera.SetViewUp(0,1,0);camera.ParallelProjectionOn();camera.SetParallelScale(67 if mode=='assembled' else 80)
        window=vtk.vtkRenderWindow();window.SetOffScreenRendering(1);window.SetSize(900,1000);window.AddRenderer(renderer);window.SetMultiSamples(8);window.Render()
        capture=vtk.vtkWindowToImageFilter();capture.SetInput(window);capture.SetInputBufferTypeToRGB();capture.ReadFrontBufferOff();capture.Update()
        path=root/'preview'/f'{mode}.png';writer=vtk.vtkPNGWriter();writer.SetFileName(str(path));writer.SetInputConnection(capture.GetOutputPort());writer.Write();window.Finalize();outputs.append(path)
    canvas=Image.new('RGB',(1800,1180),(244,242,236));draw=ImageDraw.Draw(canvas)
    font_path='/System/Library/Fonts/Supplemental/Arial.ttf'
    font=lambda size:ImageFont.truetype(font_path,size)
    draw.text((75,30),'harmony',font=font(68),fill='#263b43')
    draw.text((75,113),'R1 / Tangara-based enclosure for Bambu A1',font=font(27),fill='#596b72')
    for i,p in enumerate(outputs):canvas.paste(Image.open(p),(900*i,170))
    draw=ImageDraw.Draw(canvas)
    draw.text((220,183),'Assembled',font=font(24),fill='#596b72')
    draw.text((1020,183),'Enclosure parts (electronics omitted)',font=font(24),fill='#596b72')
    draw.text((75,1115),'57.6 × 99.75 × 23.2 mm body. Digital fit prototype; physical validation pending.',font=font(25),fill='#596b72')
    canvas.save(root/'preview/harmony-r1.png')
