#!/usr/bin/env python3
"""Harmony Sync: export Swinsian's MP3 library and player database to an SD card.

inspect is read-only. sync never formats the card or deletes removed songs.
Requires Python 3.10+ and macOS diskutil; no third-party Python packages.
"""
from __future__ import annotations
import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import plistlib
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import time
import unicodedata
from build_music_index import build

DEFAULT_DB=Path.home()/'Library/Application Support/Swinsian/Library.sqlite'
DEFAULT_MUSIC=Path.home()/'Music/Swinsian'
MANIFEST='.harmony-sync.json'

def sha256(path: Path) -> str:
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(4*1024*1024),b''):h.update(block)
    return h.hexdigest()

def safe_relative(path: str) -> bool:
    return bool(path) and not path.startswith('/') and len(path.encode('utf-8'))<192 and all(p not in ('','.','..') and not p.endswith((' ','.')) for p in path.split('/')) and not any(ord(c)<32 or ord(c)==127 or c in '\\:*?"<>|' for c in path)

def inventory(database: Path=DEFAULT_DB, music_root: Path=DEFAULT_MUSIC) -> dict:
    database=database.expanduser().resolve();music_root=music_root.expanduser().resolve()
    db=sqlite3.connect(database.as_uri()+'?mode=ro',uri=True);db.row_factory=sqlite3.Row
    try:
        db.execute('BEGIN')
        identity=str(db.execute('SELECT uuid FROM library LIMIT 1').fetchone()[0])
        rows=db.execute('SELECT track_id,path,title,artist,album,discnumber,tracknumber,length FROM track ORDER BY track_id').fetchall()
    finally:db.close()
    tracks=[];missing=[];skipped=Counter()
    for row in rows:
        t=dict(row);source=Path(t['path']).expanduser().resolve()
        if source.suffix.lower()!='.mp3':skipped[source.suffix.lower() or '(none)']+=1;continue
        if not source.is_file():missing.append(t);continue
        st=source.stat();t['path']=str(source);t['bytes']=st.st_size;t['mtime_ns']=st.st_mtime_ns
        if st.st_size>0xffffffff:raise ValueError(f'File exceeds FAT32 size limit: {source}')
        try:relative=str(source.relative_to(music_root))
        except ValueError:relative=f'_external/{t["track_id"]}/{source.name}'
        if not safe_relative(relative):relative=f'_safe/{t["track_id"]}.mp3'
        t['destination']='HARMONY/'+relative;tracks.append(t)
    # FAT names are case-insensitive. Give every colliding source its own ID.
    counts=Counter(unicodedata.normalize('NFC',t['destination']).casefold() for t in tracks)
    for t in tracks:
        if counts[unicodedata.normalize('NFC',t['destination']).casefold()]>1:t['destination']=f'HARMONY/_safe/{t["track_id"]}.mp3'
    if len({unicodedata.normalize('NFC',t['destination']).casefold() for t in tracks})!=len(tracks):raise ValueError('Unresolved destination collision')
    plan={'library_id':identity,'source_database':str(database),'tracks':tracks,'missing':missing,'skipped_formats':dict(skipped)}
    plan['summary']={'mp3_tracks':len(tracks),'bytes':sum(t['bytes'] for t in tracks),'missing_mp3':len(missing),'skipped_non_mp3':sum(skipped.values())}
    return plan

def atomic_write(path: Path,data: bytes) -> None:
    path.parent.mkdir(parents=True,exist_ok=True)
    fd,name=tempfile.mkstemp(prefix='.harmony-',dir=path.parent)
    temp=Path(name)
    try:
        with os.fdopen(fd,'wb') as f:f.write(data);f.flush();os.fsync(f.fileno())
        os.replace(temp,path)
    finally:temp.unlink(missing_ok=True)

def target_path(volume: Path,destination: str) -> Path:
    if not destination.startswith('HARMONY/') or not safe_relative(destination[8:]):raise ValueError(f'Unsafe destination: {destination}')
    path=volume/destination
    if not path.resolve().is_relative_to(volume.resolve()):raise ValueError(f'Destination escapes card: {path}')
    return path

def validate_card(volume: Path) -> None:
    info=plistlib.loads(subprocess.check_output(['diskutil','info','-plist',str(volume)]))
    if info.get('MountPoint')!=str(volume) or info.get('Internal',True) or not info.get('WritableVolume') or info.get('FilesystemType')!='msdos':
        raise ValueError('Choose the root of a mounted, writable, external FAT32 card. This command does not format disks.')
    if info.get('FilesystemName')!='MS-DOS FAT32':raise ValueError('The player requires FAT32.')

def synchronize(plan: dict,volume: Path,verify: bool=False,progress=print) -> dict:
    volume=volume.resolve()
    data,catalog=build(plan) # Validate all paths, metadata and capacity before writes.
    manifest_path=volume/MANIFEST
    previous=json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
    if previous and (previous.get('version')!=1 or previous.get('library_id')!=plan['library_id']):raise ValueError('Card belongs to another library or an unsupported sync manifest.')
    previous_entries=previous.get('tracks',[])
    owned={t['destination']:t for t in previous_entries}
    needed=sum(t['bytes'] for t in plan['tracks'] if not target_path(volume,t['destination']).exists())+len(data)+max((t['bytes'] for t in plan['tracks']),default=0)
    if shutil.disk_usage(volume).free<needed+64*1024*1024:raise ValueError('Not enough free space for this sync.')
    completed=[];copied=reused=0;started=time.monotonic()
    for i,t in enumerate(plan['tracks'],1):
        source=Path(t['path']);dest=target_path(volume,t['destination']);old=owned.get(t['destination'])
        before=source.stat()
        if (before.st_size,before.st_mtime_ns)!=(t['bytes'],t['mtime_ns']):raise ValueError(f'Source changed after inventory: {source}')
        unchanged=bool(old and old.get('path')==t['path'] and old.get('bytes')==t['bytes'] and old.get('mtime_ns')==t['mtime_ns'] and dest.is_file() and dest.stat().st_size==t['bytes'])
        if unchanged and (not verify or sha256(dest)==old['sha256']):
            digest=old['sha256'];reused+=1
        else:
            digest=sha256(source)
            existing=sha256(dest) if dest.is_file() else None
            if existing==digest:reused+=1
            else:
                if dest.exists() and not old:raise FileExistsError(f'Unmanaged file differs; left untouched: {dest}')
                if dest.exists() and old and existing!=old['sha256']:raise FileExistsError(f'Card file changed outside Harmony Sync; left untouched: {dest}')
                dest.parent.mkdir(parents=True,exist_ok=True)
                fd,name=tempfile.mkstemp(prefix='.harmony-copy-',dir=dest.parent);tmp=Path(name)
                try:
                    with source.open('rb') as src,os.fdopen(fd,'wb') as out:
                        shutil.copyfileobj(src,out,4*1024*1024);out.flush();os.fsync(out.fileno())
                    after=source.stat()
                    if (after.st_size,after.st_mtime_ns)!=(before.st_size,before.st_mtime_ns) or sha256(tmp)!=digest:raise IOError(f'Copy/source verification failed: {source}')
                    os.replace(tmp,dest);copied+=1
                finally:tmp.unlink(missing_ok=True)
        completed.append({**t,'sha256':digest})
        if i%100==0 or i==len(plan['tracks']):progress(f'{i}/{len(plan["tracks"])} tracks ready; {copied} copied, {reused} reused')
    removed=sorted(set(owned)-{t['destination'] for t in completed})
    manifest={'version':1,'library_id':plan['library_id'],'source_database':plan['source_database'],'tracks':completed}
    # Publish only after every music file succeeds. Existing catalog survives failures.
    atomic_write(volume/'HARMONY/library.hdb',data)
    atomic_write(manifest_path,(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n').encode())
    report={'summary':plan['summary'],'catalog':catalog,'copied':copied,'reused':reused,'removed_from_catalog_left_on_card':removed,'missing_mp3':plan['missing'],'skipped_formats':plan['skipped_formats'],'elapsed_seconds':round(time.monotonic()-started),'verification':'New/replaced copies SHA-256 checked; existing tracks fully hashed' if verify else 'New/replaced copies SHA-256 checked; managed unchanged files matched by source path, size, mtime and destination size'}
    atomic_write(volume/'harmony-sync-report.json',(json.dumps(report,ensure_ascii=False,indent=2)+'\n').encode())
    return report

def main() -> None:
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--library-db',type=Path,default=DEFAULT_DB)
    parser.add_argument('--music-root',type=Path,default=DEFAULT_MUSIC)
    sub=parser.add_subparsers(dest='command',required=True)
    inspect=sub.add_parser('inspect',help='Read-only inventory; do not modify the card')
    inspect.add_argument('--plan',type=Path,help='Save the complete inventory locally')
    sync=sub.add_parser('sync',help='Copy additions/changes and rebuild the database')
    sync.add_argument('--volume',type=Path,required=True,help='Mounted FAT32 card root, e.g. /Volumes/HARMONY')
    sync.add_argument('--verify',action='store_true',help='Also hash every unchanged destination file')
    args=parser.parse_args();plan=inventory(args.library_db,args.music_root)
    print(json.dumps(plan['summary'],indent=2))
    if args.command=='inspect':
        _,catalog=build(plan);print('Catalog:',json.dumps(catalog))
        if args.plan:atomic_write(args.plan,(json.dumps(plan,ensure_ascii=False,indent=2)+'\n').encode())
    else:
        volume=args.volume.expanduser().resolve();validate_card(volume)
        result=synchronize(plan,volume,args.verify)
        subprocess.run(['sync'],check=True)
        print(json.dumps(result,indent=2));print('Sync complete. Eject the card before removal.')
if __name__=='__main__':
    try:main()
    except (OSError,ValueError,AssertionError,sqlite3.Error,subprocess.CalledProcessError) as error:print(f'Harmony Sync stopped: {error}',file=sys.stderr);sys.exit(1)
