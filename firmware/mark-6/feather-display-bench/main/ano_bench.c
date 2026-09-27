/* ANO #6310 / seesaw product 5740. Protocol retained from carrier_controls.c. */
#include "ano_bench.h"
#include "carrier_board.h"
#include "driver/gpio.h"
#include "driver/i2c_master.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
static i2c_master_bus_handle_t bus;
static i2c_master_dev_handle_t device;
#define TRY(x) do { esp_err_t e=(x); if(e!=ESP_OK) return e; } while(0)
static esp_err_t read_register(uint8_t base,uint8_t reg,uint32_t *value)
{
    if(!carrier_board_ready() || !device) return ESP_ERR_INVALID_STATE;
    const uint8_t address[]={base,reg};
    uint8_t data[4];
    TRY(i2c_master_transmit(device,address,sizeof address,100));
    vTaskDelay(pdMS_TO_TICKS(10)); // STOP and seesaw processing time before read.
    TRY(i2c_master_receive(device,data,sizeof data,100));
    *value=((uint32_t)data[0]<<24)|((uint32_t)data[1]<<16)|((uint32_t)data[2]<<8)|data[3];
    return ESP_OK;
}
esp_err_t ano_bench_init(void)
{
    if(!carrier_board_ready()) return ESP_ERR_INVALID_STATE;
    // Feather V2 dedicated QT supply enable, not the carrier peripheral rail.
    TRY(gpio_set_level(2,1));
    TRY(gpio_set_direction(2,GPIO_MODE_OUTPUT));
    vTaskDelay(pdMS_TO_TICKS(250));
    i2c_master_bus_config_t cfg={.i2c_port=I2C_NUM_0,
        .sda_io_num=CARRIER_I2C_SDA,.scl_io_num=CARRIER_I2C_SCL,
        .clk_source=I2C_CLK_SRC_DEFAULT,.glitch_ignore_cnt=7,
        .flags.enable_internal_pullup=false};
    TRY(i2c_new_master_bus(&cfg,&bus));
    i2c_device_config_t dev={.dev_addr_length=I2C_ADDR_BIT_LEN_7,
        .device_address=0x49,.scl_speed_hz=100000};
    esp_err_t err=i2c_master_bus_add_device(bus,&dev,&device);
    if(err!=ESP_OK){i2c_del_master_bus(bus);return err;}
    uint32_t version=0;
    err=read_register(0,2,&version);
    if(err==ESP_OK && (version>>16)!=5740) err=ESP_ERR_INVALID_VERSION;
    const uint8_t regs[]={0x03,0x0b,0x05};
    for(unsigned i=0;i<sizeof regs && err==ESP_OK;i++){
        const uint8_t cmd[]={0x01,regs[i],0,0,0,0x3e};
        err=i2c_master_transmit(device,cmd,sizeof cmd,100);
        vTaskDelay(pdMS_TO_TICKS(10));
    }
    if(err!=ESP_OK){
        i2c_master_bus_rm_device(device);device=NULL;i2c_del_master_bus(bus);
        gpio_set_level(2,0);
        return err;
    }
    ESP_LOGI("ANO_BENCH","DETECTED address=0x49 product=%u version=0x%08lx",(unsigned)(version>>16),(unsigned long)version);
    return ESP_OK;
}
esp_err_t ano_bench_read(uint32_t *position,uint32_t *buttons)
{
    TRY(read_register(0x11,0x30,position));
    return read_register(0x01,0x04,buttons);
}
