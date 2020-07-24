//////////////////////////////////////////////////
// Simple NTP client for ESP8266.
// Copyright 2015 Richard A Burton
// richardaburton@gmail.com
// See license.txt for license terms.
//////////////////////////////////////////////////

#ifndef __NTP_H__
#define __NTP_H__
#include <c_types.h>

#define NTP_TIMEOUT_MS 5000

typedef struct {
	uint8 options;
	uint8 stratum;
	uint8 poll;
	uint8 precision;
	uint32 root_delay;
	uint32 root_disp;
	uint32 ref_id;
	uint8 ref_time[8];
	uint8 orig_time[8];
	uint8 recv_time[8];
	uint8 trans_time[8];
} ntp_t;

void ICACHE_FLASH_ATTR ntp_get_time();

#define NTP_DELAY_MS (uint16_t)120000

void rtcCount();
void ICACHE_FLASH_ATTR hw_timer_init();
void ICACHE_FLASH_ATTR hw_timer_stop();
void ICACHE_FLASH_ATTR RTC_Reset();

// NOT WORKING !!
//#define RSR_CCOUNT(r)     __asm__ __volatile__("rsr %0,ccount":"=a" (r))

extern struct tm *tm_rtc;
extern struct tm *tm_uptime;

extern uint32_t uptime_ticks;

#endif