"""Read-only native pin/geometry review of R3 J1 and its footprint library."""
import json,hashlib
from pathlib import Path
import pcbnew,wx
app=wx.App(False)
p=Path(__file__).resolve().parent;root=p.parents[3]
files=[root/f'hardware/revisions/harmony-r{r}/tangara-mainboard/tangara-mainboard.kicad_pcb' for r in (2,3)]
result={}
def vec(v):return [pcbnew.ToMM(v.x),pcbnew.ToMM(v.y)]
def info(f):
 return {pad.GetNumber():{'hole_center_world_mm':vec(pad.GetPosition()),'copper_center_world_mm':vec(pad.ShapePos()),'size_mm':vec(pad.GetSize()),'drill_mm':vec(pad.GetDrillSize()),'offset_mm':vec(pad.GetOffset()),'orientation_deg':pad.GetOrientationDegrees(),'shape':pad.GetShape(),'pad_type':pad.GetAttribute(),'net':pad.GetNetname(),'mask_margin_mm':pcbnew.ToMM(pad.GetLocalSolderMaskMargin()),'paste_margin_mm':pcbnew.ToMM(pad.GetLocalSolderPasteMargin()),'paste_ratio':pad.GetLocalSolderPasteMarginRatio(),'layer_mask':pad.GetLayerSet().FmtBin()} for pad in f.Pads()}
for rev,path in zip(('r2','r3'),files):
 b=pcbnew.LoadBoard(str(path));f=next(f for f in b.GetFootprints() if f.GetReference()=='J1');result[rev]={'pcb_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'footprint_at_mm':vec(f.GetPosition()),'footprint_rotation_deg':f.GetOrientationDegrees(),'footprint_layer':f.GetLayerName(),'pads':info(f)}
libdir=root/'hardware/revisions/harmony-r3/tangara-mainboard/footprints.pretty';lib=pcbnew.FootprintLoad(str(libdir),'CUI_SJ-3506-SMT');result['library']=info(lib)
assert all(result['r2']['pads'][n]['hole_center_world_mm']==result['r3']['pads'][n]['hole_center_world_mm'] for n in result['r3']['pads'])
assert all(result['r3']['pads'][n]['drill_mm']==[1.1,.7] for n in result['r3']['pads'])
result['hole_centers_preserved']=True;result['all_eight_slots_match_manufacturer_1p1_by_0p7']=True
result['library_pad_size_matches']={n:result['library'][n]['size_mm']==result['r3']['pads'][n]['size_mm'] for n in result['library']}
temporary_board=pcbnew.BOARD();temporary_board.Add(lib)
lib.SetPosition(f.GetPosition());lib.SetOrientationDegrees(-f.GetOrientationDegrees());lib.Flip(f.GetPosition(),False)
placed=info(lib);expected=info(f)
for n in expected:
 expected[n].pop('net');placed[n].pop('net')
assert expected==placed,'Placed library pad mismatch'
def edges(fp):
 return sorted([(g.GetShape(),tuple(vec(g.GetStart())),tuple(vec(g.GetEnd())),tuple(vec(g.GetArcMid())) if g.GetShape()==pcbnew.SHAPE_T_ARC else (),g.GetWidth()) for g in fp.GraphicalItems() if g.GetLayer()==pcbnew.Edge_Cuts])
assert edges(lib)==edges(f),'Placed library Edge.Cuts mismatch'
result['library_placed_on_board_matches_exactly_including_masks']=True;result['library_edge_cuts_match_exactly']=True
(p/'jack-native-independent.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({'hole_centers_preserved':True,'library_pad_size_matches':result['library_pad_size_matches']},indent=2))
