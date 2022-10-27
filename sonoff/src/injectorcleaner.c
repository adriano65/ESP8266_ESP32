#include <osapi.h>
#include <os_type.h>
#include <c_types.h>
#include <mem.h>
#include <gpio.h>
#include <time.h>
#include <pwm.h>

#include "mqtt.h"
#include "mqtt_client.h"
#include "gpio16.h"
#include "network.h"
#include "config.h"
#include "ntp.h"
#include "injectorcleaner.h"


//#define INJECTORCLEANER_DBG
#ifdef INJECTORCLEANER_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif

void ICACHE_FLASH_ATTR injector_timercb(FlashConfig * pFlashConfig);
os_timer_t injector_timer;
unsigned char nStatus;
unsigned int period;

#if defined(GASINJECTORCLEANER)

#if 0
void SensorInit() {
  #define PWM_CHANNELS 1
  const uint32_t period = 5000; // * 200ns ^= 1 kHz
  uint32 pin_info_list[PWM_CHANNELS][1] = {
    // MUX, FUNC, PIN
    {PERIPHS_IO_MUX_GPIO4_U,  FUNC_GPIO4, 19},
  };
  uint32 pwm_duty_init[PWM_CHANNELS] = {25, 25, 25, 25, 25};

  //pwm_init(microseconds , duty cycles, pwm channel_num, PWM0_PIN)
  pwm_init(period, pwm_duty_init, 1, pin_info_list);
  pwm_start();
}
#else
void InjectorInit() {
    nStatus=0;
    set_gpio_mode(PWM0_PIN, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    
    os_timer_disarm(&injector_timer);
    os_timer_setfn(&injector_timer, (os_timer_func_t *)injector_timercb, &flashConfig);
    os_timer_arm(&injector_timer, flashConfig.interval, 1);
}
#endif



void ICACHE_FLASH_ATTR injector_timercb(FlashConfig * _pFlashConfig) {
    FlashConfig * pFlashConfig = (FlashConfig *)_pFlashConfig;

    os_timer_disarm(&injector_timer);
    
    if (nStatus) {
      nStatus = 0;
      period=pFlashConfig->interval;
      }
    else {
      nStatus = 1;
      period=pFlashConfig->interval/pFlashConfig->dutycycle;
      }

    gpio_write(PWM0_PIN, nStatus);
    os_timer_arm(&injector_timer, period, 1);  
}
#else
void SensorInit() {
}

void ICACHE_FLASH_ATTR injector_timercb(FlashConfig * _pFlashConfig) {
}

#endif