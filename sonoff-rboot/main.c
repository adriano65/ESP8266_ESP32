//////////////////////////////////////////////////
// rBoot sample project.
// Copyright 2015 Richard A Burton
// richardaburton@gmail.com
// See license.txt for license terms.
//////////////////////////////////////////////////

#include <c_types.h>
#include <osapi.h>
#include <user_interface.h>
#include <time.h>
#include <mem.h>

#include "user_config.h"
#include "uart.h"
#include "tcp_ota.h"
#include "network.h"
#include "config.h"
#include "dht22.h"
#include "gpio16.h"
#include "main.h"

// Timer used to determine when the LED is to be turned on/off.
LOCAL os_timer_t blink_timer;
LOCAL os_timer_t button_timer;

// The current state of the LED's output.
LOCAL uint8_t led_state = 0;

// GPIO5
#define BUTTON0_PIN 1

void ICACHE_FLASH_ATTR start_button_timer(uint16_t interval) {
    os_timer_disarm(&button_timer);
    set_gpio_mode(BUTTON0_PIN, GPIO_INPUT, GPIO_PULLUP);
    os_timer_setfn(&button_timer, (os_timer_func_t *)button_timer_cb, interval);
    os_timer_arm(&button_timer, interval, 1);
}

void ICACHE_FLASH_ATTR button_timer_cb(uint16_t interval) {
    os_timer_disarm(&button_timer);
    if (gpio_read(BUTTON0_PIN)==0) { 
      start_blink_timer(10000); 
      }
    else {
      os_timer_setfn(&button_timer, (os_timer_func_t *)button_timer_cb, interval);
      os_timer_arm(&button_timer, interval, 1);  
      }
}

void ICACHE_FLASH_ATTR start_blink_timer(uint16_t interval) {
	  gpio_write(LED_CONN_PIN, 0);
    os_timer_setfn(&blink_timer, (os_timer_func_t *)blink_timer_cb, interval);
    os_timer_arm(&blink_timer, interval, 1);
}

void ICACHE_FLASH_ATTR blink_timer_cb(uint16_t interval) {
  os_timer_disarm(&blink_timer);
  os_timer_disarm(&button_timer);
	gpio_write(LED_CONN_PIN, 1);    // switch OFF
  os_timer_setfn(&button_timer, (os_timer_func_t *)button_timer_cb, interval);
  os_timer_arm(&button_timer, interval, 1);  
}

void ICACHE_FLASH_ATTR user_rf_pre_init() {
}
/* user_rf_cal_sector_set is a required function that is called by the SDK to get a flash
 * sector number where it can store RF calibration data. This was introduced with SDK 1.5.4.1
 * and is necessary because Espressif ran out of pre-reserved flash sectors. Ooops...  */
uint32 ICACHE_FLASH_ATTR user_rf_cal_sector_set(void) {
  uint32_t sect = 0;
  switch (system_get_flash_size_map()) {
	case FLASH_SIZE_4M_MAP_256_256: // 512KB
	  sect = 128 - 10; // 0x76000
	  break;
	  
	case FLASH_SIZE_8M_MAP_512_512:
	  sect = 256 - 5;
	  break;
	  
	default:
	  //sect = 256 - 5;
	  sect = 0;
	}
  return sect;
}

void ICACHE_FLASH_ATTR ShowIP() {
	struct ip_info ipconfig;
	wifi_get_ip_info(STATION_IF, &ipconfig);
	if (wifi_station_get_connect_status() == STATION_GOT_IP && ipconfig.ip.addr != 0) {
		os_printf("ip: %d.%d.%d.%d, mask: %d.%d.%d.%d, gw: %d.%d.%d.%d\r\n",
			IP2STR(&ipconfig.ip), IP2STR(&ipconfig.netmask), IP2STR(&ipconfig.gw));
	} else {
		os_printf("network status: %d\r\n", wifi_station_get_connect_status());
	}
}

void ICACHE_FLASH_ATTR ShowInfo() {
    os_printf("\r\nROM%d -> SDK: v%s\r\n", rboot_get_current_rom(), system_get_sdk_version());
    os_printf("Free Heap: %d\r\n", system_get_free_heap_size());
    os_printf("CPU Frequency: %d MHz\r\n", system_get_cpu_freq());
    os_printf("System Chip ID: 0x%x\r\n", system_get_chip_id());
    os_printf("SPI Flash ID: 0x%x\r\n", spi_flash_get_id());
    os_printf("SPI Flash Size: %d\r\n", (1 << ((spi_flash_get_id() >> 16) & 0xff)));
}

void ICACHE_FLASH_ATTR Switch() {
	uint8 before, after;
	before = rboot_get_current_rom();
	if (before == 0) after = 1; else after = 0;
	os_printf("Swapping from rom %d to rom %d.\r\n", before, after);
	rboot_set_current_rom(after);
	os_printf("Restarting...\r\n\r\n");
	system_restart();
}

void ICACHE_FLASH_ATTR ProcessCommand(char* str) {
	if (!strcmp(str, "help")) {
		os_printf("available commands\r\n");
		os_printf("  help - display this message\r\n");
		os_printf("  ip - show current ip address\r\n");
		os_printf("  restart - restart the esp8266\r\n");
		os_printf("  switch - switch to the other rom and reboot\r\n");
		os_printf("  ota - perform ota update, switch rom and reboot\r\n");
		os_printf("  info - show esp8266 info\r\n");
	} else if (!strcmp(str, "restart")) {
		os_printf("Restarting...\r\n\r\n");
		system_restart();
	} else if (!strcmp(str, "switch")) {
		Switch();
	} else if (!strcmp(str, "ota")) {
		;
	} else if (!strcmp(str, "ip")) {
		ShowIP();
	} else if (!strcmp(str, "info")) {
		ShowInfo();
	}
}

//void ICACHE_FLASH_ATTR user_init(void) {
void user_init(void) {
  bool restoreOk = FALSE;
  //configWipe(); // uncomment to reset the config for testing purposes
  restoreOk = configRestore();

  uart_init(BIT_RATE_115200);

  // Initialise all GPIOs.
  gpio_init();

  // Say hello (leave some time to cause break in TX after boot loader's msg
  sleepms(200);
  os_printf("\n%s %s\n", PROJ_NAME, VERSION);
  os_printf("Flash config restore %s\n", restoreOk ? "ok" : "FAILED");
  os_printf("Currently running rom %d.\r\n", rboot_get_current_rom());

  #define ACHILLE
  #if defined(ACHILLE)

  // NodeMCU Pin number 5 = GPIO14 - temp
  //SensorInit(DS18B20, DS18B20_PIN);

  // NodeMCU Pin number 2 = GPIO4 - humidity
  //SensorInit(DS18B20, 2);
  
  // Start the LED timer
  set_gpio_mode(LED_CONN_PIN, GPIO_OUTPUT, GPIO_FLOAT);
  start_button_timer(10);
  
/*
  set_gpio_mode(LED_CONN_PIN, GPIO_OUTPUT, GPIO_FLOAT);
  set_gpio_mode(LED_CONN_PIN, GPIO_OUTPUT, GPIO_PULLUP);
  //while (1==1) {
    gpio_write(LED_CONN_PIN, 0);
    sleepms(100);
    gpio_write(LED_CONN_PIN, 1);
    sleepms(500);

    gpio_write(LED_CONN_PIN, 0);
    sleepms(100);
    gpio_write(LED_CONN_PIN, 1);
    sleepms(500);

    gpio_write(LED_CONN_PIN, 0);
    sleepms(100);
    gpio_write(LED_CONN_PIN, 1);
    sleepms(500);
*/
  //}

  #else
  wifi_init();
  //system_phy_set_max_tpw(40);
  //system_phy_set_max_tpw(60);
  system_phy_set_max_tpw(80);
  //system_phy_set_max_tpw(160);
  
  ota_init();

  // NodeMCU Pin number 5 = GPIO14 - temp
  //SensorInit(DS18B20, DS18B20_PIN);

  // NodeMCU Pin number 2 = GPIO4 - humidity
  //SensorInit(DS18B20, 2);
  
  mqtt_client_init();
  
  // Start the LED timer
  set_gpio_mode(LED_CONN_PIN, GPIO_OUTPUT, GPIO_FLOAT);
  start_blink_timer(LED_BLINK_DELAY_INIT);
  
  // Restore I/O
  set_gpio_mode(RELE1_PIN, GPIO_OUTPUT, GPIO_PULLUP);
  gpio_write(RELE1_PIN, flashConfig.IOPort_bit3);  
  #endif
}
