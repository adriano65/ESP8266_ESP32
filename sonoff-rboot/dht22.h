/*
    Driver for the temperature and humidity sensor DHT11 and DHT22
    Official repository: https://github.com/CHERTS/esp8266-dht11_22

    Copyright (C) 2014 Mikhail Grigorev (CHERTS)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

#ifndef __DHT_DS18B_H__
#define __DHT_DS18B_H__

typedef enum {
	DISABLED,
	DHT11,
	DHT22,
	DS18B20,
} DHTType;

typedef struct {
  uint8_t pin;
  DHTType type;
  float temperature;
  float humidity;
} Sensor_Data;

Sensor_Data sensor_data;

#define DHT_MAXTIMINGS	10000
#define DHT_BREAKTIME	20
#define DHT_MAXCOUNT	32000
#define TOT_GPIO_PINS	13

bool SensorInit(DHTType, uint8_t);
bool DHTread();
char* DHTFloat2String(char* buffer, float value);

// list of commands DS18B20:

#define DS1820_WRITE_SCRATCHPAD 	0x4E
#define DS1820_READ_SCRATCHPAD      0xBE
#define DS1820_COPY_SCRATCHPAD 		0x48
#define DS1820_READ_EEPROM 			0xB8
#define DS1820_READ_PWRSUPPLY 		0xB4
#define DS1820_SEARCHROM 			0xF0
#define DS1820_SKIP_ROM             0xCC
#define DS1820_READROM 				0x33
#define DS1820_MATCHROM 			0x55
#define DS1820_ALARMSEARCH 			0xEC
#define DS1820_CONVERT_T            0x44

LOCAL os_timer_t read_sens_timer;
void ICACHE_FLASH_ATTR read_sens_timer_cb(void *arg);

bool DS18B20read(void);

#endif
