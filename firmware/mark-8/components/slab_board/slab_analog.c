#include "slab_analog.h"
#include "slab_pins.h"
#include "esp_adc/adc_oneshot.h"
#include "esp_adc/adc_cali.h"
#include "esp_adc/adc_cali_scheme.h"
#include "esp_log.h"

static adc_oneshot_unit_handle_t unit;
static adc_cali_handle_t cali;

esp_err_t slab_analog_init(void)
{
    if (unit) return ESP_OK;
    adc_oneshot_unit_init_cfg_t u = {.unit_id = ADC_UNIT_1};
    adc_oneshot_chan_cfg_t ch = {.atten = ADC_ATTEN_DB_12, .bitwidth = ADC_BITWIDTH_DEFAULT};
    esp_err_t err = adc_oneshot_new_unit(&u, &unit);
    if (err == ESP_OK) err = adc_oneshot_config_channel(unit, ADC_CHANNEL_7, &ch);  /* GPIO35 */
    if (err == ESP_OK) err = adc_oneshot_config_channel(unit, ADC_CHANNEL_0, &ch);  /* GPIO36 */
    adc_cali_line_fitting_config_t cal = {.unit_id = ADC_UNIT_1, .atten = ADC_ATTEN_DB_12,
        .bitwidth = ADC_BITWIDTH_DEFAULT, .default_vref = 1100};
    if (err == ESP_OK) err = adc_cali_create_scheme_line_fitting(&cal, &cali);
    if (err != ESP_OK) {
        ESP_LOGW("ANALOG", "ADC unavailable: %s", esp_err_to_name(err));
        cali = NULL;
    }
    return err;
}

static int pin_mv(adc_channel_t channel)
{
    if (!cali) return -1;
    int sum = 0;
    for (int i = 0; i < 16; ++i) {
        int raw, mv;
        if (adc_oneshot_read(unit, channel, &raw) != ESP_OK || adc_cali_raw_to_voltage(cali, raw, &mv) != ESP_OK)
            return -1;
        sum += mv;
    }
    return sum / 16;
}

int slab_analog_vbat_mv(void)
{
    int mv = pin_mv(ADC_CHANNEL_7);
    return mv < 0 ? -1 : (int)slab_divider_mv((unsigned)mv, SLAB_VBAT_DIVIDER_X1000);
}

int slab_analog_vbus_mv(void)
{
    int mv = pin_mv(ADC_CHANNEL_0);
    return mv < 0 ? -1 : (int)slab_divider_mv((unsigned)mv, SLAB_VBUS_DIVIDER_X1000);
}
