#include "bench_display.h"
#include "sdkconfig.h"
void signal_check(void);
void app_main(void)
{
#if CONFIG_BENCH_DISPLAY_SIGNAL_CHECK
    signal_check();
#else
    ESP_ERROR_CHECK(bench_display_init());
    ESP_ERROR_CHECK(bench_display_probe());
#endif
}
