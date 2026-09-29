#include "player_ui.h"
#include "player_prefs.h"
#include "player_bluetooth.h"
#include "album_metadata.h"
#include <assert.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
static album_t library;
static audio_player_snapshot_t audio;
static player_bt_snapshot_t bluetooth;
static player_bt_command_t last_command;
static uint8_t command_address[6];
static unsigned commands,played[ALBUM_MAX_TRACKS],played_count,played_start,calls;
const album_t *audio_player_library(void){return &library;}
audio_player_snapshot_t audio_player_snapshot(void){return audio;}
bool audio_player_play_queue(const unsigned *tracks,unsigned count,unsigned start){memcpy(played,tracks,count*sizeof(*tracks));played_count=count;played_start=start;++calls;audio.track=tracks[start];++audio.generation;audio.paused=false;return true;}
void audio_player_toggle_pause(void){audio.paused=!audio.paused;}
void audio_player_set_paused(bool paused){audio.paused=paused;}
void audio_player_step(int delta){(void)delta;++audio.generation;}
void audio_player_set_volume(unsigned n){audio.volume=n>100?100:n;}
unsigned audio_player_volume(void){return audio.volume;}
void audio_player_set_modes(bool shuffle,unsigned repeat){audio.shuffle=shuffle;audio.repeat=repeat;}
bool player_bluetooth_snapshot(player_bt_snapshot_t *out){*out=bluetooth;return true;}
bool player_bluetooth_command(player_bt_command_t command,const uint8_t address[6]){last_command=command;memset(command_address,0,6);if(address)memcpy(command_address,address,6);commands++;return true;}
static player_ui_view_t action(player_ui_input_t input,int delta){assert(player_ui_input(input,delta));player_ui_update();return player_ui_view();}
static player_ui_view_t select_item(void){return action(PLAYER_UI_SELECT,0);}
static player_ui_view_t back(void){return action(PLAYER_UI_BACK,0);}
static player_ui_view_t scroll(int delta){return action(PLAYER_UI_SCROLL,delta);}
static void reset(void){player_prefs_t p={.version=1,.volume=40};player_prefs_update(&p);memset(&audio,0,sizeof(audio));audio.volume=40;player_ui_init();calls=0;}
static void load(void){
    const char *paths[]={"Artist A/Same Album/01-01 First.mp3","Artist B/Same Album/01 Other artist.mp3","Artist A/Same Album/01-02 Second.mp3","Artist A/Other Album/01 Elsewhere.mp3","Artist A/Same Album/03 Third.mp3","Artist A/Same Album/04 Fourth.mp3","Artist A/Same Album/05 Fifth.mp3","Artist A/Same Album/06 Sixth.mp3","Artist A/Same Album/07 Seventh.mp3","Artist A/Same Album/08 Eighth.mp3","Artist A/Same Album/09 1979.mp3"};
    library.count=sizeof(paths)/sizeof(*paths);
    for(unsigned i=0;i<library.count;i++){strcpy(library.tracks[i].path,paths[i]);album_track_fallback(&library.tracks[i]);}
    library.playlist_count=1;strcpy(library.playlists[0].name,"Favorites");library.playlists[0].count=3;
    library.playlists[0].track_indices[0]=1;library.playlists[0].track_indices[1]=0;library.playlists[0].track_indices[2]=1;
    reset();
}
int main(void){
    player_prefs_init();load();assert(audio.paused&&audio.volume==40);
    assert(back().page==PLAYER_UI_ROOT);assert(select_item().page==PLAYER_UI_MUSIC);assert(select_item().page==PLAYER_UI_ARTISTS);
    player_ui_view_t v=player_ui_view();assert(v.total_count==2&&!strcmp(v.rows[0].label,"Artist A"));assert(audio.generation==0);
    v=select_item();assert(v.page==PLAYER_UI_ALBUMS&&v.total_count==2);
    v=select_item();assert(v.page==PLAYER_UI_SONGS&&v.total_count==9);assert(!strcmp(v.rows[0].label,"First"));
    v=scroll(INT_MAX);assert(v.selected==8&&v.first==3);v=scroll(INT_MIN);assert(v.selected==0&&v.first==0);
    scroll(6);v=select_item();assert(v.page==PLAYER_UI_NOW_PLAYING);assert(calls==1&&played_count==9&&played_start==6);assert(played[0]==0&&played[1]==2&&played[8]==10);
    assert(!strcmp(v.track_title,"Seventh"));scroll(1);assert(audio.volume==41);scroll(INT_MAX);assert(audio.volume==100);scroll(INT_MIN);assert(audio.volume==0);
    select_item();assert(audio.paused);action(PLAYER_UI_PLAY_PAUSE,0);assert(!audio.paused);
    v=back();assert(v.page==PLAYER_UI_SONGS&&v.selected==6&&v.first==1&&v.rows[5].playing);
    back();back();scroll(1);v=select_item();assert(v.total_count==1&&!strcmp(v.subtitle,"Artist B"));select_item();assert(calls==1);select_item();assert(played_count==1&&played[0]==1);
    /* Persistent last song restores its album paused, with safe startup volume. */
    scroll(INT_MAX);player_ui_init();assert(audio.paused&&audio.volume==40&&played_count==1&&played[0]==1);
    reset();select_item();scroll(2);v=select_item();assert(v.page==PLAYER_UI_ALL_SONGS&&v.total_count==library.count);select_item();assert(played_count==library.count);back();back();scroll(1);v=select_item();assert(v.page==PLAYER_UI_PLAYLISTS);v=select_item();assert(v.page==PLAYER_UI_PLAYLIST_SONGS&&v.total_count==3);scroll(1);select_item();assert(played_count==3&&played_start==1&&played[0]==1&&played[1]==0&&played[2]==1);
    /* Real BT actions: selecting a result only opens details; pairing is explicit. */
    reset();bluetooth.ready=true;bluetooth.found_count=2;
    strcpy(bluetooth.found[0].name,"Speaker");strcpy(bluetooth.found[1].name,"Speaker");bluetooth.found[0].address[5]=1;bluetooth.found[1].address[5]=2;
    scroll(2);select_item();scroll(1);v=select_item();assert(v.page==PLAYER_UI_BT_FOUND&&last_command==PLAYER_BT_SCAN);
    assert(strcmp(v.rows[0].detail,v.rows[1].detail));unsigned before=commands;scroll(1);v=select_item();assert(v.page==PLAYER_UI_BT_DEVICE&&commands==before);select_item();assert(last_command==PLAYER_BT_CONNECT&&command_address[5]==2);
    scroll(2);v=select_item();assert(v.page==PLAYER_UI_BT_FORGET);before=commands;select_item();assert(commands==before);select_item();scroll(1);select_item();assert(last_command==PLAYER_BT_FORGET&&command_address[5]==2);
    /* Settings persist, and the first input after timeout wakes without acting. */
    reset();scroll(3);v=select_item();assert(v.page==PLAYER_UI_SETTINGS);select_item();assert(audio.shuffle);scroll(1);select_item();assert(audio.repeat==1);select_item();assert(audio.repeat==2);select_item();assert(audio.repeat==0);scroll(1);select_item();assert(player_prefs_get().timeout_seconds==30);
    player_ui_tick(1000);player_ui_tick(31000);v=player_ui_view();assert(v.display_asleep);v=scroll(-1);assert(!v.display_asleep&&v.selected==2);v=scroll(-1);assert(v.selected==1);
    reset();for(unsigned i=0;i<31;i++)assert(player_ui_input(PLAYER_UI_SCROLL,1));assert(!player_ui_input(PLAYER_UI_BACK,0));player_ui_update();assert(player_ui_view().selected==3);
    library.count=0;library.playlist_count=0;library.status=ALBUM_STATUS_EMPTY;reset();assert(strstr(player_ui_view().notice,"restart"));select_item();select_item();assert(player_ui_view().total_count==0);assert(select_item().page==PLAYER_UI_ARTISTS);
    puts("PASS native UI: library queues/Back, volume boundaries, paused restore, real BT intent/Forget, settings, timeout wake, bounded events and storage recovery");
}
