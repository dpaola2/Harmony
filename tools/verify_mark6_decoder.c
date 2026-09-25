#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include "mp3_reader.h"

int main(int argc, char **argv)
{
    if (argc != 2) return 2;
    mp3_reader_t *reader = calloc(1, sizeof(*reader));
    int16_t pcm[MINIMP3_MAX_SAMPLES_PER_FRAME];
    if (!reader || mp3_reader_open(reader, argv[1])) { free(reader); return 2; }
    uint64_t samples = 0;
    double squares = 0;
    int count, peak = 0;
    while ((count = mp3_reader_next(reader, pcm)) > 0) {
        for (int i = 0; i < count; i++) {
            int v = pcm[i];
            if (abs(v) > peak) peak = abs(v);
            squares += (double)v * v;
        }
        samples += count;
    }
    printf("samples=%llu seconds=%.6f peak=%d rms=%.2f result=%d\n",
           (unsigned long long)samples, samples / 88200.0, peak,
           samples ? sqrt(squares / samples) : 0, count);
    mp3_reader_close(reader);
    free(reader);
    return count < 0 || !samples ? 1 : 0;
}
