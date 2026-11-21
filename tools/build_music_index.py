#!/usr/bin/env python3
"""Build Harmony's read-only, paged catalog from an audited Swinsian copy plan."""
import argparse, json, struct, zlib, unicodedata
from pathlib import Path
MAGIC=b'HARMDB01'; RECORD=532; MAX_TRACKS=16384

def text(value,limit):
    value=unicodedata.normalize('NFKD',str(value or '')).encode('ascii','replace').decode()
    value=''.join(c if 32<=ord(c)<127 else ' ' for c in value)
    return value[:limit-1]
def fixed(value,size):
    b=value.encode('utf-8');assert len(b)<size,(value,size)
    return b+b'\0'*(size-len(b))
def build(plan):
    tracks=[]
    for source in plan['tracks']:
        path=source['destination'].removeprefix('HARMONY/')
        if Path(path).suffix.lower()!='.mp3':continue
        assert len(path.encode())<192 and all(p not in ('','.','..') for p in path.split('/')) and not any(c in path for c in '\\:'),path
        tracks.append(dict(path=path,title=text(source.get('title') or Path(path).stem,128),artist=text(source.get('artist') or 'Unknown artist',96),album=text(source.get('album') or 'Unknown album',96),disc=max(0,min(65535,source.get('discnumber') or 1)),number=max(0,min(65535,source.get('tracknumber') or 0)),duration=max(0,round(source.get('length') or 0))))
    if not tracks:raise ValueError("No available MP3 tracks to index")
    if len(tracks)>MAX_TRACKS:raise ValueError(f"Library has {len(tracks)} tracks; current firmware limit is {MAX_TRACKS}")
    tracks.sort(key=lambda t:(t['artist'].lower(),t['artist'],t['album'].lower(),t['album'],t['disc'],t['number'],t['path']))
    artists=[];albums=[];records=[]
    for i,t in enumerate(tracks):
        if not i or t['artist']!=tracks[i-1]['artist']:artists.append([i,0,len(albums),0])
        if not i or (t['artist'],t['album'])!=(tracks[i-1]['artist'],tracks[i-1]['album']):albums.append([i,0]);artists[-1][3]+=1
        artists[-1][1]+=1;albums[-1][1]+=1
        raw=b''.join(fixed(t[k],n) for k,n in [('path',192),('title',128),('artist',96),('album',96)])+struct.pack('<HHIII',t['disc'],t['number'],t['duration'],len(artists)-1,len(albums)-1)
        assert len(raw)==528
        records.append(raw+struct.pack('<I',zlib.crc32(raw)))
    art=b''.join(struct.pack('<4I',*a) for a in artists);alb=b''.join(struct.pack('<2I',*a) for a in albums)
    songs=b''.join(struct.pack('<I',i) for i in sorted(range(len(tracks)),key=lambda i:(tracks[i]['title'].lower(),i)))
    paths=b''.join(struct.pack('<I',i) for i in sorted(range(len(tracks)),key=lambda i:tracks[i]['path'].encode()))
    ao=64;bo=ao+len(art);so=bo+len(alb);po=so+len(songs);ro=po+len(paths);size=ro+len(tracks)*RECORD
    tables=art+alb+songs+paths
    h=MAGIC+struct.pack('<13I',1,len(tracks),len(artists),len(albums),RECORD,ao,bo,so,po,ro,size,zlib.crc32(tables),0)
    h+=struct.pack('<I',zlib.crc32(h));assert len(h)==64
    return h+tables+b''.join(records),dict(tracks=len(tracks),artists=len(artists),albums=len(albums),bytes=size)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('plan',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    data,summary=build(json.loads(a.plan.read_text()));a.output.parent.mkdir(parents=True,exist_ok=True)
    tmp=a.output.with_suffix('.tmp');tmp.write_bytes(data);tmp.replace(a.output);print(json.dumps(summary))
