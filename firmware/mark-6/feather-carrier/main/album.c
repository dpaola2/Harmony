#include "album.h"
#include <string.h>
#include <strings.h>

static bool valid_path(const char *s)
{
    size_t n = strlen(s);
    if (n < 5 || n >= ALBUM_PATH_MAX || s[0] == '/' ||
        strcasecmp(s + n - 4, ".mp3")) return false;
    const char *part = s;
    for (const char *p = s;; ++p) {
        unsigned char c = (unsigned char)*p;
        if (c == '\\' || c == ':' || (c && c < 32) || c == 127) return false;
        if (!c || c == '/') {
            size_t len = (size_t)(p - part);
            if (!len || (len == 1 && part[0] == '.') ||
                (len == 2 && part[0] == '.' && part[1] == '.')) return false;
            part = p + 1;
        }
        if (!c) return true;
    }
}

bool album_parse(FILE *file, album_t *album)
{
    memset(album, 0, sizeof(*album));
    char line[512];
    bool first = true;
    for (;;) {
        size_t n = 0;
        int c;
        while ((c = fgetc(file)) != EOF && c != '\n') {
            if (!c || n + 1 >= sizeof(line)) goto invalid;
            line[n++] = (char)c;
        }
        if (ferror(file)) goto invalid;
        if (c == EOF && !n) break;
        if (n && line[n-1] == '\r') --n;
        line[n] = 0;
        char *path = line;
        if (first && n >= 3 && !memcmp(path, "\xef\xbb\xbf", 3)) path += 3;
        first = false;
        if (!*path || *path == '#') continue;
        if (album->count == ALBUM_MAX_TRACKS || !valid_path(path)) goto invalid;
        album_track_t *t = &album->tracks[album->count++];
        strcpy(t->path, path);
        const char *base = strrchr(path, '/');
        base = base ? base + 1 : path;
        size_t title_len = strlen(base) - 4;
        if (title_len >= sizeof(t->title)) title_len = sizeof(t->title) - 1;
        /* The current bitmap font is ASCII. Keep the actual filename untouched. */
        for (size_t i = 0; i < title_len; ++i)
            t->title[i] = (unsigned char)base[i] < 127 ? base[i] : '?';
        t->title[title_len] = 0;
    }
    if (!ferror(file) && album->count) return true;
invalid:
    memset(album, 0, sizeof(*album));
    return false;
}

#include "album_metadata.h"
#include <dirent.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/stat.h>

#define LIBRARY_MAX_DIRECTORIES 128
#define LIBRARY_MAX_DEPTH 8
#define FULL_PATH_MAX 512

typedef struct {
    char directories[LIBRARY_MAX_DIRECTORIES][ALBUM_PATH_MAX];
    unsigned char depth[LIBRARY_MAX_DIRECTORIES];
    char playlist_paths[ALBUM_MAX_PLAYLISTS][ALBUM_PATH_MAX];
    unsigned directory_count, playlist_count;
} load_scratch_t;

const char *album_status_text(album_status_t s) {
    switch(s) {
    case ALBUM_STATUS_OK:return "Library ready";
    case ALBUM_STATUS_MISSING:return "Music folder missing. Check SD card.";
    case ALBUM_STATUS_EMPTY:return "No MP3 files in HARMONY.";
    case ALBUM_STATUS_CAPACITY:return "Library limit: 512 songs, 16 playlists, 128 folders.";
    case ALBUM_STATUS_INVALID_PLAYLIST:return "Invalid M3U. Use relative MP3 paths.";
    case ALBUM_STATUS_PATH_TOO_LONG:return "Music path too long. Shorten folders.";
    case ALBUM_STATUS_TOO_DEEP:return "Music folders exceed eight levels.";
    default:return "Cannot read library. Check SD card.";
    }
}
static bool suffix(const char *s,const char *ext) {
    size_t n=strlen(s),m=strlen(ext);return n>=m && !strcasecmp(s+n-m,ext);
}
static bool join_path(char *out,size_t cap,const char *a,const char *b) {
    int n=snprintf(out,cap,"%s%s%s",a,*a?"/":"",b);return n>=0 && (size_t)n<cap;
}
static int track_order(const void *aa,const void *bb) {
    const album_track_t *a=aa,*b=bb;int c=strcasecmp(a->artist,b->artist);
    if(!c)c=strcasecmp(a->album,b->album);
    unsigned ad=a->disc_number?a->disc_number:1,bd=b->disc_number?b->disc_number:1;
    if(!c && ad!=bd)c=ad<bd?-1:1;
    if(!c && a->track_number!=b->track_number)c=a->track_number<b->track_number?-1:1;
    return c?c:strcmp(a->path,b->path);
}
static int playlist_order(const void *aa,const void *bb) {
    const album_playlist_t *a=aa,*b=bb;return strcasecmp(a->name,b->name);
}
static bool scan_directory(const char *root,album_t *a,load_scratch_t *s,unsigned index) {
    char full[FULL_PATH_MAX];
    if(!join_path(full,sizeof(full),root,s->directories[index])) {a->status=ALBUM_STATUS_PATH_TOO_LONG;return false;}
    DIR *dir=opendir(full);
    if(!dir) {a->status=index==0 && errno==ENOENT?ALBUM_STATUS_MISSING:ALBUM_STATUS_IO_ERROR;return false;}
    bool ok=true;
    for(;;) {
        errno=0;struct dirent *entry=readdir(dir);
        if(!entry) {if(errno){a->status=ALBUM_STATUS_IO_ERROR;ok=false;}break;}
        if(entry->d_name[0]=='.')continue;
        char relative[ALBUM_PATH_MAX];
        if(!join_path(relative,sizeof(relative),s->directories[index],entry->d_name) ||
           !join_path(full,sizeof(full),root,relative)) {a->status=ALBUM_STATUS_PATH_TOO_LONG;ok=false;break;}
        struct stat st;
#ifdef ESP_PLATFORM
        int result=stat(full,&st); /* FAT volumes have no symbolic links. */
#else
        int result=lstat(full,&st);
#endif
        if(result) {a->status=ALBUM_STATUS_IO_ERROR;ok=false;break;}
#ifndef ESP_PLATFORM
        if(S_ISLNK(st.st_mode)) {a->skipped_files++;continue;}
#endif
        if(S_ISDIR(st.st_mode)) {
            if(s->depth[index]>=LIBRARY_MAX_DEPTH) {a->status=ALBUM_STATUS_TOO_DEEP;ok=false;break;}
            if(s->directory_count==LIBRARY_MAX_DIRECTORIES) {a->status=ALBUM_STATUS_CAPACITY;ok=false;break;}
            unsigned next=s->directory_count++;strcpy(s->directories[next],relative);s->depth[next]=s->depth[index]+1;
        } else if(S_ISREG(st.st_mode) && suffix(relative,".mp3")) {
            if(!valid_path(relative)) {a->status=ALBUM_STATUS_INVALID_PLAYLIST;ok=false;break;}
            if(a->count==ALBUM_MAX_TRACKS) {a->status=ALBUM_STATUS_CAPACITY;ok=false;break;}
            album_track_t *t=&a->tracks[a->count];strcpy(t->path,relative);album_track_fallback(t);
            FILE *f=fopen(full,"rb");if(!f) {a->status=ALBUM_STATUS_IO_ERROR;ok=false;break;}
            if(!album_track_metadata(f,t))a->metadata_warnings++;
            bool failed=ferror(f)!=0;fclose(f);
            if(failed) {a->status=ALBUM_STATUS_IO_ERROR;ok=false;break;}
            a->count++;
        } else if(S_ISREG(st.st_mode) && (suffix(relative,".m3u")||suffix(relative,".m3u8"))) {
            if(s->playlist_count==ALBUM_MAX_PLAYLISTS) {a->status=ALBUM_STATUS_CAPACITY;ok=false;break;}
            strcpy(s->playlist_paths[s->playlist_count++],relative);
        } else a->skipped_files++;
    }
    closedir(dir);return ok;
}
static bool load_playlist(const char *root,album_t *a,const char *relative) {
    char full[FULL_PATH_MAX],directory[ALBUM_PATH_MAX];
    if(!join_path(full,sizeof(full),root,relative)){a->status=ALBUM_STATUS_PATH_TOO_LONG;return false;}
    FILE *f=fopen(full,"rb");if(!f){a->status=ALBUM_STATUS_IO_ERROR;return false;}
    strcpy(directory,relative);char *slash=strrchr(directory,'/');if(slash)*slash=0;else directory[0]=0;
    album_playlist_t *p=&a->playlists[a->playlist_count];
    size_t n=strlen(relative)-(suffix(relative,".m3u8")?5:4),w=0;
    for(size_t i=0;i<n && w+1<sizeof(p->name);i++) {
        unsigned char c=(unsigned char)relative[i];if((c&0xc0)==0x80)continue;
        p->name[w++]=(c>=32&&c<127)?(char)c:'?';
    }
    p->name[w]=0;bool first=true,ok=true;
    for(;;) {
        char line[512];size_t len=0;int c;
        while((c=fgetc(f))!=EOF && c!='\n') {
            if(!c || len+1>=sizeof(line)){ok=false;break;}line[len++]=(char)c;
        }
        if(!ok || ferror(f)){ok=false;break;}
        if(c==EOF && !len)break;
        if(len && line[len-1]=='\r')len--;
        line[len]=0;
        char *path=line;
        if(first && len>=3 && !memcmp(path,"\xef\xbb\xbf",3))path+=3;
        first=false;if(!*path || *path=='#')continue;
        char combined[ALBUM_PATH_MAX];
        if(!valid_path(path) || !join_path(combined,sizeof(combined),directory,path) || !valid_path(combined)) {ok=false;break;}
        unsigned found=0;while(found<a->count && strcmp(a->tracks[found].path,combined))found++;
        if(found==a->count){ok=false;break;}
        if(p->count==ALBUM_MAX_TRACKS){a->status=ALBUM_STATUS_CAPACITY;ok=false;break;}
        p->track_indices[p->count++]=(uint16_t)found;
    }
    bool io=ferror(f)!=0;fclose(f);
    if(!ok){if(a->status==ALBUM_STATUS_OK)a->status=io?ALBUM_STATUS_IO_ERROR:ALBUM_STATUS_INVALID_PLAYLIST;return false;}
    a->playlist_count++;return true;
}
static int database_open(const char *root, album_t *a);
bool album_load(const char *root,album_t *a) {
    if(!a)return false;
    memset(a,0,sizeof(*a));
    if(!root || !*root) {a->status=ALBUM_STATUS_MISSING;return false;}
    int indexed=database_open(root,a);
    if(indexed)return indexed>0;
    load_scratch_t *s=calloc(1,sizeof(*s));
    if(!s){a->status=ALBUM_STATUS_IO_ERROR;return false;}
    s->directory_count=1;bool ok=true;
    for(unsigned i=0;i<s->directory_count && ok;i++)ok=scan_directory(root,a,s,i);
    if(ok && !a->count){a->status=ALBUM_STATUS_EMPTY;ok=false;}
    if(ok) {
        qsort(a->tracks,a->count,sizeof(a->tracks[0]),track_order);
        for(unsigned i=0;i<s->playlist_count && ok;i++)ok=load_playlist(root,a,s->playlist_paths[i]);
        if(ok)qsort(a->playlists,a->playlist_count,sizeof(a->playlists[0]),playlist_order);
    }
    free(s);
    if(!ok){a->count=0;a->playlist_count=0;}
    return ok;
}

/* HARMDB01: little-endian tables plus independently checked fixed records.
 * Only navigation IDs/tables and sixteen recently used records occupy RAM. */
#ifdef ESP_PLATFORM
#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"
#include "esp_heap_caps.h"
typedef SemaphoreHandle_t db_mutex_t;
#define DB_LOCK(d) xSemaphoreTake((d)->mutex,portMAX_DELAY)
#define DB_UNLOCK(d) xSemaphoreGive((d)->mutex)
static void *db_alloc(size_t n) {return heap_caps_calloc(1,n,MALLOC_CAP_SPIRAM|MALLOC_CAP_8BIT);}
#else
#include <pthread.h>
typedef pthread_mutex_t db_mutex_t;
#define DB_LOCK(d) pthread_mutex_lock(&(d)->mutex)
#define DB_UNLOCK(d) pthread_mutex_unlock(&(d)->mutex)
static void *db_alloc(size_t n) {return calloc(1,n);}
#endif
#define DB_RECORD 532u
#define DB_CACHE 16u
typedef struct {
    char path[512];
    unsigned count, artists, albums, records, next;
    uint32_t *table, *artist, *album, *songs, *paths;
    struct {bool valid;unsigned id,artist,album;album_track_t track;} cache[DB_CACHE];
    char (*labels)[96]; /* Artist names followed by album names; immutable after load. */
    db_mutex_t mutex;
} database_t;
static uint32_t le32(const unsigned char *p) {return (uint32_t)p[0]|(uint32_t)p[1]<<8|(uint32_t)p[2]<<16|(uint32_t)p[3]<<24;}
static uint32_t crc32_bytes(const unsigned char *p,size_t n) {
    uint32_t c=~0u;
    for(size_t i=0;i<n;i++){c^=p[i];for(unsigned j=0;j<8;j++)c=(c>>1)^(0xedb88320u&-(c&1));}
    return ~c;
}
static int database_open(const char *root,album_t *a) {
    char path[512];if(!join_path(path,sizeof(path),root,"library.hdb"))return -1;
    FILE *f=fopen(path,"rb");if(!f){if(errno==ENOENT)return 0;a->status=ALBUM_STATUS_IO_ERROR;return -1;}
    unsigned char h[64];database_t *d=NULL;bool ok=false;
    if(fread(h,1,64,f)!=64||memcmp(h,"HARMDB01",8)||le32(h+8)!=1||le32(h+60)!=crc32_bytes(h,60))goto finish;
    unsigned n=le32(h+12),ar=le32(h+16),al=le32(h+20);
    if(!n||n>ALBUM_INDEX_MAX_TRACKS||!ar||ar>al||al>n||le32(h+24)!=DB_RECORD)goto finish;
    unsigned ao=64,bo=ao+ar*16,so=bo+al*8,po=so+n*4,ro=po+n*4,size=ro+n*DB_RECORD;
    if(le32(h+28)!=ao||le32(h+32)!=bo||le32(h+36)!=so||le32(h+40)!=po||le32(h+44)!=ro||le32(h+48)!=size)goto finish;
    if(fseek(f,0,SEEK_END)||ftell(f)!=(long)size||fseek(f,64,SEEK_SET))goto finish;
    d=db_alloc(sizeof(*d));if(!d)goto finish;
    d->table=db_alloc(ro-64);if(!d->table)goto finish;
    if(fread(d->table,1,ro-64,f)!=ro-64||crc32_bytes((unsigned char *)d->table,ro-64)!=le32(h+52))goto finish;
    /* Decode in place, also on big-endian hosts. */
    for(unsigned i=0;i<(ro-64)/4;i++)d->table[i]=le32((unsigned char *)d->table+i*4);
    d->artist=d->table;d->album=d->table+ar*4;d->songs=d->album+al*2;d->paths=d->songs+n;
    unsigned end=0,album_end=0;
    for(unsigned i=0;i<ar;i++) {uint32_t *t=d->artist+i*4;if(t[0]!=end||!t[1]||t[1]>n-end||t[2]!=album_end||!t[3]||t[3]>al-album_end)goto finish;end+=t[1];album_end+=t[3];}
    if(end!=n||album_end!=al)goto finish;
    end=0;for(unsigned i=0;i<al;i++){uint32_t *t=d->album+i*2;if(t[0]!=end||!t[1]||t[1]>n-end)goto finish;end+=t[1];}if(end!=n)goto finish;
    unsigned char *seen=calloc(n,1);if(!seen)goto finish;
    for(unsigned pass=0;pass<2;pass++) {memset(seen,0,n);uint32_t *list=pass?d->paths:d->songs;for(unsigned i=0;i<n;i++){if(list[i]>=n||seen[list[i]]){free(seen);goto finish;}seen[list[i]]=1;}}free(seen);
    d->count=n;d->artists=ar;d->albums=al;d->records=ro;strcpy(d->path,path);
    /* Keep group navigation independent of SD reads during playback. Bound this
     * optional cache so pathological catalogs retain the paged fallback. */
    if ((ar+al)*96u <= 256u*1024u) {
        d->labels=db_alloc((ar+al)*96u);
        if(d->labels) {
            unsigned artist_index=0;
            for(unsigned i=0;i<al;i++) {
                unsigned char raw[DB_RECORD];unsigned id=d->album[i*2];
                while(artist_index+1<ar && id>=d->artist[(artist_index+1)*4])artist_index++;
                if(fseek(f,ro+id*DB_RECORD,SEEK_SET)||fread(raw,1,sizeof(raw),f)!=sizeof(raw)||
                   crc32_bytes(raw,528)!=le32(raw+528)||!memchr(raw+320,0,96)||!memchr(raw+416,0,96)||
                   le32(raw+520)!=artist_index||le32(raw+524)!=i)goto finish;
                memcpy(d->labels[artist_index],raw+320,96);
                memcpy(d->labels[ar+i],raw+416,96);
            }
        }
    }

#ifdef ESP_PLATFORM
    d->mutex=xSemaphoreCreateMutex();if(!d->mutex)goto finish;
#else
    if(pthread_mutex_init(&d->mutex,NULL))goto finish;
#endif
    a->database=d;a->count=n;a->status=ALBUM_STATUS_OK;ok=true;
finish:
    fclose(f);if(!ok){if(d){free(d->labels);free(d->table);free(d);}a->status=ALBUM_STATUS_IO_ERROR;}return ok?1:-1;
}
static bool database_read(database_t *d,unsigned id,album_track_t *out,unsigned *artist,unsigned *album) {
    if(id>=d->count)return false;
    bool ok=false;DB_LOCK(d);
    unsigned slot=DB_CACHE;
    for(unsigned i=0;i<DB_CACHE;i++)if(d->cache[i].valid&&d->cache[i].id==id){slot=i;break;}
    if(slot==DB_CACHE) {
        unsigned char raw[DB_RECORD];FILE *f=fopen(d->path,"rb");if(!f)goto finish;
        bool read_ok=!fseek(f,d->records+id*DB_RECORD,SEEK_SET)&&fread(raw,1,sizeof(raw),f)==sizeof(raw);fclose(f);
        if(!read_ok||crc32_bytes(raw,528)!=le32(raw+528))goto finish;
        if(!memchr(raw,0,192)||!memchr(raw+192,0,128)||!memchr(raw+320,0,96)||!memchr(raw+416,0,96)||!valid_path((char *)raw))goto finish;
        unsigned ar=le32(raw+520),al=le32(raw+524);
        if(ar>=d->artists||al>=d->albums||id<d->artist[ar*4]||id>=d->artist[ar*4]+d->artist[ar*4+1]||id<d->album[al*2]||id>=d->album[al*2]+d->album[al*2+1]||al<d->artist[ar*4+2]||al>=d->artist[ar*4+2]+d->artist[ar*4+3])goto finish;
        slot=d->next++%DB_CACHE;album_track_t *t=&d->cache[slot].track;
        memcpy(t->path,raw,192);memcpy(t->title,raw+192,128);memcpy(t->artist,raw+320,96);memcpy(t->album,raw+416,96);
        t->disc_number=raw[512]|raw[513]<<8;t->track_number=raw[514]|raw[515]<<8;t->duration_seconds=le32(raw+516);
        d->cache[slot].id=id;d->cache[slot].artist=ar;d->cache[slot].album=al;d->cache[slot].valid=true;
    }
    *out=d->cache[slot].track;if(artist)*artist=d->cache[slot].artist;if(album)*album=d->cache[slot].album;ok=true;
finish:
    DB_UNLOCK(d);return ok;
}
bool album_read_track(const album_t *a,unsigned id,album_track_t *out) {
    memset(out,0,sizeof(*out));if(!a||id>=a->count)return false;
    if(a->database)return database_read(a->database,id,out,NULL,NULL);
    if(id>=ALBUM_MAX_TRACKS)return false;
    *out=a->tracks[id];return true;
}
/* Group tables are contiguous ranges, so no record I/O is needed to locate a group. */
static unsigned group_index(const uint32_t *table,unsigned count,unsigned stride,unsigned id) {
    unsigned lo=0,hi=count;
    while(lo+1<hi){unsigned mid=lo+(hi-lo)/2;if(table[mid*stride]<=id)lo=mid;else hi=mid;}
    return lo;
}
bool album_read_labels(const album_t *a,unsigned id,album_track_t *out) {
    memset(out,0,sizeof(*out));if(!a||id>=a->count)return false;
    database_t *d=a->database;
    if(!d||!d->labels)return album_read_track(a,id,out);
    unsigned ar=group_index(d->artist,d->artists,4,id),al=group_index(d->album,d->albums,2,id);
    memcpy(out->artist,d->labels[ar],96);memcpy(out->album,d->labels[d->artists+al],96);
    return true;
}
unsigned album_query(const album_t *a,album_query_t q,unsigned representative,unsigned *ids,unsigned capacity) {
    if(!a||!a->database||!ids)return 0;
    database_t *d=a->database;unsigned count=0,start=0;unsigned ar=0,al=0;
    if(q==ALBUM_QUERY_SONGS||(q==ALBUM_QUERY_ALBUMS&&representative<a->count)){if(representative>=d->count)return 0;ar=group_index(d->artist,d->artists,4,representative);al=group_index(d->album,d->albums,2,representative);}
    if(q==ALBUM_QUERY_ARTISTS)count=d->artists;
    else if(q==ALBUM_QUERY_ALL)count=d->count;
    else if(q==ALBUM_QUERY_SONGS){start=d->album[al*2];count=d->album[al*2+1];}
    else if(q==ALBUM_QUERY_ALBUMS){if(representative<a->count){start=d->artist[ar*4+2];count=d->artist[ar*4+3];}else count=d->albums;}
    if(count>capacity)return 0;
    for(unsigned i=0;i<count;i++)ids[i]=q==ALBUM_QUERY_ARTISTS?d->artist[i*4]:q==ALBUM_QUERY_ALBUMS?d->album[(start+i)*2]:q==ALBUM_QUERY_ALL?d->songs[i]:start+i;
    return count;
}
int album_find_path(const album_t *a,const char *path) {
    if(!a||!*path)return -1;
    album_track_t t;
    if(!a->database){for(unsigned i=0;i<a->count;i++)if(!strcmp(a->tracks[i].path,path))return (int)i;return -1;}
    database_t *d=a->database;unsigned lo=0,hi=d->count;
    while(lo<hi){unsigned mid=lo+(hi-lo)/2,id=d->paths[mid];if(!album_read_track(a,id,&t))return -1;int c=strcmp(t.path,path);if(!c)return (int)id;if(c<0)lo=mid+1;else hi=mid;}
    return -1;
}
void album_close(album_t *a) {
    if(!a||!a->database)return;
    database_t *d=a->database;
#ifdef ESP_PLATFORM
    vSemaphoreDelete(d->mutex);
#else
    pthread_mutex_destroy(&d->mutex);
#endif
    free(d->labels);free(d->table);free(d);a->database=NULL;a->count=0;
}
