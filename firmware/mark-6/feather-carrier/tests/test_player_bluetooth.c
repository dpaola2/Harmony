#define HARMONY_BT_HOST_TEST 1
#include "../main/player_bluetooth.c"
#include <assert.h>

static unsigned scans, cancels, connects, disconnects, forgets, pauses, remembers;
static bool operation_ok = true, audio_connected;
static uint8_t operated[6];
static bool scan_stub(void) { ++scans; return operation_ok; }
static bool cancel_stub(void) { ++cancels; return operation_ok; }
static bool connect_stub(const uint8_t *a) { ++connects; memcpy(operated,a,6); return operation_ok; }
static bool disconnect_stub(const uint8_t *a) { ++disconnects; memcpy(operated,a,6); return operation_ok; }
static bool forget_stub(const uint8_t *a) { ++forgets; memcpy(operated,a,6); return operation_ok; }
static void pause_stub(void) { ++pauses; }
static void audio_stub(bool connected) { audio_connected = connected; }
static void remember_stub(const uint8_t *a) { (void)a; ++remembers; }
static const uint8_t a[6] = {1,2,3,4,5,6}, b[6] = {6,5,4,3,2,1};
static bt_manager_t fresh(void) {
    scans=cancels=connects=disconnects=forgets=pauses=remembers=0;
    operation_ok=true; audio_connected=false;
    bt_manager_t m = {0};
    m.ops = (bt_operations_t){scan_stub,cancel_stub,connect_stub,disconnect_stub,forget_stub,pause_stub,audio_stub,remember_stub};
    m.view.ready=true;
    m.view.saved_count=1;
    memcpy(m.view.saved[0].address,a,6);
    strcpy(m.view.saved[0].name,"Saved speaker");
    m.view.saved[0].bonded=true;
    refresh_view(&m);
    return m;
}
static void test_scan_cancel_ignores_stale_results_and_waits_for_stop(void) {
    bt_manager_t m=fresh();
    command(&m,PLAYER_BT_SCAN,NULL);
    found(&m,b,"Same speaker name");
    assert(m.view.found_count==1 && scans==1);
    command(&m,PLAYER_BT_CANCEL,NULL);
    assert(cancels==1 && m.scan_draining);
    found(&m,a,"Late result");
    assert(m.view.found_count==1);
    command(&m,PLAYER_BT_SCAN,NULL);
    assert(scans==1);
    scan_stopped(&m);
    command(&m,PLAYER_BT_SCAN,NULL);
    assert(scans==2 && m.view.found_count==0);
}
static void test_select_waits_for_inquiry_stop_and_never_connects_arbitrary_result(void) {
    bt_manager_t m=fresh();
    command(&m,PLAYER_BT_SCAN,NULL);
    found(&m,b,"Second");
    assert(connects==0);
    command(&m,PLAYER_BT_CONNECT,b);
    assert(connects==0 && m.pending);
    scan_stopped(&m);
    assert(connects==1 && same(m.active,b) && authorized(&m,b) && !authorized(&m,a));
    connection(&m,a,true);
    assert(disconnects==1 && !m.view.connected && m.connecting);
    connection(&m,a,false);
    assert(m.connecting);
    connection(&m,b,true);
    assert(m.view.connected && remembers==1 && !audio_connected);
}
static void test_cancel_and_timeout_reject_late_connection(void) {
    bt_manager_t m=fresh();
    command(&m,PLAYER_BT_CONNECT,a);
    command(&m,PLAYER_BT_CANCEL,NULL);
    assert(!authorized(&m,a) && m.disconnecting);
    connection(&m,a,true);
    assert(!m.view.connected && disconnects==2);
    connection(&m,a,false);
    command(&m,PLAYER_BT_CONNECT,a);
    tick(&m,CONNECT_TIMEOUT_MS);
    assert(m.disconnecting && m.error && !authorized(&m,a));
    connection(&m,a,true);
    assert(!m.view.connected);
    tick(&m,CONNECT_TIMEOUT_MS+DRAIN_TIMEOUT_MS);
    assert(m.disconnecting); /* quarantine persists until actual disconnect */
    command(&m,PLAYER_BT_CONNECT,a);
    assert(connects==2);
    connection(&m,a,false);
    assert(!m.view.busy);
}
static void test_switch_waits_for_previous_link_to_close(void) {
    bt_manager_t m=fresh();
    command(&m,PLAYER_BT_CONNECT,a);
    connection(&m,a,true);
    command(&m,PLAYER_BT_SCAN,NULL);
    found(&m,b,"New speaker"); scan_stopped(&m);
    command(&m,PLAYER_BT_CONNECT,b);
    assert(connects==1 && m.disconnecting);
    connection(&m,a,false);
    assert(connects==2 && same(m.active,b));
    connection(&m,a,true); /* late previous peer */
    assert(m.connecting && !m.view.connected);
    connection(&m,b,true);
    assert(m.view.connected && same(m.last,b));
}
static void test_disconnect_retains_bond_and_suppresses_reconnect(void) {
    bt_manager_t m=fresh();
    command(&m,PLAYER_BT_CONNECT,a); connection(&m,a,true);
    command(&m,PLAYER_BT_DISCONNECT,NULL); connection(&m,a,false);
    tick(&m,60000);
    assert(connects==1 && m.view.saved_count==1 && same(m.last,a));
    assert(!m.view.connected && !m.auto_reconnect && pauses>=2);
}
static void test_unexpected_drop_reconnects_only_last_selected_and_stays_paused(void) {
    bt_manager_t m=fresh();
    command(&m,PLAYER_BT_CONNECT,a); connection(&m,a,true);
    unsigned previous_pauses=pauses;
    connection(&m,a,false);
    assert(pauses>previous_pauses && !audio_connected);
    tick(&m,4999); assert(connects==1);
    tick(&m,5000); assert(connects==2 && same(operated,a));
    connection(&m,a,true);
    assert(m.view.connected && !audio_connected && pauses>previous_pauses+1);
}
static void test_forget_disconnects_then_waits_for_bond_removal_confirmation(void) {
    bt_manager_t m=fresh();
    command(&m,PLAYER_BT_CONNECT,a); connection(&m,a,true);
    command(&m,PLAYER_BT_FORGET,a);
    assert(disconnects==1 && forgets==0 && m.view.saved_count==1);
    connection(&m,a,false);
    assert(forgets==1 && m.removing && m.view.saved_count==1);
    removed(&m,b,true);
    assert(m.removing);
    removed(&m,a,false);
    assert(!m.removing && m.view.saved_count==1 && m.error);
    command(&m,PLAYER_BT_FORGET,a); removed(&m,a,true);
    assert(m.view.saved_count==0 && !nonzero(m.last));
    tick(&m,60000); assert(connects==1);
}
static void test_pairing_failure_and_stack_error_have_recovery_state(void) {
    bt_manager_t m=fresh();
    operation_ok=false;
    command(&m,PLAYER_BT_SCAN,NULL);
    assert(m.error && !m.view.busy);
    command(&m,PLAYER_BT_CONNECT,a);
    assert(m.error && !authorized(&m,a));
    operation_ok=true;
    command(&m,PLAYER_BT_CONNECT,a);
    authentication(&m,b,false); assert(m.connecting);
    authentication(&m,a,false);
    assert(m.disconnecting && m.error && !authorized(&m,a));
}
static void test_disconnect_other_device_cannot_drop_active_peer(void) {
    bt_manager_t m=fresh();
    command(&m,PLAYER_BT_CONNECT,a); connection(&m,a,true);
    command(&m,PLAYER_BT_DISCONNECT,b);
    assert(disconnects==0 && m.view.connected && m.auto_reconnect);
    command(&m,PLAYER_BT_DISCONNECT,a);
    assert(disconnects==1 && m.disconnecting);
}
static void test_cancel_race_after_connection_closes_new_link_but_scan_cancel_keeps_old(void) {
    bt_manager_t m=fresh();
    command(&m,PLAYER_BT_CONNECT,a); connection(&m,a,true);
    command(&m,PLAYER_BT_SCAN,NULL);
    command(&m,PLAYER_BT_CANCEL,NULL);
    assert(disconnects==0 && m.view.connected);
    scan_stopped(&m);
    command(&m,PLAYER_BT_CANCEL,NULL);
    assert(disconnects==1 && m.disconnecting);
}
static void test_discovery_refreshes_migrated_saved_names_by_address(void) {
    bt_manager_t m=fresh();
    strcpy(m.view.saved[0].name,"01:02:03:04:05:06");
    command(&m,PLAYER_BT_SCAN,NULL);
    found(&m,a,"SoundCore 2");
    assert(!strcmp(m.view.saved[0].name,"SoundCore 2"));
    found(&m,b,"SoundCore 2");
    assert(m.view.found_count==2 && m.view.saved_count==1);
    command(&m,PLAYER_BT_CANCEL,NULL);
    found(&m,a,"Stale name");
    assert(!strcmp(m.view.saved[0].name,"SoundCore 2"));
}
static void test_connected_existing_bond_resolves_name_without_discovery(void) {
    bt_manager_t m=fresh();
    strcpy(m.view.saved[0].name,"01:02:03:04:05:06");
    command(&m,PLAYER_BT_CONNECT,a); connection(&m,a,true);
    assert(scans==0 && !strcmp(m.view.receiver,"01:02:03:04:05:06"));
    assert(remote_name(&m,a,"SoundCore 2",true));
    assert(!strcmp(m.view.saved[0].name,"SoundCore 2"));
    assert(!strcmp(m.view.receiver,"SoundCore 2"));
    assert(!remote_name(&m,a,"SoundCore 2",true));
    assert(scans==0 && connects==1 && same(m.last,a));
}
static void test_remote_name_failure_unknown_peer_and_forgotten_peer_preserve_cache(void) {
    bt_manager_t m=fresh();
    assert(!remote_name(&m,a,"Wrong failure name",false));
    assert(!remote_name(&m,a,"",true));
    assert(!remote_name(&m,b,"Unrequested peer",true));
    assert(!strcmp(m.view.saved[0].name,"Saved speaker"));
    command(&m,PLAYER_BT_FORGET,a); removed(&m,a,true);
    assert(!remote_name(&m,a,"Forgotten speaker",true));
    assert(m.view.saved_count==0);
}
static void test_remote_name_is_bounded_and_updates_matching_found_row(void) {
    bt_manager_t m=fresh();
    command(&m,PLAYER_BT_SCAN,NULL); found(&m,a,"Old name"); scan_stopped(&m);
    char name[250]; memset(name,'N',sizeof(name)); name[sizeof(name)-1]=0;
    assert(remote_name(&m,a,name,true));
    assert(strlen(m.view.saved[0].name)==PLAYER_BT_NAME_MAX-1);
    assert(!strcmp(m.view.saved[0].name,m.view.found[0].name));
    assert(!remote_name(&m,a,name,true));
}
int main(void) {
    test_connected_existing_bond_resolves_name_without_discovery();
    test_remote_name_failure_unknown_peer_and_forgotten_peer_preserve_cache();
    test_remote_name_is_bounded_and_updates_matching_found_row();
    test_discovery_refreshes_migrated_saved_names_by_address();
    test_disconnect_other_device_cannot_drop_active_peer();
    test_cancel_race_after_connection_closes_new_link_but_scan_cancel_keeps_old();
    test_scan_cancel_ignores_stale_results_and_waits_for_stop();
    test_select_waits_for_inquiry_stop_and_never_connects_arbitrary_result();
    test_cancel_and_timeout_reject_late_connection();
    test_switch_waits_for_previous_link_to_close();
    test_disconnect_retains_bond_and_suppresses_reconnect();
    test_unexpected_drop_reconnects_only_last_selected_and_stays_paused();
    test_forget_disconnects_then_waits_for_bond_removal_confirmation();
    test_pairing_failure_and_stack_error_have_recovery_state();
    puts("PASS: Bluetooth command/event policy, cancellation, stale peers, bonds and reconnect");
}
