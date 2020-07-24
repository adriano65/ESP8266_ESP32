/*
 * OTA firmware upgrades via TCP/IP (not HTTP).
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
#include "mqtt.h"
#include "config.h"
#include "blinkled.h"
#include "network.h"

#define NETWORK_DBG

#ifdef NETWORK_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif

extern MQTT_Client mqttClient;

char * pTXdata;
unsigned short TXdatalen=0;
int nMaxDisconnections=MAX_DISCONNECTIONS;
uint8_t nMQTTPublishFailed=0;

// Structure holding the TCP connection information.
struct espconn tcp_conn;
// TCP specific protocol structure.
esp_tcp tcp_proto;

char * ICACHE_FLASH_ATTR wifi_opmode_desc(uint8 opmode) {
  switch (opmode) {
	case STATION_MODE:
	  return "STATION_MODE";
	case SOFTAP_MODE:
	  return "SOFTAP_MODE";
	case STATIONAP_MODE:
	  return "STATIONAP_MODE";
	}
  return "";
}

void ICACHE_FLASH_ATTR scan_done(void *arg, STATUS status) {
  if (status == OK)  {
    struct bss_info *bss_link = (struct bss_info *)arg;
  
    while (bss_link != NULL) {
      DBG("(%d,\"%s\",%d,\""MACSTR"\",%d)", bss_link->authmode, bss_link->ssid, bss_link->rssi, MAC2STR(bss_link->bssid),bss_link->channel);
			// did we find a suitable access point ?
			if (!strcmp(bss_link->ssid, flashConfig.stat_conf.ssid) ) {
				DBG("Changing from SoftAP mode to station mode...");
				setWIFImode(STATION_MODE);
				return;
				}
      bss_link = bss_link->next.stqe_next;
	  	}
	}
  else {
     DBG("Scan failed!");
	}
}

#define user_procTaskPrio        0
#define user_procTaskQueueLen    1
os_event_t user_procTaskQueue[user_procTaskQueueLen];

static void ICACHE_FLASH_ATTR loop(os_event_t *events) {
	//wifi_station_set_config(&flashConfig.apconf);
    system_os_post(user_procTaskPrio, 0, 0 );
}

void ICACHE_FLASH_ATTR setWIFImode(uint8 opmode) {

	wifi_station_set_hostname(flashConfig.hostname);  
	switch (opmode) {
		case STATIONAP_MODE:
			wifi_station_disconnect();
			wifi_station_set_auto_connect(0);		//will be set to 1 after first successful connection
			
			wifi_set_opmode_current(STATIONAP_MODE);
			#if 1
			wifi_softap_get_config(&flashConfig.apconf);
			LoadDefaultAPConfig();
			wifi_softap_set_config_current(&flashConfig.apconf);
			#else
			wifi_softap_dhcps_stop();
			wifi_set_ip_info(SOFTAP_IF, &flashConfig.ip1);
			wifi_softap_dhcps_start();  
			system_os_task(loop, user_procTaskPrio,user_procTaskQueue, user_procTaskQueueLen);
			system_os_post(user_procTaskPrio, 0, 0 );
			#endif
			break;

		case STATION_MODE:
			//wifi_station_disconnect();
			wifi_softap_dhcps_stop();
			wifi_set_opmode_current(STATION_MODE);
			wifi_station_set_config_current(&flashConfig.stat_conf);		// NOT save configuration in flash
			
			#if defined(USE_DHCP)
			wifi_station_dhcpc_start();
			#else
			//static network config!
			wifi_station_dhcpc_stop();
			wifi_set_ip_info(STATION_IF, &flashConfig.ip0);
			
			#endif
			wifi_station_connect();
			break;

		default:
			DBG("Unknown mode %d", opmode);
			break;
		}
}

/* Call-back for changes in the WIFi connection's state. */
static void ICACHE_FLASH_ATTR wifi_event_cb(System_Event_t *event) {
  switch (event->event) {
		case EVENT_STAMODE_CONNECTED:
			DBG("EVENT_STAMODE_CONNECTED");
			set_blink_timer_delay(LED_BLINK_STAMODE_CONNECTED, 2);
			nMaxDisconnections=MAX_DISCONNECTIONS;
			mqtt_client_init();
			break;
			/*
		case EVENT_STAMODE_CONNECTED: {
			char ssid[33];
			uint8_t len = event->event_info.connected.ssid_len;
			if (len > 32) len = 32;
			
			strncpy(ssid, event->event_info.connected.ssid, len + 1);
			DBG("EVENT_STAMODE_CONNECTED. SSID = %s, BSSID = "MACSTR", channel = %d", ssid, MAC2STR(event->event_info.connected.bssid), event->event_info.connected.channel);
			set_blink_timer(LED_BLINK_STAMODE_CONNECTED);
			break;
			}
			*/
			
		case EVENT_STAMODE_GOT_IP:
			DBG("EVENT_STAMODE_GOT_IP");
			//	DBG("EVENT_STAMODE_GOT_IP. IP = "IPSTR", mask = "IPSTR", gateway = "IPSTR, IP2STR(&event->event_info.got_ip.ip.addr), IP2STR(&event->event_info.got_ip.mask.addr), IP2STR(&event->event_info.got_ip.gw));
			//	set_blink_timer_delay(LED_BLINK_STAMODE_GOT_IP, 1);
			break;

		case EVENT_STAMODE_DISCONNECTED:
			// reference
			// wifi_station_get_connect_status() == STATION_WRONG_PASSWORD
			DBG("EVENT_STAMODE_DISCONNECTED");
			set_blink_timer_delay(LED_BLINK_STAMODE_DISCONNECTED, 1);
			//MQTT_Disconnect(&mqttClient);
			
			if (!(nMaxDisconnections--)) {
				Event_StaMode_Disconnected_t *ev = (Event_StaMode_Disconnected_t *)&event->event_info;
				if(ev != NULL) {
					//     on_station_disconnect(ev->reason);			   
					DBG("%s connect failed -> reason %d. Going to STATIONAP mode %s ...", flashConfig.stat_conf.ssid, ev->reason, flashConfig.apconf.ssid);
					}
				set_blink_timer_delay(LED_BLINK_SOFTAPMODE, 3);
				setWIFImode(STATIONAP_MODE);
				}
			break;

		case EVENT_STAMODE_DHCP_TIMEOUT:
			// We couldn't get an IP address via DHCP, so we'll have to try re-connecting.
			DBG("EVENT_STAMODE_DHCP_TIMEOUT.");
			wifi_station_disconnect();
			wifi_station_connect();
			break;
			
		case EVENT_SOFTAPMODE_STACONNECTED:
			DBG("EVENT_STAMODE_DHCP_TIMEOUT.");
			set_blink_timer_delay(LED_BLINK_SOFTAPMODE_STACONNECTED, 1);
			break;
			
		case EVENT_SOFTAPMODE_STADISCONNECTED:
			DBG("EVENT_SOFTAPMODE_STADISCONNECTED.");
			set_blink_timer_delay(LED_BLINK_SOFTAPMODE_STADISCONNECTED, 1);
			break;
			
		case EVENT_SOFTAPMODE_PROBEREQRECVED:
			DBG("PROBE REQ.");
			break;
			
		default:
			DBG("Unexpected case %d", event->event);
			set_blink_timer_delay(LED_BLINK_SOFTAPMODE_STADISCONNECTED, 3);
    }
}

/* Handles the receiving of information */
LOCAL void ICACHE_FLASH_ATTR TCPReceiveCb(void *conn, char *pRXdata, unsigned short RXdatalen) {
    struct espconn * pCon = (struct espconn *)conn;
	
	if (pCon == NULL) return;
	pRXdata[RXdatalen-2]='\0';
	
	cmdParser(pRXdata, RXdatalen);
    os_printf("%s\r\n", pTXdata);
	espconn_sent(pCon, pTXdata, TXdatalen);
}

/* Call-back for when an incoming TCP connection has been established */
LOCAL void ICACHE_FLASH_ATTR tcp_connect_cb(void *arg) {
    struct espconn * pCon = (struct espconn *)arg;
    os_printf("TCP connection received from "IPSTR":%d to local port %d\n", IP2STR(pCon->proto.tcp->remote_ip), pCon->proto.tcp->remote_port, pCon->proto.tcp->local_port);
    espconn_regist_recvcb(pCon, TCPReceiveCb);
	espconn_set_opt(pCon, ESPCONN_REUSEADDR|ESPCONN_NODELAY);
}

void ICACHE_FLASH_ATTR wifi_init(void) {
  #if defined(MAINS)
  // range 0 - 82 --> units is 0.25 dBm step
  //system_phy_set_max_tpw(10); //less than 1 meter
  system_phy_set_max_tpw(40); //less than 1 meter
  //system_phy_set_max_tpw(60);
  #else
  system_phy_set_max_tpw(80);
  #endif
  
  pTXdata = (char *)os_zalloc(MAX_TXBUFFER);  
  //if (pTXdata)
  
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

  setWIFImode(STATION_MODE);
  
}
