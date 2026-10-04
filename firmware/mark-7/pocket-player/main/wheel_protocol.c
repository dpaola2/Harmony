#include "wheel_protocol.h"
#include <string.h>
bool wheel_decode(wheel_state_t *s,const uint8_t p[4],wheel_event_t *e)
{
    if(!s||!p||!e)return false;
    memset(e,0,sizeof(*e));
    if(p[0]!=0x35||(p[3]!=0&&p[3]!=0x80)||(p[3]==0x80&&(p[2]>190||(p[2]&1))))return false;
    uint8_t buttons=p[1]&0x3e, position=p[2]/2;
    if(s->primed){e->pressed=buttons&~s->buttons;e->released=s->buttons&~buttons;}
    bool touch=p[3]==0x80&&!buttons&&!s->buttons;
    if(touch&&s->touching){
        int delta=(int)position-s->position;
        if(delta>48)delta-=96;
        if(delta<-48)delta+=96;
        /* Ignore discontinuous contacts; three position units per menu step. */
        if(delta>=-12&&delta<=12){s->residual+=delta;e->steps=s->residual/3;s->residual-=e->steps*3;}
        else s->residual=0;
    }else s->residual=0;
    s->primed=true;s->touching=touch;s->buttons=buttons;s->position=position;
    return true;
}
