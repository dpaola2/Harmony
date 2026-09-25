#!/usr/bin/env python3
"""Render the delivered STL meshes in their supplied print orientation."""
from pathlib import Path
import vtk

H = Path(__file__).resolve().parent
window = vtk.vtkRenderWindow()
window.SetOffScreenRendering(1)
window.SetSize(1400, 1000)
window.SetMultiSamples(8)
for column, (name, label) in enumerate([('tray', 'HOLLOW TRAY'), ('front', 'REMOVABLE FRONT')]):
    renderer = vtk.vtkRenderer()
    renderer.SetViewport(column / 2, 0, (column + 1) / 2, 1)
    renderer.SetBackground(.96, .975, .985)
    window.AddRenderer(renderer)
    reader = vtk.vtkSTLReader()
    reader.SetFileName(str(H / 'print' / f'harmony-mark6-{name}.stl'))
    mapper = vtk.vtkPolyDataMapper()
    mapper.SetInputConnection(reader.GetOutputPort())
    actor = vtk.vtkActor()
    actor.SetMapper(mapper)
    actor.GetProperty().SetColor(.30, .52, .66)
    actor.GetProperty().SetAmbient(.3)
    renderer.AddActor(actor)
    camera = renderer.GetActiveCamera()
    camera.SetPosition(180, -150, 360)
    camera.SetFocalPoint(37, 89, 9)
    camera.SetViewUp(0, 1, 0)
    camera.ParallelProjectionOn()
    camera.SetParallelScale(140)
    for y, text, size in [(940, label, 26), (902, '74 x 178 mm | Unpowered fit prototype', 18),
                          (48, 'Print flat, as shown. Physical fit unverified.', 18),
                          (22, 'Display bezel is a sacrificial 0.4 mm fit feature.', 16)]:
        a = vtk.vtkTextActor()
        a.SetInput(text)
        a.SetPosition(35, y)
        a.GetTextProperty().SetFontSize(size)
        a.GetTextProperty().SetColor(.10, .20, .28)
        renderer.AddActor2D(a)
window.Render()
capture = vtk.vtkWindowToImageFilter()
capture.SetInput(window)
capture.Update()
writer = vtk.vtkPNGWriter()
writer.SetFileName(str(H / 'preview/hollow-fit.png'))
writer.SetInputConnection(capture.GetOutputPort())
writer.Write()
window.Finalize()
