from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon,Rectangle
import numpy as np,math
R=Path(__file__).resolve().parent
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11})
f,axes=plt.subplots(1,3,figsize=(21,7),gridspec_kw={'width_ratios':[1.5,1,1.2]});f.patch.set_facecolor('#f5f5ee')
def dim(ax,p,q,t,offset=(0,0)):
 p=np.array(p)+offset;q=np.array(q)+offset;ax.annotate('',xy=q,xytext=p,arrowprops={'arrowstyle':'<->','color':'#37556b','lw':1});m=(p+q)/2;ax.text(m[0],m[1],t,color='#24445a',ha='center',va='bottom',bbox=dict(facecolor='#f5f5ee',edgecolor='none',alpha=.9,pad=1),fontsize=9,rotation=90 if abs(p[0]-q[0])<.01 else 0)
a=axes[0];a.set_title('SIDE PROJECTION / millimeters',loc='left',fontweight='bold')
a.add_patch(Polygon([(0,0),(94,0),(94,80),(0,44)],fill=False,lw=2,color='#243642'))
a.add_patch(Rectangle((2.2,0),89.6,2.4,color='#54626a'))
ang=math.atan2(36,94);c=math.cos(ang);s=math.sin(ang)
def flat(u,n):return (u*c-n*s,44+u*s+n*c)
lcd=[flat(u,n) for u,n in [(31,-1.6),(92.011,-1.6),(92.011,-12.15048),(31,-12.15048)]]
a.add_patch(Polygon(lcd,color='#4284a5',alpha=.65));a.text(48,61,'Display envelope',rotation=21,color='#184761')
a.add_patch(Rectangle((39.905,29),50.8,1.57,color='#17865c'));a.add_patch(Rectangle((39.905,30.57),50.8,4.8,fill=False,linestyle='--',color='#17865c'))
a.text(42,36.5,'Upright Feather',color='#14623e')
for y in [51.34,53.88,61.5,74.2,76.74,81.82]:
 a.add_patch(Rectangle((y-1.6,11),3.2,18,color='#30383c'));a.add_patch(Rectangle((y-2,5.5),4,5.5,color='#dc9c48',alpha=.6))
a.add_patch(Rectangle((91.8,29.475),14.45,4.45,color='#57727b'))
a.plot([94,94],[25.5,38.5],color='#f5f5ee',lw=5);a.plot([91.8,106.25],[29.475,29.475],color='#57727b')
dim(a,(0,0),(94,0),'94 mm',(0,-7));dim(a,(0,0),(0,44),'44',( -6,0));dim(a,(94,0),(94,80),'80',(16,0))
dim(a,(35,2.4),(35,29),'26.6 mm floor to PCB');dim(a,(87,11),(87,29),'18 mm socket');a.annotate('3.1 mm floor gap\nbelow bend reserve',xy=(55,5.5),xytext=(5,21),arrowprops={'arrowstyle':'->'},fontsize=9)
a.text(4,85,'2.4 mm floor | 2.2 mm walls | 20.96 degree face',fontsize=10)
a.set(xlim=(-13,118),ylim=(-12,91));a.set_aspect('equal');a.axis('off')
a=axes[1];a.set_title('USB / rear opening detail',loc='left',fontweight='bold')
a.add_patch(Rectangle((13.3,25.5),15,13,facecolor='#dbe4e6',edgecolor='#263b45',lw=2))
a.add_patch(Rectangle((15.715,29.475),10.17,4.45,facecolor='#637b85',edgecolor='#243e4a'))
dim(a,(13.3,25.5),(28.3,25.5),'15 mm opening',(0,-2));dim(a,(28.3,25.5),(28.3,38.5),'13 mm',(2,0))
a.text(20.8,40.5,'Plug body: 10.17 x 4.45 mm',ha='center',fontsize=10)
a.text(20.8,21,'2.415 mm clearance per side\n3.975 mm below / 4.575 mm above\nBody length: 14.45 mm\nExposed tip: 6.86 mm',ha='center',va='top',fontsize=10,linespacing=1.8)
a.set(xlim=(7,35),ylim=(8,46));a.set_aspect('equal');a.axis('off')
a=axes[2];a.set_title('TRAY / top plan',loc='left',fontweight='bold')
a.add_patch(Rectangle((0,0),112,94,fill=False,lw=2))
a.add_patch(Rectangle((9.37,39.905),22.86,50.8,color='#15815a',alpha=.7));a.text(20.8,67,'Feather',rotation=90,ha='center',va='center',color='white')
a.add_patch(Rectangle((50,25),50.5,62.5,color='#9aa9b0',alpha=.7));a.text(75.25,55,'Battery\n50.5 x 62.5\n8.1 thick',ha='center')
a.add_patch(Rectangle((64,3),33.02,19.177,color='#d68b46'));a.text(80.51,11,'MPR121',ha='center',fontsize=9)
for x in [11.91,29.69]:
 for y in [42.445488,88.165488]:a.plot(x,y,'o',color='#f3cf72',ms=5)
a.add_patch(Rectangle((31.98,75.77),5.5,7.9,fill=False,edgecolor='#b77522',lw=2));a.text(38,85,'Battery plug\nallowance',fontsize=8)
dim(a,(0,0),(112,0),'112 mm',(0,-8));a.text(56,99,'REAR / USB',ha='center',fontsize=9);a.text(56,-17,'FRONT / capacitive controls',ha='center',fontsize=9)
a.set(xlim=(-5,117),ylim=(-22,104));a.set_aspect('equal');a.axis('off')
f.suptitle('HARMONY D REV B / DIMENSIONED MOUNTING REVIEW',fontsize=21,fontweight='bold',x=.04,ha='left',y=.99)
f.text(.04,.025,'Dimensions are nominal CAD values. Amber areas reserve plugs and wire bends. Actual cables and printed parts still require disconnected dry fitting.',fontsize=11)
f.tight_layout(rect=(0,.07,1,.94));f.savefig(R/'preview/rev-b-dimensions.png',dpi=240,facecolor=f.get_facecolor());f.savefig(R/'preview/rev-b-dimensions.svg',facecolor=f.get_facecolor())
