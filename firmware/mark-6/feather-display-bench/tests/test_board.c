#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "mock_idf.h"
#include "carrier_board.h"
static uint8_t actual[6]={0x14,0x33,0x5c,0x99,0x1a,0x29};
static uint32_t flash_bytes=8388608;
static size_t psram_bytes=2097152;
static bool initialized=true;
static unsigned levels,directions;
esp_err_t esp_read_mac(uint8_t mac[6],int kind){memcpy(mac,actual,6);return ESP_OK;}
esp_err_t esp_flash_get_size(void *chip,uint32_t *out){*out=flash_bytes;return ESP_OK;}
size_t esp_psram_get_size(void){return psram_bytes;}
bool esp_psram_is_initialized(void){return initialized;}
esp_err_t gpio_set_level(int pin,int level){
    assert(pin==25 || pin==26 || pin==32 || pin==33 || pin==4);
    assert(level==(pin==25 || pin==26 || pin==32));
    ++levels;return ESP_OK;
}
esp_err_t gpio_set_direction(int pin,int direction){
    assert(direction==GPIO_MODE_OUTPUT && levels==directions+1);
    ++directions;return ESP_OK;
}
int main(void){
    assert(carrier_board_init()==ESP_ERR_INVALID_STATE);
    assert(!levels && !directions && !carrier_board_ready());
    actual[5]=0x28;flash_bytes=4194304;
    assert(carrier_board_init()==ESP_ERR_INVALID_STATE);
    assert(!levels && !directions);
    flash_bytes=8388608;initialized=false;
    assert(carrier_board_init()==ESP_ERR_INVALID_STATE);
    assert(!levels && !directions);
    initialized=true;psram_bytes=0;
    assert(carrier_board_init()==ESP_ERR_INVALID_STATE);
    assert(!levels && !directions);
    psram_bytes=2097152;
    assert(carrier_board_init()==ESP_OK);
    assert(levels==5 && directions==5 && carrier_board_ready());
    puts("PASS bench identity/capacity rejection, LCD/SD GPIO and latch ordering");
}
