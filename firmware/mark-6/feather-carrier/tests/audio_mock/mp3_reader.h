#pragma once
#include <stdint.h>
#define MINIMP3_MAX_SAMPLES_PER_FRAME 2304
typedef struct { unsigned track, frame; bool opened; } mp3_reader_t;
int mp3_reader_open(mp3_reader_t *r,const char *path);
int mp3_reader_next(mp3_reader_t *r,int16_t *pcm);
void mp3_reader_close(mp3_reader_t *r);
