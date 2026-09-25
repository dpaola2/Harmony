#pragma once
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
/* Caller serializes ALL operations. No I/O or allocation inside this module. */
typedef struct {
    uint8_t *pcm;
    size_t capacity, read, queued, prefill;
    unsigned count, track, selection;
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
