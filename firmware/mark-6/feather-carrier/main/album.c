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
bool album_load(const char *root,album_t *a) {
    if(!a)return false;
    memset(a,0,sizeof(*a));
    if(!root || !*root) {a->status=ALBUM_STATUS_MISSING;return false;}
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
