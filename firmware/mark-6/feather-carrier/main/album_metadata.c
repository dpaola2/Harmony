#include "album_metadata.h"
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

static uint32_t be32(const unsigned char *p) {
    return (uint32_t)p[0]<<24 | (uint32_t)p[1]<<16 | (uint32_t)p[2]<<8 | p[3];
}
static bool sync32(const unsigned char *p, uint32_t *n) {
    if ((p[0]|p[1]|p[2]|p[3]) & 128) return false;
    *n=(uint32_t)p[0]<<21 | (uint32_t)p[1]<<14 | (uint32_t)p[2]<<7 | p[3]; return true;
}
/* The bundled font is ASCII. Replace each unsupported character once, without
 * altering the path used by fopen. UTF-8 continuation bytes are not new glyphs. */
static void readable(char *out, size_t cap, const char *in, size_t n) {
    size_t w=0;
    for (size_t i=0;i<n && in[i] && w+1<cap;i++) {
        unsigned char c=(unsigned char)in[i];
        if ((c&0xc0)==0x80) continue;
        out[w++]=(c>=32 && c<127)?(char)c:'?';
    }
    while(w && out[w-1]==' ') w--;
    out[w]=0;
}
void album_track_fallback(album_track_t *t) {
    const char *base=strrchr(t->path,'/'); base=base?base+1:t->path;
    const char *title=base;
    unsigned long number=strtoul(base,NULL,10);
    if (isdigit((unsigned char)*base)) {
        const char *p=base; while(isdigit((unsigned char)*p)) p++;
        /* The prepared card uses both NN Title and DD-NN Title filenames. */
        if (*p=='-' && isdigit((unsigned char)p[1])) {
            char *end=NULL;unsigned long track=strtoul(p+1,&end,10);
            if (*end==' ' || *end=='-' || *end=='.' || *end=='_') {
                t->disc_number=number<=65535?(uint16_t)number:0;
                number=track;p=end;
            }
        }
        if (*p==' ' || *p=='-' || *p=='.' || *p=='_') {
            while(*p==' ' || *p=='-' || *p=='.' || *p=='_') p++;
            if (*p) {title=p;t->track_number=number<=65535?(uint16_t)number:0;}
        }
    }
    size_t n=strlen(title); if(n>=4) n-=4;
    readable(t->title,sizeof(t->title),title,n);
    strcpy(t->artist,"Unknown artist");strcpy(t->album,"Unknown album");
    if (base>t->path) {
        const char *end=base-1,*start=end;
        while(start>t->path && start[-1]!='/') start--;
        readable(t->album,sizeof(t->album),start,(size_t)(end-start));
        if(start>t->path) {
            end=start-1;start=end;
            while(start>t->path && start[-1]!='/') start--;
            readable(t->artist,sizeof(t->artist),start,(size_t)(end-start));
        }
    }
}
static void decode_text(char *out,size_t cap,const unsigned char *p,size_t n) {
    out[0]=0;if(!n)return;
    unsigned enc=*p++;n--;
    if(enc==0) {
        size_t w=0;for(size_t i=0;i<n && p[i] && w+1<cap;i++)
            out[w++]=(p[i]>=32 && p[i]<127)?(char)p[i]:'?';
        while(w && out[w-1]==' ')w--;
        out[w]=0;
    } else if(enc==3) readable(out,cap,(const char *)p,n);
    else if(enc==1 || enc==2) {
        bool little=false;
        if(enc==1) {
            if(n<2)return;
            if(p[0]==255 && p[1]==254)little=true;
            else if(p[0]!=254 || p[1]!=255)return;
            p+=2;n-=2;
        }
        size_t w=0;
        for(size_t i=0;i+1<n && w+1<cap;i+=2) {
            unsigned c=little?(unsigned)p[i]|(unsigned)p[i+1]<<8:(unsigned)p[i]<<8|p[i+1];
            if(!c)break;
            if(c>=0xdc00 && c<=0xdfff)continue;
            out[w++]=(c>=32 && c<127)?(char)c:'?';
        }
        while(w && out[w-1]==' ')w--;
        out[w]=0;
    }
}
static void copy_text(char *out,size_t cap,const char *in) {
    if(!*in)return;
    size_t n=strlen(in);if(n>=cap)n=cap-1;memcpy(out,in,n);out[n]=0;
}
static uint16_t number16(const char *p) {
    unsigned long n=strtoul(p,NULL,10);return n<=65535?(uint16_t)n:0;
}
static bool v2(FILE *f,album_track_t *t,long size,long *audio_start,bool *tagged) {
    unsigned char h[10];*audio_start=0;*tagged=false;
    if(fseek(f,0,SEEK_SET) || fread(h,1,10,f)!=10) return size<10;
    if(memcmp(h,"ID3",3))return true;
    *tagged=true;uint32_t bytes;
    if(!sync32(h+6,&bytes) || bytes>16U*1024U*1024U || bytes>(uint32_t)(size-10))return false;
    long end=10+(long)bytes;*audio_start=end;
    if(h[3]==4 && (h[5]&0x10)) {
        if(size-end<10)return false;
        *audio_start+=10;
    }
    if((h[3]!=3 && h[3]!=4) || (h[5]&0x80))return false;
    unsigned version=h[3];
    if(h[5]&0x40) {
        unsigned char ext[4];if(fread(ext,1,4,f)!=4)return false;
        uint32_t n=be32(ext);
        if(version==4 && (!sync32(ext,&n) || n<4))return false;
        uint32_t skip=version==3?n:n-4;
        if(skip>(uint32_t)(end-ftell(f)) || fseek(f,(long)skip,SEEK_CUR))return false;
    }
    while(ftell(f)+10<=end) {
        if(fread(h,1,10,f)!=10)return false;
        if(!h[0])break;
        for(int i=0;i<4;i++) if(!((h[i]>='A'&&h[i]<='Z')||(h[i]>='0'&&h[i]<='9')))return false;
        uint32_t n=be32(h+4);
        if(version==4 && !sync32(h+4,&n))return false;
        long pos=ftell(f);if(pos<0 || n>(uint32_t)(end-pos))return false;
        /* Skip compressed, encrypted, grouped and unsynchronized frames. */
        if(n && !h[9] && (!memcmp(h,"TIT2",4)||!memcmp(h,"TPE1",4)||!memcmp(h,"TALB",4)||
                          !memcmp(h,"TRCK",4)||!memcmp(h,"TPOS",4)||!memcmp(h,"TLEN",4))) {
            unsigned char raw[384];char text[ALBUM_TITLE_MAX];
            size_t take=n<sizeof(raw)?n:sizeof(raw);
            if(fread(raw,1,take,f)!=take)return false;
            decode_text(text,sizeof(text),raw,take);
            if(!memcmp(h,"TIT2",4))copy_text(t->title,sizeof(t->title),text);
            else if(!memcmp(h,"TPE1",4))copy_text(t->artist,sizeof(t->artist),text);
            else if(!memcmp(h,"TALB",4))copy_text(t->album,sizeof(t->album),text);
            else if(!memcmp(h,"TRCK",4)) {uint16_t value=number16(text);if(value)t->track_number=value;}
            else if(!memcmp(h,"TPOS",4)) {uint16_t value=number16(text);if(value)t->disc_number=value;}
            else {unsigned long ms=strtoul(text,NULL,10);if(ms<=86400000)t->duration_seconds=(uint32_t)(ms/1000);}
        }
        if(fseek(f,pos+(long)n,SEEK_SET))return false;
    }
    return true;
}
static void v1(FILE *f,album_track_t *t,long size) {
    unsigned char b[128];if(size<128 || fseek(f,size-128,SEEK_SET) || fread(b,1,128,f)!=128 || memcmp(b,"TAG",3))return;
    char value[ALBUM_TITLE_MAX];
    readable(value,sizeof(value),(const char *)b+3,30);copy_text(t->title,sizeof(t->title),value);
    readable(value,sizeof(value),(const char *)b+33,30);copy_text(t->artist,sizeof(t->artist),value);
    readable(value,sizeof(value),(const char *)b+63,30);copy_text(t->album,sizeof(t->album),value);
    if(!b[125] && b[126])t->track_number=b[126];
}
static void frame_duration(FILE *f,album_track_t *t,long start,long size) {
    if(t->duration_seconds || start<0 || start>=size)return;
    unsigned char b[256];if(fseek(f,start,SEEK_SET))return;
    size_t n=fread(b,1,sizeof(b),f);
    /* A frame-count header gives a duration without estimating VBR from bytes. */
    for(size_t off=0;off+4<n;off++) {
        unsigned char *p=b+off;
        if(p[0]!=255 || (p[1]&0xe0)!=0xe0)continue;
        unsigned ver=(p[1]>>3)&3,layer=(p[1]>>1)&3,sr=(p[2]>>2)&3;
        if(ver==1 || layer!=1 || sr==3 || !(p[2]>>4) || (p[2]>>4)==15)continue;
        static const unsigned rates[]={44100,48000,32000};
        unsigned rate=rates[sr]/(ver==3?1:ver==2?2:4),samples=ver==3?1152:576;
        unsigned side=ver==3?((p[3]>>6)==3?17:32):((p[3]>>6)==3?9:17);
        size_t x=off+4+side+((p[1]&1)?0:2);uint32_t frames=0;
        if(x+12<=n && (!memcmp(b+x,"Xing",4)||!memcmp(b+x,"Info",4)) && (be32(b+x+4)&1)) frames=be32(b+x+8);
        x=off+4+32;
        if(!frames && x+18<=n && !memcmp(b+x,"VBRI",4))frames=be32(b+x+14);
        if(frames) {
            uint64_t seconds=(uint64_t)frames*samples/rate;
            if(seconds<=86400)t->duration_seconds=(uint32_t)seconds;
        }
        return;
    }
}
bool album_track_metadata(FILE *f,album_track_t *t) {
    if(fseek(f,0,SEEK_END))return false;
    long size=ftell(f);if(size<0)return false;
    v1(f,t,size);
    long start=0;bool tagged=false;
    bool ok=v2(f,t,size,&start,&tagged);(void)tagged;
    if(ok)frame_duration(f,t,start,size);
    return ok && !ferror(f);
}
