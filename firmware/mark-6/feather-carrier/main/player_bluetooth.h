#pragma once
#include <stdbool.h>
#include <stdint.h>

#define PLAYER_BT_SAVED_MAX 8
#define PLAYER_BT_FOUND_MAX 16
#define PLAYER_BT_NAME_MAX 64

typedef enum {
    PLAYER_BT_OFF, PLAYER_BT_IDLE, PLAYER_BT_SCANNING, PLAYER_BT_CONNECTING,
    PLAYER_BT_CONNECTED, PLAYER_BT_DISCONNECTING, PLAYER_BT_ERROR
} player_bt_state_t;
typedef enum {
    PLAYER_BT_SCAN, PLAYER_BT_CONNECT, PLAYER_BT_DISCONNECT,
    PLAYER_BT_CANCEL, PLAYER_BT_FORGET
} player_bt_command_t;
typedef struct {
    uint8_t address[6];
    char name[PLAYER_BT_NAME_MAX];
    bool bonded, connected;
} player_bt_device_t;
typedef struct {
    player_bt_state_t state;
    bool ready, busy, scanning, connected;
    unsigned saved_count, found_count;
    player_bt_device_t saved[PLAYER_BT_SAVED_MAX], found[PLAYER_BT_FOUND_MAX];
    char status[112], receiver[PLAYER_BT_NAME_MAX];
    uint8_t peer[6];
} player_bt_snapshot_t;

/* NVS and Bluedroid must already be initialized. Commands never wait for RF. */
bool player_bluetooth_init(void);
bool player_bluetooth_command(player_bt_command_t command, const uint8_t address[6]);
/* Copies bounded state, without exposing callback-owned pointers. <=2ms lock wait. */
bool player_bluetooth_snapshot(player_bt_snapshot_t *out);
