/*
 * user_main.c: Main entry-point for demonstrating OTA firmware upgrades via TCP/IP (not HTTP).
 *
 */
#include <osapi.h>
#include <gpio.h>
#include <os_type.h>
#include <mem.h>
#include <user_interface.h>
#include <ip_addr.h>
#include <time.h>
#include "uart.h"
#include "tcp_ota.h"
#include "mqtt_client.h"
#include "config.h"
#include "gpio16.h"
#include "button.h"

#if defined(SONOFFTH10)
#include "sensor.h"
extern Sensor_Data sensor_data;
#endif

#if defined(SONOFFPOW)
#include "../hlw8012/hlw8012.h"
#endif

#if defined(SONOFFPOW_DDS238_2)
#include "../dds238-2/dds238-2.h"
#endif

#if defined(MAINS_GTN1000)
#include "../gtn1000/gtn1000.h"
#endif

#if defined(MAINS_GTN_HPR)
#include "../gtn_hpr/gtn_hpr.h"
#endif

#if defined(MAINS_VMC) || defined(SONOFFDUAL)
//#include "ccs811.h"
//extern ccs811_sensor_t * ccs811_sensor;
#include "ina226.h"
#endif

#include "network.h"
#include "ntp.h"

//#define MAIN_DBG

#ifdef MAIN_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif

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

static void ICACHE_FLASH_ATTR restoreIO() {
  #if defined(MAINS)
    #if !defined(USE_TXD0)
    set_gpio_mode(GPIO_3, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    gpio_write(GPIO_3, flashConfig.IOPort_bit0);
    #warning USE_TXD0 undefined
    #endif
    set_gpio_mode(GPIO_4, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    gpio_write(GPIO_4, flashConfig.IOPort_bit1);
    set_gpio_mode(GPIO_14, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    gpio_write(GPIO_14, flashConfig.IOPort_bit2);
    set_gpio_mode(GPIO_12, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    gpio_write(GPIO_12, flashConfig.IOPort_bit3==0 ? 1 : 0);
    //gpio_write(GPIO_12, flashConfig.IOPort_bit3);
    set_gpio_mode(GPIO_13, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    gpio_write(GPIO_13, flashConfig.IOPort_bit4);
    set_gpio_mode(GPIO_0, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    gpio_write(GPIO_0, flashConfig.IOPort_bit5);
    #if !defined(USE_TXD0)
    set_gpio_mode(GPIO_1, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    gpio_write(GPIO_1, flashConfig.IOPort_bit6);
    #endif
    set_gpio_mode(GPIO_5, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    gpio_write(GPIO_5, flashConfig.IOPort_bit7);
  #else
			#if defined(ARMTRONIX)
				set_gpio_mode(GPIO_4, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
        gpio_write(GPIO_4, flashConfig.IOPort_bit0);

				set_gpio_mode(GPIO_12, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
				gpio_write(GPIO_12, flashConfig.IOPort_bit1);

				set_gpio_mode(GPIO_13, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
				gpio_write(GPIO_13, flashConfig.IOPort_bit2);

				set_gpio_mode(GPIO_14, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
				gpio_write(GPIO_14, flashConfig.IOPort_bit3);
      #else
      set_gpio_mode(GPIO_12, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
      gpio_write(GPIO_12, flashConfig.IOPort_bit0);
      set_gpio_mode(GPIO_5, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
      gpio_write(GPIO_5, flashConfig.IOPort_bit1);      
      #endif
  #endif
  
  #if defined(BUTTON0_PIN)
  //#define RELAY_PIN                       GPIO_12
  if (! set_gpio_mode(BUTTON0_PIN, GPIO_INT, GPIO_PULLUP, GPIO_PIN_INTR_NEGEDGE)) { DBG("gpio : %d not set to INT", BUTTON0_PIN); return; }
  gpio_intr_attach(BUTTON0_PIN, (gpio_intr_handler)gpio0_press_intr_callback);
  #endif
  
}

/*
 * Entry point for the program.
 * mosquitto_sub -v -p 5800 -h 192.168.1.6 -t '#' 
 */
void ICACHE_FLASH_ATTR user_init(void) {
  //msleep(4000);
  LoadConfigFromFlash(NULL, NULL);
  
  gpio_init();	// Initialise all GPIOs.

  #if defined(USE_TXD0)
  uart_init(BIT_RATE_115200);		// set  GPIO_1 (aka TXD0) to 1 !  
  os_printf("\n%s %s\n", PROJ_NAME, VERSION);			// Say hello (leave some time to cause break in TX after boot loader's msg
  #endif
  restoreIO();
  
  // Start the LED timer
  blink_timer_init();

  //wifi_set_sleep_type(NONE_SLEEP_T);

  wifi_station_set_auto_connect(0);		// will be set to 1 after first successful connection
  system_init_done_cb(wifi_init);
  ota_init(); 
  ntp_init();  
  RTC_init();
  
  #if defined(SONOFFTH10)
  // NodeMCU Pin number 5 = GPIO14 - temp/umidity onewire
  #if defined(DS18B20_PIN)
  SensorInit(DS18B20, DS18B20_PIN);
  #else  
    #if defined(DHT22_PIN)
    SensorInit(DHT22, DHT22_PIN);
    #else
      #if defined(SI7021_PIN)
      SensorInit(SI7021, SI7021_PIN);
      #endif
    #endif

  #endif
  #endif

  #if defined(SONOFFPOW)
    HLW8012Init();
  #endif

  #if defined(SONOFFPOW_DDS238_2)
    dds238Init();
  #endif

  #if defined(MAINS_GTN1000)
    gtn1000Init();
  #endif

  #if defined(MAINS_GTN_HPR)
    gtn_hprInit();
  #endif

  #if defined(MAINS_VMC) || defined(SONOFFDUAL)
    i2c_master_gpio_init();
    //ccs811_init_sensor(CCS811_I2C_ADDRESS_1);
    ina226Init(INA226_ADD);
  #endif
  
  
  hw_timer_init();
  // uSeconds * 10 ... seems to be
  hw_timer_arm(10000);        // 1/10 seconds timer
  //hw_timer_arm(1000000);
}

extern uint8_t button_press_duration;

void ICACHE_FLASH_ATTR SendStatus(char * topic, sendmessage_t type) {
  int nTmp = 0;
  switch (type) {
    case MSG_TEMP_HUMI:
      #if defined (SONOFFTH10)
      os_sprintf(pTXdata, "{\"eventdate\": \"%02d:%02d:%02d\", \"rssi\": %d, \"heap_free\": %d, \"%s\": %d.%d, \"%s\": %d.%d}", 
          tm_rtc->tm_hour,
          tm_rtc->tm_min,
          tm_rtc->tm_sec,
          wifi_station_get_rssi(), 
          (unsigned int)system_get_free_heap_size(),
          sensor_data.HasBadTemp ? "BadTemp" : "temp",
          (int)sensor_data.temperature,
          (uint8_t)((sensor_data.temperature - (int)sensor_data.temperature) * 100) & 0xFF,
          sensor_data.HasBadTemp ? "BadHumid" : "humid",
          (int)sensor_data.humidity,
          (int)((sensor_data.humidity - (int)sensor_data.humidity) * 100) );
      // sensor_data.HasBadTemp ?  ---> check oxide on 2.5 mm connector first
      #endif
      break;

    // mosquitto_sub -v -p 5800 -h 192.168.1.6 -t '+/215/#'
    case MSG_CRITICAL_ERR:
      os_sprintf(pTXdata, "{\"eventdate\":\"%02d:%02d:%02d\", \"critical_heap_free\": %d}", 
          tm_rtc->tm_hour, 
          tm_rtc->tm_min, 
          tm_rtc->tm_sec, 
          (unsigned int)system_get_free_heap_size());
      break;

    case MSG_STATUS:
      os_sprintf(pTXdata, "{\"eventdate\":\"%02d:%02d:%02d\", \"rssi\": %d, \"heap_free\": %d}", 
          tm_rtc->tm_hour, 
          tm_rtc->tm_min, 
          tm_rtc->tm_sec, 
          wifi_station_get_rssi(), 
          (unsigned int)system_get_free_heap_size());
      break;

    case MSG_BUTTON:
      #if defined(BUTTON0_PIN)
      os_sprintf(pTXdata, "{\"eventdate\":\"%02d:%02d:%02d\", \"button0\": %d}", 
          tm_rtc->tm_hour, 
          tm_rtc->tm_min, 
          tm_rtc->tm_sec, 
          (unsigned int)button_press_duration);
      #endif
      break;

    case MSG_POW:
      #if defined(SONOFFPOW)
      os_sprintf(pTXdata, "{\"eventdate\":\"%02d:%02d:%02d\", \"rssi\": %d, \"power\": %d.%d, \"voltage\": %d.%d}", 
          tm_rtc->tm_hour, 
          tm_rtc->tm_min, 
          tm_rtc->tm_sec, 
          wifi_station_get_rssi(), 
          (int)hlw8012->actualRMSPower, (int)((hlw8012->actualRMSPower-(int)hlw8012->actualRMSPower)*100),
          (int)hlw8012->actualvoltage, (int)((hlw8012->actualvoltage-(int)hlw8012->actualvoltage)*100) );
      #endif      
      break;

    case MSG_DC_VOLTAGE:
      #if defined(MAINS_VMC) || defined(SONOFFDUAL)
      os_sprintf(pTXdata, "{\"eventdate\":\"%02d:%02d:%02d\", \"rssi\": %d, \"current\": %d.%d, \"voltage\": %d.%d, \"nCounter\": %d}", 
          tm_rtc->tm_hour, 
          tm_rtc->tm_min, 
          tm_rtc->tm_sec, 
          wifi_station_get_rssi(), 
          (int)ina226_data->actualcurrent, (int)((ina226_data->actualcurrent-(int)ina226_data->actualcurrent)*100),
          (int)ina226_data->actualvoltage, (int)((ina226_data->actualvoltage-(int)ina226_data->actualvoltage)*100),
          ina226_data->nCounter );
      #endif      
      break;

    case MSG_POW_DDS238_2:
      #if defined(SONOFFPOW_DDS238_2)
      nTmp=(int)dds238_2_data->EnergyFromGrid;
      if (nTmp<0) nTmp=~nTmp;
      os_sprintf(pTXdata, "{\"eventdate\":\"%02d:%02d:%02d\", \"ActivePower\": %d.%d, \"current\": %d.%d, \"EnergyToGrid\": %d.%d, \"EnergyFromGrid\": %d.%d, \"IsWrong\": %d}",
          tm_rtc->tm_hour, 
          tm_rtc->tm_min, 
          tm_rtc->tm_sec, 
          (int)dds238_2_data->ActivePower, (uint8_t)((dds238_2_data->ActivePower-(int)dds238_2_data->ActivePower)*100),
          (int)dds238_2_data->current, (uint8_t)((dds238_2_data->current-(int)dds238_2_data->current)*100), // centinaia di mA
          (int)dds238_2_data->EnergyToGrid, (uint8_t)((dds238_2_data->EnergyToGrid-(int)dds238_2_data->EnergyToGrid)*100),
          (int)nTmp, (uint8_t)((dds238_2_data->EnergyFromGrid-(int)dds238_2_data->EnergyFromGrid)*100),
          (unsigned int)dds238_2_data->IsWrong );
      #endif      
      break;

    case MSG_GTN1000:
      #if defined(MAINS_GTN1000)
      os_sprintf(pTXdata, "{\"eventdate\":\"%02d:%02d:%02d\", \"ActivePower\": %d.%d, \"IsWrong\": %d}",
          tm_rtc->tm_hour, 
          tm_rtc->tm_min, 
          tm_rtc->tm_sec, 
          (int)gtn1000_data->ActivePower, (uint8_t)((gtn1000_data->ActivePower-(int)gtn1000_data->ActivePower)*100),
          (unsigned int)gtn1000_data->IsWrong );
      #endif      
      break;

    case MSG_GTN_HPR:
      #if defined(MAINS_GTN_HPR)
      os_sprintf(pTXdata, "{\"eventdate\":\"%02d:%02d:%02d\", \"ActivePower\": %d.%d, \"IsWrong\": %d}",
          tm_rtc->tm_hour, 
          tm_rtc->tm_min, 
          tm_rtc->tm_sec, 
          (int)gtn_hpr_data->ActivePower, (uint8_t)((gtn1000_data->ActivePower-(int)gtn1000_data->ActivePower)*100),
          (unsigned int)gtn1000_data->IsWrong );
      #endif      
      break;

    default:
      os_sprintf(pTXdata, "{\"eventdate\":\"%02d:%02d:%02d\", \"unexpected\": %d}", 
          tm_rtc->tm_hour, 
          tm_rtc->tm_min, 
          tm_rtc->tm_sec, 
          0);
      break;
    }

  // DO NOT USE QOS > 0 !!! when NOT connected it leads to memory full !!
  //if ( ! MQTT_Publish(&mqttClient, topic, pTXdata, os_strlen(pTXdata), 1, 0) ) {
  if ( ! MQTT_Publish(&mqttClient, topic, pTXdata, os_strlen(pTXdata), 0, 0) ) {
    nMQTTPublishFailed++;
    }

}
