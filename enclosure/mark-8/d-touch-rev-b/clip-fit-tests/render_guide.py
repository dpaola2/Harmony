from pathlib import Path
import trimesh
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
R=Path(__file__).resolve().parent
fig=plt.figure(figsize=(12,5),facecolor='#f5f4ef')
for n,step in enumerate([1.0,1.5,2.0],1):
 m=trimesh.load(R/f'lcd-clip-step-{step:.1f}mm-{n}-notch.stl')
 ax=fig.add_subplot(1,3,n,projection='3d',computed_zorder=False)
 ax.set_facecolor('#f5f4ef');ax.add_collection3d(Poly3DCollection(m.triangles,facecolors='#397b9b',edgecolors='#234d61',linewidths=.12))
 ax.set_xlim(0,9);ax.set_ylim(0,7);ax.set_zlim(0,4);ax.set_box_aspect((9,7,4));ax.view_init(25,-65);ax.set_axis_off()
 ax.set_title(f'{step:.1f} mm step\n{n} edge notch'+('es' if n>1 else ''),fontsize=16)
fig.suptitle('LCD clip fit tests • print orientation',fontsize=22)
fig.text(.5,.08,'Flat screw-head side on bed. Raised tip faces the display when installed.',ha='center',fontsize=12)
fig.text(.5,.025,'Keep the existing 2 mm spacer and M2 × 6 screw. Test smallest step first on an intact post.',ha='center',fontsize=11)
fig.savefig(R/'stepped-clips-guide.png',dpi=180)
