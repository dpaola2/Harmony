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
    /* Repeat-one only restarts natural EOF; manual skips remain effective. */
    playback_init(&p,buffer,sizeof(buffer),3); p.connected=true; p.repeat=2;
    first=p.generation; playback_end(&p,first,false); playback_tick(&p);
    assert(p.track==0 && p.generation!=first && !p.finished);
    playback_step(&p,1); assert(p.track==1);
    p.repeat=1; playback_step(&p,-2); assert(p.track==2);
    first=p.generation; playback_end(&p,first,false); playback_tick(&p);
    assert(p.track==0 && p.generation!=first && !p.finished);
    p.repeat=0; playback_step(&p,INT_MAX);
    playback_end(&p,p.generation,false); playback_tick(&p); assert(p.finished);

    /* Gain endpoints, monotonic curve, click-limiting ramp and exact mute. */
    assert(playback_volume_gain(0)==0 && playback_volume_gain(40)==4096);
    assert(playback_volume_gain(100)==65536 && playback_volume_gain(999)==65536);
    for(unsigned v=1;v<=100;++v) assert(playback_volume_gain(v)>=playback_volume_gain(v-1));
    playback_gain_t gain; playback_gain_init(&gain,40);
    int16_t samples[2*500];
    for(unsigned i=0;i<500;++i){samples[2*i]=32767;samples[2*i+1]=-32768;}
    playback_gain_apply(&gain,(uint8_t*)samples,sizeof(samples),100);
    int previous_sample=2047;
    for(unsigned i=0;i<500;++i){
        assert(samples[2*i]>=previous_sample && samples[2*i]-previous_sample<=71);
        assert(samples[2*i]>=0 && samples[2*i+1]<=0);
        previous_sample=samples[2*i];
    }
    assert(samples[880]==32767 && samples[881]==-32768 && !gain.remaining);
    for(unsigned i=0;i<1000;++i)samples[i]=32767;
    playback_gain_apply(&gain,(uint8_t*)samples,sizeof(samples),0);
    previous_sample=32767;
    for(unsigned i=0;i<500;++i){
        assert(samples[2*i]<=previous_sample && previous_sample-samples[2*i]<=75);
        assert(samples[2*i]==samples[2*i+1]);previous_sample=samples[2*i];
    }
    assert(!samples[880] && !samples[999] && !gain.current);
    /* A mid-ramp reversal starts from current gain, never jumps to old target. */
    memset(samples,0,sizeof(samples));
    playback_gain_apply(&gain,(uint8_t*)samples,40,100);
    int gain_before=gain.current;
    playback_gain_apply(&gain,(uint8_t*)samples,4,0);
    assert(gain.current<=gain_before && gain_before-gain.current<151);

    puts("PASS playback: 100000 randomized transfers, exact EOF drain, stale skip rejection, pause/reconnect, error/replay and album boundaries");
}
