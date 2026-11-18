/* Mark-8 copy of firmware/mark-7/pocket-player/main/ui_render.c (October 9
 * working tree), changed for the 320 x 320 ST7365P: six list rows, a larger
 * now-playing page with a volume bar (the wheel sets the volume there), the
 * battery percent from the MAX17048 and wheel labels in the footer. Same
 * palette and fonts. Pure, host-tested. */
#include <stdio.h>
#include <string.h>
#include "slab_render.h"
#include "ui_assets/fonts.h"

#define W SLAB_RENDER_W
#define H SLAB_RENDER_H
#define RGB(r,g,b) (((r>>3)<<11)|((g>>2)<<5)|(b>>3))
#define BG RGB(253,253,247)
#define INK RGB(23,41,25)
#define MUTED RGB(112,128,101)
#define SELECT RGB(52,76,53)
#define PALE RGB(233,237,223)
#define ROW_Y 72
#define ROW_H 37
#define FOOTER_Y 296

static void rect(uint16_t *f,int x,int y,int w,int h,uint16_t c)
{
    int x1=x+w,y1=y+h;
    if(x<0)x=0;
    if(y<0)y=0;
    if(x1>W)x1=W;
    if(y1>H)y1=H;
    for(int j=y;j<y1;j++)for(int i=x;i<x1;i++)f[j*W+i]=c;
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
        if(px<0||px>=W||py<0||py>=H)continue;
        unsigned at=row*g->w+col, packed=font->bitmap[g->offset+at/2];
        unsigned a=(at&1)?packed&15:packed>>4;
        if(a)f[py*W+px]=blend(color,f[py*W+px],a);
    }
}
static void text(uint16_t *f,const ui_font_t *font,int x,int y,int maxw,const char *s,uint16_t color)
{
    int right=x+maxw;bool clip=width(font,s)>maxw;
    if(clip)right-=width(font,"...");
    while(*s){unsigned c=ascii(&s);int a=advance(font,c);if(x+a>right)break;glyph(f,font,x,y,c,color);x+=a;}
    if(clip)for(int i=0;i<3;i++){glyph(f,font,x,y,'.',color);x+=advance(font,'.');}
}
static void moving_text(uint16_t *f,const ui_font_t *font,int x,int y,int maxw,const char *value,uint16_t color,uint32_t step)
{
    if (!step || width(font,value)<=maxw) { text(f,font,x,y,maxw,value,color); return; }
    /* Rotate at codepoint boundaries and include a pause-sized gap. */
    char label[ALBUM_TITLE_MAX+8];
    snprintf(label,sizeof(label),"%s   ",value);
    unsigned count=0;const char *p=label;
    while(*p){ascii(&p);count++;}
    unsigned skip=count?step%count:0;p=label;
    while(skip--&&*p)ascii(&p);
    char rotated[ALBUM_TITLE_MAX+8];
    size_t tail=strlen(p),head=(size_t)(p-label);
    memcpy(rotated,p,tail);memcpy(rotated+tail,label,head);rotated[tail+head]=0;
    text(f,font,x,y,maxw,rotated,color);
}
static const char *status(const audio_player_snapshot_t *a)
{
    return a->failed?"TRACK ERROR":a->stopped?"STOPPED":!a->connected?"NO RECEIVER":
        a->finished?"FINISHED":a->paused?"PAUSED":a->buffering?"BUFFERING":"PLAYING";
}
/* Battery: outline, fill by percent, plus a tip; a bolt-like bar when on USB. */
static void battery(uint16_t *f,int x,int y,const slab_status_t *s)
{
    rect(f,x,y,22,11,INK);rect(f,x+1,y+1,20,9,PALE);rect(f,x+22,y+3,2,5,INK);
    unsigned p=s->battery_percent>100?100:s->battery_percent;
    rect(f,x+2,y+2,(int)(18*p/100),7,p<=15?RGB(190,60,40):SELECT);
    if(s->usb)rect(f,x+6,y+4,10,3,BG);
}
static void list_row(uint16_t *f,const player_ui_view_t *v,unsigned i)
{
    int y=ROW_Y+(int)i*ROW_H;bool selected=v->selected==v->first+i;
    uint16_t fg=selected?BG:INK;
    rect(f,0,y,W,ROW_H,selected?SELECT:BG);
    moving_text(f,&ui_font_16,10,y,278,v->rows[i].label,fg,selected?v->marquee_step:0);
    moving_text(f,&ui_font_12,10,y+19,278,v->rows[i].detail,selected?PALE:MUTED,selected?v->marquee_step:0);
    text(f,&ui_font_16,298,y+8,18,v->rows[i].playing?"*":">",fg);
}
void slab_render(uint16_t *f,const player_ui_view_t *v,unsigned duration,const slab_status_t *st)
{
    if(!f||!v)return;
    slab_status_t none={0};if(!st)st=&none;
    rect(f,0,0,W,H,BG);rect(f,0,0,W,24,PALE);
    text(f,&ui_font_12,8,4,196,v->receiver,INK);
    char b[64];snprintf(b,sizeof(b),"VOL %u",v->audio.volume);
    text(f,&ui_font_12,208,4,52,b,INK);
    if(st->battery_valid){snprintf(b,sizeof(b),"%u%%",st->battery_percent>100?100:st->battery_percent);
        text(f,&ui_font_12,262,4,30,b,INK);battery(f,292,6,st);}
    moving_text(f,&ui_font_20,10,27,300,v->title,INK,v->marquee_step);
    moving_text(f,&ui_font_12,10,51,300,v->subtitle,MUTED,v->marquee_step);
    if(v->page==PLAYER_UI_NOW_PLAYING){
        moving_text(f,&ui_font_26,10,80,300,v->track_title,INK,v->marquee_step);
        moving_text(f,&ui_font_16,10,118,300,v->track_artist,MUTED,v->marquee_step);
        moving_text(f,&ui_font_16,10,142,300,v->track_album,MUTED,v->marquee_step);
        unsigned seconds=v->audio.consumed_frames/44100;
        rect(f,10,190,300,6,PALE);
        if(duration)rect(f,10,190,(int)(300ULL*(seconds>duration?duration:seconds)/duration),6,SELECT);
        snprintf(b,sizeof(b),"%u:%02u",seconds/60,seconds%60);text(f,&ui_font_12,10,202,100,b,MUTED);
        if(duration){snprintf(b,sizeof(b),"%u:%02u",duration/60,duration%60);text(f,&ui_font_12,257,202,53,b,MUTED);}
        text(f,&ui_font_16,10,232,200,status(&v->audio),INK);
        text(f,&ui_font_12,10,264,60,"Volume",MUTED);
        rect(f,70,270,240,4,PALE);
        rect(f,70,270,(int)(240*(v->audio.volume>100?100:v->audio.volume)/100),4,SELECT);
        snprintf(b,sizeof(b),"%u/%u",v->audio.queue_count?v->audio.queue_position+1:0,v->audio.queue_count);
        text(f,&ui_font_12,10,FOOTER_Y+5,236,"WHEEL: VOLUME  CENTRE: PAUSE",MUTED);
    }else{
        for(unsigned i=0;i<v->row_count&&i<PLAYER_UI_ROWS;i++)list_row(f,v,i);
        if(!v->row_count)text(f,&ui_font_16,10,92,300,"No items",MUTED);
        text(f,&ui_font_12,10,FOOTER_Y+5,236,"HOME: BACK  CENTRE: SELECT",MUTED);
        snprintf(b,sizeof(b),"%u/%u",v->total_count?v->selected+1:0,v->total_count);
    }
    text(f,&ui_font_12,250,FOOTER_Y+5,66,b,MUTED);
    rect(f,0,FOOTER_Y,W,1,PALE);
    if(v->notice[0]){rect(f,0,FOOTER_Y+1,W,H-FOOTER_Y-1,PALE);moving_text(f,&ui_font_12,8,FOOTER_Y+5,304,v->notice,INK,v->marquee_step);}
}
bool slab_render_has_long_text(const player_ui_view_t *v)
{
    if(width(&ui_font_12,v->notice)>304||width(&ui_font_20,v->title)>300||width(&ui_font_12,v->subtitle)>300)return true;
    if(v->page==PLAYER_UI_NOW_PLAYING)return width(&ui_font_26,v->track_title)>300||width(&ui_font_16,v->track_artist)>300||width(&ui_font_16,v->track_album)>300;
    for(unsigned i=0;i<v->row_count&&i<PLAYER_UI_ROWS;i++)if(v->first+i==v->selected)
        return width(&ui_font_16,v->rows[i].label)>278||width(&ui_font_12,v->rows[i].detail)>278;
    return false;
}
