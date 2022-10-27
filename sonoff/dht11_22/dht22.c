/*
 * sonoff implementation
  #define DHTPIN 14 --> gpio14 == pin 5
  #define DHTTYPE DHT22
*/

#include <ets_sys.h>
#include <osapi.h>
#include <c_types.h>
#include <user_interface.h>
#include <gpio.h>
#include "gpio16.h"
#include "mqtt.h"
#include "config.h"
#include "network.h"
#include "sensor.h"
#include "dht22.h"

#define DHT_DEBUG

#ifdef DHT_DEBUG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(...)
#endif

extern uint8_t pin_num[];
Sensor_Data sensor_data;

static inline float ICACHE_FLASH_ATTR scale_humidity(DHTType sensor_type, int *data) {
	if(sensor_type == DHT11) {
		return (float) data[0];
		} 
	else {
		float humidity = data[0] * 256 + data[1];
		return humidity /= 10;
		}
}

static inline float ICACHE_FLASH_ATTR scale_temperature(DHTType sensor_type, int *data) {
	if(sensor_type == DHT11) {
	  return (float) data[2];
	  } 
	else {
	  float temperature = data[2] & 0x7f;
	  temperature *= 256;
	  temperature += data[3];
	  temperature /= 10;
	  if (data[2] & 0x80)
		  temperature *= -1;
	  return temperature;
	  }
}

bool ICACHE_FLASH_ATTR DHTread() {
	int counter = 0;
	int laststate = 1;
	int i = 0;
	int j = 0;
	int checksum = 0;
	int data[100];
	data[0] = data[1] = data[2] = data[3] = data[4] = 0;

	set_gpio_mode(sensor_data.pin, GPIO_OUTPUT, GPIO_FLOAT, GPIO_PIN_INTR_DISABLE);
	// Wake up device, 250ms of high
	gpio_write(sensor_data.pin, 1);
	msleep(250);
	// Hold low for 20ms
	gpio_write(sensor_data.pin, 0);
	msleep(20);
	// High for 40ns
	gpio_write(sensor_data.pin, 1);
	os_delay_us(40);
	// Set DHT_PIN pin as an input
	set_gpio_mode(sensor_data.pin, GPIO_INPUT, GPIO_FLOAT, GPIO_PIN_INTR_DISABLE);

	// wait for pin to drop?
	while (gpio_read(sensor_data.pin) == 1 && i < DHT_MAXCOUNT) {
	  os_delay_us(1);
	  i++;
	  }

	if(i == DHT_MAXCOUNT) {
	  DBG("Failed to get reading from GPIO%d, dying", pin_num[sensor_data.pin]);
	  return false;
	  }

	// read data
	for (i = 0; i < DHT_MAXTIMINGS; i++) {
	  // Count high time (in approx us)
	  counter = 0;
	  while (gpio_read(sensor_data.pin) == laststate) {
		  counter++;
		  os_delay_us(1);
		  if (counter == 1000)
			  break;
			}
	  laststate = gpio_read(sensor_data.pin);
	  if (counter == 1000)
			break;
	  // store data after 3 reads
	  if ((i>3) && (i%2 == 0)) {
			// shove each bit into the storage bytes
			data[j/8] <<= 1;
			if (counter > DHT_BREAKTIME)
				data[j/8] |= 1;
			j++;
			}
		}

  if (j >= 39) {
	  checksum = (data[0] + data[1] + data[2] + data[3]) & 0xFF;
	  DBG("DHT%s: %02x %02x %02x %02x [%02x] CS: %02x (GPIO%d)", sensor_data.type==DHT11 ? "11":"22", data[0], data[1], data[2], data[3], data[4], checksum, pin_num[sensor_data.pin]);
	  if (data[4] == checksum) {
			// checksum is valid
			sensor_data.temperature = scale_temperature(sensor_data.type, data);
			sensor_data.humidity = scale_humidity(sensor_data.type, data);
			//DBG("DHT: Temperature =  %d *C, Humidity = %d %%\r\n", (int)(reading.temperature * 100), (int)(reading.humidity * 100));
			DBG("Temperature = %d *C, Humidity = %d %% (GPIO%d)", (int) (sensor_data.temperature * 100), (int) (sensor_data.humidity * 100), pin_num[sensor_data.pin]);
			} 
	  else {
			//DBG("Checksum was incorrect after %d bits. Expected %d but got %d\r\n", j, data[4], checksum);
			DBG("DHT: Checksum was incorrect after %d bits. Expected %d but got %d (GPIO%d)", j, data[4], checksum, pin_num[sensor_data.pin]);
			return false;
			}
		} 
  else {
		DBG("DHT: Got too few bits: %d should be at least 40 (GPIO%d)", j, pin_num[sensor_data.pin]);
		return false;
		}
  return true;
}

bool ICACHE_FLASH_ATTR DHTSensorInit(DHTType senstype, uint8_t pin) {
  bool res=false;
  sensor_data.pin = pin;
  sensor_data.type = senstype;
  DBG("on GPIO%d", pin_num[sensor_data.pin]);
  
  return res;
}
