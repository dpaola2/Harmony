#pragma once
/* Mark-8 copy of firmware/mark-6/feather-player-bench/components/bench_storage.
 * Same API (the shared Mark-6 audio_player.c calls it), changed for the slab:
 * the card has its own VSPI bus (SCK 5, MOSI 19, MISO 21, CS 25), the clock is
 * CONFIG_SLAB_SD_SPI_KHZ (10 MHz retry), and unmount frees the bus so 3V3_PERIPH can switch
 * off. Read-only, as before. */
#include "esp_err.h"
#include "sdmmc_cmd.h"
esp_err_t bench_storage_mount(void);
void bench_storage_unmount(void);
/* Mounted card, or NULL. For the bring-up raw read test. */
sdmmc_card_t *bench_storage_card(void);
/* SPI clock of the mounted card in kHz (CONFIG_SLAB_SD_SPI_KHZ, or 10000 after
 * a failed first mount), or 0. */
unsigned bench_storage_khz(void);
