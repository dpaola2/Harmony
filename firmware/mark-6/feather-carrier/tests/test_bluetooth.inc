#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdatomic.h>
#include "audio_player.h"
#define ESP_LOGI(...) ((void)0)
#define ESP_LOGE(...) ((void)0)
enum { ESP_A2D_CONNECTION_STATE_EVT=1, ESP_A2D_AUDIO_STATE_EVT,
 ESP_A2D_AUDIO_CFG_EVT, ESP_A2D_MEDIA_CTRL_ACK_EVT, ESP_A2D_REPORT_SNK_DELAY_VALUE_EVT };
enum { ESP_A2D_CONNECTION_STATE_CONNECTED, ESP_A2D_CONNECTION_STATE_DISCONNECTED };
enum { ESP_A2D_AUDIO_STATE_STARTED, ESP_A2D_AUDIO_STATE_STOPPED };
enum { ESP_A2D_MEDIA_CTRL_CHECK_SRC_RDY, ESP_A2D_MEDIA_CTRL_START, ESP_A2D_MEDIA_CTRL_SUSPEND };
#define ESP_A2D_MEDIA_CTRL_ACK_SUCCESS 0
/* Only state/event fields used by the actual state-machine functions. */
typedef struct {
 struct {int state;} conn_stat;
 struct {int state;} audio_stat;
 struct {int cmd,status;} media_ctrl_stat;
 struct {int delay_value;} a2d_report_delay_value_stat;
} esp_a2d_cb_param_t;
static int s_a2d_state,s_media_state,s_connecting_intv;
static unsigned s_pkt_cnt;
static atomic_bool shutdown_requested;
static uint8_t s_peer_bda[6];
static unsigned connects,disconnects,suspends,starts;
static audio_player_snapshot_t snapshot;
static bool audio_connected;
static void esp_a2d_source_connect(const void *bda) {(void)bda;++connects;}
static void esp_a2d_source_disconnect(const void *bda) {(void)bda;++disconnects;}
static void esp_bt_gap_cancel_discovery(void) {}
static void esp_a2d_media_ctrl(int cmd) {if(cmd==ESP_A2D_MEDIA_CTRL_SUSPEND) ++suspends;if(cmd==ESP_A2D_MEDIA_CTRL_START) ++starts;}
audio_player_snapshot_t audio_player_snapshot(void) {return snapshot;}
void audio_player_connected(bool value) {audio_connected=value;}
void audio_player_log(void) {}
