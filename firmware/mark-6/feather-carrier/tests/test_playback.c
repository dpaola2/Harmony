#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
#include "playback.h"
static uint32_t rng = 0x59734;
static unsigned random_value(void) { rng = rng * 1664525 + 1013904223; return rng; }
int main(void)
{
    uint8_t buffer[64], out[128];
    uint32_t data[32];
    for (unsigned i=0;i<32;++i) data[i]=i+1;
    playback_t p;
    playback_init(&p,buffer,sizeof(buffer),3);
    uint32_t first=p.generation;
    assert(playback_push(&p,first,data,48)==48);
    assert(playback_read(&p,out,16)==0 && p.queued==48); /* disconnected */
    p.connected=true;
    playback_activate(&p);
    assert(p.paused && playback_read(&p,out,16)==0 && p.queued==48);
    playback_activate(&p);
    assert(playback_read(&p,out,16)==16 && !memcmp(data,out,16));
    p.connected=false;
    assert(playback_read(&p,out,16)==0 && p.consumed_frames==4);
    p.connected=true;
    assert(playback_read(&p,out,16)==16 && !memcmp((uint8_t*)data+16,out,16));
    playback_end(&p,first,false);
    playback_tick(&p);
    assert(p.track==0); /* Must drain the last 16 bytes before advancing. */
    assert(playback_read(&p,out,64)==16);
    for(unsigned i=16;i<64;++i) assert(out[i]==0);
    playback_tick(&p);
    assert(p.track==1 && p.selection==1 && p.generation!=first);
    assert(playback_push(&p,first,data,48)==0); /* in-flight decoder skip */
    playback_end(&p,first,true);
    assert(!p.failed);
    playback_activate(&p);
    playback_step(&p,1);
    assert(p.track==2 && p.paused); /* pause survives skip */
    playback_step(&p,1); assert(p.track==2);
    playback_browse(&p,INT_MIN); assert(p.selection==0);
    playback_browse(&p,INT_MAX); assert(p.selection==2);
    playback_activate(&p); assert(!p.paused);
    assert(playback_push(&p,p.generation,data,4)==4);
    assert(playback_read(&p,out,4)==0); /* prefill */
    playback_end(&p,p.generation,false);
    assert(playback_read(&p,out,4)==4); /* short final track */
    playback_tick(&p); assert(p.finished && p.track==2);
    playback_tick(&p); assert(p.finished && p.track==2); /* no repeat */
    playback_activate(&p); assert(!p.finished && p.buffering && !p.paused);
    playback_end(&p,p.generation,true);
    playback_tick(&p); assert(p.failed && p.track==2 && !p.queued);
    playback_browse(&p,-1); playback_activate(&p);
    assert(!p.failed && p.track==1);
    p.stopped=true; first=p.generation;
    playback_activate(&p); playback_step(&p,-1);
    assert(p.generation==first && playback_push(&p,first,data,32)==0);

    /* Randomized wrap/partial-transfer stress, comparing every consumed frame
       with an independent monotonically numbered stream. */
    playback_init(&p,buffer,sizeof(buffer),1); p.connected=true;
    uint32_t written=0,read=0;
    for(unsigned k=0;k<100000;++k) {
        if(random_value()&0x100) {
            unsigned wanted=(random_value()%32+1)*4;
            for(unsigned j=0;j<32;++j) data[j]=written+j;
            written+=(uint32_t)playback_push(&p,p.generation,data,wanted)/4;
        } else {
            unsigned wanted=(random_value()%32+1)*4;
            size_t n=playback_read(&p,out,wanted);
            for(size_t j=0;j<n;j+=4) {uint32_t v;memcpy(&v,out+j,4);assert(v==read++);}
        }
        assert(p.queued==(written-read)*4 && p.queued<=sizeof(buffer));
    }
    playback_end(&p,p.generation,false);
    size_t n=playback_read(&p,out,sizeof(out));
    for(size_t j=0;j<n;j+=4) {uint32_t v;memcpy(&v,out+j,4);assert(v==read++);}
    playback_tick(&p); assert(p.finished && read==written);
    puts("PASS playback: 100000 randomized transfers, exact EOF drain, stale skip rejection, pause/reconnect, error/replay and album boundaries");
}
