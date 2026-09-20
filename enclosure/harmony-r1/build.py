#!/usr/bin/env python3
# SPDX-License-Identifier: CERN-OHL-S-2.0
# Harmony modifications, 2026-09-13. Derived from Cool Tech Zone Tangara.
# Run: uv run --with cadquery==2.8.0 --with trimesh --with matplotlib build.py
"""Build printable Harmony R1 parts from pinned Tangara mechanical sources.

Preserves the manufactured hardware interfaces. STEP uses assembly coordinates;
STL uses print coordinates. 3MF files contain geometry only, not printer G-code.
"""
from pathlib import Path
import json
import hashlib
import zipfile
import xml.etree.ElementTree as ET
import cadquery as cq
import trimesh
import numpy as np

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "source"
BACK_REINFORCEMENT = 1.0  # outward; original battery cavity stays unchanged
ENGRAVE_DEPTH = 0.30
TOL = 0.03


def step(name):
    return cq.importers.importStep(str(SRC / f"{name}.step")).val()


def brep(name):
    return cq.Shape.importBrep(str(SRC / f"{name}.brep"))


def box(w, h, d, xyz):
    return cq.Workplane("XY").box(w, h, d).translate(xyz).val()


def bed(shape, rotation=None):
    if rotation:
        axis, angle = rotation
        shape = shape.rotate((0, 0, 0), axis, angle)
    b = shape.BoundingBox()
    return shape.translate((-(b.xmin+b.xmax)/2, -(b.ymin+b.ymax)/2, -b.zmin))


def mesh(shape):
    vertices, triangles = shape.tessellate(TOL, 0.1)
    m = trimesh.Trimesh(vertices=[v.toTuple() for v in vertices],
                        faces=triangles, process=True)
    # Imported tangent fillets produce duplicate vertices a few nanometers
    # apart. Weld at 0.1 micron, then remove collapsed/duplicate triangles.
    # This preserves the BRep; no holes are filled or surfaces smoothed.
    m.merge_vertices(digits_vertex=7)
    m.update_faces(m.nondegenerate_faces())
    m.update_faces(m.unique_faces())
    m.remove_unreferenced_vertices()
    return m


def write_3mf(path, models):
    ns = "http://schemas.microsoft.com/3dmanufacturing/core/2015/02"
    ET.register_namespace("", ns)
    tag = lambda x: f"{{{ns}}}{x}"
    root = ET.Element(tag("model"), unit="millimeter", attrib={"{http://www.w3.org/XML/1998/namespace}lang":"en-US"})
    ET.SubElement(root, tag("metadata"), name="Title").text = "Harmony R1 fit prototype"
    resources = ET.SubElement(root, tag("resources"))
    build = ET.SubElement(root, tag("build"))
    for i, (name, shape, x, y) in enumerate(models, 1):
        m = mesh(shape)
        obj = ET.SubElement(resources, tag("object"), id=str(i), type="model", name=name)
        el = ET.SubElement(obj, tag("mesh"))
        vs = ET.SubElement(el, tag("vertices"))
        for v in m.vertices:
            ET.SubElement(vs, tag("vertex"), x=f"{v[0]:.6f}", y=f"{v[1]:.6f}", z=f"{v[2]:.6f}")
        ts = ET.SubElement(el, tag("triangles"))
        for t in m.faces:
            ET.SubElement(ts, tag("triangle"), v1=str(t[0]), v2=str(t[1]), v3=str(t[2]))
        ET.SubElement(build, tag("item"), objectid=str(i), transform=f"1 0 0 0 1 0 0 0 1 {x} {y} 0")
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("3D/3dmodel.model", ET.tostring(root, encoding="utf-8", xml_declaration=True))
        z.writestr("[Content_Types].xml", '<?xml version="1.0"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/></Types>')
        z.writestr("_rels/.rels", '<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')


def make_parts():
    front = step("front")
    back_original = step("back")
    # The outside rear face includes its screw openings. Extruding it outward
    # thickens the 1 mm floor and leaves the original countersinks recessed.
    face = max((f for f in back_original.Faces()
                if f.geomType() == "PLANE" and f.normalAt().z < -.99
                and abs(f.Center().z + 10.6) < .01), key=lambda f: f.Area())
    skin = cq.Solid.extrudeLinear(face.outerWire(), face.innerWires(), cq.Vector(0,0,-BACK_REINFORCEMENT))
    back = back_original.fuse(skin).clean()
    # Embossing is avoided so both exterior faces still lie flat on the bed.
    label = cq.Workplane("XY").text("harmony", 3.0, .4, font="Arial", kind="regular",
                                     halign="center", valign="center", combine=False).val()
    back = back.cut(label.rotate((0,0,0),(1,0,0),180).translate((0,0,-11.3))).clean()
    # A pair of shallow grip grooves is clear of the screw counterbores.
    for y in [-25,25]:
        groove = cq.Workplane("XY").slot2D(32,1.2).extrude(.4).val().translate((0,y,-11.7))
        back = back.cut(groove)
    # Front label fits the bridge between screen and wheel, outside electronics.
    mark = cq.Workplane("XY").text("harmony", 2.3, .4, font="Arial", kind="regular",
                                    halign="center", valign="center", combine=False).val()
    front = front.cut(mark.translate((0,3.5,11.3))).clean()
    # Cached wheel/lens coordinates are local to the faceplate's parent group.
    parent_shift = (-23.4,44.475,7.59)
    # New circular print cover replaces upstream's non-circular FR4 cover.
    wheel = cq.Workplane('XY').circle(21.95).extrude(.6).val().translate((0,-22.115,7.6))
    centre_mark = cq.Workplane('XY').circle(8.3).circle(7.7).extrude(.13).val().translate((0,-22.115,8.08))
    wheel = wheel.cut(centre_mark).clean()
    # The old 0.75 mm reference lens intersects the newer roof. Use a clear
    # 0.5 mm sheet with 0.2 mm shorter length, secured with perimeter tape.
    lens = box(39.6,34.4,.5,(-.85,24.575,10.15))
    # The old cached cover fouls the newer Rev-03b retainer. Give the 43.9 mm
    # flange a 44.4 mm recess, ending at z=8.4. The original front aperture
    # still captures the cover; its face remains at the original height.
    pocket = cq.Workplane('XY').circle(22.2).extrude(.9).val().translate((0,-22.115,7.5))
    front = front.cut(pocket).clean()
    # A separate circular visual insert is intentionally absent: centre sensing
    # uses the same continuous insulating cover as the outer ring.
    # Convert the upstream sprung cage to passive guides. Its spring surfaces
    # overlap the cached pack envelope. Remove that preload, then reconnect
    # the remaining guides outside the pack with two 1 mm thick ties.
    battery_space = box(45.1,72.85,8.1,(2.9,2.825,-5.55))
    cage = step('battery-cage').cut(battery_space)
    cage = cage.fuse(box(1.2,82,1,(-20.5,0,-8.9)))
    cage = cage.fuse(box(47,1.2,1,(2.6,40.5,-8.9)))
    cage = cage.cut(back_original).clean()
    parts = {"front":front, "back":back, "touch-cover":wheel,
             "button-upper":brep("button1-reference"),
             "button-lower":brep("button2-reference"),
             "hold-switch":step("hold-switch"), "sd-caddy":step("sd-caddy"),
             "battery-cage":cage}
    coupon = box(15,15,40,(-22,43,0))
    parts["fit-front"] = front.intersect(coupon)
    parts["fit-back"] = back.intersect(coupon)
    rotations = {"front":((1,0,0),180), "fit-front":((1,0,0),180),
                 "button-upper":((0,1,0),90), "button-lower":((0,1,0),90),
                 "hold-switch":((0,1,0),-90), "sd-caddy":((0,1,0),90)}
    prints = {name:bed(s,rotations.get(name)) for name,s in parts.items()}
    return parts, prints, lens, back_original


def render(parts, lens):
    from render_vtk import render as render_model
    render_model(parts, lens, ROOT)


def main():
    for name in ["cad","print","preview"]:(ROOT/name).mkdir(exist_ok=True)
    parts, prints, lens, original_back = make_parts()
    report={"status":"digital fit prototype, not physically validated", "parts":{},"checks":{}}
    for name,s in parts.items():
        m=mesh(prints[name])
        assert s.isValid() and len(s.Solids())==1,(name,"invalid CAD")
        assert m.is_watertight and m.is_winding_consistent and m.volume>0,(name,"invalid mesh")
        # OCCT's cached tessellation can expand BRep bounds by its deflection;
        # the exported vertices are the actual print bounds.
        assert abs(m.bounds[0,2])<1e-5 and max(m.extents)<256,(name,"bed bounds")
        cq.exporters.export(s,str(ROOT/"cad"/f"{name}.step"))
        m.export(ROOT/"print"/f"{name}.stl")
        report["parts"][name]={"solid_valid":True,"watertight":True,"winding_consistent":True,
            "print_size_mm":[round(float(v),3) for v in m.extents],
            "volume_mm3":round(s.Volume(),3),"triangles":len(m.faces)}
    # Exterior changes must not put material inside the original shell or
    # remove the stock back. Engravings only remove the added 1 mm rear skin.
    report["checks"]["back_original_removed_mm3"]=original_back.cut(parts['back']).Volume()
    assert report["checks"]["back_original_removed_mm3"]<.01
    overlaps={}
    names=[n for n in parts if not n.startswith('fit-')]
    for i,a in enumerate(names):
        for b in names[i+1:]:
            v=parts[a].intersect(parts[b]).Volume()
            if v>.01:overlaps[f"{a}/{b}"]=round(v,4)
    report['checks']['part_intersections_mm3']=overlaps
    assert not overlaps, ('assembly interference', overlaps)
    for name in ['front','back','touch-cover']:
        v=parts[name].intersect(lens).Volume()
        report['checks'][f'{name}_lens_intersection_mm3']=round(v,6)
        assert v < .01, (name, 'lens interference', v)
    report['checks']['a1_plate_mm']=[256,256]
    battery = brep('battery-reference')
    for name in ['back','battery-cage']:
        v=parts[name].intersect(battery).Volume()
        report['checks'][f'{name}_battery_intersection_mm3']=round(v,6)
        assert v < .01,(name,'battery interference',v)
    cq.exporters.export(battery,str(ROOT/'cad/battery-envelope-reference.step'))
    write_3mf(ROOT/'print/harmony-shells.3mf',[(n,prints[n],x,128) for n,x in [('front',83),('back',173)]])
    write_3mf(ROOT/'print/harmony-small-parts.3mf',[(n,prints[n],x,y) for n,x,y in [
        ('touch-cover',50,60),('battery-cage',125,80),('button-upper',185,45),
        ('button-lower',205,45),('hold-switch',185,80),('sd-caddy',210,115)]])
    write_3mf(ROOT/'print/harmony-fit-test.3mf',[(n,prints[n],x,128) for n,x in [('fit-front',100),('fit-back',145)]])
    cq.exporters.export(lens,str(ROOT/'cad/display-lens-reference.step'))
    cq.exporters.export(cq.Compound.makeCompound([parts[n] for n in names]+[lens]),str(ROOT/'cad/enclosure-assembly.step'))
    (ROOT/'validation.json').write_text(json.dumps(report,indent=2)+'\n')
    render(parts,lens)
    print(json.dumps(report,indent=2))
    sums={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
          for folder in ['source','cad','print'] for p in sorted((ROOT/folder).glob('*')) if p.is_file()}
    (ROOT/'sha256.json').write_text(json.dumps(sums,indent=2)+'\n')


if __name__=='__main__':main()
