#pragma once
/* Wheel task: owns the I2C bus while it runs.
 *
 * It follows hardware README "Firmware for the touch wheel": the MPR121 is
 * read only after TOUCH_IRQ falls (item 3), so every I2C transfer happens
 * in the quiet gap right after a touch measurement. Other I2C work (fuel
 * gauge, haptics) runs in the same slot, or, when the wheel stays idle past
 * the work's deadline, with the MPR121 stopped for the transfer. */
#include <stdbool.h>
#include <stdint.h>
#include "esp_err.h"
#include "mpr121.h"
#include "wheel.h"

/* Called in the wheel task right after each MPR121 read (frame set) and on
 * clock ticks between reads (frame NULL, only holds). I2C use is allowed here. */
typedef void (*slab_wheel_cb_t)(const wheel_events_t *ev, const mpr121_frame_t *frame, void *ctx);
typedef void (*slab_wheel_work_t)(void *arg);

/* The MPR121 must already be started (mpr121_start). Task priority and core
 * are the caller's choice; keep it above the display task. */
esp_err_t slab_wheel_start(const wheel_config_t *cfg, slab_wheel_cb_t cb, void *ctx,
                           unsigned priority, int core);
/* Stops the task and the IRQ handler. The MPR121 keeps its configuration. */
esp_err_t slab_wheel_stop(void);
bool slab_wheel_running(void);
/* Queue I2C work for the next quiet slot. max_wait_ms bounds how long it
 * may wait for a touch before it runs with the MPR121 stopped. false = full. */
bool slab_wheel_quiet_work(slab_wheel_work_t fn, void *arg, uint32_t max_wait_ms);
/* Counters for the bring-up test. */
uint32_t slab_wheel_irq_count(void);
uint32_t slab_wheel_read_count(void);
/* Swap the decoder settings (bring-up). */
void slab_wheel_set_config(const wheel_config_t *cfg);
wheel_state_t slab_wheel_state(void);
