/*
 * tcp_ota.h: Over The Air (OTA) firmware upgrade via direct TCP/IP connection.
 *
 */

#ifndef TCP_OTA_H
#define TCP_OTA_H

// The TCP port used to listen to for connections.
#define OTA_PORT 65056

// The number of bytes to use for the OTA message buffer (NOT the firmware buffer).
#define OTA_BUFFER_LEN 32

// Type used to define the possible status values of OTA upgrades.
typedef enum {
    NOT_STARTED,
    CONNECTION_ESTABLISHED,
    RECEIVING_HEADER,
    RECEIVING_FIRMWARE,
    REBOOTING,
    ERROR
} ota_state_t;

/* Initialises the required connection information to listen for OTA messages.
 * WiFi must first have been set up for this to succeed.
 */
void ICACHE_FLASH_ATTR ota_init();

#endif
