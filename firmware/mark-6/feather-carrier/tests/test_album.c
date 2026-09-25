#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "album.h"
static album_t album;
static bool parse(const char *text)
{
    FILE *file=tmpfile(); assert(file);
    fputs(text,file);rewind(file);
    bool ok=album_parse(file,&album);fclose(file);return ok;
}
int main(void)
{
    assert(parse("\xef\xbb\xbf#EXTM3U\r\n#EXTINF:3,Ignored title\r\n01 First.mp3\r\nfolder/02 Second.MP3\n"));
    assert(album.count==2 && !strcmp(album.tracks[0].title,"01 First"));
    assert(!strcmp(album.tracks[1].path,"folder/02 Second.MP3"));
    assert(parse("Café/01 Été.mp3\n"));
    assert(!strcmp(album.tracks[0].path,"Café/01 Été.mp3"));
    assert(parse("HIGHER.MP3"));
    const char *bad[]={"", "#EXTM3U\n", "../a.mp3\n", "/a.mp3\n", "a/../b.mp3\n", "a//b.mp3\n", "./a.mp3\n", "C:\\a.mp3\n", "https://x/a.mp3\n", "a.wav\n", "good.mp3\nbad.wav\n", "a\tb.mp3\n"};
    for(unsigned i=0;i<sizeof(bad)/sizeof(*bad);++i) {assert(!parse(bad[i]));assert(!album.count);}
    char longline[600];memset(longline,'a',sizeof(longline));longline[599]=0;
    assert(!parse(longline));
    FILE *f=tmpfile();assert(f);
    for(unsigned i=0;i<ALBUM_MAX_TRACKS;++i) fprintf(f,"%02u.mp3\n",i);
    rewind(f);assert(album_parse(f,&album) && album.count==ALBUM_MAX_TRACKS);
    fseek(f,0,SEEK_END);fputs("extra.mp3\n",f);rewind(f);
    assert(!album_parse(f,&album) && !album.count);fclose(f);
    f=tmpfile();assert(f);
    const char hidden[]="good.mp3\0bad.wav\n";
    fwrite(hidden,1,sizeof(hidden)-1,f);rewind(f);
    assert(!album_parse(f,&album));fclose(f);
    puts("PASS album: ordered BOM/CRLF M3U, 64-track bound, empty/invalid/traversal rejection");
}
