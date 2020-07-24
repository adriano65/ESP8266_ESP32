
#include <osapi.h>
#include <gpio.h>
#include <os_type.h>
#include <mem.h>
#include <user_interface.h>
#include <ip_addr.h>
#include <time.h>
#include "uart.h"
#include "mqtt_client.h"
#include "sensor.h"
#include "config.h"
#include "gpio16.h"
#include "button.h"
#include "blinkled.h"

#define BLINKLED_DBG

#ifdef BLINKLED_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif

#ifdef LED_CONN_PIN
os_timer_t blink_timer;
Blink_Data * blink_data;
//void os_timer_arm(os_timer_t *ptimer, uint32 msec, bool repeat_flag);
void ICACHE_FLASH_ATTR blink_timercb(Blink_Data * _blink_data) {
    //struct Blink_Data * blink_data = (struct Blink_Data *)_blink_data;
    switch (blink_data->state_machine) {
      case LED_ON:
        gpio_write(LED_CONN_PIN, LED_CONN_PIN_ACTIVELOW ? 0 : 1);
        blink_data->state_machine=LED_OFF;
        break;

      case LED_OFF:
        gpio_write(LED_CONN_PIN, LED_CONN_PIN_ACTIVELOW ? 1 : 0);
        blink_data->state_machine=LED_WAIT;
        break;

      case LED_ON2_BLINKS:
        gpio_write(LED_CONN_PIN, LED_CONN_PIN_ACTIVELOW ? 0 : 1);
        blink_data->state_machine=LED_OFF2_BLINKS_WAIT;
        break;

      case LED_OFF2_BLINKS_WAIT:
        gpio_write(LED_CONN_PIN, LED_CONN_PIN_ACTIVELOW ? 1 : 0);
        blink_data->state_machine=LED_OFF2_BLINKS_WAIT2;
        break;

      case LED_OFF2_BLINKS_WAIT2:
        blink_data->state_machine=LED_OFF2_BLINKS;
        break;

      case LED_OFF2_BLINKS:
        blink_data->state_machine=LED_ON;
        break;

      case LED_ON3_BLINKS:
        gpio_write(LED_CONN_PIN, LED_CONN_PIN_ACTIVELOW ? 0 : 1);
        blink_data->state_machine=LED_OFF3_BLINKS_WAIT;
        break;

      case LED_OFF3_BLINKS_WAIT:
        gpio_write(LED_CONN_PIN, LED_CONN_PIN_ACTIVELOW ? 1 : 0);
        blink_data->state_machine=LED_OFF3_BLINKS_WAIT3;
        break;

      case LED_OFF3_BLINKS_WAIT3:
        blink_data->state_machine=LED_ON2_BLINKS;
        break;

      case LED_WAIT: 
        switch (blink_data->nBlinks) {
          case 1:
            //DBG("blink_data->intervals_50mS -> %d", blink_data->intervals_50mS);
            blink_data->state_machine=(blink_data->nCounter % blink_data->intervals_50mS) ? LED_WAIT : LED_ON;
            break;
          case 2:
            blink_data->state_machine=(blink_data->nCounter % blink_data->intervals_50mS) ? LED_WAIT : LED_ON2_BLINKS;
            break;
          case 3:
            blink_data->state_machine=(blink_data->nCounter % blink_data->intervals_50mS) ? LED_WAIT : LED_ON3_BLINKS;
            break;
          default:
            DBG("blink_data->nBlinks -> %d", blink_data->nBlinks);
            blink_data->state_machine=LED_ON;
            break;
          }
        break;
      }
    blink_data->nCounter++;
    //DBG("blink_data->nCounter -> %d", blink_data->nCounter);
}

/* Sets the interval of the timer controlling the blinking of the LED. */
void ICACHE_FLASH_ATTR set_blink_timer_delay(uint16_t _interval, unsigned char _nBlinks) {
    os_timer_disarm(&blink_timer);
    blink_data->intervals_50mS=_interval;
    blink_data->nBlinks=_nBlinks;
    blink_data->state_machine=LED_OFF;
    blink_data->nCounter=0;
    os_timer_arm(&blink_timer, 50, 1);
}

void ICACHE_FLASH_ATTR blink_timer_init() {
    blink_data = (Blink_Data *)os_zalloc(sizeof(Blink_Data));
    set_gpio_mode(LED_CONN_PIN, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    os_timer_setfn(&blink_timer, (os_timer_func_t *)blink_timercb, blink_data);
    set_blink_timer_delay(10, 1);
}

#else
void ICACHE_FLASH_ATTR blink_timer_init() {}
void ICACHE_FLASH_ATTR set_blink_timer_delay(uint16_t delay, unsigned char nBlinks) {}
#endif

