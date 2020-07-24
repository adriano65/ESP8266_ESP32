//#include "ets_sys.h"
#include <osapi.h>
#include <c_types.h>
#include <gpio.h>

#include "crc16.h"
#include "gpio16.h"
#include "pktbuf.h"
#include "mqtt_msg.h"
#include "mqtt.h"
#include "config.h"
#include "cmd.h"

#define CMD_DBG

#ifdef CMD_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif

extern MQTT_Client mqttClient;

void(* resetFunction) (void) = 0;

void ICACHE_FLASH_ATTR cmdParser(char *pBuf, unsigned short len, char * pTXdata, int *TXdatalen) {
	switch(pBuf[0]) {
		case 'C':
			C_cmd_interpreter(pBuf[1], pTXdata, TXdatalen);
			break;

		case 'O':
			O_cmd_interpreter(pBuf[1], pTXdata, TXdatalen);
			break;

		case 'T':
			T_cmd_interpreter(pBuf[1], pTXdata, TXdatalen);
			break;

		case 'F':
			F_cmd_interpreter(pBuf[1], pTXdata, TXdatalen);
			break;

		case 'S':
			S_cmd_interpreter(pBuf[1], pTXdata, TXdatalen);
			break;

		case 's':		//Stats
			Stat_cmd(pBuf[1], pTXdata, TXdatalen);
			break;

		case 'R':
		    system_restart();
			//resetFunction();
			break;

		case 'D':	// deep sleep
			D_cmd_interpreter(pBuf, pTXdata, TXdatalen);
			break;

		case 'H':		//Toggle Heart Beat
			//bit_flip(CmdsMask, BIT(3));
			*TXdatalen=os_sprintf(pTXdata, "HeartBeat changed");
			break;
			
		case 'M':
			M_cmd_interpreter(pBuf, pTXdata, TXdatalen);
			break;
			
		case '?':
			*TXdatalen=os_sprintf(pTXdata, "O<n> -> switch On output number n\r\n");
			*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "F<n> -> switch Off output number n\r\n");
			*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "T<n> -> Toggle output\r\n");
			*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "S<n> -> return output status\r\n");
			*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "C -> save Configuration\r\n");
			*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "s -> show Stats\r\n");
			*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "R -> Reset\r\n");
			*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "D<n> -> deep sleep for n seconds\r\n");
			*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "H -> Start/Stop Heartbeat\r\n");
			*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "M -> send MQTT heartbeat\r\n");
			*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, VERSION);
			break;

		case '\r':
			return;
			
		case '\n':
			return;
			
		default:
			*TXdatalen=os_sprintf(pTXdata, "Bad Command");
			break;
		}
	*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "\r\n");
	//iRxBuf=0;
	//checkInputs();

	//if (nTicks==0 && bit_is_set(CmdsMask, 3)) {printf_P(PSTR("HB%03u\n"),nloopCnt++); nTicks++;}
}

void ICACHE_FLASH_ATTR F_cmd_interpreter(char arg, char * pTXdata, int *TXdatalen) {
	switch(arg) {
		case '3':
			set_gpio_mode(6, GPIO_OUTPUT, GPIO_PULLUP);
			gpio_write(6, 0);
			flashConfig.IOPort_bit3=0;
			break;
		default:
			*TXdatalen=os_sprintf(pTXdata, "BAD arg %0u\r\n", arg);
			return;
		}
	*TXdatalen=os_sprintf(pTXdata, "OK\r\n");
	/* TODO save configuration after some seconds */
	// configSave();
}

void ICACHE_FLASH_ATTR O_cmd_interpreter(char arg, char * pTXdata, int *TXdatalen) {
	switch(arg) {
		case '3':
			set_gpio_mode(6, GPIO_OUTPUT, GPIO_PULLUP);
			gpio_write(6, 1);
			flashConfig.IOPort_bit3=1;
			break;
		default:
			*TXdatalen=os_sprintf(pTXdata, "BAD arg %0u\n\r", arg);
			return;
		}
	*TXdatalen=os_sprintf(pTXdata, "OK\r\n");
	/* TODO save configuration after some seconds */
	//configSave();
}

/*
 * - - - BIG FAT WARN!!! - - - 
 * 
 * NEVER EVER USE GPIO_REG_READ !!
 * 
 * 
*/

void ICACHE_FLASH_ATTR T_cmd_interpreter(char arg, char * pTXdata, int *TXdatalen) {
	switch(arg) {
		case '3':
			if (flashConfig.IOPort_bit3) { GPIO_OUTPUT_SET(12, 1); flashConfig.IOPort_bit3=0; }
			else 						 { GPIO_OUTPUT_SET(12, 0); flashConfig.IOPort_bit3=1; }
			break;
		default:
			*TXdatalen=os_sprintf(pTXdata, "BAD arg %0u\n\r", arg);
			return;
		}
	*TXdatalen=os_sprintf(pTXdata, "OK\r\n");
	/* TODO save configuration after some seconds */
	//configSave();
}

void ICACHE_FLASH_ATTR S_cmd_interpreter(char arg, char * pTXdata, int *TXdatalen) {
	switch(arg) {
		case '0':
			*TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.IOPort_bit0==0 ? "0" : "1");
			break;
		case '1':
			*TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.IOPort_bit1==0 ? "0" : "1");
			break;
		case '2':
			*TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.IOPort_bit2==0 ? "0" : "1");
			break;
		case '3':
			*TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.IOPort_bit3==0 ? "0" : "1");
			break;
		case '4':
			*TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.IOPort_bit4==0 ? "0" : "1");
			break;
		case '5':
			*TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.IOPort_bit5==0 ? "0" : "1");
			break;
		case '6':
			*TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.IOPort_bit6==0 ? "0" : "1");
			break;
		case '7':		// Not externally Connected
			*TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.IOPort_bit7==0 ? "0" : "1");
			break;
		default:
			*TXdatalen=os_sprintf(pTXdata, "BAD arg %0u\n\r", arg);
			return;
		}
}

void ICACHE_FLASH_ATTR C_cmd_interpreter(char arg, char * pTXdata, int *TXdatalen) {
	configSave();
	*TXdatalen=os_sprintf(pTXdata, "OK\r\n");
}
	
void ICACHE_FLASH_ATTR D_cmd_interpreter(char * arg, char * pTXdata, int *TXdatalen) {
	//gpio_pin_wakeup_enable(GPIO_ID_PIN(4), GPIO_PIN_INTR_HILEVEL);
	//system_deep_sleep_set_option(4);	// disable rf on wake up
	//system_deep_sleep_set_option(2);	// no radio calibration on wake up
	system_deep_sleep_set_option(1);	// Radio calibration is done after deep-sleep wake up
	system_deep_sleep(atoi(arg+1)*1000000);
	//system_deep_sleep_instant(10000000);	// uSeconds
}

void ICACHE_FLASH_ATTR M_cmd_interpreter(char * arg, char * pTXdata, int *TXdatalen) {
	os_sprintf(pTXdata, "{\"rssi\":%d, \"heap_free\":%d}", wifi_station_get_rssi(), (unsigned int)system_get_free_heap_size());
	MQTT_Connect(&mqttClient);
	MQTT_Publish(&mqttClient, ESP_MQTT_TOPIC, pTXdata, os_strlen(pTXdata), 1, 0);
	*TXdatalen=os_sprintf(pTXdata, "OK\r\n");
}

void ICACHE_FLASH_ATTR Stat_cmd(char arg, char * pTXdata, int *TXdatalen) {
	*TXdatalen=os_sprintf(pTXdata, "flashConfig.IOPort_bit0: %d\r\n",			   flashConfig.IOPort_bit0);
	*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "flashConfig.IOPort_bit1: %d\r\n", flashConfig.IOPort_bit1);
	*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "flashConfig.IOPort_bit2: %1x\r\n", flashConfig.IOPort_bit2);
	*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "flashConfig.IOPort_bit3: %1x\r\n", flashConfig.IOPort_bit3);
	*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "flashConfig.IOPort_bit4: %1x\r\n", flashConfig.IOPort_bit4);
	*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "flashConfig.IOPort_bit5: %1x\r\n", flashConfig.IOPort_bit5);
	*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "flashConfig.IOPort_bit6: %1x\r\n", flashConfig.IOPort_bit6);
	*TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "flashConfig.IOPort_bit7: %1x\r\n", flashConfig.IOPort_bit7);
}