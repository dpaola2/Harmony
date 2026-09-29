#define main original_audio_runtime_test
#define heap_caps_malloc original_heap_caps_malloc
#include "test_audio_runtime.c"
#undef main
#undef heap_caps_malloc
static bool empty_library, allocation_failure;
void *heap_caps_malloc(size_t n,unsigned flags)
{
    return allocation_failure ? NULL : original_heap_caps_malloc(n,flags);
}
bool album_load(const char *root, album_t *value)
{
    assert(!strcmp(root,"/sd/HARMONY"));
    memset(value,0,sizeof(*value));
    if(empty_library){value->status=ALBUM_STATUS_INVALID_PLAYLIST;return false;}
    value->count=3;
    const char *names[]={"one.mp3","two.mp3","three.mp3"};
    for(unsigned i=0;i<3;++i){strcpy(value->tracks[i].path,names[i]);strcpy(value->tracks[i].title,names[i]);}
    return true;
}
const char *album_status_text(album_status_t status) {(void)status;return "Invalid playlist";}
static void ready(void)
{
    int64_t until=esp_timer_get_time()+1000000;
    while(audio_player_snapshot().buffering && esp_timer_get_time()<until)usleep(1000);
    assert(!audio_player_snapshot().buffering);
}
static void read_block(int16_t *samples) {audio_player_read((uint8_t*)samples,512*sizeof(*samples));}
int main(int argc,char **argv)
{
    empty_library=argc>1 && !strcmp(argv[1],"empty");
    allocation_failure=argc>1 && !strcmp(argv[1],"allocation");
    if(allocation_failure){
        assert(!audio_player_prepare());
        audio_player_snapshot_t failure=audio_player_snapshot();
        assert(failure.failed && failure.stopped && failure.paused && !failure.count);
        assert(!audio_player_library() && !atomic_load(&mounted));
        audio_player_connected(true);audio_player_toggle_pause();silence();
        puts("PASS UI audio: pre-lock allocation failure is reported failed/stopped/paused and silent");
        return 0;
    }
    assert(audio_player_prepare());
    audio_player_snapshot_t s=audio_player_snapshot();
    assert(s.paused && s.volume==40 && audio_player_volume()==40);
    if(empty_library){
        assert(!s.count && s.failed && !s.stopped && !s.buffering);
        assert(audio_player_library()->status==ALBUM_STATUS_INVALID_PLAYLIST);
        audio_player_connected(true);audio_player_toggle_pause();silence();
        assert(!atomic_load(&mounted));audio_player_stop();
        puts("PASS UI audio: unavailable library retains visible error and silent controls without decoder");
        return 0;
    }
    audio_player_connected(true);silence();assert(audio_player_snapshot().paused);
    audio_player_set_paused(false);
    int16_t samples[512];read_block(samples);
    for(unsigned i=0;i<512;++i)assert(samples[i]==100);
    uint32_t generation=audio_player_snapshot().generation;
    audio_player_set_volume(100);read_block(samples);
    int last=100;
    for(unsigned i=0;i<512;i+=2){assert(samples[i]>=last && samples[i]<=1600);assert(samples[i]==samples[i+1]);last=samples[i];}
    read_block(samples);assert(samples[511]==1600);
    audio_player_set_volume(0);read_block(samples);read_block(samples);assert(samples[511]==0);
    silence();assert(audio_player_snapshot().generation==generation);
    audio_player_set_volume(999);assert(audio_player_volume()==100);
    audio_player_set_volume(40);read_block(samples);read_block(samples);assert(samples[511]==100);
    audio_player_connected(false);assert(audio_player_snapshot().paused);silence();
    audio_player_connected(true);assert(audio_player_snapshot().paused);silence();
    audio_player_set_paused(false);read_block(samples);assert(samples[511]==100);

    unsigned queue[]={0,1,2,1};
    assert(audio_player_play_queue(queue,4,2));audio_player_set_paused(true);
    generation=audio_player_snapshot().generation;
    audio_player_set_modes(true,AUDIO_REPEAT_OFF);
    s=audio_player_snapshot();
    assert(s.shuffle && s.track==2 && s.queue_position==0 && s.generation==generation);
    unsigned occurrences[3]={0};
    for(unsigned i=0;i<4;++i){s=audio_player_snapshot();++occurrences[s.track];audio_player_step(1);}
    assert(occurrences[0]==1 && occurrences[1]==2 && occurrences[2]==1);
    s=audio_player_snapshot();generation=s.generation;
    audio_player_set_modes(false,AUDIO_REPEAT_ALL);
    assert(audio_player_snapshot().track==s.track && audio_player_snapshot().generation==generation);
    assert(audio_player_snapshot().repeat==AUDIO_REPEAT_ALL && !audio_player_snapshot().shuffle);
    audio_player_set_modes(true,AUDIO_REPEAT_ONE);
    assert(audio_player_play_queue(queue,4,1));
    assert(audio_player_snapshot().track==1 && audio_player_snapshot().queue_position==0);
    assert(audio_player_snapshot().repeat==AUDIO_REPEAT_ONE);
    audio_player_set_modes(false,999);assert(audio_player_snapshot().repeat==AUDIO_REPEAT_OFF);
    ready();audio_player_stop();pthread_join(task,NULL);
    puts("PASS UI audio: paused boot/reconnect, exact quiet gain, immediate queued-PCM ramp/mute, clamped volume, shuffle duplicate membership, preserved start/generation and mode validation");
    return 0;
}
