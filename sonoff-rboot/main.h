//////////////////////////////////////////////////
// rBoot sample project.
// Copyright 2015 Richard A Burton
// richardaburton@gmail.com
// See license.txt for license terms.
//////////////////////////////////////////////////

#ifndef __MAIN_H__
#define __MAIN_H__

// values will be passed in from the Makefile
#ifndef WIFI_SSID
#define WIFI_SSID "ssid"
#endif
#ifndef WIFI_PWD
#define WIFI_PWD "password"
#endif

void ICACHE_FLASH_ATTR button_timer_cb(uint16_t interval);
void ICACHE_FLASH_ATTR start_blink_timer(uint16_t interval);
void ICACHE_FLASH_ATTR blink_timer_cb(uint16_t interval);

#endif
