#include "playback.h"
#include <string.h>

static void start(playback_t *p, unsigned track)
{
    p->track = track;
    ++p->generation;
    p->read = p->queued = p->consumed_frames = 0;
    p->eof = p->finished = p->failed = false;
    p->buffering = true;
}
void playback_init(playback_t *p, uint8_t *pcm, size_t capacity, unsigned count)
{
    *p = (playback_t){.pcm = pcm, .capacity = capacity & ~(size_t)3,
        .count = count, .prefill = (capacity / 2) & ~(size_t)3};
    start(p, 0);
    if (!pcm || capacity < 8 || !count) p->failed = p->stopped = true;
}
static unsigned move(unsigned index, unsigned count, int delta)
{
    int64_t next = (int64_t)index + delta;
    if (next < 0) return 0;
    if (next >= count) return count ? count - 1 : 0;
    return (unsigned)next;
}
void playback_browse(playback_t *p, int delta)
{
    p->selection = move(p->selection, p->count, delta);
}
void playback_activate(playback_t *p)
{
    if (p->stopped) return;
    if (p->selection != p->track || p->finished || p->failed) {
        start(p, p->selection);
        p->paused = false;
    } else p->paused = !p->paused;
}
void playback_step(playback_t *p, int delta)
{
    if (p->stopped) return;
    unsigned next = move(p->track, p->count, delta);
    /* Clamp at both boundaries; do not replay the last track on NEXT. */
    if (next == p->track) return;
    p->selection = next;
    start(p, next); /* A skip preserves the user's pause choice. */
}
size_t playback_push(playback_t *p, uint32_t generation, const void *data, size_t bytes)
{
    if (generation != p->generation || p->stopped || p->failed || p->eof) return 0;
    size_t n = p->capacity - p->queued;
    if (n > bytes) n = bytes;
    n &= ~(size_t)3;
    size_t at = (p->read + p->queued) % p->capacity;
    size_t first = p->capacity - at;
    if (first > n) first = n;
    memcpy(p->pcm + at, data, first);
    memcpy(p->pcm, (const uint8_t *)data + first, n - first);
    p->queued += n;
    if (p->queued >= p->prefill) p->buffering = false;
    return n;
}
size_t playback_read(playback_t *p, void *data, size_t bytes)
{
    memset(data, 0, bytes);
    if (!p->connected || p->paused || p->stopped || p->failed || p->buffering) return 0;
    size_t n = p->queued < bytes ? p->queued : bytes;
    n &= ~(size_t)3;
    size_t first = p->capacity - p->read;
    if (first > n) first = n;
    memcpy(data, p->pcm + p->read, first);
    memcpy((uint8_t *)data + first, p->pcm, n - first);
    p->read = (p->read + n) % p->capacity;
    p->queued -= n;
    p->consumed_frames += n / 4;
    p->total_frames += n / 4;
    if (n < (bytes & ~(size_t)3) && !p->eof) p->underrun_bytes += (bytes & ~(size_t)3) - n;
    return n;
}
void playback_end(playback_t *p, uint32_t generation, bool failed)
{
    if (generation != p->generation) return;
    p->eof = true;
    p->buffering = false;
    p->failed = failed;
    if (failed) p->queued = 0;
}
void playback_tick(playback_t *p)
{
    if (!p->eof || p->queued || p->failed || p->stopped || p->finished || p->paused || !p->connected) return;
    if (p->track + 1 < p->count) {
        unsigned next = p->track + 1;
        if (p->selection == p->track) p->selection = next;
        start(p, next);
    } else p->finished = true;
}
