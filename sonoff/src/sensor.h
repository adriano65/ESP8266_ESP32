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

#ifndef __SENSOR_H__
#define __SENSOR_H__

#include <c_types.h>

typedef enum {
	DISABLED,
	DHT11,
	DHT22,
	DS18B20,
	SI7021,
} DHTType;

enum {
	NOBADREADING=0,
	BADPROTOCRC=1,
	FIRSTRESETFAILED=2,
	SECONDRESETFAILED=3,
	THIRDRESETFAILED=4,
	SPIKEDETECTED=5,
} BadReadingType;


//#define READINGTYPE(n) ((((y) % 4) == 0 && ((y) % 100) != 0) || ((y) % 400) == 0)

typedef struct {
  uint8_t pin;
  DHTType type;
  float temperature;
  float temperature_old;
  bool HasBadTemp;
  float humidity;
  float humidity_old;
  bool HasBadHumi;
} Sensor_Data;

bool ICACHE_FLASH_ATTR DHTSensorInit(DHTType, uint8_t);

static os_timer_t read_sens_timer;
void ICACHE_FLASH_ATTR read_sens_timer_cb(void *arg);

#endif
