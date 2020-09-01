#ifndef NETWORK_H
#define NETWORK_H
#include <c_types.h>

#define MAX_CONN 2
#define TCP_CONN_TIMEOUT 60 // seconds
// Send buffer size
#define MAX_TXBUFFER 1512
//#define MAX_TXBUFFER 100
#define MAX_DISCONNECTIONS 2

extern char * pTXdata;
extern unsigned short TXdatalen;

extern uint8_t nMQTTPublishFailed;

void ICACHE_FLASH_ATTR wifi_init();
void ICACHE_FLASH_ATTR user_scan(void);
void ICACHE_FLASH_ATTR scan_done(void *arg, STATUS status);

void ICACHE_FLASH_ATTR start_scanAPs_timer();
void ICACHE_FLASH_ATTR setWIFImode(uint8 opmode);
char * ICACHE_FLASH_ATTR wifi_opmode_desc(uint8 opmode);

typedef enum {
    MSG_INVALID,
    MSG_CRITICAL_ERR,
    MSG_TEMP,
    MSG_TEMP_HUMI,
    MSG_STATUS,
    MSG_BUTTON,
    MSG_POW,
    MSG_DC_VOLTAGE,
    MSG_POW_DDS238_2,
    MSG_HOUSE_POW_METER_TX,
    MSG_HOUSE_POW_METER_RX,
    MSG_TBD2
} sendmessage_t;

#endif
