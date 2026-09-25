#!/usr/bin/env python3
"""Depth-buffered preview of the delivered mesh."""
from pathlib import Path
import vtk

def render(mesh, dimensions, output):
    # Read the delivered STL instead of reconstructing appearance from rectangles.
    reader=vtk.vtkSTLReader()
    reader.SetFileName(str(output.parent/'print/harmony-mark6-size-74x178x28.stl'))
    mapper=vtk.vtkPolyDataMapper();mapper.SetInputConnection(reader.GetOutputPort())
    actor=vtk.vtkActor();actor.SetMapper(mapper)
    actor.GetProperty().SetColor(.40,.53,.64)
    actor.GetProperty().SetInterpolationToFlat()
    actor.GetProperty().SetAmbient(.3)
    actor.GetProperty().SetDiffuse(.7)
    renderer=vtk.vtkRenderer();renderer.SetBackground(.965,.973,.98)
    renderer.AddActor(actor)
    camera=renderer.GetActiveCamera();camera.SetPosition(180,-300,500)
    camera.SetFocalPoint(0,0,14);camera.SetViewUp(0,1,0)
    camera.ParallelProjectionOn();camera.SetParallelScale(120)
    def text(x,y,value,size,color):
        a=vtk.vtkTextActor();a.SetInput(value);a.SetPosition(x,y)
        prop=a.GetTextProperty();prop.SetFontSize(size);prop.SetColor(*color)
        prop.SetFontFamilyToArial();renderer.AddActor2D(a)
    text(55,975,'HARMONY / MARK 6',22,(.08,.42,.64))
    text(55,925,'74 x 178 x 28 mm',32,(.09,.17,.23))
    text(55,885,'Solid size dummy | Depth provisional',19,(.34,.40,.46))
    text(55,35,'Check pocket fit and thumb reach. No electronics cavity or functional controls.',17,(.34,.40,.46))
    window=vtk.vtkRenderWindow();window.SetOffScreenRendering(1)
    window.AddRenderer(renderer);window.SetSize(1200,1040)
    window.SetMultiSamples(8);window.Render()
    capture=vtk.vtkWindowToImageFilter();capture.SetInput(window);capture.Update()
    writer=vtk.vtkPNGWriter();writer.SetFileName(str(output/'size-mockup.png'))
    writer.SetInputConnection(capture.GetOutputPort());writer.Write();window.Finalize()

if __name__=='__main__':
    here=Path(__file__).resolve().parent
    render(None,[74,178,28],here/'preview')
