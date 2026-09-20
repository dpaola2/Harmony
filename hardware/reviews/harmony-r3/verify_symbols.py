#!/usr/bin/env python3
"""Check every WM8523 pin type and both explicit EP pins against reviewed intent."""
import json,re
from pathlib import Path
HERE=Path(__file__).resolve().parent
REV=HERE.parents[2]/'hardware/revisions/harmony-r3/tangara-mainboard'
def parse(path):
    tokens=iter(re.findall(r'"(?:\\.|[^"\\])*"|[()]|[^\s()]+',path.read_text()))
    def value(t):
        if t=='(':
            a=[]
            for x in tokens:
                if x==')':return a
                a.append(value(x))
            raise ValueError('Unclosed form')
        return t[1:-1] if t.startswith('"') else t
    return value(next(tokens))
def walk(x):
    if isinstance(x,list):
        yield x
        for v in x:yield from walk(v)
def symbol(tree,name):
    return next(n for n in walk(tree) if len(n)>1 and n[0]=='symbol' and n[1].split(':')[-1]==name)
def pins(sym):
    return {next(c[1] for c in n if isinstance(c,list) and c[0]=='number'):n for n in walk(sym) if len(n)>2 and n[0]=='pin'}
golden={str(k):v for k,v in {1:'output',2:'output',3:'output',4:'power_in',5:'output',6:'power_in',7:'output',8:'input',9:'bidirectional',10:'bidirectional',11:'input',12:'bidirectional',13:'bidirectional',14:'input',15:'input',16:'input',17:'power_in',18:'output',19:'power_in',20:'output'}.items()}
report={}
for filename in ('audio.kicad_sch','symbols.kicad_sym'):
    tree=parse(REV/filename);wm=pins(symbol(tree,'WM8523'))
    actual={k:p[1] for k,p in wm.items()}
    assert actual==golden,(filename,actual)
    ep=pins(symbol(tree,'INA1620'))['25']
    assert ep[1]=='power_in' and 'hide' not in ep
    report[filename]={'WM8523_pin_types':actual,'INA1620_EP_visible':True}
for filename in ('peripherals.kicad_sch','symbols.kicad_sym'):
    ep=pins(symbol(parse(REV/filename),'PCA8575BS'))['25']
    assert ep[1]=='power_in' and 'hide' not in ep
    report.setdefault(filename,{})['PCA8575_EP_visible']=True
(HERE/'symbol-verification.json').write_text(json.dumps({'result':'PASS','evidence':'Cirrus WM8523 v4.3 pp4 and15; TI INA1620 p3; NXP PCA8575 p5; reviewed by Codex','files':report},indent=2)+'\n')
print('All 20 WM8523 pin types match reviewed model; EP fixes agree in cache and local library.')
