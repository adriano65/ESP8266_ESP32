#include <osapi.h>
#include <os_type.h>
#include <c_types.h>
#include <gpio.h>
#include <time.h>

#include "mqtt.h"
#include "mqtt_client.h"
#include "gpio16.h"
#include "network.h"
#include "config.h"
#include "ntp.h"
#include "button.h"

//#define BUTTON_DBG

#ifdef BUTTON_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif

#if defined(BUTTON0_PIN)
static os_timer_t button0_timer;
static os_timer_t bell0_timer;
uint8_t button_press_duration = 0;

static void ICACHE_FLASH_ATTR button0_timer_cb(uint16_t interval) {
    os_timer_disarm(&button0_timer);
    DBG("--");  
    button_press_duration=2;
    SendStatus(MQTT_BTN_TOPIC, MSG_BUTTON);
    os_timer_setfn(&button0_timer, (os_timer_func_t *)button0_timer_cb, &interval);
    os_timer_arm(&button0_timer, interval, 1);  
}

/* Sets the interval of the timer controlling delay */
void ICACHE_FLASH_ATTR start_button0_timer(uint16_t interval) {
    os_timer_disarm(&bell0_timer);
    os_timer_setfn(&button0_timer, (os_timer_func_t *)button0_timer_cb, &interval);
    os_timer_arm(&button0_timer, interval, 1);
}

static void ICACHE_FLASH_ATTR bell0_timer_cb(void *arg) {
    os_timer_disarm(&bell0_timer);
    button_press_duration=1;
    //SendStatus(MQTT_BTN_TOPIC, MSG_BUTTON);
    //button_press_duration=0;
    gpio_write(RELAY_PIN, 0);
}

void ICACHE_FLASH_ATTR start_bell0_timer(uint16_t interval) {
    os_timer_disarm(&bell0_timer);
    os_timer_setfn(&bell0_timer, (os_timer_func_t *)bell0_timer_cb, (void *)0);
    os_timer_arm(&bell0_timer, interval, 1);
}

static bool ICACHE_FLASH_ATTR deBounce(uint8_t expectedstate) {
    uint8_t nTent=0;
    
    while ((expectedstate==gpio_read(BUTTON0_PIN)) && (nTent<100)){
      os_delay_us(100);
      nTent++;
      }   
    return (nTent<100) ? FALSE : TRUE;
}

gpio_intr_handler gpio0_press_intr_callback(unsigned pin, unsigned level) {
    if (deBounce(0)) {
      set_gpio_mode(BUTTON0_PIN, GPIO_INT, GPIO_PULLUP, GPIO_PIN_INTR_POSEDGE);
      gpio_intr_attach(BUTTON0_PIN, (gpio_intr_handler)gpio0_release_intr_callback);
      start_button0_timer(3000);
      button_press_duration=1;
      }
}
// mosquitto_sub -v -p 5800 -h 192.168.1.6 -t '+/224/#'
gpio_intr_handler gpio0_release_intr_callback(unsigned pin, unsigned level) {
  gpio_intr_deattach(pin);
  os_timer_disarm(&button0_timer);
  os_timer_disarm(&bell0_timer);
  switch (button_press_duration) {
    case 1:
      if (flashConfig.map2.Enable.doorBell) {
        DBG("doorBell enabled");
        gpio_write(RELAY_PIN, 1);
        }
      start_bell0_timer(300);
      SendStatus(MQTT_BTN_TOPIC, MSG_BUTTON);
      break;
    case 2:
      gpio_write(RELAY_PIN, 0);
      break;
    case 3:	// !!! Erase ALL configuration and restart in AP mode
      LoadDefaultConfig(NULL,NULL);
      configSave(NULL,NULL);
      system_restart();
      break;
    default:  // AKA case 0 too :-)
      gpio_write(RELAY_PIN, 0);
      DBG("Too spikes or Long pressed");
      break;
    }
  button_press_duration=0;
  SendStatus(MQTT_BTN_TOPIC, MSG_BUTTON);
  if (! set_gpio_mode(BUTTON0_PIN, GPIO_INT, GPIO_PULLUP, GPIO_PIN_INTR_NEGEDGE)) { DBG("gpio : %d not set to INT", BUTTON0_PIN); }
  gpio_intr_attach(BUTTON0_PIN, (gpio_intr_handler)gpio0_press_intr_callback);
}

#else
gpio_intr_handler gpio0_press_intr_callback(unsigned pin, unsigned level);
#endif
