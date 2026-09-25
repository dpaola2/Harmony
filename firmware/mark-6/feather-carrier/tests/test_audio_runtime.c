#include "runtime.h"
#undef fopen
#include <assert.h>
#include <stdatomic.h>
#include <stdarg.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include "mp3_reader.h"
#include "audio_player.h"
static pthread_t task;
static atomic_bool mounted;
static atomic_uint fail_track;
static void (*producer_fn)(void *);
static void *run(void *arg) {producer_fn(arg);return NULL;}
SemaphoreHandle_t xSemaphoreCreateMutexStatic(StaticSemaphore_t *p) {assert(!pthread_mutex_init(p,NULL));return p;}
int xSemaphoreTake(SemaphoreHandle_t p,uint32_t ticks) {return !(ticks?pthread_mutex_lock(p):pthread_mutex_trylock(p));}
void xSemaphoreGive(SemaphoreHandle_t p) {assert(!pthread_mutex_unlock(p));}
void vSemaphoreDelete(SemaphoreHandle_t p) {assert(!pthread_mutex_destroy(p));}
int xTaskCreatePinnedToCore(void (*fn)(void*),const char *name,unsigned stack,void *arg,unsigned priority,void *handle,int core)
{(void)name;(void)stack;(void)priority;(void)handle;(void)core;producer_fn=fn;return pthread_create(&task,NULL,run,arg)?0:1;}
void vTaskDelay(unsigned n) {usleep(n*1000);}
void vTaskDelete(void *unused) {(void)unused;pthread_exit(NULL);}
void *heap_caps_malloc(size_t n,unsigned flags) {(void)flags;return malloc(n);}
int64_t esp_timer_get_time(void) {struct timespec t;clock_gettime(CLOCK_MONOTONIC,&t);return (int64_t)t.tv_sec*1000000+t.tv_nsec/1000;}
int bench_storage_mount(void) {atomic_store(&mounted,true);return 0;}
void bench_storage_unmount(void) {atomic_store(&mounted,false);}
void test_log(const char *tag,const char *fmt,...) {(void)tag;(void)fmt;}
FILE *test_fopen(const char *path,const char *mode)
{
    (void)mode;assert(!strcmp(path,"/sd/HARMONY/ALBUM.M3U"));
    FILE *f=tmpfile();assert(f);fputs("one.mp3\ntwo.mp3\nthree.mp3\n",f);rewind(f);return f;
}
int mp3_reader_open(mp3_reader_t *r,const char *path)
{
    *r=(mp3_reader_t){0};
    const char *names[]={"one.mp3","two.mp3","three.mp3"};
    for(unsigned i=0;i<3;++i) if(strstr(path,names[i])) r->track=i+1;
    assert(r->track);r->opened=true;return 0;
}
int mp3_reader_next(mp3_reader_t *r,int16_t *pcm)
{
    assert(r->opened);
    if(atomic_load(&fail_track)==r->track) return -1;
    if(r->frame++==20) return 0;
    for(unsigned i=0;i<MINIMP3_MAX_SAMPLES_PER_FRAME;++i) pcm[i]=(int16_t)(1600*r->track);
    return MINIMP3_MAX_SAMPLES_PER_FRAME;
}
void mp3_reader_close(mp3_reader_t *r) {r->opened=false;}
static void silence(void)
{
    int16_t samples[512];audio_player_read((uint8_t*)samples,sizeof(samples));
    for(unsigned i=0;i<512;++i) assert(samples[i]==0);
}
int main(void)
{
    assert(audio_player_prepare());
    assert(audio_player_snapshot().count==3);
    silence(); /* disconnected before first media start */
    audio_player_connected(true);
    audio_player_activate();silence();assert(audio_player_snapshot().paused);
    audio_player_connected(false);audio_player_activate();silence();
    audio_player_connected(true);
    audio_player_step(1); /* skip buffered first track */
    unsigned heard=0;
    for(unsigned i=0;i<1000 && heard<1024;++i) {
        int16_t pcm[512];audio_player_read((uint8_t*)pcm,sizeof(pcm));
        for(unsigned j=0;j<512;++j) {assert(pcm[j]==0 || pcm[j]==200);heard+=pcm[j]!=0;}
        usleep(1000);
    }
    assert(heard>=1024);
    audio_player_connected(false);
    uint32_t consumed=audio_player_snapshot().consumed_frames;
    silence();usleep(10000);silence();assert(audio_player_snapshot().consumed_frames==consumed);
    audio_player_step(-1);audio_player_connected(true);
    uint32_t counts[3]={0};unsigned last=0;
    int64_t deadline=esp_timer_get_time()+5000000;
    while(!audio_player_finished() && esp_timer_get_time()<deadline) {
        int16_t pcm[512];audio_player_read((uint8_t*)pcm,sizeof(pcm));
        for(unsigned i=0;i<512;++i) if(pcm[i]) {
            unsigned track=(unsigned)pcm[i]/100;assert(track>=1 && track<=3 && track>=last);
            last=track;++counts[track-1];
        }
        usleep(100);
    }
    assert(audio_player_finished());
    for(unsigned i=0;i<3;++i) assert(counts[i]==20*MINIMP3_MAX_SAMPLES_PER_FRAME);
    assert(atomic_load(&mounted)); /* replay remains available */
    atomic_store(&fail_track,3);audio_player_activate();
    deadline=esp_timer_get_time()+1000000;
    while(!audio_player_snapshot().failed && esp_timer_get_time()<deadline) usleep(1000);
    assert(audio_player_snapshot().failed);silence();
    audio_player_log();audio_player_stop();pthread_join(task,NULL);
    assert(!atomic_load(&mounted));silence();
    puts("PASS actual audio tasks: concurrent producer/callback, skip flush, quiet gain, pause/disconnect, exact three-track sample counts, format failure and unmount");
}
