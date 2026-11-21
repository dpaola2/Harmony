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
    if(y1>240)y1=240;
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
        if(px<0||px>=320||py<0||py>=240)continue;
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
static void list_row(uint16_t *f,const player_ui_view_t *v,unsigned i)
{
    int y=66+(int)i*37;bool selected=v->selected==v->first+i;
    uint16_t fg=selected?BG:INK;
    rect(f,0,y,320,37,selected?SELECT:BG);
    moving_text(f,&ui_font_16,10,y,278,v->rows[i].label,fg,selected?v->marquee_step:0);
    moving_text(f,&ui_font_12,10,y+19,278,v->rows[i].detail,selected?PALE:MUTED,selected?v->marquee_step:0);
    text(f,&ui_font_16,298,y+8,18,v->rows[i].playing?"*":">",fg);
}
bool ui_render_selection(uint16_t *f,const player_ui_view_t *v,const player_ui_view_t *old)
{
    /* Full compact frame is inexpensive; strip comparison still avoids SPI writes. */
    (void)f;(void)v;(void)old;return false;
}
void ui_render(uint16_t *f,const player_ui_view_t *v,unsigned duration)
{
    if(!f||!v)return;
    rect(f,0,0,320,240,BG);rect(f,0,0,320,21,PALE);
    text(f,&ui_font_12,8,2,v->battery_mv?160:221,v->receiver,INK);
    if(v->battery_mv){char volts[16];snprintf(volts,sizeof(volts),"%u.%02uV",v->battery_mv/1000,(v->battery_mv%1000)/10);text(f,&ui_font_12,177,2,64,volts,INK);}
    char b[64];snprintf(b,sizeof(b),"VOL %u",v->audio.volume);
    text(f,&ui_font_12,246,2,70,b,INK);
    moving_text(f,&ui_font_20,10,23,300,v->title,INK,v->marquee_step);
    moving_text(f,&ui_font_12,10,47,300,v->subtitle,MUTED,v->marquee_step);
    if(v->page==PLAYER_UI_NOW_PLAYING){
        moving_text(f,&ui_font_20,10,78,300,v->track_title,INK,v->marquee_step);
        moving_text(f,&ui_font_16,10,111,300,v->track_artist,MUTED,v->marquee_step);
        moving_text(f,&ui_font_16,10,137,300,v->track_album,MUTED,v->marquee_step);
        unsigned seconds=v->audio.consumed_frames/44100;
        rect(f,10,176,300,4,PALE);
        if(duration)rect(f,10,176,(int)(300ULL*(seconds>duration?duration:seconds)/duration),4,SELECT);
        snprintf(b,sizeof(b),"%u:%02u",seconds/60,seconds%60);text(f,&ui_font_12,10,188,100,b,MUTED);
        if(duration){snprintf(b,sizeof(b),"%u:%02u",duration/60,duration%60);text(f,&ui_font_12,257,188,53,b,MUTED);}
        text(f,&ui_font_12,10,221,220,status(&v->audio),MUTED);
        snprintf(b,sizeof(b),"%u/%u",v->audio.queue_count?v->audio.queue_position+1:0,v->audio.queue_count);
    }else{
        for(unsigned i=0;i<v->row_count&&i<PLAYER_UI_ROWS;i++)list_row(f,v,i);
        if(!v->row_count)text(f,&ui_font_16,10,86,300,"No items",MUTED);
        text(f,&ui_font_12,10,221,236,"MENU: BACK  CENTER: SELECT",MUTED);
        snprintf(b,sizeof(b),"%u/%u",v->total_count?v->selected+1:0,v->total_count);
    }
    text(f,&ui_font_12,260,221,56,b,MUTED);
    rect(f,0,216,320,1,PALE);
    if(v->notice[0]){rect(f,0,217,320,23,PALE);moving_text(f,&ui_font_12,8,221,304,v->notice,INK,v->marquee_step);}
}
bool ui_render_has_long_text(const player_ui_view_t *v)
{
    if(width(&ui_font_12,v->notice)>304||width(&ui_font_20,v->title)>300||width(&ui_font_12,v->subtitle)>300)return true;
    if(v->page==PLAYER_UI_NOW_PLAYING)return width(&ui_font_20,v->track_title)>300||width(&ui_font_16,v->track_artist)>300||width(&ui_font_16,v->track_album)>300;
    for(unsigned i=0;i<v->row_count&&i<PLAYER_UI_ROWS;i++)if(v->first+i==v->selected)
        return width(&ui_font_16,v->rows[i].label)>278||width(&ui_font_12,v->rows[i].detail)>278;
    return false;
}
