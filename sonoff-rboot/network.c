/*
 * user_main.c: Main entry-point for demonstrating OTA firmware upgrades via TCP/IP (not HTTP).
 *
 * Date: 26/05/2016
 */
#include <ets_sys.h>
#include <osapi.h>
#include <gpio.h>
#include <os_type.h>
#include <ip_addr.h>
#include <mem.h>
#include <espconn.h>

#include "user_interface.h"
#include "tcp_ota.h"
#include "pktbuf.h"
#include "mqtt_msg.h"
#include "mqtt.h"
#include "config.h"
#include "network.h"

//#define NETWORK_DBG

#ifdef NETWORK_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif

extern MQTT_Client mqttClient;

struct ip_info ipi;
WiFiStates wifiState = wifiIsDisconnected;

char pTXdata[MAX_TXBUFFER];
int TXdatalen=0;

// Structure holding the TCP connection information.
LOCAL struct espconn tcp_conn;

// TCP specific protocol structure.
LOCAL esp_tcp tcp_proto;

// The IP address of the last system to send us any data.
LOCAL uint32_t last_addr = 0;

static bool ICACHE_FLASH_ATTR parse_ip(char *buff, ip_addr_t *ip_ptr) {
  char *next = buff; // where to start parsing next integer
  int found = 0;     // number of integers parsed
  uint32_t ip = 0;   // the ip addres parsed
  for (int i=0; i<32; i++) { // 32 is just a safety limit
    char c = buff[i];
    if (c == '.' || c == 0) {
      // parse the preceding integer and accumulate into IP address
      bool last = c == 0;
      buff[i] = 0;
      uint32_t v = atoi(next);
      ip = ip | ((v&0xff)<<(found*8));
      next = buff+i+1; // next integer starts after the '.'
      found++;
      if (last) { // if at end of string we better got 4 integers
        ip_ptr->addr = ip;
        return found == 4;
      }
      continue;
    }
    if (c < '0' || c > '9') return false;
  }
  return false;
}

/* Call-back for changes in the WIFi connection's state. */
static void ICACHE_FLASH_ATTR wifi_event_cb(System_Event_t *event) {
    // To determine what actually happened, we need to look at the event.
    switch (event->event) {
        case EVENT_STAMODE_CONNECTED: {
		  // We are connected as a station, but we don't have an IP address yet.
		  char ssid[33];
		  uint8_t len = event->event_info.connected.ssid_len;
		  if (len > 32) {
			  len = 32;
		  }
		  strncpy(ssid, event->event_info.connected.ssid, len + 1);
		  DBG("EVENT_STAMODE_CONNECTED. SSID = %s, BSSID = "MACSTR", channel = %d.\n",
					ssid, MAC2STR(event->event_info.connected.bssid), event->event_info.connected.channel);
		  set_blink_timer(LED_BLINK_DELAY_STAMODE_CONNECTED);
		  break;
		  }
        case EVENT_STAMODE_DISCONNECTED:
		  wifiState = wifiIsDisconnected;
		  set_blink_timer(LED_BLINK_DELAY_STAMODE_DISCONNECTED);
		  last_addr = 0;
		  MQTT_Disconnect(&mqttClient);
		  break;

        case EVENT_STAMODE_GOT_IP:
			wifiState = wifiGotIP;
            DBG("EVENT_STAMODE_GOT_IP. IP = "IPSTR", mask = "IPSTR", gateway = "IPSTR"\n", 
                      IP2STR(&event->event_info.got_ip.ip.addr), 
                      IP2STR(&event->event_info.got_ip.mask.addr),
                      IP2STR(&event->event_info.got_ip.gw));
			//MQTT_Connect(&mqttClient);
            break;

        case EVENT_STAMODE_DHCP_TIMEOUT:
            // We couldn't get an IP address via DHCP, so we'll have to try re-connecting.
            DBG("EVENT_STAMODE_DHCP_TIMEOUT.\n");
            wifi_station_disconnect();
            wifi_station_connect();
            set_blink_timer(LED_BLINK_DELAY_DHCP_TIMEOUT);
            break;
			
        default:
		  DBG("????\n");
		  break;
    }
}

/* Handles the receiving of information */
LOCAL void ICACHE_FLASH_ATTR TCPReceiveCb(void *arg, char *RXdata, unsigned short RXdatalen) {
    struct espconn *conn = (struct espconn *)arg;
	
	if (conn == NULL) return;
	
	//DBG("RXdata[0] %d, RXdatalen %d\n", RXdata[0], RXdatalen);
	os_memset(pTXdata, 0, MAX_TXBUFFER);
	cmdParser(RXdata, RXdatalen, pTXdata, &TXdatalen);
    //os_printf("%s\n", pTXdata);
	espconn_sent(conn, pTXdata, TXdatalen);
}

/* Call-back for when an incoming TCP connection has been established */
LOCAL void ICACHE_FLASH_ATTR tcp_connect_cb(void *arg) {
    struct espconn *conn = (struct espconn *)arg;
    DBG("TCP connection received from "IPSTR":%d to local port %d\n", IP2STR(conn->proto.tcp->remote_ip), conn->proto.tcp->remote_port, conn->proto.tcp->local_port);
    espconn_regist_recvcb(conn, TCPReceiveCb);
	espconn_set_opt(conn, ESPCONN_REUSEADDR|ESPCONN_NODELAY);
}

/* Sets up the WiFi interface on the ESP-8266. */
void ICACHE_FLASH_ATTR wifi_init() {
    // Set station mode - we will talk to a WiFi router.
    wifi_set_opmode_current(STATION_MODE);

    // Set up the network name and password.
    struct station_config sc;
    strncpy(sc.ssid, WIFI_SSID, 32);
    strncpy(sc.password, WIFI_PASSWD, 64);
    wifi_station_set_config(&sc);
	
    #if defined(USE_DHCP)
    wifi_station_dhcpc_start();
	#else
    //static network config!
    wifi_station_dhcpc_stop();
	parse_ip(ESP_IPADDRESS, &ipi.ip);
    parse_ip(ESP_NETMASK, &ipi.netmask);
    parse_ip(ESP_GATEWAY, &ipi.gw);
	
    //ipi.gw.addr = flashConfig.gateway;
    wifi_set_ip_info(0, &ipi);
	#endif
    //DBG("Wifi uses IP %s, netmask %s, gw %s\n", ESP_IPADDRESS, ESP_NETMASK, ESP_GATEWAY);
	
    // Set up the call back for the status of the WiFi.
	//void wifi_set_event_handler_cb(wifi_event_handler_cb_t cb);
    wifi_set_event_handler_cb(wifi_event_cb);

	os_memset(&tcp_proto, 0, sizeof(tcp_proto));
    tcp_conn.type = ESPCONN_TCP;
    tcp_conn.state = ESPCONN_NONE;
    tcp_proto.local_port = 23;
    tcp_conn.proto.tcp = &tcp_proto;
	
    espconn_regist_connectcb(&tcp_conn, tcp_connect_cb);
    espconn_accept(&tcp_conn);
	espconn_tcp_set_max_con_allow(&tcp_conn, MAX_CONN);	
	espconn_regist_time(&tcp_conn, TCP_CONN_TIMEOUT, 0);
}
