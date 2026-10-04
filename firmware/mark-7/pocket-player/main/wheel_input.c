/* Experimental event-mode Photo wheel transport. Wheel supplies the clock.
 * No SPI peripheral CS is synthesized: use falling-edge capture and idle-gap framing.
 * Timing/drop behavior must be qualified with A2DP running on the second Feather.
 */
#include <string.h>
#include "sdkconfig.h"
#include "carrier_controls.h"
#include "carrier_board.h"
#include "player_ui.h"
#include "wheel_protocol.h"
#include "driver/gpio.h"
#include "esp_timer.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/queue.h"
static QueueHandle_t packets;
static uint32_t word;
static unsigned bits;
static int64_t last_edge;
static void clock_edge(void *unused)
{
    int64_t now=esp_timer_get_time();
    if(now-last_edge>100){bits=0;word=0;}
    last_edge=now;
    if(bits>=32)return;
    word|=(uint32_t)gpio_get_level(WHEEL_DATA)<<bits++;
    if(bits==32){BaseType_t wake=pdFALSE;xQueueSendFromISR(packets,&word,&wake);if(wake)portYIELD_FROM_ISR();}
}
static void wheel_task(void *unused)
{
    wheel_state_t state={0};uint32_t raw;
    while(1){
        if(!xQueueReceive(packets,&raw,pdMS_TO_TICKS(500)))continue;
        uint8_t p[]={raw,raw>>8,raw>>16,raw>>24};wheel_event_t e;
        if(!wheel_decode(&state,p,&e)){state=(wheel_state_t){0};continue;}
        if(e.steps&&!player_ui_input(PLAYER_UI_SCROLL,e.steps))ESP_LOGW("WHEEL","UI queue full");
        /* Ignore chords, issue only the new edge of a single held button. */
        if(state.buttons && !(state.buttons&(state.buttons-1))){
            player_ui_input_t action;
            switch(e.pressed){case 2:action=PLAYER_UI_SELECT;break;case 4:action=PLAYER_UI_NEXT;break;
                case 8:action=PLAYER_UI_PREVIOUS;break;case 16:action=PLAYER_UI_PLAY_PAUSE;break;
                case 32:action=PLAYER_UI_BACK;break;default:continue;}
            if(!player_ui_input(action,0))ESP_LOGW("WHEEL","UI queue full");
        }
    }
}
esp_err_t carrier_controls_start(void)
{
    if(!carrier_board_ready())return ESP_ERR_INVALID_STATE;
    packets=xQueueCreate(32,sizeof(uint32_t));if(!packets)return ESP_ERR_NO_MEM;
    gpio_config_t inputs={.pin_bit_mask=(1ULL<<WHEEL_CLOCK)|(1ULL<<WHEEL_DATA)|(1ULL<<WHEEL_WAKE),
        .mode=GPIO_MODE_INPUT,.pull_up_en=GPIO_PULLUP_DISABLE,.pull_down_en=GPIO_PULLDOWN_DISABLE};
    esp_err_t err=gpio_config(&inputs);
    if(err==ESP_OK)err=gpio_set_level(WHEEL_CONFIG,1);
    if(err==ESP_OK)err=gpio_set_direction(WHEEL_CONFIG,GPIO_MODE_OUTPUT);
    if(err==ESP_OK)err=gpio_set_level(WHEEL_COMMAND,1);
    if(err==ESP_OK)err=gpio_set_direction(WHEEL_COMMAND,GPIO_MODE_OUTPUT);
    if(err==ESP_OK){
        err=gpio_install_isr_service(0);
        if(err==ESP_ERR_INVALID_STATE)err=ESP_OK; /* Service already installed. */
    }
    if(err==ESP_OK)err=gpio_set_intr_type(WHEEL_CLOCK,GPIO_INTR_NEGEDGE);
    if(err==ESP_OK)err=gpio_isr_handler_add(WHEEL_CLOCK,clock_edge,NULL);
    if(err==ESP_OK&&xTaskCreatePinnedToCore(wheel_task,"photo_wheel",4096,NULL,3,NULL,0)!=pdPASS)err=ESP_ERR_NO_MEM;
    if(err!=ESP_OK){gpio_intr_disable(WHEEL_CLOCK);gpio_isr_handler_remove(WHEEL_CLOCK);vQueueDelete(packets);packets=NULL;}
    else ESP_LOGW("WHEEL","Experimental capture enabled; sleep command/wake not implemented; bench timing validation required");
    return err;
}
