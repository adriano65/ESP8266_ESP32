#include "ets_sys.h"
#include "osapi.h"
#include "gpio.h"
#include "os_type.h"

#define TOSECONDS(seconds)  ((seconds)*1000000UL)

static const int pin = 5;
//static const int pin = 1;	 //GPIO1 -> esp-01 ?
//static const int pin = 2;	 //GPIO2 -> esp-12e
static volatile os_timer_t some_timer;

void callback_timerfunc(void *arg) {
  if (GPIO_REG_READ(GPIO_OUT_ADDRESS) & (1 << pin)) {
	GPIO_OUTPUT_SET(5, 0);			// set gpio low (switch on)
	//GPIO_OUTPUT_SET(2, 0);			// set gpio low (switch on)
	os_timer_arm(&some_timer, 30, 0);
	}
  else {
	//GPIO_OUTPUT_SET(2, 1);		// set gpio high (switch off)
	GPIO_OUTPUT_SET(5, 1);		// set gpio high (switch off)
	os_timer_arm(&some_timer, 970, 0);
	}
}

void ICACHE_FLASH_ATTR user_init() {
  gpio_init();		// init gpio subsytem

  PIN_FUNC_SELECT(PERIPHS_IO_MUX_U0TXD_U, FUNC_GPIO1); //use pin as GPIO1 instead of UART TXD
  //PIN_FUNC_SELECT(PERIPHS_IO_MUX_U0TXD_U, FUNC_GPIO2); //use pin as GPIO2 instead of UART TXD -> esp-12e
  gpio_output_set(0, 0, (1 << pin), 0); 	// enable pin as output
  gpio_output_set((1 << pin), 0, 0, 0);		// set gpio high (switch off)
  
  //gpio_pin_wakeup_enable(GPIO_ID_PIN(4), GPIO_PIN_INTR_HILEVEL);
  //system_deep_sleep_set_option(4);	// disable rf on wake up
  //system_deep_sleep(TOSECONDS(10));
  //system_deep_sleep_instant(TOSECONDS(6));
  
  os_delay_us(TOSECONDS(3));
  os_timer_setfn(&some_timer, (os_timer_func_t *)callback_timerfunc, NULL);
  // setup timer (500ms, repeating)
  // os_timer_arm(&some_timer, 500, 1);
  // setup timer (100ms, not repeating)
  os_timer_arm(&some_timer, 100, 0);
}

//system_get_rtc_time