#include <stdio.h>
#include <string.h>
#include "ui_render.h"
#include "ui_assets/fonts.h"
#define RGB(r,g,b) (((r>>3)<<11)|((g>>2)<<5)|(b>>3))
#define BG RGB(253,253,247)
#define INK RGB(23,41,25)
#define MUTED RGB(112,128,101)
#define SELECT RGB(52,76,53)
#define PALE RGB(233,237,223)

static void rect(uint16_t *f,int x,int y,int w,int h,uint16_t c)
{
    int x1=x+w,y1=y+h;
    if(x<0)x=0;
    if(y<0)y=0;
    if(x1>320)x1=320;
    if(y1>480)y1=480;
    for(int j=y;j<y1;j++)for(int i=x;i<x1;i++)f[j*320+i]=c;
}
static uint16_t blend(uint16_t fg,uint16_t bg,unsigned alpha)
{
    unsigned r=(((fg>>11)&31)*alpha+((bg>>11)&31)*(15-alpha)+7)/15;
    unsigned g=(((fg>>5)&63)*alpha+((bg>>5)&63)*(15-alpha)+7)/15;
    unsigned b=((fg&31)*alpha+(bg&31)*(15-alpha)+7)/15;
    return (r<<11)|(g<<5)|b;
}
static unsigned ascii(const char **p)
{
    unsigned c=(unsigned char)*(*p)++;
    if(c>=128){while(((unsigned char)**p&0xc0)==0x80)(*p)++;return '?';}
    return c>=32&&c<=126?c:'?';
}
static int advance(const ui_font_t *font,unsigned c){return (font->glyphs[c-32].advance+8)/16;}
static int width(const ui_font_t *font,const char *s)
{
    int n=0;while(*s)n+=advance(font,ascii(&s));return n;
}
static void glyph(uint16_t *f,const ui_font_t *font,int x,int y,unsigned c,uint16_t color)
{
    const ui_glyph_t *g=&font->glyphs[c-32];
    int top=y+font->height-font->baseline-g->h-g->y;
    for(int row=0;row<g->h;row++)for(int col=0;col<g->w;col++){
        int px=x+g->x+col,py=top+row;
        if(px<0||px>=320||py<0||py>=480)continue;
        unsigned at=row*g->w+col, packed=font->bitmap[g->offset+at/2];
        unsigned a=(at&1)?packed&15:packed>>4;
        if(a)f[py*320+px]=blend(color,f[py*320+px],a);
    }
}
static void text(uint16_t *f,const ui_font_t *font,int x,int y,int maxw,const char *s,uint16_t color)
{
    int right=x+maxw;bool clip=width(font,s)>maxw;
    if(clip)right-=width(font,"...");
    while(*s){unsigned c=ascii(&s);int a=advance(font,c);if(x+a>right)break;glyph(f,font,x,y,c,color);x+=a;}
    if(clip)for(int i=0;i<3;i++){glyph(f,font,x,y,'.',color);x+=advance(font,'.');}
}
static void song_title(uint16_t *f,const char *title)
{
    char first[ALBUM_TITLE_MAX];snprintf(first,sizeof(first),"%s",title);
    if(width(&ui_font_20,first)<=280){text(f,&ui_font_20,20,294,280,first,INK);return;}
    size_t last_space=0,cut=0;int n=0;
    const char *p=title;
    while(*p){const char *before=p;unsigned c=ascii(&p);n+=advance(&ui_font_20,c);if(n>280)break;
        cut=(size_t)(p-title);if(c==' ')last_space=(size_t)(before-title);}
    if(last_space)cut=last_space;
    if(cut>=sizeof(first))cut=sizeof(first)-1;
    memcpy(first,title,cut);first[cut]=0;text(f,&ui_font_20,20,289,280,first,INK);
    while(title[cut]==' ')cut++;
    text(f,&ui_font_20,20,314,280,title+cut,INK);
}
static const char *status(const audio_player_snapshot_t *a)
{
    return a->failed?"TRACK ERROR":a->stopped?"STOPPED":!a->connected?"CONNECTING":
        a->finished?"FINISHED":a->paused?"PAUSED":a->buffering?"BUFFERING":"PLAYING";
}
static void list_row(uint16_t *f,const player_ui_view_t *v,unsigned i)
{
    int y=124+(int)i*52;bool selected=v->selected==v->first+i;
    uint16_t fg=selected?BG:INK,detail=selected?PALE:MUTED;
    rect(f,0,y,320,52,selected?SELECT:BG);
    text(f,&ui_font_16,16,y+7,267,v->rows[i].label,fg);
    text(f,&ui_font_12,16,y+29,267,v->rows[i].detail,detail);
    text(f,&ui_font_20,293,y+12,24,v->rows[i].playing?"*":">",fg);
}
bool ui_render_selection(uint16_t *f,const player_ui_view_t *v,const player_ui_view_t *old)
{
    if(!f||!v||!old||v->page==PLAYER_UI_NOW_PLAYING||v->page!=old->page||
       v->first!=old->first||v->row_count!=old->row_count||v->total_count!=old->total_count||
       v->audio.connected!=old->audio.connected||strcmp(v->title,old->title)||
       strcmp(v->subtitle,old->subtitle)||strcmp(v->notice,old->notice)||
       memcmp(v->rows,old->rows,sizeof(v->rows))) return false;
    for(unsigned i=0;i<v->row_count&&i<PLAYER_UI_ROWS;i++)
        if(v->first+i==v->selected||v->first+i==old->selected)list_row(f,v,i);
    if(!v->notice[0]){
        rect(f,240,446,80,34,BG);
        char b[24];snprintf(b,sizeof(b),"%u/%u",v->total_count?v->selected+1:0,v->total_count);
        text(f,&ui_font_12,266,454,48,b,MUTED);
    }
    return true;
}
void ui_render(uint16_t *f,const player_ui_view_t *v,unsigned duration)
{
    if(!f||!v)return;
    rect(f,0,0,320,480,BG);rect(f,0,0,320,30,PALE);
    text(f,&ui_font_12,12,8,180,v->audio.connected?"SoundCore 2":"Connecting speaker",INK);
    text(f,&ui_font_12,222,8,88,"QUIET -24dB",INK);
    text(f,&ui_font_12,16,49,288,v->subtitle,MUTED);
    text(f,&ui_font_26,16,71,288,v->title,INK);
    if(v->page==PLAYER_UI_NOW_PLAYING){
        for(int y=145;y<275;y++)for(int x=95;x<225;x++){
            int dx=x-160,dy=y-210,d=dx*dx+dy*dy;
            if(d<=4096)f[y*320+x]=d<625?RGB(183,195,148):(d/160)%2?RGB(41,57,43):RGB(53,71,53);
        }
        text(f,&ui_font_12,140,204,42,v->audio.paused?"PAUSE":"PLAY",SELECT);
        song_title(f,v->track_title);
        text(f,&ui_font_16,20,350,280,v->track_artist,MUTED);
        text(f,&ui_font_16,20,373,280,v->track_album,MUTED);
        unsigned seconds=v->audio.consumed_frames/44100;
        rect(f,20,411,280,3,PALE);
        if(duration)rect(f,20,411,(int)(280ULL*(seconds>duration?duration:seconds)/duration),3,SELECT);
        char b[64];snprintf(b,sizeof(b),"%u:%02u",seconds/60,seconds%60);text(f,&ui_font_12,20,420,100,b,MUTED);
        if(duration){snprintf(b,sizeof(b),"%u:%02u",duration/60,duration%60);text(f,&ui_font_12,260,420,50,b,MUTED);}
        text(f,&ui_font_12,16,454,200,status(&v->audio),MUTED);
        snprintf(b,sizeof(b),"%u / %u",v->audio.queue_count?v->audio.queue_position+1:0,v->audio.queue_count);text(f,&ui_font_12,249,454,60,b,MUTED);
    }else{
        for(unsigned i=0;i<v->row_count&&i<PLAYER_UI_ROWS;i++){
            list_row(f,v,i);
        }
        if(!v->row_count)text(f,&ui_font_16,16,150,288,"No items",MUTED);
        text(f,&ui_font_12,16,454,232,"MENU: BACK   CENTER: SELECT",MUTED);
        char b[24];snprintf(b,sizeof(b),"%u/%u",v->total_count?v->selected+1:0,v->total_count);text(f,&ui_font_12,266,454,48,b,MUTED);
    }
    rect(f,0,445,320,1,PALE);
    if(v->notice[0]){rect(f,0,445,320,35,PALE);text(f,&ui_font_12,12,455,296,v->notice,INK);}
}
