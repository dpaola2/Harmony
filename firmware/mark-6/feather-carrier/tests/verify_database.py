#!/usr/bin/env python3
"""Exercise disk-backed indexing beyond the legacy limit, without MP3 files."""
from pathlib import Path
import importlib.util,subprocess,tempfile,struct,zlib
P=Path(__file__).resolve().parents[1];ROOT=P.parents[2]
spec=importlib.util.spec_from_file_location('builder',ROOT/'tools/build_music_index.py');b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b)
tracks=[dict(destination=f'HARMONY/track-{i:05}.mp3',title=f'Title {17000-i:05}',artist=f'Artist {i//1000}',album=f'Album {i//600}',tracknumber=i%600+1,discnumber=1,length=180) for i in range(16384)]
data,summary=b.build({'tracks':tracks})
with tempfile.TemporaryDirectory(prefix='harmony-db-') as td:
 d=Path(td);exe=d/'test';root=d/'HARMONY';root.mkdir();db=root/'library.hdb'
 subprocess.run(['cc','-std=gnu11','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-pthread','-I'+str(P/'main'),str(P/'tests/test_database.c'),str(P/'main/album.c'),str(P/'main/album_metadata.c'),'-o',str(exe)],check=True)
 db.write_bytes(data);subprocess.run([str(exe),str(root)],check=True)
 for mode in ('header','truncate','tables','record'):
  bad=bytearray(data)
  if mode=='header':bad[12]^=1
  elif mode=='truncate':bad=bad[:-1]
  elif mode=='tables':bad[64]^=1
  else:bad[struct.unpack_from('<I',bad,44)[0]+532+192]^=1
  db.write_bytes(bad);subprocess.run([str(exe),str(root),'record' if mode=='record' else 'invalid'],check=True)
 # Same real UI implementation, now backed by the large database.
 db.write_bytes(data)
 fixture=(ROOT/'firmware/mark-7/pocket-player/tests/test_ui.c').read_text().replace('played[ALBUM_MAX_TRACKS]','played[ALBUM_INDEX_MAX_TRACKS]').replace('int main(void)','void original_main(void)')
 fixture+='''\nint main(int argc,char **argv){assert(argc==2);assert(album_load(argv[1],&library));reset();assert(select_item().page==PLAYER_UI_MUSIC);scroll(2);player_ui_view_t v=select_item();assert(v.total_count==16384);v=scroll(INT_MAX);assert(v.selected==16383);select_item();assert(played_count==16384&&played_start==16383);assert(audio.track==played[16383]);player_ui_update();player_ui_init();assert(audio.paused);assert(played_count>0&&played_count<=600);album_close(&library);puts("PASS database UI: 16,384-song navigation, full queue and paused album restore");}\n'''
 (d/'ui.c').write_text(fixture)
 subprocess.run(['cc','-std=gnu11','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-pthread','-DPLAYER_UI_ROWS=4','-I'+str(P/'main'),str(d/'ui.c'),*[str(P/'main'/f) for f in ('player_ui.c','player_prefs.c','album.c','album_metadata.c')],'-o',str(d/'ui')],check=True)
 subprocess.run([str(d/'ui'),str(root)],check=True)
print('Database tests passed',summary)
