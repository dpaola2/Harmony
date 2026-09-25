#pragma once
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <pthread.h>
#include <stdlib.h>
#define ESP_OK 0
#define pdTRUE 1
#define pdPASS 1
#define portMAX_DELAY UINT32_MAX
#define pdMS_TO_TICKS(x) (x)
#define MALLOC_CAP_SPIRAM 1
#define MALLOC_CAP_8BIT 2
#define ESP_LOGI(tag,fmt,...) test_log(tag,fmt,##__VA_ARGS__)
#define ESP_LOGE(tag,fmt,...) test_log(tag,fmt,##__VA_ARGS__)
typedef pthread_mutex_t StaticSemaphore_t;
typedef pthread_mutex_t *SemaphoreHandle_t;
SemaphoreHandle_t xSemaphoreCreateMutexStatic(StaticSemaphore_t *storage);
int xSemaphoreTake(SemaphoreHandle_t lock, uint32_t ticks);
void xSemaphoreGive(SemaphoreHandle_t lock);
void vSemaphoreDelete(SemaphoreHandle_t lock);
int xTaskCreatePinnedToCore(void (*fn)(void *),const char*,unsigned,void*,unsigned,void*,int);
void vTaskDelay(unsigned ticks);
void vTaskDelete(void *task);
void *heap_caps_malloc(size_t n,unsigned flags);
int64_t esp_timer_get_time(void);
int bench_storage_mount(void);
void bench_storage_unmount(void);
FILE *test_fopen(const char *path,const char *mode);
void test_log(const char *tag,const char *fmt,...);
#define fopen test_fopen
