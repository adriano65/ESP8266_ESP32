/*
 * tcp_ota.h: Over The Air (OTA) firmware upgrade via direct TCP/IP connection.
 *
 */

#ifndef TCP_OTA_H
#define TCP_OTA_H

/*
 * Initialises the required connection information to listen for OTA messages.
 * WiFi must first have been set up for this to succeed.
 */

#define ROM0 	UPGRADE_FW_BIN1
#define ROM1 	UPGRADE_FW_BIN2

void ICACHE_FLASH_ATTR ota_init();

#define LED_BLINK_DELAY_INIT					700
#define LED_BLINK_DELAY_STAMODE_CONNECTED		200
#define LED_BLINK_DELAY_STAMODE_DISCONNECTED	2000
#define LED_BLINK_DELAY_DHCP_TIMEOUT			1200

#endif
