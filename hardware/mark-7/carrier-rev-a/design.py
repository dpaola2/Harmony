"""Mark-7 passive carrier definition. Coordinates match rear-review-c assembly."""
from pathlib import Path
import json
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
NAME='harmony-mark7-carrier'
X0=57.895488370848504
headers=json.loads((REPO/'hardware/mark-6/carrier-rev-a/reference/feather-v2-header-pins.json').read_text())['pins']
outline=[(6.5,77),(16,77),(16,72),(60,72),(60,100.3),(6.5,100.3),(6.5,95.6),(14,95.6),(14,81.2),(6.5,81.2)]
mounts=[(9.635488,79.54),(55.355488,79.54),(9.635488,97.32),(55.355488,97.32)]
ties=[(40,74),(44,74),(51,74),(55,74)]
# Firmware GPIO numbers are deliberately NOT the Feather's default SPI pins.
wires=[('P1','VIN','3V3','JP1',15,94.5,None),('P2','GND','GND','JP1',13,94.5,None),
 ('P3','TFT_CS','TFT_CS','JP1',12,94.5,26),('P4','SD_CS','SD_CS','JP1',11,94.5,25),
 ('P5','LITE','LITE','JP1',7,94.5,4),('P6','MISO','MISO','JP1',4,94.5,21),
 ('P7','MOSI','MOSI','JP3',6,74.5,27),('P8','DC','DC','JP3',7,74.5,33),
 ('P9','RST','TFT_RST','JP3',9,74.5,32),('P10','SCK','SCK','JP3',10,74.5,14),
 ('P11','ANO_INT','ANO_INT','JP1',10,94.5,34)]
def position(h):return (X0-h['eagle_x_mm'],99.86-h['eagle_y_mm'])
def pin(head,num):return next(h for h in headers if h['header']==head and h['pin']==num)
netmap={(h,n):net for _,_,net,h,n,_,_ in wires}
