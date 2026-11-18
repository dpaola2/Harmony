"""Check JLCPCB stock and library type (basic / extended) for every LCSC part in design.py.

Plain Python 3 (run as `python3 -I check_stock.py`). Queries JLCPCB's public parts search (no login)
and writes jlcpcb/stock.json. Network data only; nothing is ordered or uploaded.
"""
import datetime
import json
import sys
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from design import PARTS  # noqa: E402

URL = 'https://jlcpcb.com/api/overseas-pcb-order/v1/shoppingCart/smtGood/selectSmtComponentList'


def query(code):
    req = urllib.request.Request(URL, data=json.dumps({'keyword': code, 'currentPage': 1, 'pageSize': 10}).encode(),
                                 headers={'Content-Type': 'application/json', 'User-Agent': 'Mozilla/5.0'})
    d = json.load(urllib.request.urlopen(req, timeout=30))
    for c in ((d.get('data') or {}).get('componentPageInfo') or {}).get('list') or []:
        if c.get('componentCode') == code:
            prices = c.get('componentPrices') or []
            return dict(mpn=c.get('componentModelEn'), brand=c.get('componentBrandEn'),
                        library_type=c.get('componentLibraryType'), stock=c.get('stockCount'),
                        package=c.get('componentSpecificationEn'),
                        unit_price_usd=min(prices, key=lambda x: x['startNumber'])['productPrice'] if prices else None)
    return None


need = {}
for prt in PARTS:
    if prt['bom'] and prt['lcsc']:
        need.setdefault(prt['lcsc'], []).append(prt['ref'])
out = dict(checked=datetime.datetime.now().isoformat(timespec='seconds'), parts={})
for code, refs in sorted(need.items()):
    try:
        info = query(code)
    except Exception as e:  # network failure is recorded, not hidden
        info = dict(error=str(e))
    out['parts'][code] = dict(refs=refs, qty_per_board=len(refs), **(info or dict(error='not found')))
    print(code, refs, info)
(HERE / 'jlcpcb').mkdir(exist_ok=True)
(HERE / 'jlcpcb/stock.json').write_text(json.dumps(out, indent=1) + '\n')
