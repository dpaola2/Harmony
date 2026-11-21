import importlib.util
import json
from pathlib import Path
import sqlite3
import sys
import tempfile
import unittest
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
import harmony_sync as sync

class HarmonySyncTest(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name);self.music=self.root/'music';self.music.mkdir();self.card=self.root/'card';self.card.mkdir();self.db=self.root/'Library.sqlite'
        c=sqlite3.connect(self.db);c.execute('CREATE TABLE library(uuid TEXT)');c.execute("INSERT INTO library VALUES ('test-library')")
        c.execute('CREATE TABLE track(track_id INTEGER,path TEXT,title TEXT,artist TEXT,album TEXT,discnumber INTEGER,tracknumber INTEGER,length REAL)');c.commit();c.close()
    def add(self,ident,name,title='Song'):
        p=self.music/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b'music-'+str(ident).encode())
        c=sqlite3.connect(self.db);c.execute('INSERT INTO track VALUES (?,?,?,?,?,?,?,?)',(ident,str(p),title,'Artist','Album',1,ident,120));c.commit();c.close();return p
    def run_sync(self,verify=False):return sync.synchronize(sync.inventory(self.db,self.music),self.card,verify,lambda _:None)
    def test_incremental_metadata_additions_and_removals(self):
        source=self.add(1,'song.mp3');first=self.run_sync();self.assertEqual(first['copied'],1)
        dest=self.card/'HARMONY/song.mp3';mtime=dest.stat().st_mtime_ns;old_index=(self.card/'HARMONY/library.hdb').read_bytes()
        second=self.run_sync();self.assertEqual((second['copied'],second['reused']),(0,1));self.assertEqual(dest.stat().st_mtime_ns,mtime)
        c=sqlite3.connect(self.db);c.execute("UPDATE track SET title='Corrected title'");c.commit();c.close();self.run_sync()
        self.assertNotEqual(old_index,(self.card/'HARMONY/library.hdb').read_bytes());self.assertEqual(dest.stat().st_mtime_ns,mtime)
        source.write_bytes(b'changed source bytes');self.assertEqual(self.run_sync()['copied'],1);self.assertEqual(dest.read_bytes(),source.read_bytes())
        self.add(2,'new.mp3');self.assertEqual(self.run_sync()['copied'],1)
        c=sqlite3.connect(self.db);c.execute('DELETE FROM track WHERE track_id=1');c.commit();c.close();result=self.run_sync()
        self.assertTrue(dest.exists());self.assertIn('HARMONY/song.mp3',result['removed_from_catalog_left_on_card'])
    def test_skip_missing_safe_names_and_collisions(self):
        self.add(1,'What?.mp3');self.add(2,'skip.flac');missing=self.add(3,'missing.mp3');missing.unlink()
        plan=sync.inventory(self.db,self.music);self.assertEqual(plan['summary']['mp3_tracks'],1);self.assertEqual(plan['summary']['missing_mp3'],1);self.assertEqual(plan['skipped_formats'],{'.flac':1});self.assertEqual(plan['tracks'][0]['destination'],'HARMONY/_safe/1.mp3')
    def test_conflicting_unmanaged_file_preserves_catalog(self):
        self.add(1,'song.mp3');self.run_sync();original=(self.card/'HARMONY/library.hdb').read_bytes()
        self.add(2,'new.mp3');(self.card/'HARMONY/new.mp3').write_bytes(b'other file')
        with self.assertRaises(FileExistsError):self.run_sync()
        self.assertEqual(original,(self.card/'HARMONY/library.hdb').read_bytes());self.assertEqual((self.card/'HARMONY/new.mp3').read_bytes(),b'other file')
    def test_verification_detects_same_size_corruption(self):
        self.add(1,'song.mp3');self.run_sync();p=self.card/'HARMONY/song.mp3';p.write_bytes(b'x'*p.stat().st_size)
        with self.assertRaises(FileExistsError):self.run_sync(verify=True)
    def test_resume_adopts_identical_existing_copy(self):
        p=self.add(1,'song.mp3');dest=self.card/'HARMONY/song.mp3';dest.parent.mkdir();dest.write_bytes(p.read_bytes())
        result=self.run_sync();self.assertEqual((result['copied'],result['reused']),(0,1));self.assertTrue((self.card/sync.MANIFEST).exists())
    def test_failed_copy_keeps_original_index(self):
        self.add(1,'song.mp3');self.run_sync();original=(self.card/'HARMONY/library.hdb').read_bytes()
        self.add(2,'new.mp3');plan=sync.inventory(self.db,self.music);(self.music/'new.mp3').write_bytes(b'changed after inventory')
        with self.assertRaises(ValueError):sync.synchronize(plan,self.card,progress=lambda _:None)
        self.assertEqual(original,(self.card/'HARMONY/library.hdb').read_bytes())
    def test_duplicate_library_paths_receive_distinct_safe_names(self):
        source=self.add(1,'song.mp3')
        c=sqlite3.connect(self.db);c.execute('INSERT INTO track VALUES (?,?,?,?,?,?,?,?)',(2,str(source),'Duplicate','Artist','Album',1,2,120));c.commit();c.close()
        plan=sync.inventory(self.db,self.music)
        self.assertEqual({t['destination'] for t in plan['tracks']},{'HARMONY/_safe/1.mp3','HARMONY/_safe/2.mp3'})
        self.assertFalse(sync.safe_relative('bad\x7fname.mp3'))
    def test_reject_traversal_and_wrong_library(self):
        with self.assertRaises(ValueError):sync.target_path(self.card,'HARMONY/../escape.mp3')
        self.add(1,'song.mp3');self.run_sync();p=self.card/sync.MANIFEST;manifest=json.loads(p.read_text());manifest['library_id']='other';p.write_text(json.dumps(manifest))
        with self.assertRaises(ValueError):self.run_sync()
if __name__=='__main__':unittest.main()
