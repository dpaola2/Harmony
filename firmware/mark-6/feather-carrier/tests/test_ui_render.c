#include "ui_render.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc,char **argv)
{
    uint16_t *guard=calloc(320*480+2,sizeof(*guard));assert(guard);
    uint16_t *frame=guard+1;guard[0]=0x1234;guard[320*480+1]=0x5678;
    player_ui_view_t v={0};
    v.audio.connected=true;v.audio.queue_position=4;v.audio.queue_count=10;
    v.audio.consumed_frames=44100*72;
    strcpy(v.subtitle,"RADIOHEAD");strcpy(v.title,"Now Playing");
    strcpy(v.track_title,"Weird Fishes - Arpeggi");strcpy(v.track_artist,"Radiohead");strcpy(v.track_album,"In Rainbows");
    v.page=PLAYER_UI_NOW_PLAYING;ui_render(frame,&v,318);
    if(argc>1){FILE *file=fopen(argv[1],"wb");assert(file);fprintf(file,"P6\n320 480\n255\n");
        for(int i=0;i<320*480;i++){unsigned c=frame[i];unsigned char rgb[]={((c>>11)&31)*255/31,((c>>5)&63)*255/63,(c&31)*255/31};fwrite(rgb,1,3,file);}fclose(file);}
    for(unsigned page=0;page<=PLAYER_UI_SETTINGS;page++){
        v.page=page;v.row_count=6;v.total_count=64;v.first=58;v.selected=63;
        for(unsigned i=0;i<6;i++){memset(v.rows[i].label,'W',sizeof(v.rows[i].label)-1);strcpy(v.rows[i].detail,"UTF-8 fallback: café");}
        ui_render(frame,&v,0);assert(guard[0]==0x1234&&guard[320*480+1]==0x5678);
        strcpy(v.notice,"Volume uses the speaker buttons during this first UI test.");ui_render(frame,&v,1);
    }
    uint16_t *expected=calloc(320*480,sizeof(*expected));assert(expected);
    v.page=PLAYER_UI_SONGS;v.notice[0]=0;v.first=0;v.total_count=6;v.selected=0;
    ui_render(frame,&v,0);
    for(unsigned selection=1;selection<6;selection++){
        player_ui_view_t old=v;v.selected=selection;
        assert(ui_render_selection(frame,&v,&old));ui_render(expected,&v,0);
        assert(!memcmp(frame,expected,320*480*sizeof(*frame)));
    }
    player_ui_view_t changed=v;changed.first=1;assert(!ui_render_selection(frame,&changed,&v));
    changed=v;changed.rows[0].playing=!v.rows[0].playing;assert(!ui_render_selection(frame,&changed,&v));
    free(expected);
    assert(guard[0]==0x1234&&guard[320*480+1]==0x5678);free(guard);
    puts("PASS actual renderer: all pages, long names, Unicode fallback, unknown duration, frame bounds");
}
