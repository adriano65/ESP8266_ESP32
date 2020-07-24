#ifndef NETWORK_H
#define NETWORK_H

#define MAX_CONN 2
#define TCP_CONN_TIMEOUT 60 // seconds
// Send buffer size
#define MAX_TXBUFFER 1460

typedef enum { 
  wifiIsDisconnected, 
  wifiIsConnected, 
  wifiGotIP }
WiFiStates;

void ICACHE_FLASH_ATTR wifiStateChangeCb(WiFiStates status);
void ICACHE_FLASH_ATTR wifi_init();

extern WiFiStates wifiState;

#endif
