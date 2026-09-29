/* Bluetooth commands and callbacks are serialized by one worker. The policy
 * below is also exercised on the host; ESP-IDF bindings follow the policy. */
#include "player_bluetooth.h"
#include <stddef.h>
#include <stdio.h>
#include <string.h>

#define CONNECT_TIMEOUT_MS 30000u
#define DRAIN_TIMEOUT_MS 8000u

typedef struct {
    bool (*scan)(void);
    bool (*cancel_scan)(void);
    bool (*connect)(const uint8_t *);
    bool (*disconnect)(const uint8_t *);
    bool (*forget)(const uint8_t *);
    void (*pause)(void);
    void (*audio)(bool);
    void (*remember)(const uint8_t *);
} bt_operations_t;

typedef struct {
    player_bt_snapshot_t view;
    bt_operations_t ops;
    bool connecting, disconnecting, scan_draining, pending, removing, error;
    bool auto_reconnect;
    uint8_t active[6], pending_address[6], forgetting[6], last[6];
    uint32_t now, deadline, scan_deadline, retry_at;
} bt_manager_t;

static bool same(const uint8_t *a, const uint8_t *b) { return memcmp(a, b, 6) == 0; }
static bool nonzero(const uint8_t *a) {
    static const uint8_t zero[6]; return !same(a, zero);
}
static void message(bt_manager_t *m, const char *text) {
    snprintf(m->view.status, sizeof(m->view.status), "%s", text);
}
static player_bt_device_t *lookup(bt_manager_t *m, const uint8_t *address) {
    for (unsigned i = 0; i < m->view.saved_count; ++i)
        if (same(m->view.saved[i].address, address)) return &m->view.saved[i];
    for (unsigned i = 0; i < m->view.found_count; ++i)
        if (same(m->view.found[i].address, address)) return &m->view.found[i];
    return NULL;
}
static bool is_saved(bt_manager_t *m, const uint8_t *address) {
    for (unsigned i = 0; i < m->view.saved_count; ++i)
        if (same(m->view.saved[i].address, address)) return true;
    return false;
}
static void refresh_view(bt_manager_t *m) {
    m->view.busy = m->connecting || m->disconnecting || m->view.scanning || m->scan_draining || m->removing;
    m->view.state = m->disconnecting ? PLAYER_BT_DISCONNECTING :
        m->connecting ? PLAYER_BT_CONNECTING :
        (m->view.scanning || m->scan_draining) ? PLAYER_BT_SCANNING :
        m->error ? PLAYER_BT_ERROR : m->view.connected ? PLAYER_BT_CONNECTED : PLAYER_BT_IDLE;
    memcpy(m->view.peer, m->active, 6);
    player_bt_device_t *device = lookup(m, m->active);
    if (m->view.connected)
        snprintf(m->view.receiver, sizeof(m->view.receiver), "%s", device ? device->name : "Bluetooth receiver");
    else m->view.receiver[0] = 0;
    for (unsigned i = 0; i < m->view.saved_count; ++i)
        m->view.saved[i].connected = m->view.connected && same(m->active, m->view.saved[i].address);
    for (unsigned i = 0; i < m->view.found_count; ++i)
        m->view.found[i].connected = m->view.connected && same(m->active, m->view.found[i].address);
}
/* A name response may arrive after disconnect, but must still identify a saved
 * bond or the selected active receiver. Never recreate forgotten devices. */
static bool remote_name(bt_manager_t *m, const uint8_t *address, const char *name, bool success) {
    if (!success || !name || !name[0]) return false;
    if (!is_saved(m, address) &&
        !((m->connecting || m->view.connected) && !m->disconnecting && same(m->active, address))) return false;
    char bounded[PLAYER_BT_NAME_MAX];
    snprintf(bounded, sizeof(bounded), "%.*s", (int)sizeof(bounded) - 1, name);
    bool changed = false;
    for (unsigned group = 0; group < 2; ++group) {
        player_bt_device_t *devices = group ? m->view.found : m->view.saved;
        unsigned count = group ? m->view.found_count : m->view.saved_count;
        for (unsigned i = 0; i < count; ++i) {
            if (same(devices[i].address, address) && strcmp(devices[i].name, bounded)) {
                memcpy(devices[i].name, bounded, strlen(bounded) + 1);
                changed = true;
            }
        }
    }
    if (changed) refresh_view(m);
    return changed;
}
static void fail(bt_manager_t *m, const char *text) { m->error = true; message(m, text); }
static void begin_connect(bt_manager_t *m, const uint8_t *address) {
    m->ops.pause();
    m->ops.audio(false);
    memcpy(m->active, address, 6);
    m->error = false;
    m->connecting = true;
    m->deadline = m->now + CONNECT_TIMEOUT_MS;
    message(m, "Connecting. Playback stays paused.");
    if (!m->ops.connect(address)) {
        m->connecting = false;
        fail(m, "Could not start connection. Put receiver in pairing mode and retry.");
    }
}
static void begin_disconnect(bt_manager_t *m) {
    m->ops.pause();
    m->ops.audio(false);
    m->connecting = false;
    m->disconnecting = true;
    m->deadline = m->now + DRAIN_TIMEOUT_MS;
    message(m, "Disconnecting...");
    if (!m->ops.disconnect(m->active))
        fail(m, "Disconnect request failed. Waiting for link to close; restart if needed.");
}
static void remove_bond(bt_manager_t *m) {
    m->deadline = m->now + DRAIN_TIMEOUT_MS;
    if (!m->ops.forget(m->forgetting)) {
        m->removing = false;
        fail(m, "Could not remove pairing. Try Forget again.");
    } else message(m, "Removing local pairing...");
}
static void continue_pending(bt_manager_t *m) {
    if (m->scan_draining || m->view.scanning || m->disconnecting) return;
    if (m->removing) {
        if (m->view.connected || m->connecting) begin_disconnect(m);
        else remove_bond(m);
    } else if (m->pending) {
        if (m->view.connected || m->connecting) begin_disconnect(m);
        else {
            uint8_t address[6]; memcpy(address, m->pending_address, 6);
            m->pending = false;
            begin_connect(m, address);
        }
    }
}
static void stop_scan(bt_manager_t *m) {
    m->view.scanning = false;
    m->scan_draining = true;
    m->scan_deadline = m->now + DRAIN_TIMEOUT_MS;
    if (!m->ops.cancel_scan()) fail(m, "Could not cancel discovery. Waiting for scan to stop.");
}
static void command(bt_manager_t *m, player_bt_command_t cmd, const uint8_t *address) {
    m->error = false;
    if (cmd == PLAYER_BT_CANCEL) {
        if (m->removing) { message(m, "Forget is already in progress; wait for completion."); return; }
        m->pending = false;
        m->auto_reconnect = false;
        m->retry_at = 0;
        if (m->view.scanning) stop_scan(m);
        if (m->connecting || (m->view.connected && !m->scan_draining)) begin_disconnect(m);
        if (!m->disconnecting && !m->scan_draining) message(m, "Cancelled.");
    } else if (cmd == PLAYER_BT_SCAN) {
        if (m->view.busy) { message(m, "Finish or cancel the current operation first."); return; }
        m->ops.pause();
        m->retry_at = 0;
        m->view.found_count = 0;
        memset(m->view.found, 0, sizeof(m->view.found));
        if (m->ops.scan()) {
            m->view.scanning = true;
            m->scan_deadline = m->now + 20000u;
            message(m, "Searching for audio devices. Playback paused.");
        } else fail(m, "Discovery failed. Try Find devices again.");
    } else if (cmd == PLAYER_BT_CONNECT) {
        if (m->disconnecting || m->removing || m->scan_draining) {
            message(m, "Wait for the current operation to finish."); return;
        }
        if (!address || !lookup(m, address)) { fail(m, "Device is no longer listed. Search again."); return; }
        if (!is_saved(m, address) && m->view.saved_count >= PLAYER_BT_SAVED_MAX) {
            fail(m, "Saved device limit reached. Forget a device first."); return;
        }
        if (m->view.connected && same(address, m->active)) { message(m, "Already connected."); return; }
        m->auto_reconnect = false;
        m->retry_at = 0;
        memcpy(m->pending_address, address, 6);
        m->pending = true;
        if (m->view.scanning) stop_scan(m);
        continue_pending(m);
    } else if (cmd == PLAYER_BT_DISCONNECT) {
        if (address && nonzero(address) && !same(address, m->active)) {
            message(m, "That device is not the active receiver."); return;
        }
        m->auto_reconnect = false; m->retry_at = 0; m->pending = false;
        if (m->view.scanning) stop_scan(m);
        if ((m->view.connected || m->connecting) && !m->disconnecting) begin_disconnect(m);
        else message(m, "Not connected.");
    } else if (cmd == PLAYER_BT_FORGET) {
        if (!address || !is_saved(m, address)) { fail(m, "Device is not saved."); return; }
        if (m->view.busy) { message(m, "Finish or cancel the current operation first."); return; }
        if (same(address, m->last)) { m->auto_reconnect = false; m->retry_at = 0; }
        m->pending = false;
        memcpy(m->forgetting, address, 6);
        m->removing = true;
        m->deadline = m->now + DRAIN_TIMEOUT_MS;
        if (same(address, m->active) && m->view.connected) begin_disconnect(m);
        else remove_bond(m);
    }
    refresh_view(m);
}
static bool authorized(bt_manager_t *m, const uint8_t *address) {
    return m->connecting && !m->disconnecting && same(m->active, address);
}
static void found(bt_manager_t *m, const uint8_t *address, const char *name) {
    if (!m->view.scanning || m->scan_draining) return;
    player_bt_device_t *device = NULL;
    for (unsigned i = 0; i < m->view.found_count; ++i)
        if (same(m->view.found[i].address, address)) device = &m->view.found[i];
    if (!device && m->view.found_count < PLAYER_BT_FOUND_MAX)
        device = &m->view.found[m->view.found_count++];
    if (!device) { message(m, "Device list full. Select a device or search again."); return; }
    memcpy(device->address, address, 6);
    if (name[0]) snprintf(device->name, sizeof(device->name), "%s", name);
    else if (!device->name[0]) snprintf(device->name, sizeof(device->name),
        "%02X:%02X:%02X:%02X:%02X:%02X", address[0], address[1], address[2], address[3], address[4], address[5]);
    device->bonded = is_saved(m, address);
    if (name[0] && device->bonded) {
        for (unsigned i = 0; i < m->view.saved_count; ++i)
            if (same(m->view.saved[i].address, address))
                snprintf(m->view.saved[i].name, sizeof(m->view.saved[i].name), "%s", name);
    }
    refresh_view(m);
}
static void scan_stopped(bt_manager_t *m) {
    if (!m->view.scanning && !m->scan_draining) return;
    m->view.scanning = false; m->scan_draining = false;
    message(m, m->view.found_count ? "Search complete. Select a device to connect." : "No audio devices found. Enable pairing mode and search again.");
    continue_pending(m);
    refresh_view(m);
}
static void connection(bt_manager_t *m, const uint8_t *address, bool connected) {
    if (connected) {
        if (!authorized(m, address)) {
            m->ops.disconnect(address); /* Never accept late or unsolicited peers. */
            return;
        }
        m->connecting = false; m->view.connected = true; m->error = false;
        m->ops.pause();
        memcpy(m->last, address, 6);
        m->auto_reconnect = true;
        m->ops.remember(address);
        message(m, "Connected. Press Play to resume.");
    } else if (same(address, m->active)) {
        bool unexpected = m->view.connected && !m->disconnecting;
        bool failed = m->connecting;
        m->view.connected = false; m->connecting = false; m->disconnecting = false;
        m->ops.pause(); m->ops.audio(false);
        if (unexpected && m->auto_reconnect && is_saved(m, m->last)) {
            m->retry_at = m->now + 5000u;
            message(m, "Connection lost. Playback paused; reconnecting to selected receiver.");
        } else if (failed) fail(m, "Connection failed. Enable pairing mode and try again.");
        else if (!m->error) message(m, "Disconnected. Playback paused.");
        continue_pending(m);
    }
    refresh_view(m);
}
static void authentication(bt_manager_t *m, const uint8_t *address, bool success) {
    if (!same(m->active, address) || (!m->connecting && !m->view.connected)) return;
    if (!success) {
        m->auto_reconnect = false; m->pending = false;
        begin_disconnect(m);
        fail(m, "Pairing failed. Enable pairing mode and retry Connect.");
    }
    refresh_view(m);
}
static void removed(bt_manager_t *m, const uint8_t *address, bool success) {
    if (!m->removing || !same(m->forgetting, address)) return;
    m->removing = false;
    if (success) {
        for (unsigned i = 0; i < m->view.saved_count; ++i) {
            if (!same(m->view.saved[i].address, address)) continue;
            memmove(&m->view.saved[i], &m->view.saved[i + 1],
                    (m->view.saved_count - i - 1) * sizeof(m->view.saved[0]));
            --m->view.saved_count; break;
        }
        if (same(m->last, address)) { memset(m->last, 0, 6); m->ops.remember(m->last); }
        for (unsigned i = 0; i < m->view.found_count; ++i)
            if (same(m->view.found[i].address, address)) m->view.found[i].bonded = false;
        message(m, "Local pairing forgotten. Receiver pairing record is unchanged.");
    } else fail(m, "Forget failed. Pairing was kept; try again.");
    refresh_view(m);
}
static bool due(uint32_t now, uint32_t deadline) { return (int32_t)(now - deadline) >= 0; }
static void tick(bt_manager_t *m, uint32_t now) {
    m->now = now;
    if (m->view.scanning && due(now, m->scan_deadline)) stop_scan(m);
    if (m->scan_draining && due(now, m->scan_deadline)) {
        /* Keep quarantine until STOPPED: a late inquiry cannot belong to a new scan. */
        fail(m, "Discovery did not stop. Restart Bluetooth by restarting Harmony.");
    }
    if (m->connecting && due(now, m->deadline)) {
        m->auto_reconnect = false;
        begin_disconnect(m);
        fail(m, "Connection timed out. Enable pairing mode and try again after disconnect.");
    } else if ((m->disconnecting || m->removing) && due(now, m->deadline)) {
        fail(m, "Bluetooth operation timed out. Restart Harmony if it does not finish.");
    }
    if (m->retry_at && due(now, m->retry_at) && !m->view.busy && !m->view.connected) {
        m->retry_at = 0;
        if (is_saved(m, m->last)) begin_connect(m, m->last);
    }
    refresh_view(m);
}

#ifndef HARMONY_BT_HOST_TEST
#include "audio_player.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/queue.h"
#include "freertos/semphr.h"
#include "esp_timer.h"
#include "esp_log.h"
#include "esp_bt_device.h"
#include "esp_gap_bt_api.h"
#include "esp_a2dp_api.h"
#include "esp_avrc_api.h"
#include "nvs.h"
#include <stdatomic.h>

static const char *TAG = "player_bt";
static bt_manager_t manager;
static QueueHandle_t events;
static SemaphoreHandle_t view_lock;
static player_bt_snapshot_t published;
static portMUX_TYPE auth_lock = portMUX_INITIALIZER_UNLOCKED;
static bool allow_pairing;
static uint8_t allowed_address[6];
static atomic_bool event_overflow;
static atomic_bool worker_started;
static nvs_handle_t preferences;
static bool have_preferences;
static int media_state;
static uint32_t media_check_at;

enum { EV_COMMAND, EV_FOUND, EV_SCAN_STOP, EV_CONNECTION, EV_AUTH, EV_REMOVED, EV_AUDIO, EV_MEDIA, EV_PAIRING_UNSUPPORTED, EV_REMOTE_NAME };
typedef struct {
    unsigned kind;
    int code, value;
    uint8_t address[6];
    char name[PLAYER_BT_NAME_MAX];
} bt_event_t;
static bool scan_op(void) {
    return esp_bt_gap_start_discovery(ESP_BT_INQ_MODE_GENERAL_INQUIRY, 10, 0) == ESP_OK;
}
static bool cancel_op(void) { return esp_bt_gap_cancel_discovery() == ESP_OK; }
static bool connect_op(const uint8_t *a) {
    portENTER_CRITICAL(&auth_lock);
    memcpy(allowed_address, a, 6); allow_pairing = true;
    portEXIT_CRITICAL(&auth_lock);
    media_state = 0;
    return esp_a2d_source_connect((uint8_t *)a) == ESP_OK;
}
static bool disconnect_op(const uint8_t *a) {
    portENTER_CRITICAL(&auth_lock);
    if (same(a, allowed_address)) allow_pairing = false;
    portEXIT_CRITICAL(&auth_lock);
    return esp_a2d_source_disconnect((uint8_t *)a) == ESP_OK;
}
static bool forget_op(const uint8_t *a) { return esp_bt_gap_remove_bond_device((uint8_t *)a) == ESP_OK; }
static void pause_op(void) { audio_player_set_paused(true); }
static void audio_op(bool connected) { audio_player_connected(connected); }
static void persist(void) {
    if (!have_preferences) { fail(&manager, "Preferences unavailable. Bluetooth changes last until restart."); return; }
    esp_err_t err = nvs_set_blob(preferences, "last", manager.last, 6);
    if (err == ESP_OK) err = nvs_set_blob(preferences, "names", manager.view.saved, sizeof(manager.view.saved));
    if (err == ESP_OK) err = nvs_set_u8(preferences, "count", manager.view.saved_count);
    if (err == ESP_OK) err = nvs_commit(preferences);
    if (err != ESP_OK) fail(&manager, "Could not save Bluetooth preferences. Retry after restart.");
}
static void remember_op(const uint8_t *a) { (void)a; persist(); }
static void reconcile_bonds(void) {
    esp_bd_addr_t addresses[PLAYER_BT_SAVED_MAX];
    int total = esp_bt_gap_get_bond_device_num();
    int count = total > PLAYER_BT_SAVED_MAX ? PLAYER_BT_SAVED_MAX : total;
    if (count < 0 || (count && esp_bt_gap_get_bond_device_list(&count, addresses) != ESP_OK)) {
        fail(&manager, "Could not read saved pairings."); return;
    }
    player_bt_device_t saved[PLAYER_BT_SAVED_MAX] = {0};
    for (int i = 0; i < count; ++i) {
        player_bt_device_t *old = lookup(&manager, addresses[i]);
        if (old) saved[i] = *old;
        memcpy(saved[i].address, addresses[i], 6);
        saved[i].bonded = true;
        if (!saved[i].name[0]) snprintf(saved[i].name, sizeof(saved[i].name),
            "%02X:%02X:%02X:%02X:%02X:%02X", addresses[i][0], addresses[i][1], addresses[i][2],
            addresses[i][3], addresses[i][4], addresses[i][5]);
    }
    memcpy(manager.view.saved, saved, sizeof(saved));
    manager.view.saved_count = count;
    if (total > PLAYER_BT_SAVED_MAX) fail(&manager, "Only the first 8 bonded devices are shown. Forget unused devices.");
    refresh_view(&manager);
}
static void publish(void) {
    refresh_view(&manager);
    portENTER_CRITICAL(&auth_lock);
    allow_pairing = manager.connecting && !manager.disconnecting;
    memcpy(allowed_address, manager.active, 6);
    portEXIT_CRITICAL(&auth_lock);
    if (xSemaphoreTake(view_lock, pdMS_TO_TICKS(2)) == pdTRUE) {
        published = manager.view;
        xSemaphoreGive(view_lock);
    }
}
static void enqueue(bt_event_t *event) {
    if (xQueueSend(events, event, 0) != pdTRUE) atomic_store(&event_overflow, true);
}
static bool pairing_allowed(const uint8_t *a) {
    portENTER_CRITICAL(&auth_lock);
    bool allowed = allow_pairing && same(a, allowed_address);
    portEXIT_CRITICAL(&auth_lock);
    return allowed;
}
static void gap_callback(esp_bt_gap_cb_event_t event, esp_bt_gap_cb_param_t *p) {
    bt_event_t e = {0};
    switch (event) {
    case ESP_BT_GAP_DISC_RES_EVT: {
        uint32_t cod = 0;
        e.kind = EV_FOUND; memcpy(e.address, p->disc_res.bda, 6);
        for (int i = 0; i < p->disc_res.num_prop; ++i) {
            esp_bt_gap_dev_prop_t *prop = &p->disc_res.prop[i];
            if (prop->type == ESP_BT_GAP_DEV_PROP_COD && prop->len >= sizeof(cod)) memcpy(&cod, prop->val, sizeof(cod));
            if (prop->type == ESP_BT_GAP_DEV_PROP_BDNAME && prop->len > 0)
                snprintf(e.name, sizeof(e.name), "%.*s", prop->len, (char *)prop->val);
            if (prop->type == ESP_BT_GAP_DEV_PROP_EIR) {
                uint8_t len = 0;
                uint8_t *name = esp_bt_gap_resolve_eir_data(prop->val, ESP_BT_EIR_TYPE_CMPL_LOCAL_NAME, &len);
                if (!name) name = esp_bt_gap_resolve_eir_data(prop->val, ESP_BT_EIR_TYPE_SHORT_LOCAL_NAME, &len);
                if (name) snprintf(e.name, sizeof(e.name), "%.*s", len, (char *)name);
            }
        }
        if (esp_bt_gap_is_valid_cod(cod) && (esp_bt_gap_get_cod_srvc(cod) & ESP_BT_COD_SRVC_RENDERING)) enqueue(&e);
        break;
    }
    case ESP_BT_GAP_DISC_STATE_CHANGED_EVT:
        if (p->disc_st_chg.state == ESP_BT_GAP_DISCOVERY_STOPPED) { e.kind = EV_SCAN_STOP; enqueue(&e); }
        break;
    case ESP_BT_GAP_READ_REMOTE_NAME_EVT:
        e.kind = EV_REMOTE_NAME; memcpy(e.address, p->read_rmt_name.bda, 6);
        e.value = p->read_rmt_name.stat == ESP_BT_STATUS_SUCCESS;
        snprintf(e.name, sizeof(e.name), "%.*s", (int)sizeof(e.name) - 1, (char *)p->read_rmt_name.rmt_name);
        enqueue(&e); break;
    case ESP_BT_GAP_AUTH_CMPL_EVT:
        e.kind = EV_AUTH; memcpy(e.address, p->auth_cmpl.bda, 6);
        e.value = p->auth_cmpl.stat == ESP_BT_STATUS_SUCCESS;
        snprintf(e.name, sizeof(e.name), "%.*s", (int)sizeof(e.name) - 1, (char *)p->auth_cmpl.device_name);
        enqueue(&e); break;
    case ESP_BT_GAP_PIN_REQ_EVT: {
        esp_bt_pin_code_t pin = {'1', '2', '3', '4'};
        bool allowed = pairing_allowed(p->pin_req.bda) && !p->pin_req.min_16_digit;
        esp_bt_gap_pin_reply(p->pin_req.bda, allowed, allowed ? 4 : 0, pin);
        if (pairing_allowed(p->pin_req.bda) && p->pin_req.min_16_digit) {
            e.kind = EV_PAIRING_UNSUPPORTED; memcpy(e.address, p->pin_req.bda, 6); enqueue(&e);
        }
        break;
    }
    case ESP_BT_GAP_CFM_REQ_EVT:
        esp_bt_gap_ssp_confirm_reply(p->cfm_req.bda, pairing_allowed(p->cfm_req.bda)); break;
    case ESP_BT_GAP_KEY_REQ_EVT:
        esp_bt_gap_ssp_passkey_reply(p->key_req.bda, false, 0);
        if (pairing_allowed(p->key_req.bda)) {
            e.kind = EV_PAIRING_UNSUPPORTED; memcpy(e.address, p->key_req.bda, 6); enqueue(&e);
        }
        break;
    case ESP_BT_GAP_REMOVE_BOND_DEV_COMPLETE_EVT:
        e.kind = EV_REMOVED; memcpy(e.address, p->remove_bond_dev_cmpl.bda, 6);
        e.value = p->remove_bond_dev_cmpl.status == ESP_BT_STATUS_SUCCESS;
        enqueue(&e); break;
    default: break;
    }
}
static void a2dp_callback(esp_a2d_cb_event_t event, esp_a2d_cb_param_t *p) {
    bt_event_t e = {0};
    if (event == ESP_A2D_CONNECTION_STATE_EVT) {
        if (p->conn_stat.state != ESP_A2D_CONNECTION_STATE_CONNECTED &&
            p->conn_stat.state != ESP_A2D_CONNECTION_STATE_DISCONNECTED) return;
        e.kind = EV_CONNECTION; memcpy(e.address, p->conn_stat.remote_bda, 6);
        e.value = p->conn_stat.state == ESP_A2D_CONNECTION_STATE_CONNECTED;
    } else if (event == ESP_A2D_AUDIO_STATE_EVT) {
        e.kind = EV_AUDIO; memcpy(e.address, p->audio_stat.remote_bda, 6);
        e.value = p->audio_stat.state == ESP_A2D_AUDIO_STATE_STARTED;
    } else if (event == ESP_A2D_MEDIA_CTRL_ACK_EVT) {
        e.kind = EV_MEDIA; e.code = p->media_ctrl_stat.cmd;
        e.value = p->media_ctrl_stat.status == ESP_A2D_MEDIA_CTRL_ACK_SUCCESS;
    } else return;
    enqueue(&e);
}
static int32_t pcm_callback(uint8_t *data, int32_t len) { return audio_player_read(data, len); }
static void media_event(bt_event_t *e) {
    if (!manager.view.connected || manager.disconnecting) return;
    if (e->kind == EV_AUDIO && same(e->address, manager.active)) {
        if (e->value) { media_state = 2; audio_player_connected(true); }
        else { media_state = 0; audio_player_connected(false); audio_player_set_paused(true); }
    } else if (e->kind == EV_MEDIA) {
        if (e->code == ESP_A2D_MEDIA_CTRL_CHECK_SRC_RDY && e->value && media_state == 0) {
            if (esp_a2d_media_ctrl(ESP_A2D_MEDIA_CTRL_START) == ESP_OK) media_state = 1;
        } else if (e->code == ESP_A2D_MEDIA_CTRL_START && media_state == 1) {
            media_state = e->value ? 2 : 0;
            audio_player_connected(e->value);
        }
    }
}
static void worker(void *arg) {
    (void)arg;
    bt_event_t event;
    uint32_t diagnostics_at = manager.now + 10000u;
    player_bt_state_t logged_state = PLAYER_BT_OFF;
    char logged_status[sizeof(manager.view.status)] = {0};
    for (;;) {
        bool received = xQueueReceive(events, &event, pdMS_TO_TICKS(100)) == pdTRUE;
        manager.now = (uint32_t)(esp_timer_get_time() / 1000);
        if (received) {
            switch (event.kind) {
            case EV_COMMAND:
                ESP_LOGI(TAG, "command=%d peer=%02x:%02x:%02x:%02x:%02x:%02x", event.code,
                    event.address[0], event.address[1], event.address[2], event.address[3], event.address[4], event.address[5]);
                command(&manager, event.code, event.address);
                break;
            case EV_FOUND: {
                player_bt_device_t *saved = lookup(&manager, event.address);
                bool renamed = manager.view.scanning && !manager.scan_draining && event.name[0] &&
                    saved && is_saved(&manager, event.address) && strcmp(saved->name, event.name);
                found(&manager, event.address, event.name);
                if (renamed) persist();
                break;
            }
            case EV_SCAN_STOP: scan_stopped(&manager); break;
            case EV_CONNECTION: {
                bool selected = event.value && authorized(&manager, event.address);
                connection(&manager, event.address, event.value);
                if (selected) {
                    reconcile_bonds(); persist();
                    /* Existing bonds need not authenticate or appear in inquiry.
                     * Resolve the name on their established link as well. */
                    esp_err_t err = esp_bt_gap_read_remote_name(event.address);
                    if (err != ESP_OK) ESP_LOGW(TAG, "Remote name request failed: %s; cached name retained", esp_err_to_name(err));
                }
                break;
            }
            case EV_REMOTE_NAME:
                if (remote_name(&manager, event.address, event.name, event.value)) {
                    persist();
                    ESP_LOGI(TAG, "Resolved receiver name: %s", event.name);
                }
                break;
            case EV_AUTH:
                if (event.value && same(manager.active, event.address) &&
                    (manager.connecting || manager.view.connected) && !manager.disconnecting) {
                    player_bt_device_t *device = lookup(&manager, event.address);
                    if (device && event.name[0]) snprintf(device->name, sizeof(device->name), "%s", event.name);
                    reconcile_bonds(); persist();
                }
                else if (event.value && !is_saved(&manager, event.address)) {
                    /* Pairing can complete after Cancel. Do not retain that new bond. */
                    esp_bt_gap_remove_bond_device(event.address);
                }
                authentication(&manager, event.address, event.value); break;
            case EV_REMOVED: removed(&manager, event.address, event.value); if (event.value) { reconcile_bonds(); persist(); } break;
            case EV_PAIRING_UNSUPPORTED:
                if (authorized(&manager, event.address)) {
                    begin_disconnect(&manager);
                    fail(&manager, "Receiver needs PIN entry. Use a receiver with automatic pairing; PIN entry is not supported yet.");
                }
                break;
            case EV_AUDIO: case EV_MEDIA: media_event(&event); break;
            }
        }
        if (atomic_exchange(&event_overflow, false)) {
            command(&manager, PLAYER_BT_CANCEL, NULL);
            audio_player_set_paused(true);
            fail(&manager, "Bluetooth event queue overflow. Playback paused; restart if stuck.");
        }
        tick(&manager, manager.now);
        if (manager.view.connected && !manager.disconnecting && media_state != 2 && due(manager.now, media_check_at)) {
            if (media_state == 1) media_state = 0; /* retry a missing media ACK */
            esp_a2d_media_ctrl(ESP_A2D_MEDIA_CTRL_CHECK_SRC_RDY);
            media_check_at = manager.now + 2000u;
        }
        if (manager.view.state != logged_state || strcmp(manager.view.status, logged_status)) {
            ESP_LOGI(TAG, "state=%d connected=%d peer=%02x:%02x:%02x:%02x:%02x:%02x %s",
                manager.view.state, manager.view.connected, manager.active[0], manager.active[1],
                manager.active[2], manager.active[3], manager.active[4], manager.active[5], manager.view.status);
            logged_state = manager.view.state;
            snprintf(logged_status, sizeof(logged_status), "%s", manager.view.status);
        }
        if (due(manager.now, diagnostics_at)) {
            audio_player_log();
            ESP_LOGI(TAG, "worker_stack_free_min=%u", (unsigned)uxTaskGetStackHighWaterMark(NULL));
            diagnostics_at = manager.now + 10000u;
        }
        publish();
    }
}
bool player_bluetooth_snapshot(player_bt_snapshot_t *out) {
    if (!out || !view_lock || xSemaphoreTake(view_lock, pdMS_TO_TICKS(2)) != pdTRUE) return false;
    *out = published; xSemaphoreGive(view_lock); return true;
}
bool player_bluetooth_command(player_bt_command_t cmd, const uint8_t address[6]) {
    if (!atomic_load(&worker_started) || !events || cmd < PLAYER_BT_SCAN || cmd > PLAYER_BT_FORGET) return false;
    if ((cmd == PLAYER_BT_CONNECT || cmd == PLAYER_BT_FORGET) && !address) return false;
    bt_event_t event = {.kind = EV_COMMAND, .code = cmd};
    if (address) memcpy(event.address, address, 6);
    return xQueueSend(events, &event, 0) == pdTRUE;
}
bool player_bluetooth_init(void) {
    if (events) return false;
    manager.ops = (bt_operations_t){scan_op, cancel_op, connect_op, disconnect_op, forget_op, pause_op, audio_op, remember_op};
    manager.now = (uint32_t)(esp_timer_get_time() / 1000);
    events = xQueueCreate(32, sizeof(bt_event_t));
    view_lock = xSemaphoreCreateMutex();
    if (!events || !view_lock) return false;
    have_preferences = nvs_open("player_bt", NVS_READWRITE, &preferences) == ESP_OK;
    if (have_preferences) {
        uint8_t count = 0; size_t size = sizeof(manager.view.saved);
        if (nvs_get_u8(preferences, "count", &count) == ESP_OK && count <= PLAYER_BT_SAVED_MAX &&
            nvs_get_blob(preferences, "names", manager.view.saved, &size) == ESP_OK && size == sizeof(manager.view.saved)) {
            manager.view.saved_count = count;
            for (unsigned i = 0; i < count; ++i) manager.view.saved[i].name[PLAYER_BT_NAME_MAX - 1] = 0;
        }
        size = 6;
        if (nvs_get_blob(preferences, "last", manager.last, &size) != ESP_OK || size != 6) memset(manager.last, 0, 6);
    }
    reconcile_bonds();
    esp_err_t err = esp_bt_gap_register_callback(gap_callback);
    if (err == ESP_OK) err = esp_bt_gap_set_device_name("Harmony Mark-6");
    if (err == ESP_OK) err = esp_bt_gap_set_scan_mode(ESP_BT_NON_CONNECTABLE, ESP_BT_NON_DISCOVERABLE);
    if (err == ESP_OK) err = esp_a2d_register_callback(a2dp_callback);
    if (err == ESP_OK) err = esp_a2d_source_register_data_callback(pcm_callback);
    if (err == ESP_OK) err = esp_a2d_source_init();
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "Bluetooth setup: %s", esp_err_to_name(err));
        fail(&manager, "Bluetooth setup failed. Restart Harmony to retry.");
        publish();
        return false;
    }
    manager.view.ready = true;
    message(&manager, "Choose a saved device or Find devices. Playback paused.");
    if (nonzero(manager.last) && is_saved(&manager, manager.last)) {
        manager.auto_reconnect = true;
        manager.retry_at = manager.now + 1500u;
        message(&manager, "Reconnecting to last selected receiver. Playback paused.");
    }
    audio_player_set_paused(true);
    publish();
    if (xTaskCreate(worker, "player_bt", 6144, NULL, 5, NULL) != pdPASS) {
        manager.view.ready = false;
        fail(&manager, "Bluetooth worker could not start. Restart Harmony.");
        publish();
        return false;
    }
    atomic_store(&worker_started, true);
    return true;
}
#endif
