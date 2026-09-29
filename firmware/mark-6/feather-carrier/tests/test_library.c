#define _DARWIN_C_SOURCE
#define _POSIX_C_SOURCE 200809L
#include "album.h"
#include "album_metadata.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>

static album_t library;
static char root[256];
static void full(char *out,const char *relative) {int n=snprintf(out,512,"%s/%s",root,relative);assert(n>0&&n<512);}
static void directory(const char *path) {char b[512];full(b,path);assert(!mkdir(b,0700));}
static FILE *file(const char *path) {char b[512];full(b,path);FILE *f=fopen(b,"wb");assert(f);return f;}
static void text_file(const char *path,const char *text) {FILE *f=file(path);fputs(text,f);fclose(f);}
static void remove_file(const char *path) {char b[512];full(b,path);assert(!unlink(b));}
static void be32(unsigned char *p,unsigned n) {p[0]=n>>24;p[1]=n>>16;p[2]=n>>8;p[3]=n;}
static void sync32(unsigned char *p,unsigned n) {p[0]=(n>>21)&127;p[1]=(n>>14)&127;p[2]=(n>>7)&127;p[3]=n&127;}
static void frame(FILE *f,const char *id,const unsigned char *value,size_t size,int version) {
    unsigned char h[10]={0};memcpy(h,id,4);if(version==4)sync32(h+4,(unsigned)size);else be32(h+4,(unsigned)size);
    fwrite(h,1,10,f);fwrite(value,1,size,f);
}
static void field(FILE *f,const char *id,const char *text,int version) {
    unsigned char v[200]={3};size_t n=strlen(text);assert(n+1<sizeof(v));memcpy(v+1,text,n);frame(f,id,v,n+1,version);
}
static void tagged(const char *path,const char *artist,const char *album,const char *title,const char *disc,const char *track,int version) {
    FILE *f=file(path);unsigned char h[10]={'I','D','3',0,0,0,0,0,0,0};h[3]=version;fwrite(h,1,10,f);
    field(f,"TPE1",artist,version);field(f,"TALB",album,version);field(f,"TIT2",title,version);
    field(f,"TPOS",disc,version);field(f,"TRCK",track,version);field(f,"TLEN","245500",version);
    long bytes=ftell(f)-10;sync32(h+6,(unsigned)bytes);rewind(f);fwrite(h,1,10,f);fclose(f);
}
static unsigned find_track(const char *path) {for(unsigned i=0;i<library.count;i++)if(!strcmp(library.tracks[i].path,path))return i;assert(0);return 0;}
static void remove_tree(const char *path) {
    DIR *d=opendir(path);assert(d);struct dirent *e;
    while((e=readdir(d))) {
        if(!strcmp(e->d_name,".")||!strcmp(e->d_name,".."))continue;
        char p[1024];snprintf(p,sizeof(p),"%s/%s",path,e->d_name);struct stat s;assert(!lstat(p,&s));
        if(S_ISDIR(s.st_mode))remove_tree(p);else assert(!unlink(p));
    }
    closedir(d);assert(!rmdir(path));
}
static void fresh(void) {
    if(*root)remove_tree(root);
    strcpy(root,"/tmp/harmony-library-XXXXXX");assert(mkdtemp(root));
}
static void metadata_tests(void) {
    fresh();directory("Folder artist");directory("Folder artist/Folder album");
    tagged("Folder artist/Folder album/01 B.mp3","Metadata artist","Shared album","Tagged B","2/2","1/8",3);
    tagged("Folder artist/Folder album/02 A.mp3","Metadata artist","Shared album","Tagged A","1/2","12/12",4);
    tagged("Other.mp3","Other artist","Shared album","Other","1","1",4);
    text_file("Folder artist/Folder album/03 Fallback.MP3", "no tags");
    text_file("README.txt","ignored");
    text_file("ALBUM.M3U","\xef\xbb\xbf#EXTM3U\r\nOther.mp3\r\nFolder artist/Folder album/02 A.mp3\n");
    text_file("Folder artist/Folder album/Local.m3u8","03 Fallback.MP3\n01 B.mp3\n");
    assert(album_load(root,&library));assert(library.count==4&&library.playlist_count==2&&library.skipped_files==1);
    unsigned a=find_track("Folder artist/Folder album/02 A.mp3"),b=find_track("Folder artist/Folder album/01 B.mp3");
    assert(a<b && library.tracks[a].disc_number==1 && library.tracks[a].track_number==12);
    assert(!strcmp(library.tracks[a].title,"Tagged A") && !strcmp(library.tracks[a].artist,"Metadata artist"));
    assert(library.tracks[a].duration_seconds==245);
    unsigned fallback=find_track("Folder artist/Folder album/03 Fallback.MP3");
    assert(!strcmp(library.tracks[fallback].title,"Fallback"));assert(!strcmp(library.tracks[fallback].artist,"Folder artist"));
    assert(!strcmp(library.tracks[fallback].album,"Folder album") && library.tracks[fallback].track_number==3);
    assert(!strcmp(library.playlists[0].name,"ALBUM"));
    assert(library.playlists[0].track_indices[0]==find_track("Other.mp3") && library.playlists[0].track_indices[1]==a);
    assert(library.playlists[1].track_indices[0]==fallback && library.playlists[1].track_indices[1]==b);
    /* Reader opened no files for writing: original bytes remain unchanged. */
    char path[512];full(path,"README.txt");FILE *f=fopen(path,"rb");assert(f);char buf[8]={0};assert(fread(buf,1,7,f)==7);fclose(f);assert(!strcmp(buf,"ignored"));
    const char *bad[]={"../Other.mp3\n","/Other.mp3\n","https://x/Other.mp3\n","C:\\Other.mp3\n","./Other.mp3\n","a//Other.mp3\n","missing.mp3\n","Other.wav\n"};
    for(unsigned i=0;i<sizeof(bad)/sizeof(*bad);i++) {
        text_file("Bad.m3u",bad[i]);assert(!album_load(root,&library));assert(library.status==ALBUM_STATUS_INVALID_PLAYLIST&&!library.count&&!library.playlist_count);
    }
    remove_file("Bad.m3u");
    FILE *nul=file("Bad.m3u");const char hidden[]="Other.mp3\0bad.mp3\n";fwrite(hidden,1,sizeof(hidden)-1,nul);fclose(nul);
    assert(!album_load(root,&library)&&library.status==ALBUM_STATUS_INVALID_PLAYLIST);remove_file("Bad.m3u");
}
static void tag_encoding_tests(void) {
    album_track_t fallback={0};strcpy(fallback.path,"Third Eye Blind/Third Eye Blind/01-14 God Of Wine.mp3");
    album_track_fallback(&fallback);assert(fallback.disc_number==1&&fallback.track_number==14);
    assert(!strcmp(fallback.title,"God Of Wine"));
    fresh();FILE *f=file("01 Unicode.mp3");
    unsigned char h[10]={'I','D','3',4,0,0,0,0,0,0};fwrite(h,1,10,f);
    const unsigned char utf16[]={1,255,254,'H',0,'i',0,' ',0,0xe9,0};frame(f,"TIT2",utf16,sizeof(utf16),4);
    field(f,"TPE1","Bj\xc3\xb6rk",4);
    long end=ftell(f);sync32(h+6,(unsigned)(end-10));rewind(f);fwrite(h,1,10,f);fclose(f);
    assert(album_load(root,&library));assert(!strcmp(library.tracks[0].title,"Hi ?")&&!strcmp(library.tracks[0].artist,"Bj?rk"));
    f=file("02 Malformed.mp3");unsigned char bad[10]={'I','D','3',3,0,0,127,127,127,127};fwrite(bad,1,10,f);fclose(f);
    assert(album_load(root,&library));assert(library.metadata_warnings==1);assert(!strcmp(library.tracks[find_track("02 Malformed.mp3")].title,"Malformed"));
    f=file("03 Legacy.mp3");unsigned char v1[128]={0};memcpy(v1,"TAG",3);memcpy(v1+3,"Legacy title",12);memcpy(v1+33,"Legacy artist",13);memcpy(v1+63,"Legacy album",12);v1[126]=9;fwrite(v1,1,128,f);fclose(f);
    assert(album_load(root,&library));unsigned legacy=find_track("03 Legacy.mp3");assert(!strcmp(library.tracks[legacy].title,"Legacy title")&&library.tracks[legacy].track_number==9);
    f=file("04 Duration.mp3");unsigned char mp3[256]={255,251,144,0};memcpy(mp3+36,"Xing",4);be32(mp3+40,1);be32(mp3+44,10000);fwrite(mp3,1,256,f);fclose(f);
    assert(album_load(root,&library));assert(library.tracks[find_track("04 Duration.mp3")].duration_seconds==261);
    f=file("05 Malformed frame.mp3");memset(h,0,10);memcpy(h,"ID3",3);h[3]=4;sync32(h+6,10);fwrite(h,1,10,f);memcpy(h,"TIT2",4);sync32(h+4,100);h[8]=h[9]=0;fwrite(h,1,10,f);fclose(f);
    assert(album_load(root,&library));assert(library.metadata_warnings==2);
    f=file("06 Huge frame.mp3");memset(h,0,10);memcpy(h,"ID3",3);h[3]=3;sync32(h+6,10);fwrite(h,1,10,f);
    memcpy(h,"TIT2",4);be32(h+4,0xffffffffU);h[8]=h[9]=0;fwrite(h,1,10,f);fclose(f);
    assert(album_load(root,&library));assert(library.metadata_warnings==3);
}
static void limit_tests(void) {
    fresh();assert(!album_load(root,&library)&&library.status==ALBUM_STATUS_EMPTY);
    for(unsigned i=0;i<512;i++){char p[32];snprintf(p,sizeof(p),"%03u.mp3",i);text_file(p,"");}
    assert(album_load(root,&library)&&library.count==512);
    text_file("overflow.mp3","");assert(!album_load(root,&library)&&library.status==ALBUM_STATUS_CAPACITY&&!library.count);remove_file("overflow.mp3");
    for(unsigned i=0;i<16;i++){char p[32];snprintf(p,sizeof(p),"%u.m3u",i);text_file(p,"001.mp3\n");}
    assert(album_load(root,&library)&&library.playlist_count==16);
    text_file("overflow.m3u","001.mp3\n");assert(!album_load(root,&library)&&library.status==ALBUM_STATUS_CAPACITY);remove_file("overflow.m3u");
    FILE *p=file("0.m3u");for(unsigned i=0;i<513;i++)fputs("001.mp3\n",p);fclose(p);
    assert(!album_load(root,&library)&&library.status==ALBUM_STATUS_CAPACITY);
    fresh();text_file("Song.mp3","");char linked[512];full(linked,"outside.mp3");assert(!symlink("/etc/passwd",linked));
    assert(album_load(root,&library)&&library.count==1&&library.skipped_files==1);
    char depth[64]="";for(unsigned i=0;i<9;i++){strcat(depth,i?"/d":"d");directory(depth);}
    assert(!album_load(root,&library)&&library.status==ALBUM_STATUS_TOO_DEEP);
    fresh();text_file("Song.mp3","");
    for(unsigned i=0;i<128;i++){char p[32];snprintf(p,sizeof(p),"dir%u",i);directory(p);}
    assert(!album_load(root,&library)&&library.status==ALBUM_STATUS_CAPACITY);
    remove_tree(root);root[0]=0;
    assert(!album_load("/tmp/harmony-no-such-library-folder",&library)&&library.status==ALBUM_STATUS_MISSING);
    assert(!album_load(NULL,&library)&&library.status==ALBUM_STATUS_MISSING);
}
int main(void) {
    metadata_tests();tag_encoding_tests();limit_tests();
    printf("PASS library: metadata, fallbacks, ordered safe M3U, capacities, Unicode, malformed tags, missing/empty storage; album_t=%zu bytes\n",sizeof(album_t));
}
