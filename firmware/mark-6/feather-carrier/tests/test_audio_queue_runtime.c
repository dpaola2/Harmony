/* Reuse the pthread decoder/RTOS fixtures, exercise the real queue adapter. */
#define main original_audio_runtime_test
#include "test_audio_runtime.c"
#undef main
int main(void)
{
    assert(audio_player_prepare());
    const album_t *loaded = audio_player_library();
    assert(loaded && loaded->count == 3);
    unsigned invalid[] = {0, 3};
    assert(!audio_player_play_queue(invalid, 2, 0));
    unsigned tracks[] = {2, 0};
    assert(!audio_player_play_queue(tracks, 2, 2));
    assert(audio_player_play_queue(tracks, 2, 0));
    audio_player_snapshot_t s = audio_player_snapshot();
    assert(s.track == 2 && s.queue_count == 2 && s.queue_position == 0 && s.count == 3);
    audio_player_step(-1); assert(audio_player_snapshot().track == 2);
    audio_player_step(1); assert(audio_player_snapshot().track == 0);
    audio_player_step(1); assert(audio_player_snapshot().track == 0);
    audio_player_toggle_pause(); assert(audio_player_snapshot().paused);
    audio_player_step(-1); assert(audio_player_snapshot().track == 2 && audio_player_snapshot().paused);
    audio_player_toggle_pause();
    audio_player_connected(true);
    uint32_t counts[3] = {0};
    int64_t deadline = esp_timer_get_time() + 5000000;
    while (!audio_player_finished() && esp_timer_get_time() < deadline) {
        int16_t pcm[512]; audio_player_read((uint8_t *)pcm, sizeof(pcm));
        for (unsigned i = 0; i < 512; ++i) if (pcm[i]) {
            unsigned track = (unsigned)pcm[i] / 100;
            assert(track == 3 || track == 1);
            if (track == 3) assert(!counts[0]);
            ++counts[track - 1];
        }
        usleep(100);
    }
    assert(audio_player_finished());
    assert(counts[0] == 20 * MINIMP3_MAX_SAMPLES_PER_FRAME && !counts[1]);
    assert(counts[2] == 20 * MINIMP3_MAX_SAMPLES_PER_FRAME);
    assert(audio_player_snapshot().track == 0); /* No fallthrough to global track 1. */
    audio_player_stop(); pthread_join(task, NULL);
    puts("PASS actual audio queue: validation, global indices, clamped skips, pause retention, reordered decoder output, exact samples and stop at selected queue end");
}
