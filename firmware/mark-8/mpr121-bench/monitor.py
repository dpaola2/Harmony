"""Capture a bounded touch-bench session. No firmware writes."""
import argparse,time,serial
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--seconds',type=int,default=600);p.add_argument('--reset',action='store_true');p.add_argument('--log',required=True);a=p.parse_args()
s=serial.Serial('/dev/cu.usbserial-5B1E0643571',115200,timeout=.2)
if a.reset:
 s.dtr=False;s.rts=True;time.sleep(.1);s.rts=False
end=time.monotonic()+a.seconds
with Path(a.log).open('a',buffering=1) as f:
 while time.monotonic()<end:
  line=s.readline().decode(errors='replace')
  if line:f.write(line)
s.close()
