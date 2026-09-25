"""Waveshare 29318 vendor STEP placed in the Mark 6 front-view coordinate frame."""
from pathlib import Path

HERE = Path(__file__).resolve().parent
STEP = HERE / 'reference/waveshare-29318/3.5inch_Capacitive_Touch_LCD_3Dand2D/3.5inch_Capacitive_Touch_LCD.step'
DISPLAY_RECT = [6.5, 4.0, 61.0111908, 92.4468164]
ACTIVE_RECT = [12.5256, 13.5034, 48.96, 73.44]
DISPLAY_Z = [16.74952, 27.3]
FFC_CENTER = [37.01, 20.32]

def load_display():
    import cadquery as cq
    # Vendor glass faces -Z. Swap X/Y and flip Z with a proper 180-degree
    # rotation, placing its portrait glass face toward the case front.
    s = cq.importers.importStep(str(STEP)).val()
    return s.rotate((0, 0, 0), (1, 1, 0), 180).translate((9.43102579, -94.63853517, 20.99952))
