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
#include "pktbuf.h"
#include "mqtt_msg.h"
#include "mqtt.h"

#include "config.h"
#include "dht22.h"

#define DHT_DEBUG

#ifdef DHT_DEBUG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); } while(0)
#else
#define DBG(...)
#endif

extern uint8_t pin_num[];
extern char pTXdata[];
extern int TXdatalen;
extern MQTT_Client mqttClient;

static inline float scale_humidity(DHTType sensor_type, int *data) {
	if(sensor_type == DHT11) {
		return (float) data[0];
	} else {
		float humidity = data[0] * 256 + data[1];
		return humidity /= 10;
	}
}

static inline float scale_temperature(DHTType sensor_type, int *data) {
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

char* DHTFloat2String(char* buffer, float value) {
  os_sprintf(buffer, "%d.%d", (int)(value),(int)((value - (int)value)*100));
  return buffer;
}

bool DHTread() {
	int counter = 0;
	int laststate = 1;
	int i = 0;
	int j = 0;
	int checksum = 0;
	int data[100];
	data[0] = data[1] = data[2] = data[3] = data[4] = 0;
	uint8_t pin = pin_num[sensor_data.pin];

	// Wake up device, 250ms of high
	GPIO_OUTPUT_SET(pin, 1);
	sleepms(250);
	// Hold low for 20ms
	GPIO_OUTPUT_SET(pin, 0);
	sleepms(20);
	// High for 40ns
	GPIO_OUTPUT_SET(pin, 1);
	os_delay_us(40);
	// Set DHT_PIN pin as an input
	GPIO_DIS_OUTPUT(pin);

	// wait for pin to drop?
	while (GPIO_INPUT_GET(pin) == 1 && i < DHT_MAXCOUNT) {
	  os_delay_us(1);
	  i++;
	  }

	if(i == DHT_MAXCOUNT) {
	  DBG("Failed to get reading from GPIO%d, dying\n", pin);
	  return false;
	  }

	// read data
	for (i = 0; i < DHT_MAXTIMINGS; i++) {
	  // Count high time (in approx us)
	  counter = 0;
	  while (GPIO_INPUT_GET(pin) == laststate) {
		  counter++;
		  os_delay_us(1);
		  if (counter == 1000)
			  break;
		}
	  laststate = GPIO_INPUT_GET(pin);
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
	  DBG("DHT%s: %02x %02x %02x %02x [%02x] CS: %02x (GPIO%d)\n", sensor_data.type==DHT11 ? "11":"22",
				data[0], data[1], data[2], data[3], data[4], checksum, pin);
	  if (data[4] == checksum) {
		// checksum is valid
		sensor_data.temperature = scale_temperature(sensor_data.type, data);
		sensor_data.humidity = scale_humidity(sensor_data.type, data);
		//DBG("DHT: Temperature =  %d *C, Humidity = %d %%\r\n", (int)(reading.temperature * 100), (int)(reading.humidity * 100));
		DBG("Temperature*100 =  %d *C, Humidity*100 = %d %% (GPIO%d)\n",
			  (int) (sensor_data.temperature * 100), (int) (sensor_data.humidity * 100), pin);
		} 
	  else {
		//DBG("Checksum was incorrect after %d bits. Expected %d but got %d\r\n", j, data[4], checksum);
		DBG("DHT: Checksum was incorrect after %d bits. Expected %d but got %d (GPIO%d)\n",
					j, data[4], checksum, pin);
		return false;
		}
	} 
  else {
	DBG("DHT: Got too few bits: %d should be at least 40 (GPIO%d)\n", j, pin);
	return false;
	}
  return true;
}

void ICACHE_FLASH_ATTR read_sens_timer_cb(void *arg){
  static uint8_t i;
  
  os_timer_disarm(&read_sens_timer);
  switch (sensor_data.type) {
	case DHT11:
	case DHT22:
	  if (DHTread()) {
		//char buff[20];
		//os_printf("GPIO%d\r\n", pin_num[sensor.pin]);
		//os_printf("Temperature: %s *C\r\n", DHTFloat2String(buff, data.temperature));
		//os_printf("Humidity: %s %%\r\n", DHTFloat2String(buff, data.humidity));
		} 
	  else {
		DBG("Failed to read temperature and humidity sensor on GPIO%d\n", pin_num[sensor_data.pin]);
		}
	  break;
	  
	case DS18B20:
	  if (DS18B20read()) {
		os_sprintf(pTXdata, "{\"rssi\":%d, \"heap_free\":%d, \"temp\":%d.%d}", wifi_station_get_rssi(), (unsigned int)system_get_free_heap_size(), (int)sensor_data.temperature,  (int)(sensor_data.temperature - (int)sensor_data.temperature) * 100);
		} 
	  else {
		os_sprintf(pTXdata, "{\"rssi\":%d, \"heap_free\":%d}", wifi_station_get_rssi(), (unsigned int)system_get_free_heap_size());
		DBG("Failed to read temperature sensor on GPIO%d\n", pin_num[sensor_data.pin]);
		}
	  //MQTT_Connect(&mqttClient);
	  //MQTT_Publish(&mqttClient, ESP_MQTT_TOPIC, pTXdata, os_strlen(pTXdata), 1, 0);
	  break;
	  
	case DISABLED:
	  break;
	  
	default:
	  DBG("mah\n");
	  break;
	}
	os_timer_arm(&read_sens_timer, READ_DELAY, 1);
}

bool SensorInit(DHTType senstype, uint8_t pin) {
  bool res=false;
  sensor_data.pin = pin;
  sensor_data.type = senstype;
  DBG("on GPIO%d\r\n", pin_num[sensor_data.pin]);
  
  os_timer_disarm(&read_sens_timer);
  os_timer_setfn(&read_sens_timer, (os_timer_func_t *)read_sens_timer_cb, (void *)0);
  os_timer_arm(&read_sens_timer, READ_DELAY, 1);
  return res;
}
