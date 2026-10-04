#include "ui_render.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static void save(const char *path,uint16_t *f){FILE *o=fopen(path,"wb");assert(o);fprintf(o,"P6\n320 240\n255\n");for(int i=0;i<320*240;i++){unsigned c=f[i];unsigned char rgb[]={((c>>11)&31)*255/31,((c>>5)&63)*255/63,(c&31)*255/31};fwrite(rgb,1,3,o);}fclose(o);}
int main(int argc,char **argv){
    uint16_t *f=calloc(320*240,sizeof(*f));assert(f);player_ui_view_t v={0};
    v.audio.connected=true;v.audio.volume=40;v.audio.queue_count=10;v.audio.queue_position=4;v.audio.consumed_frames=44100*72;
    strcpy(v.receiver,"SoundCore 2");strcpy(v.title,"Now Playing");strcpy(v.subtitle,"HARMONY");
    strcpy(v.track_title,"Weird Fishes - Arpeggi");strcpy(v.track_artist,"Radiohead");strcpy(v.track_album,"In Rainbows");
    v.page=PLAYER_UI_NOW_PLAYING;ui_render(f,&v,318);if(argc>1)save(argv[1],f);
    v.page=PLAYER_UI_MUSIC;strcpy(v.title,"Music");strcpy(v.subtitle,"45 songs");v.row_count=4;v.total_count=4;v.selected=1;
    const char *names[]={"Artists","Albums","Songs","Playlists"};for(int i=0;i<4;i++)strcpy(v.rows[i].label,names[i]);
    ui_render(f,&v,0);if(argc>2)save(argv[2],f);
    for(unsigned page=0;page<=PLAYER_UI_BT_FORGET;page++)for(unsigned step=0;step<140;step++){
        v.page=page;v.marquee_step=step;v.first=60;v.selected=63;v.total_count=64;
        for(int i=0;i<4;i++){memset(v.rows[i].label,'W',sizeof(v.rows[i].label)-1);strcpy(v.rows[i].detail,"UTF-8: café");}
        strcpy(v.notice,"Cannot connect. Choose another receiver or try again.");ui_render(f,&v,step%2?1:0);
    }
    assert(ui_render_has_long_text(&v));free(f);puts("Compact renderer: all pages/scroll/long text/notice bounds pass");
}
