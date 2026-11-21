#include "ano_sleep_gate.h"
#include <assert.h>
#include <stdio.h>
int main(void)
{
    ano_sleep_gate_t g={0};
    assert(!ano_sleep_gate_poll(&g,false,0x3e,true,0));
    assert(!ano_sleep_gate_poll(&g,true,0x3c,true,1000)); /* held Select */
    assert(!ano_sleep_gate_poll(&g,true,0x3e,false,2000)); /* latched/stuck IRQ */
    assert(!ano_sleep_gate_poll(&g,true,0x3e,true,3000));
    assert(!ano_sleep_gate_poll(&g,true,0x3e,true,3499));
    assert(ano_sleep_gate_poll(&g,true,0x3e,true,3500));
    assert(!ano_sleep_gate_poll(&g,true,0x3e,false,3501));
    assert(!ano_sleep_gate_poll(&g,true,0x3e,true,4000));
    assert(!ano_sleep_gate_poll(&g,false,0x3e,true,4500)); /* canceled */
    assert(!ano_sleep_gate_poll(&g,true,0x3e,true,5000));
    assert(!ano_sleep_gate_poll(&g,true,0x3c,true,5499)); /* renewed press */
    assert(!ano_sleep_gate_poll(&g,true,0x3e,true,5500));
    assert(ano_sleep_gate_poll(&g,true,0x3e,true,6000));
    g=(ano_sleep_gate_t){0};
    assert(!ano_sleep_gate_poll(&g,true,0x3e,true,UINT32_MAX-99));
    assert(!ano_sleep_gate_poll(&g,true,0x3e,true,399));
    assert(ano_sleep_gate_poll(&g,true,0x3e,true,400));
    puts("PASS sleep arming: release, stuck IRQ, cancellation, held button, clock wrap");
}
