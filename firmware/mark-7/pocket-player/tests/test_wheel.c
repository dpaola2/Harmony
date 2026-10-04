#include <assert.h>
#include <stdio.h>
#include "wheel_protocol.h"
static wheel_event_t feed(wheel_state_t *s,int buttons,int pos,int touch){wheel_event_t e;uint8_t p[]={0x35,buttons,pos*2,touch?0x80:0};assert(wheel_decode(s,p,&e));return e;}
int main(void){wheel_state_t s={0};wheel_event_t e;
    assert(feed(&s,0,94,1).steps==0);assert(feed(&s,0,1,1).steps==1);
    assert(feed(&s,0,94,1).steps==-1);feed(&s,0,0,0);assert(feed(&s,0,40,1).steps==0);
    assert(feed(&s,0,60,1).steps==0); /* implausible jump */
    assert(feed(&s,2,0,1).pressed==2);assert(feed(&s,2,30,1).pressed==0);
    assert(feed(&s,0,90,1).released==2);assert(feed(&s,0,40,1).steps==0);
    uint8_t idle[]={255,255,255,255};assert(!wheel_decode(&s,idle,&e));
    uint8_t odd[]={0x35,0,3,0x80};assert(!wheel_decode(&s,odd,&e));
    uint8_t far[]={0x35,0,192,0x80};assert(!wheel_decode(&s,far,&e));
    s=(wheel_state_t){0};assert(feed(&s,32,0,0).pressed==0); /* boot key consumed */
    assert(feed(&s,0,0,0).released==32);assert(feed(&s,32,0,0).pressed==32);
    puts("Photo wheel decode: wrap, lift, discontinuity, button edges and invalid packets pass");}
