#include <assert.h>
#include <stdio.h>
#include "input_filter.h"
int main(void)
{
    input_filter_t f={0};
    input_events_t e=input_filter_poll(&f,UINT32_MAX,0x3c,0,1);
    assert(!e.pressed && !e.steps); /* held center at boot */
    e=input_filter_poll(&f,0,0x3e,10,1);assert(e.steps==1);
    e=input_filter_poll(&f,UINT32_MAX,0x3e,50,1);assert(e.steps==-1);
    e=input_filter_poll(&f,10000,0x3c,60,1);assert(!e.steps && !e.pressed);
    e=input_filter_poll(&f,10000,0x3e,70,1);assert(!e.pressed); /* bounce */
    e=input_filter_poll(&f,10000,0x3c,80,1);assert(!e.pressed);
    e=input_filter_poll(&f,10000,0x3c,119,1);assert(!e.pressed);
    e=input_filter_poll(&f,10000,0x3c,120,1);assert(e.pressed==(1U<<INPUT_SELECT));
    e=input_filter_poll(&f,10000,0x3c,500,1);assert(!e.pressed); /* no hold repeats */
    for(unsigned rotation=0;rotation<4;++rotation) {
        f=(input_filter_t){0};
        input_filter_poll(&f,0,0x3e,UINT32_MAX-20,rotation);
        input_filter_poll(&f,0,0x3a,UINT32_MAX-10,rotation); /* raw UP */
        e=input_filter_poll(&f,0,0x3a,29,rotation);
        assert(e.pressed==(1U<<(1+rotation))); /* debounce across timer wrap */
    }
    puts("PASS controls: startup-held key, 40ms bounce/hold handling, encoder and clock wrap, jump rejection, four rotations");
}
