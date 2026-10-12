"""Generate editable passive interconnect schematic using existing symbol primitives."""
from design import *
import uuid,csv
# Reuse generator definitions only; do not execute the older carrier circuit.
source=(REPO/'hardware/mark-6/carrier-rev-a/build_schematic.py').read_text()
ns={'__file__':str(HERE/'build_schematic.py')}
exec(compile(source[:source.index("feather_a=")],'<schematic-primitives>','exec'),ns)
ns.update(HERE=HERE,NAME=NAME,ROOT=str(uuid.uuid5(uuid.NAMESPACE_URL,'harmony/mark7/carrier/a')))
block,add,text=ns['block'],ns['add'],ns['text']
for ref,head,count,x in [('J1','JP1',16,55),('J2','JP3',12,145)]:
 block(head,[(str(i),pin(head,i)['vendor_net'] or 'NC','passive') for i in range(1,count+1)])
 add(ref,head,'Feather '+head+' socket',x,70,{str(i):netmap.get((head,i)) for i in range(1,count+1)},'Harmony:Feather_'+head,mpn=f'SSW-1{count:02}-01-G-S',note='Top-facing socket; vendor pin numbering, no mirroring')
block('Wire',[('1','WIRE','passive')])
for idx,(ref,label,net,head,num,y,gpio) in enumerate(wires):
 add(ref,'Wire',label,240 if idx<6 else 325,35+(idx if idx<6 else idx-6)*20,{'1':net},'Harmony:WirePad',note='Solder insulated faceplate wire here; P11 optional ANO INT')
ns['passive']('R','R')
add('R1','R','10k optional wake',150,145,{'1':'3V3','2':'ANO_INT'},'Harmony:R_Axial_P7.62',note='Optional through-hole 10k pull-up for ANO INT; existing QT cable carries power/I2C')
text('MARK 7 PASSIVE CARRIER / REV A / FIT REVIEW',25,15,2)
text('Battery -> Feather JST. ANO -> Feather STEMMA QT. No new charger or power rail.\nDisplay VIN -> Feather 3V3. Display 3Vo stays disconnected.\nSCK = GPIO14, MOSI = GPIO27 (NOT the pins labeled SCK/MO on Feather).\nTFT RST = GPIO32 (NOT Feather RESET). P11 is optional; cable-only firmware still wakes by Reset.\nSolder sockets and wires on carrier; plug the unmodified Feather in last.\nMechanical stack and cable fit require the dummy test before PCB ordering.',25,175)
q=ns['q'];symbols=ns['symbols'];items=ns['items'];root=ns['ROOT']
cache='\n'.join(s[0].replace('(symbol '+q(name),'(symbol '+q('Harmony:'+name),1) for name,s in symbols.items())
(HERE/(NAME+'.kicad_sch')).write_text(f'(kicad_sch (version 20231120) (generator "eeschema") (uuid {q(root)}) (paper "A3") (title_block (title "Harmony Mark-7 passive carrier") (date "2026-10-11") (rev "A-FIT-REVIEW")) (lib_symbols {cache})\n'+'\n'.join(items)+')\n')
(HERE/'connections.json').write_text(json.dumps({'components':ns['components'],'wires':[dict(ref=r,label=l,net=n,header=h,pin=p,gpio=g,xy=[position(pin(h,p))[0],y]) for r,l,n,h,p,y,g in wires]},indent=2)+'\n')
(HERE/(NAME+'.kicad_pro')).write_text('{}\n')
with (HERE/'bom.csv').open('w') as f:
 w=csv.writer(f);w.writerow(['Quantity','Part','Description']);w.writerows([[1,'SSW-116-01-G-S','16-position through-hole female socket'],[1,'SSW-112-01-G-S','12-position through-hole female socket'],[1,'10k through-hole axial resistor','Optional ANO INT pull-up; user owns 10k resistors'],[1,NAME,'1.6 mm two-layer carrier PCB'],[4,'M2x6 self-tapping','Existing steel screws; use 2 mm printed under-head spacers'],[1,'Flexible insulated wire','Ten display wires; optional eleventh ANO INT wire. Length from dry fit.']])
print('Schematic generated')

(HERE/"Harmony.kicad_sym").write_text('(kicad_symbol_lib (version 20231120) (generator "kicad_symbol_editor")\n'+"\n".join(s[0] for s in symbols.values())+')\n')
(HERE/"sym-lib-table").write_text('(sym_lib_table (version 7) (lib (name "Harmony") (type "KiCad") (uri "${KIPRJMOD}/Harmony.kicad_sym") (options "") (descr "Mark 7 carrier")))\n')
