"""STEP, STL and 3MF output. Print files are in print orientation."""
import os
import zipfile
from xml.sax.saxutils import escape

import cadquery as cq

PRINTED = {
    # name: (file stem, pose, colour hex)
    "front shell": ("front-shell", "flip", "#DCD9D1"),
    "back plate": ("back-plate", "lift9.5", "#D6D3CC"),
    "wheel disc": ("wheel-disc", "lift1.0", "#1E1E21"),
    "button cap": ("button-cap", "lift4.8", "#CCC9C2"),
}


def print_pose(shape, pose):
    """Move a part from device coordinates to its print orientation, centred
    on x = y = 0 with its lowest point at z = 0."""
    if pose == "flip":   # front face down on the plate
        s = shape.rotate(cq.Vector(0, 0, 0), cq.Vector(1, 0, 0), 180)
    else:
        s = shape
    b = s.BoundingBox()
    return s.translate(cq.Vector(-(b.xmin + b.xmax) / 2, -(b.ymin + b.ymax) / 2, -b.zmin))


def mesh_of(shape, tol=0.01, ang=0.1):
    v, f = shape.tessellate(tol, ang)
    return [(p.x, p.y, p.z) for p in v], f


def write_3mf(path, objects):
    """objects: list of (name, shape, (dx, dy), colour hex)."""
    res, items = [], []
    mats = "".join(f'<base name="{escape(n)}" displaycolor="{c}FF"/>' for n, _, _, c in objects)
    res.append(f'<basematerials id="1">{mats}</basematerials>')
    for i, (name, shape, (dx, dy), col) in enumerate(objects):
        oid = i + 2
        verts, tris = mesh_of(shape)
        vx = "".join(f'<vertex x="{x:.4f}" y="{y:.4f}" z="{z:.4f}"/>' for x, y, z in verts)
        tx = "".join(f'<triangle v1="{a}" v2="{b}" v3="{c}"/>' for a, b, c in tris)
        res.append(f'<object id="{oid}" name="{escape(name)}" type="model" pid="1" pindex="{i}">'
                   f'<mesh><vertices>{vx}</vertices><triangles>{tx}</triangles></mesh></object>')
        items.append(f'<item objectid="{oid}" transform="1 0 0 0 1 0 0 0 1 {dx:.3f} {dy:.3f} 0"/>')
    model = ('<?xml version="1.0" encoding="UTF-8"?>'
             '<model unit="millimeter" xml:lang="en-US" '
             'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">'
             '<metadata name="Title">Harmony Mark-8 slab rev A</metadata>'
             f'<resources>{"".join(res)}</resources><build>{"".join(items)}</build></model>')
    ct = ('<?xml version="1.0" encoding="UTF-8"?>'
          '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
          '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
          '<Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>'
          '</Types>')
    rels = ('<?xml version="1.0" encoding="UTF-8"?>'
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
            '<Relationship Target="/3D/3dmodel.model" Id="rel0" '
            'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", ct)
        z.writestr("_rels/.rels", rels)
        z.writestr("3D/3dmodel.model", model)


def export_all(solids, model_items, outdir):
    by = {it["name"]: it for it in solids}
    step_dir = os.path.join(outdir, "step")
    print_dir = os.path.join(outdir, "print")
    os.makedirs(step_dir, exist_ok=True)
    os.makedirs(print_dir, exist_ok=True)
    written = []
    posed = {}
    for name, (stem, pose, col) in PRINTED.items():
        shape = by[name]["shape"]
        p = os.path.join(step_dir, stem + ".step")
        cq.exporters.export(shape, p, "STEP")
        written.append(p)
        ps = print_pose(shape, pose)
        posed[name] = ps
        p = os.path.join(print_dir, stem + ".stl")
        cq.exporters.export(ps, p, "STL", tolerance=0.01, angularTolerance=0.1)
        written.append(p)
        p = os.path.join(print_dir, stem + ".3mf")
        write_3mf(p, [(name, ps, (128.0, 128.0), col)])
        written.append(p)
    # One A1 plate (256 x 256, origin at the plate corner) for the three parts in
    # the case colour. The wheel disc is black and prints on its own plate.
    plate = [("front shell", posed["front shell"], (95.0, 128.0), PRINTED["front shell"][2]),
             ("back plate", posed["back plate"], (161.0, 128.0), PRINTED["back plate"][2]),
             ("button cap", posed["button cap"], (128.0, 200.0), PRINTED["button cap"][2])]
    p = os.path.join(print_dir, "case-colour-plate.3mf")
    write_3mf(p, plate)
    written.append(p)
    # whole assembly in device coordinates
    asm = cq.Assembly(name="harmony-mark8-slab-rev-a")
    for it in solids:
        num = it["item"]
        r, g, b = model_items[num][2]
        asm.add(it["shape"], name=it["name"].replace(" ", "_"), color=cq.Color(r, g, b))
    p = os.path.join(step_dir, "assembly.step")
    asm.save(p, "STEP")
    written.append(p)
    return written, posed
