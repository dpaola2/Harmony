int main(void)
{
    esp_a2d_cb_param_t e={0};
    s_a2d_state=APP_AV_STATE_UNCONNECTED;
    bt_app_av_sm_hdlr(BT_APP_HEART_BEAT_EVT,NULL);
    assert(connects==1 && s_a2d_state==APP_AV_STATE_CONNECTING);
    for(int i=0;i<3;++i) bt_app_av_sm_hdlr(BT_APP_HEART_BEAT_EVT,NULL);
    assert(disconnects==1 && s_a2d_state==APP_AV_STATE_DISCONNECTING);
    /* A late successful response is accepted even after cancellation. */
    e.conn_stat.state=ESP_A2D_CONNECTION_STATE_CONNECTED;
    bt_app_av_sm_hdlr(ESP_A2D_CONNECTION_STATE_EVT,&e);
    assert(s_a2d_state==APP_AV_STATE_CONNECTED);
    e.media_ctrl_stat.cmd=ESP_A2D_MEDIA_CTRL_CHECK_SRC_RDY;
    bt_app_av_sm_hdlr(ESP_A2D_MEDIA_CTRL_ACK_EVT,&e);assert(starts==1);
    e.media_ctrl_stat.cmd=ESP_A2D_MEDIA_CTRL_START;
    bt_app_av_sm_hdlr(ESP_A2D_MEDIA_CTRL_ACK_EVT,&e);assert(audio_connected);
    for(int i=0;i<60;++i) bt_app_av_sm_hdlr(BT_APP_HEART_BEAT_EVT,NULL);
    assert(!suspends && !snapshot.stopped); /* removed 400-second cutoff */
    e.conn_stat.state=ESP_A2D_CONNECTION_STATE_DISCONNECTED;
    bt_app_av_sm_hdlr(ESP_A2D_CONNECTION_STATE_EVT,&e);
    assert(!audio_connected && !shutdown_requested && !snapshot.stopped);
    bt_app_av_sm_hdlr(BT_APP_HEART_BEAT_EVT,NULL);assert(connects==2);
    e.conn_stat.state=ESP_A2D_CONNECTION_STATE_CONNECTED;
    bt_app_av_sm_hdlr(ESP_A2D_CONNECTION_STATE_EVT,&e);
    e.audio_stat.state=ESP_A2D_AUDIO_STATE_STARTED;
    bt_app_av_sm_hdlr(ESP_A2D_AUDIO_STATE_EVT,&e);assert(audio_connected);
    s_media_state=APP_AV_MEDIA_STATE_STARTED;
    snapshot.stopped=true;
    bt_app_av_sm_hdlr(BT_APP_HEART_BEAT_EVT,NULL);
    assert(shutdown_requested && suspends==1 && !audio_connected);
    /* Audio-stop event can precede suspend ACK. Preserve STOPPING until ACK. */
    e.audio_stat.state=ESP_A2D_AUDIO_STATE_STOPPED;
    bt_app_av_sm_hdlr(ESP_A2D_AUDIO_STATE_EVT,&e);
    assert(s_media_state==APP_AV_MEDIA_STATE_STOPPING);
    e.media_ctrl_stat.cmd=ESP_A2D_MEDIA_CTRL_SUSPEND;
    bt_app_av_sm_hdlr(ESP_A2D_MEDIA_CTRL_ACK_EVT,&e);
    assert(disconnects==2);
    e.conn_stat.state=ESP_A2D_CONNECTION_STATE_DISCONNECTED;
    bt_app_av_sm_hdlr(ESP_A2D_CONNECTION_STATE_EVT,&e);
    bt_app_av_sm_hdlr(BT_APP_HEART_BEAT_EVT,NULL);assert(connects==2);
    e.conn_stat.state=ESP_A2D_CONNECTION_STATE_CONNECTED;
    bt_app_av_sm_hdlr(ESP_A2D_CONNECTION_STATE_EVT,&e);assert(disconnects==3);
    puts("PASS actual Bluetooth state handlers: connection timeout/late response, 60 simulated heartbeats, retry, stop-before-ACK and fatal shutdown");
}
