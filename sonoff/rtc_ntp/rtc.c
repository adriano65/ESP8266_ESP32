#include <osapi.h>
#include <os_type.h>
#include <c_types.h>
#include <gpio.h>
#include <mem.h>
#include <sys/time.h>
#include <time.h>

#include "mqtt.h"
#include "mqtt_client.h"
#include "gpio16.h"
#include "config.h"
#include "network.h"
#include "ntp.h"

#if defined(SONOFFPOW)
#include "../hlw8012/hlw8012.h"
#endif

#if defined(SONOFFPOW_DDS238_2)
#include "../dds238-2/dds238-2.h"
unsigned char TXbuf[8];
extern unsigned int nDDS238Statem;
#endif

#if defined(MAINS_GTN1000)
#include "../gtn1000/gtn1000.h"
unsigned char TXbuf[8];
extern unsigned int nGTN1000Statem;
#endif

#if defined(MAINS_GTN_HPR)
#include "../gtn_hpr/gtn_hpr.h"
unsigned char TXbuf[8];
extern unsigned int nGTN_HPRStatem;
#endif

//#define RTC_DBG

#ifdef RTC_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#define PRINTNET(format, ...) do { if (pTXdata) { *TXdatalen=os_sprintf(pTXdata, format, ## __VA_ARGS__ ); *TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "\n");} } while(0)
#else
#define DBG(format, ...) do { } while(0)
#define PRINTNET(format, ...) do { } while(0)
#endif

#define RTC_MAGIC 0x55aaaa55

#define MEM_MAGIC           0x75507921
#define MEM_DELTA_ADDR      64
#define MEM_CAL_ADDR        (MEM_DELTA_ADDR + 2)
#define MEM_USER_MAGIC_ADDR (MEM_CAL_ADDR + 1)
#define MEM_USER_LEN_ADDR   (MEM_USER_MAGIC_ADDR + 1)
#define MEM_USER_DATA_ADDR  (MEM_USER_LEN_ADDR + 1)
#define MEM_USER_MAXLEN     (512 - (MEM_USER_DATA_ADDR - MEM_DELTA_ADDR) * 4)

typedef struct {
  uint64 timeAcc;
  uint32 magic;
  uint32 timeBase;
} RTC_TIMER;

/*
struct tm
{
  int	tm_sec;
  int	tm_min;
  int	tm_hour;
  int	tm_mday;
  int	tm_mon;
  int	tm_year;
  int	tm_wday;
  int	tm_yday;
  int	tm_isdst;
};
*/
struct tm *tm_rtc;
struct tm * tm_uptime;

void ICACHE_FLASH_ATTR RTC_init() {
  RTC_TIMER rtcTimer;

  os_printf( "rtc time init...\r\n");
  tm_rtc = (struct tm *)os_zalloc(sizeof(struct tm));
  tm_uptime = (struct tm *)os_zalloc(sizeof(struct tm));

  system_rtc_mem_read(64, &rtcTimer, sizeof(rtcTimer));
  if (rtcTimer.magic != RTC_MAGIC) { RTC_Reset(); }
}

void ICACHE_FLASH_ATTR RTC_Reset() {
  RTC_TIMER rtcTimer;

  rtcTimer.magic = RTC_MAGIC;
  rtcTimer.timeAcc = 0;
  rtcTimer.timeBase = system_get_rtc_time();
  //os_printf( "time base: %d \r\n", rtcTimer.timeBase );
  system_rtc_mem_write(MEM_DELTA_ADDR, &rtcTimer, sizeof(rtcTimer));

}

void ICACHE_FLASH_ATTR update_tm_rtc() {  
  uint32_t uptime_ticks;
  uint32 rtcT1, rtcT2, st1, cal1, cal2;
  time_t totalRTCSeconds, totalUptimeSeconds;
  RTC_TIMER rtcTimer;
  
  uptime_ticks = system_get_time();

  system_rtc_mem_read(MEM_DELTA_ADDR, &rtcTimer, sizeof(rtcTimer));  
  rtcT1 = system_get_rtc_time();
  st1 = system_get_time();
  cal1 = system_rtc_clock_cali_proc();
  os_delay_us(300);
  rtcT2 = system_get_rtc_time();
  cal2 = system_rtc_clock_cali_proc();
  /*
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "RTC t2 - t1: %d\r\n", rtcT2 - rtcT1);
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "SYS t2 - t1: %d\r\n", uptime_ticks - st1);
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "Cal 1: %d.%d\r\n", ((cal1 * 1000) >> 12) / 1000, ((cal1 * 1000) >> 12) % 1000 );
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "Cal 2: %d.%d\r\n", ((cal2 * 1000) >> 12) / 1000, ((cal2 * 1000) >> 12) % 1000 );
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "===================\r\n");
  */
  rtcTimer.timeAcc += ( ((uint64) (rtcT2 - rtcTimer.timeBase)) * ((uint64) ((cal2 * 1000) >> 12)) );
  totalRTCSeconds = rtcTimer.timeAcc / 1000000000;
  tm_rtc=localtime(&totalRTCSeconds);
  if (tm_rtc->tm_year<2019) tm_rtc->tm_year=2019;
  if (tm_rtc->tm_mon==0 || tm_rtc->tm_mon>12 ) tm_rtc->tm_mon=1;
  if (tm_rtc->tm_mday==0 || tm_rtc->tm_mday>31) tm_rtc->tm_mday=1;
  
	// warn! localtime and gmtime functions breaks the global tm_struct !!!
	//tm_local=localtime(&totalUptimeSeconds);
  totalUptimeSeconds  = uptime_ticks/1000000;
  tm_uptime->tm_hour = totalUptimeSeconds/3600;
  tm_uptime->tm_min = (totalUptimeSeconds % 3600)/60;
  tm_uptime->tm_sec = totalUptimeSeconds % 60;
  // FIXME ! put next in closing functions
  // os_free(tm_uptime);

  /*
  //TXdatalen+=os_sprintf(pTXdata+TXdatalen, "RTC time accuracy: %d\r\n", rtcTimer.timeAcc);
  TXdatalen+=os_sprintf(pTXdata+TXdatalen, "Power on time: %02d:%02d:%02d hh:mm:ss\r\n", tm_rtc->tm_hour, tm_rtc->tm_min , tm_rtc->tm_sec);
  */

  rtcTimer.timeBase = rtcT2;
  //bool system_rtc_mem_write(uint8 des_addr, const void *src_addr, uint16 save_size);
  system_rtc_mem_write(MEM_DELTA_ADDR, &rtcTimer, sizeof(rtcTimer));
}

#define US_TO_RTC_TIMER_TICKS(t)          \
    ((t) ?                                   \
     (((t) > 0x35A) ?                   \
      (((t)>>2) * ((APB_CLK_FREQ>>4)/250000) + ((t)&0x3) * ((APB_CLK_FREQ>>4)/1000000))  :    \
      (((t) *(APB_CLK_FREQ>>4)) / 1000000)) :    \
     0)

#define FRC1_ENABLE_TIMER  BIT7
#define FRC1_AUTO_LOAD  BIT6
//TIMER PREDIVED MODE
typedef enum {
    DIVDED_BY_1 = 0,		//timer clock
    DIVDED_BY_16 = 4,	  //divided by 16
    DIVDED_BY_256 = 8,	//divided by 256
} TIMER_PREDIVED_MODE;

typedef enum {			//timer interrupt mode
    TM_LEVEL_INT = 1,	// level interrupt
    TM_EDGE_INT   = 0,	//edge interrupt
} TIMER_INT_MODE;

typedef enum {
    FRC1_SOURCE = 0,	
    NMI_SOURCE = 1,	
} FRC1_TIMER_SOURCE_TYPE;

void ICACHE_FLASH_ATTR hw_timer_isr_cb(void);

/******************************************************************************
* FunctionName : hw_timer_arm
* Description  : set a trigger timer delay for this timer.
* Parameters   : uint32 val : in autoload mode
                        50 ~ 0x7fffff;  for FRC1 source.
                        100 ~ 0x7fffff;  for NMI source.
in non autoload mode:
                        10 ~ 0x7fffff;  
* Returns      : NONE
*******************************************************************************/
void ICACHE_FLASH_ATTR hw_timer_arm(u32 val){
  RTC_REG_WRITE(FRC1_LOAD_ADDRESS, US_TO_RTC_TIMER_TICKS(val));
}
  
void ICACHE_FLASH_ATTR hw_timer_stop(void) {
    TM1_EDGE_INT_DISABLE();
    ETS_FRC1_INTR_DISABLE();
    RTC_REG_WRITE(FRC1_CTRL_ADDRESS, 0);
}

void ICACHE_FLASH_ATTR hw_timer_init() {
  RTC_REG_WRITE(FRC1_CTRL_ADDRESS, FRC1_AUTO_LOAD | DIVDED_BY_256 | FRC1_ENABLE_TIMER | TM_EDGE_INT);
        
  ETS_FRC_TIMER1_INTR_ATTACH( hw_timer_isr_cb, NULL);
  
  TM1_EDGE_INT_ENABLE();
  ETS_FRC1_INTR_ENABLE();
}

void ICACHE_FLASH_ATTR hw_timer_isr_cb(void) {
    //disable global interrupt
	  ETS_GPIO_INTR_DISABLE();

    static uint8_t nCounter=0;

    //os_printf("hw_timer_isr_cb %d\n", nCounter);
    //TM1_EDGE_INT_DISABLE();
    if ( !(nCounter%20) ) {
      update_tm_rtc();
      }

    #if defined(MAINS) && !defined(MAINS_GTN1000) && !defined(MAINS_GTN_HPR)
    if ( !(nCounter%READ_DELAY) ) {
      SendStatus(MQTT_STAT_TOPIC, MSG_STATUS);
      }
    #endif

    #if defined(SONOFFPOW)
    if ( !(nCounter%(READ_DELAY/2)) ) {
      updateCurrent();
      updateVoltage();
      updateActivePower();
      }
    if ( !(nCounter%READ_DELAY) ) {
	    SendStatus(MQTT_STAT_TOPIC, MSG_POW);
      }
    #endif

    #if defined(SONOFFPOW_DDS238_2)
    if ( !(nCounter%(READ_DELAY/2)) ) {
      prepare_buff(TXbuf);
      uart0_write(TXbuf, 8);
      nDDS238Statem=SM_WAITING_DDS238_ANSWER;
      }
    if ( !(nCounter%READ_DELAY) ) {
      SendStatus(MQTT_STAT_TOPIC, MSG_POW_DDS238_2);
      }
    #endif

    #if defined(MAINS_GTN1000)
    if ( !(nCounter%(READ_DELAY)) ) {
      if (nGTN1000Statem==SM_WAITING_MERDANERA) {
        espconn_connect(pGTN1000Conn);
        }
      else {
        SendStatus(MQTT_STAT_TOPIC, MSG_GTN1000);
        }
      }
    #endif

    #if defined(MAINS_GTN_HPR)
    if ( !(nCounter%(READ_DELAY)) ) {
        //espconn_connect(pGTN_HPRConn);
        SendStatus(MQTT_STAT_TOPIC, MSG_GTN_HPR);
      }
    #endif


    if ( !(nCounter%100) ) {
      if ( wifi_get_opmode() == STATIONAP_MODE ) {
        wifi_station_scan(NULL, scan_done);
        }

      if (! isFlashconfig_actual()) {
        DBG("isFlashconfig_actual");
        configSave();
        }

      if (system_get_free_heap_size() < 30000) {
	      SendStatus(MQTT_STAT_TOPIC, MSG_CRITICAL_ERR);
        RTC_Reset();
        system_restart();
        }
      }

    #if defined(SONOFFTH10)
    if ( !(nCounter%READ_DELAY) ) {
      #if defined(DS18B20_PIN)
      if (! DS18B20read()) {
        DBG("Failed to read sensor");
        }
      #else  
        #if defined(DHT22_PIN)
        if (!DHTread()) {
          DBG("Failed to read sensor");
          }
        #else
          #if defined(SI7021_PIN)
          if (! SI7021read()) {
            DBG("Failed to read sensor");
            }
          #endif
        #endif
      #endif        
	    SendStatus(MQTT_STAT_TOPIC, MSG_TEMP_HUMI);
      #warning askfjdsofjodis
      }
    #endif

    #if defined(ARMTRONIX)
    if ( !(nCounter%READ_DELAY) ) {
	    SendStatus(MQTT_STAT_TOPIC, MSG_STATUS);
      }
    #endif

    #if defined(MAINS_VMC) || defined(SONOFFDUAL)
    if ( !(nCounter%50) ) {
      if (ina226_get_results()) {
	      SendStatus(MQTT_STAT_TOPIC, MSG_DC_VOLTAGE);
        }
      }
    #endif

    nCounter++;
    //enable global interrupt
    ETS_GPIO_INTR_ENABLE();
    
    //TM1_EDGE_INT_ENABLE();
}
