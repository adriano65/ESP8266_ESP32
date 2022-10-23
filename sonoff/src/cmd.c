//#include "ets_sys.h"
#include <osapi.h>
#include <c_types.h>
#include <gpio.h>
#include <time.h>
#include <mem.h>

#include "mqtt.h"
#include "mqtt_client.h"
#include "gpio16.h"
#include "uart.h"
#include "network.h"
#include "config.h"
#include "../rtc_ntp/ntp.h"

#if defined(MAINS_VMC) || defined(SONOFFDUAL)
//#include "ccs811.h"
//extern ccs811_sensor_t * ccs811_sensor;
#include "ina226.h"
#endif

#include "../hlw8012/hlw8012.h"

#include "cmd.h"

#define CMD_DBG

#ifdef CMD_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif

//void(* resetFunction) (void) = 0;

void ICACHE_FLASH_ATTR cmdParser(char *pInBuf, unsigned short InBufLen) {
	os_memset(pTXdata, 0, MAX_TXBUFFER);
	TXdatalen=0;
	switch(pInBuf[0]) {
		case 'a':
			a_cmd_interpreter(&pInBuf[2]);
			break;
			
		case 'C':
			C_cmd_interpreter(pInBuf[1]);
			break;

		case 'c':
			c_cmd_interpreter(pInBuf[1]);
			break;

		#if defined(MAINS)
		case 'D':	// deep sleep
			D_cmd_interpreter(&pInBuf[2]);
			break;
		#endif
			
		#if defined(GASINJECTORCLEANER)
		case 'd':	// duty cycle
			//TXdatalen=os_sprintf(pTXdata, "duty cycle");
			d_cmd_interpreter(&pInBuf[2]);
			break;
		#endif
			
		case 'F':
			F_cmd_interpreter(pInBuf[1]);
			break;

		case 'H':
			//bit_flip(CmdsMask, BIT(3));
			TXdatalen=os_sprintf(pTXdata, "HeartBeat changed");
			break;
			
		#if defined(GASINJECTORCLEANER)
		case 'i':
			//TXdatalen=os_sprintf(pTXdata, "interval");
			i_cmd_interpreter(&pInBuf[2]);
			break;
		#endif

    #if defined(SONOFFPOW_DDS238_2)
		case 'I':
			I_cmd_interpreter(pInBuf[1]);
			break;
    #endif

		case 'm':
			m_cmd_interpreter(pInBuf);
			break;
			
		case 'O':
			O_cmd_interpreter(pInBuf[1]);
			break;

		#if defined(SONOFFPOW)
		case 'p':
			power_cmd_parser(pInBuf);
			break;
		#endif
			
		case 'P':
			P_cmd_interpreter(pInBuf[1]);
			break;

		case 'S':
			S_cmd_interpreter(pInBuf[1]);
			break;

		case 's':
			Stat_cmd(pInBuf[1]);
			break;

		case 't':
			t_cmd_interpreter(&pInBuf[2]);
			break;
			
		case 'T':
			T_cmd_interpreter(pInBuf[1]);
			break;

		case 'R':
			/*
			reset causes:
				0: 
				1: normal boot
				2: reset pin
				3: software reset
				4: watchdog reset

			boot device:
				0:
				1: ram
				3: flash
			*/
		  system_restart();
      // following is unuseful :-)
			//TXdatalen=os_sprintf(pTXdata, "Restarting...");
			break;

		case 'w':
			w_cmd_interpreter(&pInBuf[2]);
			break;
			
    #if defined(HOUSE_POW_METER_TX) || defined(SONOFFPOW_DDS238_2)
		case 'x':
			x_cmd_interpreter(&pInBuf[2]);
			break;
    #endif

		case '?':
			TXdatalen=os_sprintf(pTXdata, "\n%s %s %s\n", PROJ_NAME, VERSION, BINDATE);
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "C -> save Configuration\r\n");
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "F<n> -> switch Off output number n\r\n");
			#if defined(SONOFFPOW_DDS238_2)
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "I<0,1> -> Input Button Enable\r\n");
			#endif
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "O<n> -> switch On output number n\r\n");
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "T<n> -> Toggle output\r\n");
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "P<n> <ms> -> Pulse output\r\n");
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "S<n> -> return output status\r\n");
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "t -> generic test cmd\r\n");
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "s -> show Stats\r\n");
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "c -> load default conf\r\n");
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "R -> Reset\r\n");
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "m -> send status via MQTT\r\n");
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "w <ssid,passwd> -> set access point\r\n");
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "a <essid,passwd> -> set AP param\r\n");
			#if defined(SONOFFPOW)
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "p -> show power (p1 change to volt/amp)\r\n");
			#endif
			#if defined(MAINS)			
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "D <n> -> deep sleep for n seconds\r\n");
			#endif
      #if defined(HOUSE_POW_METER_TX) || defined(SONOFFPOW_DDS238_2)
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "x <ip> -> Power Meter RX Address\r\n");
			#endif
      #if defined(GASINJECTORCLEANER)
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "d <divisor> -> dutycyle divisor (%u)\r\n", flashConfig.dutycycle);
			TXdatalen+=os_sprintf(pTXdata+TXdatalen, "i <interval> -> total ms period (%u)\r\n", flashConfig.interval);
			#endif
			break;

		case '\r':
		case '\n':
			break;
			
		default:
			TXdatalen=os_sprintf(pTXdata, "Bad Command");
			break;
		}
	TXdatalen+=os_sprintf(pTXdata+TXdatalen, "\r\n\0");
	//iRxBuf=0;
	//checkInputs();

	//if (nTicks==0 && bit_is_set(CmdsMask, 3)) {printf_P(PSTR("HB%03u\n"),nloopCnt++); nTicks++;}
}

void ICACHE_FLASH_ATTR F_cmd_interpreter(char arg) {
	switch(arg) {
	  #if defined(MAINS)
	  case '0':
		  gpio_write(GPIO_3, 0);
		  flashConfig.map1.IOPort.bit0=0;
		  break;
	  case '1':
		  gpio_write(GPIO_4, 0);
		  flashConfig.map1.IOPort.bit1=0;
		  break;
	  case '2':
		  gpio_write(GPIO_14, 0);
		  flashConfig.map1.IOPort.bit2=0;
		  break;
	  case '3':
		  gpio_write(GPIO_12, 1);
		  flashConfig.map1.IOPort.bit3=0;
		  break;
	  #else
			#if defined(ARMTRONIX)
			case '0':
				gpio_write(GPIO_4, 0);
				flashConfig.map1.IOPort.bit0=0;
				break;
			case '1':
				gpio_write(GPIO_12, 0);
				flashConfig.map1.IOPort.bit1=0;
				break;
			case '2':
				gpio_write(GPIO_13, 0);
				flashConfig.map1.IOPort.bit2=0;
				break;
			case '3':
				gpio_write(GPIO_14, 0);
				flashConfig.map1.IOPort.bit3=0;
				break;			
			#else
				#if defined(SONOFFDUAL)
				case '0':
					gpio_write(GPIO_12, 0);
					flashConfig.map1.IOPort.bit0=0;
					break;
				case '1':
					gpio_write(GPIO_5, 0);
					flashConfig.map1.IOPort.bit1=0;
					break;
				#else
			case '3':
				gpio_write(GPIO_12, 0);
				flashConfig.map1.IOPort.bit3=0;
				break;
			#endif
		#endif
	  #endif

	  #if defined(MAINS)
	  case '4':
		  gpio_write(GPIO_13, 0);
		  flashConfig.map1.IOPort.bit4=0;
		  break;
	  case '5':
		  gpio_write(GPIO_0, 0);
		  flashConfig.map1.IOPort.bit5=0;
		  break;
	  case '6':
		  gpio_write(GPIO_1, 0);
		  flashConfig.map1.IOPort.bit6=0;
		  break;
	  case '7':		// Not externally Connected
		  gpio_write(GPIO_5, 0);
		  flashConfig.map1.IOPort.bit7=0;
		  break;
	  #endif
	  default:
		  TXdatalen=os_sprintf(pTXdata, "BAD arg %0u\r\n", arg);
		  return;
	  }
	TXdatalen=os_sprintf(pTXdata, "OK\r\n");
}

#if defined(SONOFFPOW_DDS238_2)
void ICACHE_FLASH_ATTR I_cmd_interpreter(char arg) {
	switch(arg) {
	  case '?':
		  TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.map2.Enable.doorBell ? "1" : "0");
		  break;
	  case '0':
		  flashConfig.map2.Enable.doorBell=0;
		  break;
	  case '1':
		  flashConfig.map2.Enable.doorBell=1;
		  break;
	  default:
		  TXdatalen=os_sprintf(pTXdata, "BAD arg %0u\r\n", arg);
		  return;
	  }
	TXdatalen=os_sprintf(pTXdata, "OK");
}
#endif

void ICACHE_FLASH_ATTR O_cmd_interpreter(char arg) {
	switch(arg) {
		#if defined(MAINS)
		case '0':
			gpio_write(GPIO_3, 1);
			flashConfig.map1.IOPort.bit0=1;
			break;
		case '1':
			gpio_write(GPIO_4, 1);
			flashConfig.map1.IOPort.bit1=1;
			break;
		case '2':
			gpio_write(GPIO_14, 1);
			flashConfig.map1.IOPort.bit2=1;
			break;
		case '3':
			gpio_write(GPIO_12, 0);
			flashConfig.map1.IOPort.bit3=1;
			break;
		#else
			#if defined(ARMTRONIX)
			case '0':
				gpio_write(GPIO_4, 1);
				flashConfig.map1.IOPort.bit0=1;
				break;
			case '1':
				gpio_write(GPIO_12, 1);
				flashConfig.map1.IOPort.bit1=1;
				break;
			case '2':
				gpio_write(GPIO_13, 1);
				flashConfig.map1.IOPort.bit2=1;
				break;
			case '3':
				gpio_write(GPIO_14, 1);
				flashConfig.map1.IOPort.bit3=1;
				break;			
			#else
				#if defined(SONOFFDUAL)
				case '0':
					gpio_write(GPIO_12, 1);
					flashConfig.map1.IOPort.bit0=1;
					break;
				case '1':
					gpio_write(GPIO_5, 1);
					flashConfig.map1.IOPort.bit1=1;
					break;
				#else
				case '3':
					gpio_write(GPIO_12, 1);
					flashConfig.map1.IOPort.bit3=1;
					break;
				#endif
			#endif
		#endif
			
		#if defined(MAINS)
		case '4':
			gpio_write(GPIO_13, 1);
			flashConfig.map1.IOPort.bit4=1;
			break;
		case '5':
			gpio_write(GPIO_0, 1);
			flashConfig.map1.IOPort.bit5=1;
			break;
		case '6':
		  #if !defined(USE_TXD0)
			gpio_write(GPIO_1, 1);
			flashConfig.map1.IOPort.bit6=1;
      #endif
			break;
		case '7':		// Not externally Connected
			gpio_write(GPIO_5, 1);
			flashConfig.map1.IOPort.bit7=1;
			break;
		#endif
		default:
			TXdatalen=os_sprintf(pTXdata, "BAD arg %0u\r\n", arg);
			return;
		}
	TXdatalen=os_sprintf(pTXdata, "OK\r\n");
}

void ICACHE_FLASH_ATTR P_cmd_interpreter(char arg) {
	switch(arg) {
		#if defined(MAINS)
		case '7':		// Not externally Connected
			gpio_write(GPIO_5, 1);
			msleep(200);	// OK
			//msleep(350);	// OK
			//msleep(550);	// NOT OK
			gpio_write(GPIO_5, 0);
			break;
		#endif
		default:
			TXdatalen=os_sprintf(pTXdata, "BAD arg %0u\r\n", arg);
			return;
		}
	TXdatalen=os_sprintf(pTXdata, "OK\r\n");
}

#if defined(HOUSE_POW_METER_TX) || defined(SONOFFPOW_DDS238_2)
void ICACHE_FLASH_ATTR x_cmd_interpreter(char * pInbuf) {
  //char *tmpbuff;  
  //tmpbuff=(char *)os_malloc(100);
  //tmpbuff=(char *)strsep(&pInbuf, ".");
  //os_sprintf(flashConfig.apconf.ssid, tmpbuff);
  TXdatalen=os_sprintf(pTXdata, "pInbuf: %s\r\n", pInbuf);
  parse_ip(pInbuf, &flashConfig.HPRx_IP);
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "HPRx_IP: "IPSTR"\r\n", IP2STR(&flashConfig.HPRx_IP));
	TXdatalen+=os_sprintf(pTXdata+TXdatalen, "OK\r\n");
}
#endif

void ICACHE_FLASH_ATTR RefreshIO(void) {
#if defined(REFRESHIO)
	#warning THIS IS A WORK-AROUND FOR POWER SUPPLY OR EMI PROBLEMS

	#if defined(SONOFFTH10)
		if (flashConfig.map1.IOPort.bit3==1) {
			gpio_write(GPIO_12, 1);
			}
	#endif

	#if defined(ARMTRONIX)
		if (flashConfig.map1.IOPort.bit0==1) {
			gpio_write(GPIO_4, 1);
			}
		if (flashConfig.map1.IOPort.bit1==1) {
			gpio_write(GPIO_12, 1);
			}
		if (flashConfig.map1.IOPort.bit2==1) {
			gpio_write(GPIO_13, 1);
			}
		if (flashConfig.map1.IOPort.bit3==1) {
			gpio_write(GPIO_14, 1);
			}
		#warning "ARMTRONIX defined!"
	#endif

	#if defined(MAINS)
		#if !defined(USE_TXD0)
		if (flashConfig.map1.IOPort.bit0==1) {
			gpio_write(GPIO_3, 1);
			}
		#endif
		if (flashConfig.map1.IOPort.bit1==1) {
			gpio_write(GPIO_4, 1);
			}
		if (flashConfig.map1.IOPort.bit2==1) {
			gpio_write(GPIO_14, 1);
			}
		if (flashConfig.map1.IOPort.bit3==1) {
			gpio_write(GPIO_12, 1);
			}
		if (flashConfig.map1.IOPort.bit4==1) {
			gpio_write(GPIO_13, 1);
			}
		if (flashConfig.map1.IOPort.bit5==1) {
			gpio_write(GPIO_0, 1);
			}
		#if !defined(USE_TXD0)
		if (flashConfig.map1.IOPort.bit6==1) {
			gpio_write(GPIO_1, 1);
			}
		#endif
		if (flashConfig.map1.IOPort.bit7==1) {
			gpio_write(GPIO_5, 1);
			}
		#warning "MAINS defined!"
	#endif
#endif
}

/* - - - BIG FAT WARN!!! - - -  
 * NEVER EVER USE GPIO_REG_READ !! */

void ICACHE_FLASH_ATTR T_cmd_interpreter(char arg) {
	switch(arg) {
	  #if defined(MAINS) || defined(ARMTRONIX)
	  case '0':
			if (flashConfig.map1.IOPort.bit0) { gpio_write(GPIO_3, 0); flashConfig.map1.IOPort.bit0=0; }
			else 						 { gpio_write(GPIO_3, 1); flashConfig.map1.IOPort.bit0=1; }
			break;
	  case '1':
		  if (flashConfig.map1.IOPort.bit1) { gpio_write(GPIO_4, 0); flashConfig.map1.IOPort.bit1=0; }
		  else 						 { gpio_write(GPIO_4, 1); flashConfig.map1.IOPort.bit1=1; }
		  break;
	  case '2':
		  if (flashConfig.map1.IOPort.bit2) { gpio_write(GPIO_14, 0); flashConfig.map1.IOPort.bit2=0; }
		  else 						 { gpio_write(GPIO_14, 1); flashConfig.map1.IOPort.bit2=1; }
		  break;
	  case '3':
		  if (flashConfig.map1.IOPort.bit3) { gpio_write(GPIO_12, 1); flashConfig.map1.IOPort.bit3=0; }
		  else 						 { gpio_write(GPIO_12, 0); flashConfig.map1.IOPort.bit3=1; }
		  break;
	  #else
	  case '3':
		  if (flashConfig.map1.IOPort.bit3) { gpio_write(GPIO_12, 0); flashConfig.map1.IOPort.bit3=0; }
		  else 						 { gpio_write(GPIO_12, 1); flashConfig.map1.IOPort.bit3=1; }
		  break;
	  #endif
	  #if defined(MAINS)
	  case '4':
		  if (flashConfig.map1.IOPort.bit4) { gpio_write(GPIO_13, 0); flashConfig.map1.IOPort.bit4=0; }
		  else 						 { gpio_write(GPIO_13, 1); flashConfig.map1.IOPort.bit4=1; }
		  break;
	  case '5':
		  if (flashConfig.map1.IOPort.bit5) { gpio_write(3, 0); flashConfig.map1.IOPort.bit5=0; }
		  else 						 { gpio_write(3, 1); flashConfig.map1.IOPort.bit5=1; }
		  break;
	  case '6':
		  if (flashConfig.map1.IOPort.bit6) { gpio_write(GPIO_1, 0); flashConfig.map1.IOPort.bit6=0; }
		  else 						 { gpio_write(GPIO_1, 1); flashConfig.map1.IOPort.bit6=1; }
		  break;
	  case '7':		// Not externally Connected
		  if (flashConfig.map1.IOPort.bit7) { gpio_write(GPIO_5, 0); flashConfig.map1.IOPort.bit7=0; }
		  else 						 { gpio_write(GPIO_5, 1); flashConfig.map1.IOPort.bit7=1; }
		  break;
	  #endif
	  default:
		  TXdatalen=os_sprintf(pTXdata, "BAD arg %0u\n\r", arg);
		  return;
	  }
	TXdatalen=os_sprintf(pTXdata, "OK\r\n");
}

void ICACHE_FLASH_ATTR S_cmd_interpreter(char arg) {
	switch(arg) {
	  #if defined(MAINS) || defined(ARMTRONIX)
	  case '0':
		  TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.map1.IOPort.bit0==0 ? "0" : "1");
		  break;
	  case '1':
		  TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.map1.IOPort.bit1==0 ? "0" : "1");
		  break;
	  case '2':
		  TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.map1.IOPort.bit2==0 ? "0" : "1");
		  break;
	  #endif

	  case '3':
		  TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.map1.IOPort.bit3==0 ? "0" : "1");
		  break;
	  #if defined(MAINS)
	  case '4':
		  TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.map1.IOPort.bit4==0 ? "0" : "1");
		  break;
	  case '5':
		  TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.map1.IOPort.bit5==0 ? "0" : "1");
		  break;
	  case '6':
		  TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.map1.IOPort.bit6==0 ? "0" : "1");
		  break;
	  case '7':		// Not externally Connected
		  TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.map1.IOPort.bit7==0 ? "0" : "1");
		  break;
	  #endif

	  #if defined(SONOFFDUAL)
	  case '0':
		  TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.map1.IOPort.bit0==0 ? "0" : "1");
		  break;
	  case '1':
		  TXdatalen=os_sprintf(pTXdata, "%s\r\n", flashConfig.map1.IOPort.bit1==0 ? "0" : "1");
		  break;
	  #endif
	  
	  default:
		  TXdatalen=os_sprintf(pTXdata, "BAD arg %0u\n\r", arg);
		  return;
	  }
}

void ICACHE_FLASH_ATTR C_cmd_interpreter(char arg) {
  configSave();
  TXdatalen=os_sprintf(pTXdata, "OK");  // cr lf will be added by parser.
}
	
void ICACHE_FLASH_ATTR c_cmd_interpreter(char arg) {
  LoadDefaultConfig();
  TXdatalen=os_sprintf(pTXdata, "Default configuration restored, check AP\r\n");
}
	
#if defined(MAINS)
void ICACHE_FLASH_ATTR D_cmd_interpreter(char * arg) {
  //gpio_pin_wakeup_enable(GPIO_ID_PIN(4), GPIO_PIN_INTR_HILEVEL);
  //system_deep_sleep_set_option(4);	// disable rf on wake up
  //system_deep_sleep_set_option(2);	// no radio calibration on wake up
  system_deep_sleep_set_option(1);	// Radio calibration is done after deep-sleep wake up
  system_deep_sleep(atoi(arg+1)*1000000);
  //system_deep_sleep_instant(10000000);	// uSeconds
}
#endif

#if defined(GASINJECTORCLEANER)
void ICACHE_FLASH_ATTR d_cmd_interpreter(char * arg) {
  flashConfig.dutycycle=(unsigned char)atoi(arg);
}
void ICACHE_FLASH_ATTR i_cmd_interpreter(char * arg) {
  flashConfig.interval=(unsigned char)atoi(arg);
}
#endif

void ICACHE_FLASH_ATTR m_cmd_interpreter(char * arg) {
  #if defined(SONOFFPOW)
  SendStatus(MQTT_STAT_TOPIC, MSG_POW);
  #else
  SendStatus(MQTT_STAT_TOPIC, MSG_TEMP_HUMI);
  #endif
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "OK\r\n");
}

void ICACHE_FLASH_ATTR Stat_cmd(char arg) {
	struct ip_info info;

	#if defined(MAINS) || defined(ARMTRONIX)
	TXdatalen=os_sprintf(pTXdata, "IObit0: %d\n",			  flashConfig.map1.IOPort.bit0);
	TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IObit1: %1x\n", flashConfig.map1.IOPort.bit1);
	TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IObit2: %1x\n", flashConfig.map1.IOPort.bit2);
	TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IObit3: %1x\n", flashConfig.map1.IOPort.bit3);
	#else
		#if defined(SONOFFDUAL)
		TXdatalen=os_sprintf(pTXdata, "IObit0: %d\n",			  flashConfig.map1.IOPort.bit0);
		TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IObit1: %1x\n", flashConfig.map1.IOPort.bit1);
		#else
		TXdatalen=os_sprintf(pTXdata, "IObit3: %1x\n", flashConfig.map1.IOPort.bit3);
		#endif
	#endif
	#if defined(MAINS)
	TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IObit4: %1x\n", flashConfig.map1.IOPort.bit4);
	TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IObit5: %1x\n", flashConfig.map1.IOPort.bit5);
	TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IObit6: %1x\n", flashConfig.map1.IOPort.bit6);
	TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IObit7: %1x\n", flashConfig.map1.IOPort.bit7);
	#endif
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "Date %04d-%02d-%02dT%02d:%02d:%02d, uptime %02u:%02u:%02u, FlashConfig size %d, crc 0x%04X\n", tm_rtc->tm_year, tm_rtc->tm_mon, tm_rtc->tm_mday, tm_rtc->tm_hour, tm_rtc->tm_min, tm_rtc->tm_sec, tm_uptime->tm_hour, tm_uptime->tm_min, tm_uptime->tm_sec, sizeof(FlashConfig), flashConfig.crc);

  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "AP name = %s, password %s\n", flashConfig.apconf.ssid, flashConfig.apconf.password);
  
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "MQTT_TOPIC = %s, MQTT_HOST = %s, MQTTPubFailed %d\n", MQTT_STAT_TOPIC, MQTT_HOST, nMQTTPublishFailed);
  //TXdatalen+=os_sprintf(pTXdata+TXdatalen, "SSID = %s, Passwd = %s, len %d\n", flashConfig.stat_conf.ssid, flashConfig.stat_conf.password, strlen(flashConfig.stat_conf.password));
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "SSID = %s, Passwd = %s\n", flashConfig.stat_conf.ssid, flashConfig.stat_conf.password);
  
  switch (wifi_get_opmode()) {
    case STATION_MODE:
      TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IP = "IPSTR", mask = "IPSTR", gateway = "IPSTR"\n", IP2STR(&flashConfig.ip0.ip.addr), IP2STR(&flashConfig.ip0.netmask.addr), IP2STR(&flashConfig.ip0.gw.addr));
      break;
    case SOFTAP_MODE:
      wifi_get_ip_info(SOFTAP_IF, &info);
      TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IP = "IPSTR", mask = "IPSTR", gateway = "IPSTR"\n", IP2STR(&info.ip.addr), IP2STR(&info.netmask.addr), IP2STR(&info.gw.addr));
      break;
    case STATIONAP_MODE:
      wifi_get_ip_info(SOFTAP_IF, &info);
      TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IPo = "IPSTR", mask = "IPSTR", gateway = "IPSTR"\n", IP2STR(&info.ip.addr), IP2STR(&info.netmask.addr), IP2STR(&info.gw.addr));
      TXdatalen+=os_sprintf(pTXdata+TXdatalen, "IPi = "IPSTR", mask = "IPSTR", gateway = "IPSTR"\n", IP2STR(&flashConfig.ip1.ip.addr), IP2STR(&flashConfig.ip1.netmask.addr), IP2STR(&flashConfig.ip1.gw.addr));
      break;
    default:
      TXdatalen+=os_sprintf(pTXdata+TXdatalen, "unknown mode\n");
      break;
    }
  #if defined(HOUSE_POW_METER_TX) || defined(SONOFFPOW_DDS238_2)
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "HPRx_IP = "IPSTR"\n", IP2STR(&flashConfig.HPRx_IP));
	#endif
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "rssi = %d, heap_free = %d, vdd33 = %d\n", wifi_station_get_rssi(), (unsigned int)system_get_free_heap_size(), system_get_vdd33()/1024);
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "system boot mode=%d, WifiOpMode=%s\n", system_get_boot_mode(), wifi_opmode_desc(wifi_get_opmode()));
}

void ICACHE_FLASH_ATTR w_cmd_interpreter(char * pInbuf) {
  char *tmpbuff;
  
  tmpbuff=(char *)os_malloc(100);
  tmpbuff=(char *)strsep(&pInbuf, ",");
  os_sprintf(flashConfig.stat_conf.ssid, tmpbuff);
  
  tmpbuff=(char *)strsep(&pInbuf, ",");
  
  // tmpbuff[strlen(tmpbuff)-2]=0; //? only via telnet ???
  os_sprintf(flashConfig.stat_conf.password, tmpbuff);
  //os_memcpy(&flashConfig.stat_conf.password, tmpbuff, strlen(tmpbuff)-2);
  
  os_free(tmpbuff);
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "OK\r\n");
}

void ICACHE_FLASH_ATTR a_cmd_interpreter(char * pInbuf) {
  char *tmpbuff;
  
  tmpbuff=(char *)os_malloc(100);
  tmpbuff=(char *)strsep(&pInbuf, ",");
  os_sprintf(flashConfig.apconf.ssid, tmpbuff);
  //TXdatalen+=os_sprintf(pTXdata+TXdatalen, "ssid: %s\r\n", flashConfig.stat_conf.ssid);
  
  tmpbuff=(char *)strsep(&pInbuf, ",");
  os_sprintf(flashConfig.apconf.password, tmpbuff);
  //os_memcpy(&flashConfig.apconf.password, tmpbuff, strlen(tmpbuff)-2);
  
  os_free(tmpbuff);
  
  TXdatalen=os_sprintf(pTXdata, "OK\r\n");
}

void ICACHE_FLASH_ATTR t_cmd_interpreter(char * pInbuf) {
//	RTC_Reset();
//	ccs811_init_sensor(CCS811_I2C_ADDRESS_1);
	#if defined(MAINS_VMC) || defined(SONOFFDUAL)
 	ina226_get_results();
	TXdatalen=os_sprintf(pTXdata+TXdatalen, "current %d.%d, voltage %d.%d, nCounter %d\r\n", (int)ina226_data->actualcurrent, (int)((ina226_data->actualcurrent-(int)ina226_data->actualcurrent)*100),
          									  (int)ina226_data->actualvoltage, (int)((ina226_data->actualvoltage-(int)ina226_data->actualvoltage)*100),
          									  ina226_data->nCounter );
	#endif
	TXdatalen+=os_sprintf(pTXdata+TXdatalen, "OK\r\n");
}

#if defined(SONOFFDUAL)
void ICACHE_FLASH_ATTR dual_switch_rele(char * pInbuf) {
	unsigned char Val; 
  	uart_init(BIT_RATE_19200);		// set  GPIO_1 (aka TXD0) to 1 !
	switch (pInbuf[0]) {
		case '0':
			Val=0x00;
			break;
		case '1':
			Val=0x01;
			break;
		case '2':
			Val=0x02;
			break;
		default:
			Val=0x03;
			break;
		}
	/*
	where 0xxx seems to be:
	0x00 both off
	0x01 relay one on
	0x02 relay two on
	0x03 both relays on
	*/

	os_printf("%c%c%c%c", 0xA0, 0x04, Val, 0xA1);
	TXdatalen+=os_sprintf(pTXdata+TXdatalen, "OK\r\n");
}
#endif


#if defined(SONOFFPOW)
void ICACHE_FLASH_ATTR power_cmd_parser(char * pInbuf) {
  showData();
  if (pInbuf[1]=='1') {
  	if ( hlw8012->sel_pin_val == CF1_VOLTAGE_MEASURE ) {
	  hlw8012->sel_pin_val = CF1_AMPERE_MEASURE;
	  gpio_write(SEL_PIN, CF1_AMPERE_MEASURE);
	  }
	else {
	  hlw8012->sel_pin_val = CF1_VOLTAGE_MEASURE;
	  gpio_write(SEL_PIN, CF1_VOLTAGE_MEASURE);
	  }
  	}
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "set to %s\r\n", hlw8012->sel_pin_val == CF1_VOLTAGE_MEASURE ? "VOLTAGE" : "AMPERE");
}
#endif
