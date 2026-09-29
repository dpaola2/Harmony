/* Single display-task owner; controls use a bounded SPSC event queue. */
#include "player_ui.h"
#include "player_prefs.h"
#include "player_bluetooth.h"
#include <stdatomic.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#define EVENT_COUNT 32
#define STACK_DEPTH 8
#define ALL_ARTISTS ALBUM_MAX_TRACKS

typedef struct { player_ui_input_t input; int delta; } event_t;
typedef struct {
    player_ui_page_t page;
    unsigned selected, first, artist, album;
    uint8_t address[6];
    char device_name[PLAYER_BT_NAME_MAX];
} screen_t;
static const album_t *library;
static screen_t screens[STACK_DEPTH];
static unsigned depth;
static uint32_t revision, now_ms, active_ms;
static bool asleep;
static event_t events[EVENT_COUNT];
static atomic_uint event_read, event_write;
static char notice[128];
static player_prefs_t prefs;
static player_bt_snapshot_t bt;
/* Scratch arrays stay off the display stack. This task is their sole owner. */
static unsigned ids[ALBUM_MAX_TRACKS];
static bool list_cached;
static player_ui_page_t cached_page;
static unsigned cached_artist, cached_album, cached_count;
static bool same_artist(unsigned a,unsigned b) { return !strcmp(library->tracks[a].artist,library->tracks[b].artist); }
static bool same_album(unsigned a,unsigned b) { return same_artist(a,b)&&!strcmp(library->tracks[a].album,library->tracks[b].album); }
static unsigned items(const screen_t *s)
{
    if(list_cached&&s->page==cached_page&&s->artist==cached_artist&&s->album==cached_album)return cached_count;
    list_cached=true;cached_page=s->page;cached_artist=s->artist;cached_album=s->album;cached_count=0;
    unsigned count=0;
    if(!library)return 0;
    if(s->page==PLAYER_UI_PLAYLIST_SONGS){
        if(s->album>=library->playlist_count)return 0;
        const album_playlist_t *p=&library->playlists[s->album];
        for(unsigned i=0;i<p->count&&i<ALBUM_MAX_TRACKS;i++)if(p->track_indices[i]<library->count)ids[count++]=p->track_indices[i];
        cached_count=count;return count;
    }
    for(unsigned i=0;i<library->count;i++){
        if(s->page==PLAYER_UI_ALL_SONGS){ids[count++]=i;continue;}
        if(s->page==PLAYER_UI_SONGS){if(s->album<library->count&&same_album(i,s->album))ids[count++]=i;continue;}
        if(s->page==PLAYER_UI_ALBUMS&&s->artist!=ALL_ARTISTS&&!same_artist(i,s->artist))continue;
        bool duplicate=false;
        for(unsigned j=0;j<count;j++)if(s->page==PLAYER_UI_ARTISTS?same_artist(i,ids[j]):same_album(i,ids[j])){duplicate=true;break;}
        if(!duplicate)ids[count++]=i;
    }
    /* Albums retain disc/track order from the index; All Songs sorts by title. */
    if(s->page==PLAYER_UI_ALL_SONGS)for(unsigned i=1;i<count;i++){
        unsigned key=ids[i],j=i;
        while(j&&strcasecmp(library->tracks[ids[j-1]].title,library->tracks[key].title)>0){ids[j]=ids[j-1];j--;}
        ids[j]=key;
    }
    cached_count=count;return count;
}
static unsigned screen_count(const screen_t *s)
{
    switch(s->page){
    case PLAYER_UI_ROOT: case PLAYER_UI_MUSIC:return 4;
    case PLAYER_UI_SETTINGS:return 3;
    case PLAYER_UI_NOW_PLAYING:return 0;
    case PLAYER_UI_BLUETOOTH:return 3;
    case PLAYER_UI_BT_SAVED:return bt.saved_count;
    case PLAYER_UI_BT_FOUND:return bt.found_count;
    case PLAYER_UI_BT_DEVICE:return 3;
    case PLAYER_UI_BT_FORGET:return 2;
    case PLAYER_UI_PLAYLISTS:return library?library->playlist_count:0;
    default:return items(s);
    }
}
static void clamp_screen(screen_t *s)
{
    unsigned count=screen_count(s);
    if(s->selected>=count)s->selected=count?count-1:0;
    if(s->selected<s->first)s->first=s->selected;
    if(s->selected>=s->first+PLAYER_UI_ROWS)s->first=s->selected-PLAYER_UI_ROWS+1;
}
static void push(player_ui_page_t page,unsigned artist,unsigned album)
{
    if(depth+1>=STACK_DEPTH)return;
    screens[++depth]=(screen_t){.page=page,.artist=artist,.album=album};
}
static void command(player_bt_command_t cmd,const uint8_t *address)
{
    if(!player_bluetooth_command(cmd,address))snprintf(notice,sizeof(notice),"Bluetooth busy; try again");
}
void player_ui_init(void)
{
    list_cached=false;
    library=audio_player_library();
    if(library&&library->count>ALBUM_MAX_TRACKS)library=NULL;
    player_prefs_init();prefs=player_prefs_get();
    audio_player_set_volume(prefs.volume);
    audio_player_set_modes(prefs.shuffle,prefs.repeat);
    audio_player_set_paused(true);
    /* Restore the last song in its album queue, always paused before BT starts. */
    if(library&&prefs.track_path[0])for(unsigned i=0;i<library->count;i++)if(!strcmp(prefs.track_path,library->tracks[i].path)){
        screen_t restore={.page=PLAYER_UI_SONGS,.album=i};
        unsigned count=items(&restore),at=0;
        while(at<count&&ids[at]!=i)at++;
        if(at<count){audio_player_play_queue(ids,count,at);audio_player_set_paused(true);}
        break;
    }
    depth=0;screens[0]=(screen_t){.page=PLAYER_UI_ROOT};
    notice[0]=0;revision=1;now_ms=active_ms=0;asleep=false;
    memset(&bt,0,sizeof(bt));
    atomic_store(&event_read,0);atomic_store(&event_write,0);
}
bool player_ui_input(player_ui_input_t input,int delta)
{
    if(input<PLAYER_UI_SCROLL||input>PLAYER_UI_NEXT)return false;
    unsigned w=atomic_load_explicit(&event_write,memory_order_relaxed),next=(w+1)%EVENT_COUNT;
    if(next==atomic_load_explicit(&event_read,memory_order_acquire))return false;
    events[w]=(event_t){input,delta};atomic_store_explicit(&event_write,next,memory_order_release);return true;
}
void player_ui_tick(uint32_t time)
{
    if(!now_ms)active_ms=time;
    now_ms=time;
    if(prefs.timeout_seconds&&now_ms-active_ms>=prefs.timeout_seconds*1000)asleep=true;
}
static void handle(event_t event)
{
    screen_t *s=&screens[depth];
    active_ms=now_ms;
    if(asleep){asleep=false;return;}
    notice[0]=0;++revision;clamp_screen(s);
    if(event.input==PLAYER_UI_BACK){if(depth)--depth;return;}
    if(event.input==PLAYER_UI_PLAY_PAUSE){audio_player_toggle_pause();return;}
    if(event.input==PLAYER_UI_PREVIOUS||event.input==PLAYER_UI_NEXT){audio_player_step(event.input==PLAYER_UI_NEXT?1:-1);return;}
    if(event.input==PLAYER_UI_SCROLL){
        if(s->page==PLAYER_UI_NOW_PLAYING){
            int64_t level=(int64_t)audio_player_volume()+event.delta;
            audio_player_set_volume(level<0?0:level>100?100:(unsigned)level);return;
        }
        unsigned count=screen_count(s);int64_t next=(int64_t)s->selected+event.delta;
        s->selected=next<0?0:next>=count?(count?count-1:0):(unsigned)next;clamp_screen(s);return;
    }
    if(event.input!=PLAYER_UI_SELECT)return;
    switch(s->page){
    case PLAYER_UI_ROOT:{const player_ui_page_t pages[]={PLAYER_UI_MUSIC,PLAYER_UI_NOW_PLAYING,PLAYER_UI_BLUETOOTH,PLAYER_UI_SETTINGS};push(pages[s->selected],ALL_ARTISTS,0);break;}
    case PLAYER_UI_MUSIC:{const player_ui_page_t pages[]={PLAYER_UI_ARTISTS,PLAYER_UI_ALBUMS,PLAYER_UI_ALL_SONGS,PLAYER_UI_PLAYLISTS};push(pages[s->selected],ALL_ARTISTS,0);break;}
    case PLAYER_UI_ARTISTS: case PLAYER_UI_ALBUMS: case PLAYER_UI_SONGS: case PLAYER_UI_ALL_SONGS: case PLAYER_UI_PLAYLIST_SONGS:{
        unsigned count=items(s);if(!count)break;
        if(s->page==PLAYER_UI_ARTISTS)push(PLAYER_UI_ALBUMS,ids[s->selected],0);
        else if(s->page==PLAYER_UI_ALBUMS)push(PLAYER_UI_SONGS,s->artist,ids[s->selected]);
        else if(audio_player_play_queue(ids,count,s->selected))push(PLAYER_UI_NOW_PLAYING,s->artist,s->album);
        else snprintf(notice,sizeof(notice),"Cannot play; choose another song");
        break;
    }
    case PLAYER_UI_PLAYLISTS:if(library&&s->selected<library->playlist_count)push(PLAYER_UI_PLAYLIST_SONGS,ALL_ARTISTS,s->selected);break;
    case PLAYER_UI_NOW_PLAYING:audio_player_toggle_pause();break;
    case PLAYER_UI_SETTINGS:
        if(s->selected==0)prefs.shuffle=!prefs.shuffle;
        else if(s->selected==1)prefs.repeat=(prefs.repeat+1)%3;
        else {const unsigned timeouts[]={0,30,60,120};unsigned i=0;while(i<3&&timeouts[i]!=prefs.timeout_seconds)i++;prefs.timeout_seconds=timeouts[(i+1)%4];}
        audio_player_set_modes(prefs.shuffle,prefs.repeat);break;
    case PLAYER_UI_BLUETOOTH:
        if(s->selected==0)push(PLAYER_UI_BT_SAVED,0,0);
        else if(s->selected==1){command(PLAYER_BT_SCAN,NULL);push(PLAYER_UI_BT_FOUND,0,0);}
        else if(bt.busy)command(PLAYER_BT_CANCEL,NULL);
        else if(bt.connected)command(PLAYER_BT_DISCONNECT,bt.peer);
        else snprintf(notice,sizeof(notice),"No active connection or scan");
        break;
    case PLAYER_UI_BT_SAVED:case PLAYER_UI_BT_FOUND:{
        unsigned count=s->page==PLAYER_UI_BT_SAVED?bt.saved_count:bt.found_count;
        if(s->selected>=count)break;
        player_bt_device_t d=s->page==PLAYER_UI_BT_SAVED?bt.saved[s->selected]:bt.found[s->selected];
        push(PLAYER_UI_BT_DEVICE,0,0);s=&screens[depth];memcpy(s->address,d.address,6);snprintf(s->device_name,sizeof(s->device_name),"%s",d.name);break;
    }
    case PLAYER_UI_BT_DEVICE:
        if(s->selected==0)command(PLAYER_BT_CONNECT,s->address);
        else if(s->selected==1)command(PLAYER_BT_DISCONNECT,s->address);
        else {screen_t copy=*s;push(PLAYER_UI_BT_FORGET,0,0);memcpy(screens[depth].address,copy.address,6);snprintf(screens[depth].device_name,sizeof(screens[depth].device_name),"%s",copy.device_name);}
        break;
    case PLAYER_UI_BT_FORGET:
        if(s->selected==1)command(PLAYER_BT_FORGET,s->address);
        if(depth)--depth;
        break;
    default:break;
    }
}
void player_ui_update(void)
{
    (void)player_bluetooth_snapshot(&bt);
    unsigned r=atomic_load_explicit(&event_read,memory_order_relaxed);
    while(r!=atomic_load_explicit(&event_write,memory_order_acquire)){
        event_t e=events[r];r=(r+1)%EVENT_COUNT;atomic_store_explicit(&event_read,r,memory_order_release);handle(e);
    }
    clamp_screen(&screens[depth]);
    audio_player_snapshot_t a=audio_player_snapshot();
    prefs.volume=a.volume;
    if(library&&a.track<library->count)snprintf(prefs.track_path,sizeof(prefs.track_path),"%s",library->tracks[a.track].path);
    player_prefs_update(&prefs);
}
player_ui_view_t player_ui_view(void)
{
    player_ui_view_t v={0};screen_t *s=&screens[depth];
    v.page=s->page;v.first=s->first;v.selected=s->selected;v.total_count=screen_count(s);v.revision=revision;
    v.audio=audio_player_snapshot();v.display_asleep=asleep;
    /* Slow marquee makes clipped names accessible without constant fast redraw. */
    v.marquee_step=now_ms-active_ms>1800?(now_ms-active_ms-1800)/600:0;
    snprintf(v.notice,sizeof(v.notice),"%s",notice);
    snprintf(v.receiver,sizeof(v.receiver),"%s",bt.connected?bt.receiver:bt.state==PLAYER_BT_CONNECTING?"Connecting...":"No receiver");
    if(library&&v.audio.track<library->count){
        const album_track_t *t=&library->tracks[v.audio.track];
        snprintf(v.track_title,sizeof(v.track_title),"%s",t->title);snprintf(v.track_artist,sizeof(v.track_artist),"%s",t->artist);snprintf(v.track_album,sizeof(v.track_album),"%s",t->album);
    }
    const char *titles[]={"Harmony","Music","Artists","Albums","Songs","Now Playing","Bluetooth","Settings","Songs","Playlists","Playlist","Saved devices","Find devices","Device","Forget device?"};
    snprintf(v.title,sizeof(v.title),"%s",titles[s->page]);
    if(s->page==PLAYER_UI_ALBUMS&&s->artist!=ALL_ARTISTS&&library)snprintf(v.subtitle,sizeof(v.subtitle),"%s",library->tracks[s->artist].artist);
    else if(s->page==PLAYER_UI_SONGS&&library&&s->album<library->count){snprintf(v.title,sizeof(v.title),"%s",library->tracks[s->album].album);snprintf(v.subtitle,sizeof(v.subtitle),"%s",library->tracks[s->album].artist);}
    else if(s->page==PLAYER_UI_PLAYLIST_SONGS&&library&&s->album<library->playlist_count)snprintf(v.title,sizeof(v.title),"%s",library->playlists[s->album].name);
    else if(s->page==PLAYER_UI_NOW_PLAYING)snprintf(v.subtitle,sizeof(v.subtitle),"%s",v.track_artist);
    else if(s->page==PLAYER_UI_BT_DEVICE||s->page==PLAYER_UI_BT_FORGET){snprintf(v.subtitle,sizeof(v.subtitle),"%s",s->device_name);if(!v.notice[0])snprintf(v.notice,sizeof(v.notice),"%s",bt.status);}
    else if(s->page==PLAYER_UI_BLUETOOTH||s->page==PLAYER_UI_BT_SAVED||s->page==PLAYER_UI_BT_FOUND){snprintf(v.subtitle,sizeof(v.subtitle),"%s",bt.status);}
    else if(s->page==PLAYER_UI_SETTINGS)snprintf(v.subtitle,sizeof(v.subtitle),"%s",player_prefs_available()?"Saved on this player":"Preferences unavailable");
    else snprintf(v.subtitle,sizeof(v.subtitle),"%u songs",library?library->count:0);
    if((!library||!library->count)&&(s->page<=PLAYER_UI_SONGS||s->page==PLAYER_UI_ALL_SONGS||s->page==PLAYER_UI_PLAYLISTS))
        snprintf(v.notice,sizeof(v.notice),"%s; insert card, restart",library?album_status_text(library->status):"No music card");
    if(v.audio.failed&&s->page==PLAYER_UI_NOW_PLAYING)snprintf(v.notice,sizeof(v.notice),"Track error; skip or choose another song");
    if(s->page==PLAYER_UI_ARTISTS||s->page==PLAYER_UI_ALBUMS||s->page==PLAYER_UI_SONGS||s->page==PLAYER_UI_ALL_SONGS||s->page==PLAYER_UI_PLAYLIST_SONGS)items(s);
    for(unsigned i=s->first;i<v.total_count&&v.row_count<PLAYER_UI_ROWS;i++){
        player_ui_row_t *row=&v.rows[v.row_count++];
        if(s->page==PLAYER_UI_ROOT){const char *l[]={"Music","Now Playing","Bluetooth","Settings"};snprintf(row->label,sizeof(row->label),"%s",l[i]);}
        else if(s->page==PLAYER_UI_MUSIC){const char *l[]={"Artists","Albums","Songs","Playlists"};snprintf(row->label,sizeof(row->label),"%s",l[i]);}
        else if(s->page==PLAYER_UI_SETTINGS){
            if(i==0){snprintf(row->label,sizeof(row->label),"Shuffle");snprintf(row->detail,sizeof(row->detail),"%s",prefs.shuffle?"On":"Off");}
            else if(i==1){const char *r[]={"Off","All","One"};snprintf(row->label,sizeof(row->label),"Repeat");snprintf(row->detail,sizeof(row->detail),"%s",r[prefs.repeat]);}
            else {snprintf(row->label,sizeof(row->label),"Display timeout");if(prefs.timeout_seconds)snprintf(row->detail,sizeof(row->detail),"%u seconds",prefs.timeout_seconds);else snprintf(row->detail,sizeof(row->detail),"Always on");}
        }else if(s->page==PLAYER_UI_BLUETOOTH){const char *l[]={"Saved devices","Find devices",bt.busy?"Cancel connection / scan":bt.connected?"Disconnect receiver":"Cancel operation"};snprintf(row->label,sizeof(row->label),"%s",l[i]);}
        else if(s->page==PLAYER_UI_BT_SAVED||s->page==PLAYER_UI_BT_FOUND){
            const player_bt_device_t *d=s->page==PLAYER_UI_BT_SAVED?&bt.saved[i]:&bt.found[i];
            snprintf(row->label,sizeof(row->label),"%s",d->name[0]?d->name:"Unnamed receiver");
            snprintf(row->detail,sizeof(row->detail),"%02X:%02X:%02X:%02X:%02X:%02X%s",d->address[0],d->address[1],d->address[2],d->address[3],d->address[4],d->address[5],d->connected?"  Connected":"");
        }else if(s->page==PLAYER_UI_BT_DEVICE){const char *l[]={"Pair / connect","Disconnect","Forget..."};snprintf(row->label,sizeof(row->label),"%s",l[i]);}
        else if(s->page==PLAYER_UI_BT_FORGET){snprintf(row->label,sizeof(row->label),"%s",i?"Forget this device":"Cancel");snprintf(row->detail,sizeof(row->detail),"%s",i?"Remove this player's saved pairing":"Keep saved pairing");}
        else if(s->page==PLAYER_UI_PLAYLISTS){snprintf(row->label,sizeof(row->label),"%s",library->playlists[i].name);snprintf(row->detail,sizeof(row->detail),"%u songs",library->playlists[i].count);}
        else{
            unsigned id=ids[i];const album_track_t *t=&library->tracks[id];
            snprintf(row->label,sizeof(row->label),"%s",s->page==PLAYER_UI_ARTISTS?t->artist:s->page==PLAYER_UI_ALBUMS?t->album:t->title);
            if(s->page!=PLAYER_UI_ARTISTS)snprintf(row->detail,sizeof(row->detail),"%s",t->artist);
            if(s->page!=PLAYER_UI_ARTISTS&&s->page!=PLAYER_UI_ALBUMS)row->playing=id==v.audio.track;
        }
    }
    return v;
}
