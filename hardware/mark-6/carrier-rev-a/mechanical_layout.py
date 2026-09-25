#!/usr/bin/env python3
"""Reproducible 2-D reservations. This is not collision-checked assembly CAD."""
from pathlib import Path
import json
import math
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent

def layout():
    root = ET.parse(HERE / 'reference/Adafruit ESP32 Feather V2.brd')
    module = root.find('.//board/elements/element[@name="X3"]')
    package = root.find(f'.//library[@name="{module.get("library")}"]/packages/package[@name="{module.get("package")}"]')
    antenna = package.find('rectangle[@layer="41"]')
    assert module.get('rot') == 'R270'
    # Eagle y points up; drawing y points down. Feather PCB is 50.8 x 22.86.
    theta = math.radians(270)
    vertices = []
    for x in [float(antenna.get('x1')), float(antenna.get('x2'))]:
        for y in [float(antenna.get('y1')), float(antenna.get('y2'))]:
            bx = float(module.get('x')) + x*math.cos(theta) - y*math.sin(theta)
            by = float(module.get('y')) + x*math.sin(theta) + y*math.cos(theta)
            vertices.append((bx, 22.86-by))
    antenna_local = [min(p[0] for p in vertices), min(p[1] for p in vertices),
                     max(p[0] for p in vertices), max(p[1] for p in vertices)]
    # 90-degree rotation makes the ANO board 40.64 wide and 35.56 high.
    controls = [16.68, 103.0, 40.64, 35.56]
    margin = 15.0
    controls_to_halo = 2.0
    feather_x = 5.5
    feather_y = controls[1]+controls[3]+controls_to_halo+margin-antenna_local[1]
    ant = [round(antenna_local[0]+feather_x, 3), round(antenna_local[1]+feather_y, 3),
           round(antenna_local[2]+feather_x, 3), round(antenna_local[3]+feather_y, 3)]
    halo = [round(ant[0]-margin,3), round(ant[1]-margin,3),
            round(ant[2]+margin,3), round(ant[3]+margin,3)]
    data = {
        'revision': 'B', 'units': 'mm',
        'status': 'Size and planar placement study; no enclosure or PCB manufacturing release',
        'case': [74,178,28], 'case_corner_radius': 5,
        'depth_status': '28 mm is a mockup assumption within the provisional 25-30 mm budget',
        'rectangle_format': '[left, top, width, height] from front-view upper-left',
        'display_board': [6.5,4,61.0111908,92.4468164],
        'display_active_guide': [12.5256,13.5034,48.96,73.44],
        'controls_board': controls, 'controls_rotation_deg': 90,
        'wheel_center': [37,120.78], 'wheel_diameter': 34.4,
        'feather_board': [feather_x,round(feather_y,3),50.8,22.86],
        'feather_usb_occupied_extension_left': 1.5,
        'antenna_vendor_restrict_local_bounds': [round(v,3) for v in antenna_local],
        'antenna_case_bounds': ant, 'antenna_15mm_halo_bounds': halo,
        'antenna_halo_format': '[left, top, right, bottom]',
        'antenna_status': 'Planar reservation for other modules; Feather sockets and carrier copper intrude and require RF layout review. Halo extends beyond the proposed plastic shell. No all-direction RF clearance or performance pass.',
        'battery_reserved': [4,8,32,79,10.5],
        'rear_reservations': {'SD':[43,12,20,18], '3V3 supply':[43,38,20,15], 'Ribbon':[43,63,20,10]},
        'checks': {'display_to_controls_gap': round(103-96.4468164,3),
                   'controls_to_antenna_halo_gap': round(halo[1]-138.56,3),
                   'feather_bottom_to_case_edge': round(178-feather_y-22.86,3),
                   'halo_beyond_case_bottom': round(max(0,halo[3]-178),3)},
        'limitations': ['No Z-stack collision check; 28 mm depth unverified',
                        'No functional apertures, fasteners or mounting bosses',
                        'QT plug and ribbon bend volumes still unmodeled',
                        'Carrier RF cutout and socket land review remain',
                        'ANO direction mapping needs 90-degree firmware remap',
                        'Battery reserve is not a qualified swelling allowance; USB first'],
        'sources': ['reference/design-sources.json',
                    'https://docs.espressif.com/projects/esp-hardware-design-guidelines/en/latest/esp32/pcb-layout-design.html']
    }
    # Bounds and non-overlap for the named planar reservations, not a 3-D assembly test.
    for key in ['display_board','controls_board','feather_board']:
        x,y,w,h = data[key]
        assert x >= 2 and y >= 2 and x+w <= 72 and y+h <= 176, (key, data[key])
    assert data['checks']['controls_to_antenna_halo_gap'] >= 2
    assert ant[2] < 74 and ant[3] < 178
    return data

if __name__ == '__main__':
    data = layout()
    (HERE/'placement.json').write_text(json.dumps(data,indent=2)+'\n')
    print(json.dumps(data['checks'],indent=2))
