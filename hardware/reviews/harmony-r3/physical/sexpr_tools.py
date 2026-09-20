"""Locate balanced KiCad expressions without reformatting unrelated source."""
def spans(s,token):
 import re
 for m in re.finditer(r'\('+re.escape(token)+r'(?=\s|\))',s):
  i=m.start();depth=0;quoted=False;escape=False
  for j in range(i,len(s)):
   c=s[j]
   if quoted:
    if escape:escape=False
    elif c=='\\':escape=True
    elif c=='"':quoted=False
   elif c=='"':quoted=True
   elif c=='(':depth+=1
   elif c==')':
    depth-=1
    if depth==0:yield i,j+1;break
