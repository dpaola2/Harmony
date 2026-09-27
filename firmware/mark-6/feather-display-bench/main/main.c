#include <inttypes.h>
#include <stdio.h>
#include "ano_bench.h"
#include "bench_display.h"
#include "carrier_board.h"
#include "input_filter.h"
#include "driver/gpio.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

static esp_err_t line(int y,const char *text)
{
    char padded[39];
    snprintf(padded,sizeof padded,"%-38.38s",text);
    return bench_display_text(8,y,padded,0xffff,0);
}
static void show_error(const char *where,esp_err_t err)
{
    char text[39];
    snprintf(text,sizeof text,"%s: %s",where,esp_err_to_name(err));
    ESP_LOGE("ANO_BENCH","%s",text);
    (void)line(440,text);
}
void app_main(void)
{
    ESP_LOGI("LCD_BENCH","LCD and QT rotary bench; no SD, touch or radios");
    esp_err_t err=carrier_board_init();
    if(err!=ESP_OK){ESP_LOGE("LCD_BENCH","Identity/capacity check failed; outputs disabled");return;}
    err=bench_display_init();
    if(err==ESP_OK) err=bench_display_probe();
    if(err!=ESP_OK){gpio_set_level(CARRIER_TFT_LITE,0);return;}
    err=ano_bench_init();
    if(err!=ESP_OK){show_error("Rotary init",err);return;}
    if((err=line(180,"ROTARY CONNECTED"))!=ESP_OK){show_error("Display",err);return;}
    const char *names[]={"CENTER","UP","LEFT","DOWN","RIGHT"};
    const unsigned logical[]={INPUT_SELECT,INPUT_UP,INPUT_LEFT,INPUT_DOWN,INPUT_RIGHT};
    unsigned counts[5]={0};
    input_filter_t filter={0};
    uint32_t origin=0,last_position=0;
    uint8_t last_stable=0;
    bool first=true;
    unsigned heartbeats=0;
    for(;;){
        uint32_t position,buttons;
        err=ano_bench_read(&position,&buttons);
        if(err!=ESP_OK){show_error("Rotary read",err);return;}
        if(first) origin=position;
        input_events_t events=input_filter_poll(&filter,position,buttons,
            (uint32_t)(esp_timer_get_time()/1000),0);
        char text[39];
        if(first || position!=last_position){
            snprintf(text,sizeof text,"WHEEL: %" PRId32,(int32_t)(position-origin));
            if((err=line(210,text))!=ESP_OK){show_error("Display",err);return;}
            ESP_LOGI("ANO_BENCH","POSITION=%" PRId32 " delta=%d",(int32_t)(position-origin),events.steps);
        }
        for(unsigned i=0;i<5;i++){
            if(events.pressed & (1U<<logical[i])) ++counts[i];
            bool changed=((filter.stable^last_stable)&(1U<<i))!=0;
            if(first || changed){
                bool down=(filter.stable&(1U<<i))!=0;
                snprintf(text,sizeof text,"%-6s %-4s count=%u",names[i],down?"DOWN":"UP",counts[i]);
                if((err=line(250+28*i,text))!=ESP_OK){show_error("Display",err);return;}
                ESP_LOGI("ANO_BENCH","%s %s count=%u",names[i],down?"pressed":"released",counts[i]);
            }
        }
        if(first){
            if((err=line(410,"Turn wheel; press all five buttons"))!=ESP_OK){show_error("Display",err);return;}
            ESP_LOGI("ANO_BENCH","READY_FOR_INPUT");
        }
        first=false;last_position=position;last_stable=filter.stable;
        if(++heartbeats%200==0) ESP_LOGI("ANO_BENCH","Input polling active");
        vTaskDelay(pdMS_TO_TICKS(20));
    }
}
