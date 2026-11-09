/* Standalone bench for the spare Feather 14:33:5c:99:1a:28.
 * MPR121 register settings follow Adafruit's BSD-licensed driver defaults.
 * Register reference: https://github.com/adafruit/Adafruit_MPR121
 * No radio, display, storage, or battery handling in this test.
 */
#include <stdio.h>
#include <string.h>
#include "driver/gpio.h"
#include "driver/i2c.h"
#include "driver/rtc_io.h"
#include "esp_mac.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#define PORT I2C_NUM_0
#define ADDR 0x5a
static esp_err_t rd(uint8_t reg, uint8_t *buf, size_t n) {
 return i2c_master_write_read_device(PORT,ADDR,&reg,1,buf,n,pdMS_TO_TICKS(100));
}
static void wr(uint8_t reg,uint8_t value) {
 uint8_t b[]={reg,value}; ESP_ERROR_CHECK(i2c_master_write_to_device(PORT,ADDR,b,2,pdMS_TO_TICKS(100)));
}
void app_main(void) {
 uint8_t mac[6]; const uint8_t expected[]={0x14,0x33,0x5c,0x99,0x1a,0x28};
 ESP_ERROR_CHECK(esp_read_mac(mac,ESP_MAC_WIFI_STA));
 if(memcmp(mac,expected,6)){ESP_LOGE("TOUCH","Wrong Feather: peripheral outputs left untouched");return;}
 rtc_gpio_hold_dis(GPIO_NUM_2); rtc_gpio_deinit(GPIO_NUM_2); gpio_deep_sleep_hold_dis();
 ESP_ERROR_CHECK(gpio_set_direction(GPIO_NUM_2,GPIO_MODE_OUTPUT));
 ESP_ERROR_CHECK(gpio_set_level(GPIO_NUM_2,1)); vTaskDelay(pdMS_TO_TICKS(100));
 i2c_config_t cfg={.mode=I2C_MODE_MASTER,.sda_io_num=22,.scl_io_num=20,
  .sda_pullup_en=GPIO_PULLUP_ENABLE,.scl_pullup_en=GPIO_PULLUP_ENABLE,.master.clk_speed=100000};
 ESP_ERROR_CHECK(i2c_param_config(PORT,&cfg));ESP_ERROR_CHECK(i2c_driver_install(PORT,cfg.mode,0,0,0));
 printf("TOUCH_BENCH spare=14:33:5c:99:1a:28 QT_PWR=2 SDA=22 SCL=20\n");
 uint8_t value=0;
 while(rd(0x5d,&value,1)!=ESP_OK){printf("WAIT: no sensor response at 0x5A; check QT cable\n");vTaskDelay(pdMS_TO_TICKS(2000));}
 wr(0x80,0x63);vTaskDelay(pdMS_TO_TICKS(10));wr(0x5e,0);
 ESP_ERROR_CHECK(rd(0x5d,&value,1));
 if(value!=0x24){printf("FAIL: reset register=0x%02x, expected 0x24\n",value);return;}
 for(int i=0;i<12;i++){wr(0x41+2*i,12);wr(0x42+2*i,6);}
 const uint8_t settings[][2]={{0x2b,1},{0x2c,1},{0x2d,14},{0x2e,0},{0x2f,1},{0x30,5},{0x31,1},{0x32,0},{0x33,0},{0x34,0},{0x35,0},{0x5b,0},{0x5c,0x10},{0x5d,0x20},{0x7b,0},{0x5e,0x8c}};
 for(size_t i=0;i<sizeof(settings)/sizeof(settings[0]);i++)wr(settings[i][0],settings[i][1]);
 ESP_ERROR_CHECK(rd(0x5e,&value,1));if(value!=0x8c){printf("FAIL: electrode enable readback=0x%02x\n",value);return;}
 printf("PASS: MPR121 responds at 0x5A; reset and configuration verified. 12 electrodes enabled; touch=12 release=6.\n");
 uint16_t previous=0;unsigned ticks=0;
 while(1){
  uint8_t status[2],filtered[24],baseline[12];
  if(rd(0,status,2)!=ESP_OK||rd(4,filtered,24)!=ESP_OK||rd(0x1e,baseline,12)!=ESP_OK){printf("ERROR: I2C read failed\n");vTaskDelay(pdMS_TO_TICKS(500));continue;}
  uint16_t touched=(status[0]|(status[1]<<8))&0x0fff;
  if(status[1]&0x80)printf("ERROR: sensor overcurrent flag\n");
  if(touched!=previous){for(int i=0;i<12;i++)if((touched^previous)&(1<<i))printf("E%d %s\n",i,(touched&(1<<i))?"TOUCH":"RELEASE");previous=touched;}
  if(ticks++%50==0){printf("SAMPLE mask=0x%03x",touched);for(int i=0;i<5;i++){int f=filtered[2*i]|(filtered[2*i+1]<<8),b=baseline[i]<<2;printf(" E%d=%d/%d/d%d",i,f,b,b-f);}printf("\n");}
  vTaskDelay(pdMS_TO_TICKS(20));
 }
}
