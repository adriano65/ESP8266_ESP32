/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Include Files                                                                                       //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
//
#include <osapi.h>
#include <ets_sys.h>
#include <c_types.h>
#include <mem.h>
#include <ip_addr.h>
#include <espconn.h>
#include <errno.h>
#include <limits.h>

#include "gpio16.h"
#include "mqtt_client.h"
#include "config.h"
#include "uart.h"
#include "housePowerMeterRx.h"

//#define GTN_HPRX_DBG

#ifdef GTN_HPRX_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#define PRINTNET(format, ...) do { if (pTXdata) { TXdatalen+=os_sprintf(pTXdata+TXdatalen, format, ## __VA_ARGS__ ); TXdatalen+=os_sprintf(pTXdata+TXdatalen, "\n");} } while(0)
#else
#define DBG(format, ...) do { } while(0)
#define PRINTNET(format, ...) do { } while(0)
#endif


// UartDev is defined and initialized in rom code.
extern UartDevice UartDev;
HPMeterRx_t * HPMeterRx_data;
unsigned int nGTN_HPRStatem;
struct espconn * pGTN_HPRConn;
static os_timer_t rs485_timer;
sys_mutex_t RxBuf_lock;
sys_mutex_t TxBuf_lock;
uint8_t pPowerMeterRxBuff[8];
uint8_t nNegativeCount;

//mosquitto_sub -v -p 5800 -h 192.168.1.6 -t 'housePowerMeterRx/242/+'
static void ICACHE_FLASH_ATTR uart0_rx_handler(void *para) {
	  /* uart0 and uart1 intr combine together, when interrupt occur, see reg 0x3ff20020, bit2, bit0 represents uart1 and uart0 respectively */
    RcvMsgBuff *pRxBuff = (RcvMsgBuff *)para;
    uint8 RcvChar;

    if (UART_RXFIFO_FULL_INT_ST != (READ_PERI_REG(UART_INT_ST(UART0)) & UART_RXFIFO_FULL_INT_ST)) { DBG("UARTFIFO"); return; }
    WRITE_PERI_REG(UART_INT_CLR(UART0), UART_RXFIFO_FULL_INT_CLR);

    while (READ_PERI_REG(UART_STATUS(UART0)) & (UART_RXFIFO_CNT << UART_RXFIFO_CNT_S)) {
		    RcvChar = READ_PERI_REG(UART_FIFO(UART0)) & 0xFF;
        sys_mutex_lock(&RxBuf_lock);
        *(pRxBuff->pWritePos++)=RcvChar;
        UartDev.received=pRxBuff->pWritePos - pRxBuff->pRcvMsgBuff;
        sys_mutex_unlock(&RxBuf_lock);

        switch (nGTN_HPRStatem) {
          case SM_NULL:
            break;

          case SM_WAITING_GTNPOW_DATA:
            if ( UartDev.received == GTN_HPRX_MSG_LEN) {
              ETS_UART_INTR_DISABLE();
              //HPMeterRx_data->batVolts = ((myBytes22(5) * 256) + myBytes22(6)) / 10
              float tmpBatVolts = (float)( (pRxBuff->pRcvMsgBuff[5] << 8) | (pRxBuff->pRcvMsgBuff[6]) ) / 10;
              if (tmpBatVolts < 35) { HPMeterRx_data->batVolts = tmpBatVolts; }

              //HPMeterRx_data->batAmps = ((myBytes22(7) * 256) + myBytes22(8)) / 10
              float tmpBatAmps = (float)( (pRxBuff->pRcvMsgBuff[7] << 8) | (pRxBuff->pRcvMsgBuff[8]) ) / 10;
              if (tmpBatAmps < 25) { HPMeterRx_data->batVolts = tmpBatAmps; }
              ResetRxBuff();
              }
            break;            

          case SM_DISABLE_SOCKET:
            espconn_disconnect(pGTN_HPRConn);
	          ETS_UART_INTR_DISABLE();
            pGTN_HPRConn=NULL;
            msleep(10000);
            break;
          }

        // boundary checks
        if ( UartDev.received > (RX_BUFF_SIZE-1) ) {
          ResetRxBuff();
          nGTN_HPRStatem=SM_WAITING_GTNPOW_DATA;
          }

      }
}

void ICACHE_FLASH_ATTR ResetRxBuff() {
  sys_mutex_lock(&RxBuf_lock);
  UartDev.rcv_buff.pWritePos = UartDev.rcv_buff.pRcvMsgBuff;
  UartDev.received=0;
  //clear rx fifo
  SET_PERI_REG_MASK(UART_CONF0(UART0), UART_RXFIFO_RST);
  CLEAR_PERI_REG_MASK(UART_CONF0(UART0), UART_RXFIFO_RST);
  sys_mutex_unlock(&RxBuf_lock);
  ETS_UART_INTR_ENABLE();
}

int ICACHE_FLASH_ATTR housePowerMeterRxInit() {
  HPMeterRx_data = (HPMeterRx_t *)os_zalloc(sizeof(HPMeterRx_t));
  UartDev.baut_rate 	 = 4800;
  UartDev.data_bits    = EIGHT_BITS;
  UartDev.flow_ctrl    = NONE_CTRL;
  UartDev.parity       = NONE_BITS;
  UartDev.stop_bits    = ONE_STOP_BIT;
  //UartDev.rcv_buff.TrigLvl=50;
  uart_config(uart0_rx_handler);
  ResetRxBuff();

  pGTN_HPRConn = (struct espconn *)os_zalloc(sizeof(struct espconn));  
  pGTN_HPRConn->type = ESPCONN_TCP;
  pGTN_HPRConn->state = ESPCONN_NONE;
  pGTN_HPRConn->proto.tcp = (esp_tcp *)os_zalloc(sizeof(esp_tcp));
  pGTN_HPRConn->proto.tcp->local_port = 5001;   // listening port

  //espconn_regist_connectcb(pGTN_HPRConn, pGTN_HPR_connect_cb);
  espconn_accept(pGTN_HPRConn);
  espconn_regist_recvcb(pGTN_HPRConn, pGTN_HPR_rx_cb);
  espconn_regist_disconcb(pGTN_HPRConn, pGTN_HPR_disc_cb);
  espconn_regist_reconcb(pGTN_HPRConn, pGTN_HPR_recon_cb);
  espconn_tcp_set_max_con_allow(pGTN_HPRConn, 1);
  espconn_regist_time(pGTN_HPRConn, 15, 0);
  //pTCPConn->reverse = pMQTTclient;
  nNegativeCount=0;
  flashConfig.WattOffset=350;
  nGTN_HPRStatem=SM_WAITING_GTNPOW_DATA;
	msleep(10);
  start_rs485_timer(TX_DELAY);
	return TRUE;
}

void ICACHE_FLASH_ATTR pGTN_HPR_rx_cb(void *arg, char *data, uint16_t len) {
    struct espconn *pCon = (struct espconn *)arg;
		int m;
    /*
    uint8_t *addr_array = NULL;
    addr_array = pCon->proto.tcp->remote_ip;
    ip_addr_t addr;
    IP4_ADDR(&addr, pCon->proto.tcp->remote_ip[0], pCon->proto.tcp->remote_ip[1], pCon->proto.tcp->remote_ip[2], pCon->proto.tcp->remote_ip[3]);
    if (ota_ip == 0) {
      // There is no previously stored IP address, so we have it.
      ota_ip = addr.addr;
      ota_port = pCon->proto.tcp->remote_port;
      ota_state = CONNECTION_ESTABLISHED;
      }
    */
    /*
    Protocol specification :
    Data rate @ 4800bps, 8 data, 1 stop
    Packet size : 8 Bytes
    0 1 : 0x24
    1 2 : 0x56
    2 3 : 0x00
    3 4 : 0x21
    4 5 : xa (2 byte watts as short integer xaxb) (byte high)
    5 6 : xb  (byte low)
    6 7 : 0x80 (hex / spacer)
    7 8 : checksum
    */
    sys_mutex_lock(&TxBuf_lock);
    os_memcpy(pPowerMeterRxBuff, data, len);
    m = *(signed char *)(&(pPowerMeterRxBuff[4]));
    m *= 1 << CHAR_BIT;
    m |= pPowerMeterRxBuff[5];
    HPMeterRx_data->HousePowerReq = (float)(m)/1;

    if (HPMeterRx_data->HousePowerReq<0) {
      switch (++nNegativeCount) {
        case 3:
          flashConfig.WattOffset = 250;
          break;
        case 4:
          flashConfig.WattOffset = 150;
          break;
        default:
          flashConfig.WattOffset = 350;
        }
      HPMeterRx_data->HousePowerReq = flashConfig.WattOffset;
      }
    else {
      HPMeterRx_data->HousePowerReq = HPMeterRx_data->HousePowerReq + flashConfig.WattOffset;
      nNegativeCount=0;
      }
    if (HPMeterRx_data->HousePowerReq>3000) { HPMeterRx_data->HousePowerReq=3000; }

    pPowerMeterRxBuff[4] = (unsigned int)HPMeterRx_data->HousePowerReq >> 8  & 0xFF;
    pPowerMeterRxBuff[5] = (unsigned int)HPMeterRx_data->HousePowerReq & 0xFF;
    pPowerMeterRxBuff[7] = 264 - pPowerMeterRxBuff[4] - pPowerMeterRxBuff[5];  // new checksum
    sys_mutex_unlock(&TxBuf_lock);

}
void ICACHE_FLASH_ATTR pGTN_HPR_disc_cb(void *arg) {
}
void ICACHE_FLASH_ATTR pGTN_HPR_recon_cb(void *arg, int8_t err) {
}

int ICACHE_FLASH_ATTR uart0_tx_one_char(uint8 TxChar) {
    while (true) {
		  uint32 fifo_cnt = READ_PERI_REG(UART_STATUS(UART0)) & (UART_TXFIFO_CNT<<UART_TXFIFO_CNT_S);
		  if ((fifo_cnt >> UART_TXFIFO_CNT_S & UART_TXFIFO_CNT) < 126) {
			  break;
		    }
	    }
	WRITE_PERI_REG(UART_FIFO(UART0), TxChar);
	return TRUE;
}

void ICACHE_FLASH_ATTR uart0_write(char *c, int len) {
    int nlen;

    for (nlen=0; nlen<len; nlen++) {
        uart0_tx_one_char(c[nlen]);
        }
}

void ICACHE_FLASH_ATTR start_rs485_timer(uint16_t interval) {
    os_timer_disarm(&rs485_timer);
    os_timer_setfn(&rs485_timer, (os_timer_func_t *)rs485_timer_cb, interval);
    os_timer_arm(&rs485_timer, interval, 1);
}

static void ICACHE_FLASH_ATTR rs485_timer_cb(uint16_t interval) {
    os_timer_disarm(&rs485_timer);

    #if 1
    float media=(HPMeterRx_data->HousePowerReq + HPMeterRx_data->HousePowerPrevReq)/2;
    pPowerMeterRxBuff[4] = (unsigned int)media >> 8  & 0xFF;
    pPowerMeterRxBuff[5] = (unsigned int)media & 0xFF;
    pPowerMeterRxBuff[7] = 264 - pPowerMeterRxBuff[4] - pPowerMeterRxBuff[5];  // new checksum
    #endif

    // send data to GTN1000 (700 ms minimum cycle!!) ----------------------------------
    uart0_write(pPowerMeterRxBuff, 8);

    HPMeterRx_data->HousePowerPrevReq=HPMeterRx_data->HousePowerReq;

    os_timer_setfn(&rs485_timer, (os_timer_func_t *)rs485_timer_cb, interval);
    os_timer_arm(&rs485_timer, interval, 1);
}


