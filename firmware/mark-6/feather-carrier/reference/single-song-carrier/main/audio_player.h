#pragma once
#include <stdbool.h>
#include <stdint.h>
bool audio_player_prepare(void);
int32_t audio_player_read(uint8_t *data, int32_t len);
bool audio_player_finished(void);
void audio_player_stop(void);
void audio_player_log(void);
typedef struct {
    uint32_t consumed_frames;
    bool finished, stopped, failed;
} audio_player_snapshot_t;
audio_player_snapshot_t audio_player_snapshot(void);
