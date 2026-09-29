#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
enum { PLAYBACK_REPEAT_OFF, PLAYBACK_REPEAT_ALL, PLAYBACK_REPEAT_ONE };
/* Caller serializes ALL operations. No I/O or allocation inside this module. */
typedef struct {
    uint8_t *pcm;
    size_t capacity, read, queued, prefill;
    unsigned count, track, selection, repeat;
    uint32_t generation, consumed_frames;
    uint64_t total_frames, underrun_bytes;
    bool connected, paused, eof, finished, stopped, failed, buffering;
} playback_t;
void playback_init(playback_t *p, uint8_t *pcm, size_t capacity, unsigned count);
void playback_browse(playback_t *p, int delta);
void playback_activate(playback_t *p);
void playback_step(playback_t *p, int delta);
/* Stale decoder generations must never enqueue audio after a skip. */
size_t playback_push(playback_t *p, uint32_t generation, const void *data, size_t bytes);
size_t playback_read(playback_t *p, void *data, size_t bytes);
void playback_end(playback_t *p, uint32_t generation, bool failed);
/* Advance only after all PCM from the preceding track has drained. */
void playback_tick(playback_t *p);

/* Q16 gain, callback-owned ramp state; no lock/allocation required. */
typedef struct {
    int32_t current, target, step, remainder, error;
    unsigned remaining;
} playback_gain_t;
uint32_t playback_volume_gain(unsigned volume);
void playback_gain_init(playback_gain_t *gain, unsigned volume);
void playback_gain_apply(playback_gain_t *gain, uint8_t *data, size_t bytes, unsigned volume);
