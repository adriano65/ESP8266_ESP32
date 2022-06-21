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
#include "housePowerMeterTx.h"

//#define GTN_HPTX_DBG

#ifdef GTN_HPTX_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#define PRINTNET(format, ...) do { if (pTXdata) { TXdatalen+=os_sprintf(pTXdata+TXdatalen, format, ## __VA_ARGS__ ); TXdatalen+=os_sprintf(pTXdata+TXdatalen, "\n");} } while(0)
#else
#define DBG(format, ...) do { } while(0)
#define PRINTNET(format, ...) do { } while(0)
#endif


// UartDev is defined and initialized in rom code.
extern UartDevice UartDev;

HPMeterTx_t * HPMeterTx_data;
unsigned int nHPMeterTxStatem;
struct espconn * pHPMeterTxConn;
sys_mutex_t RxBuf_lock;

//mosquitto_sub -v -p 5800 -h 192.168.1.6 -t 'housePowerMeterTx/116/+'
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

        switch (nHPMeterTxStatem) {
          case SM_WAITING_GTN1000_POLL:
            if ( UartDev.received == GTN1000_RX_MSG_LEN) { 
              //if (pRxBuff->pRcvMsgBuff[0]==GTN1000_ADDRESS) {
                ETS_UART_INTR_DISABLE();
                HPMeterTx_data->IsWrong++;
                for (int n=0;n<8;n++){ HPMeterTx_data->pTmpBuff[n]=UartDev.rcv_buff.pRcvMsgBuff[n]; }
                /*
                Protocol specification :
                Data rate @ 4800bps, 8 data, 1 stop
                Packet size : 8 Bytes
                0 1 : 0x24 - 36
                1 2 : 0x56 - 86
                2 3 : 0x00 - 00
                3 4 : 0x21 - 33
                4 5 : xa (2 byte watts as short integer xaxb) (byte high)
                5 6 : xb  (byte low)
                6 7 : 0x80 (hex / spacer)
                7 8 : checksum
                */

                uint8_t my_checksum = 264 - UartDev.rcv_buff.pRcvMsgBuff[4] - UartDev.rcv_buff.pRcvMsgBuff[5];    //checksum
                if (UartDev.rcv_buff.pRcvMsgBuff[7]==my_checksum) {
                  HPMeterTx_data->IsWrong=0;
                  HPMeterTx_data->ActivePower = (float)( (UartDev.rcv_buff.pRcvMsgBuff[4] << 8) | (UartDev.rcv_buff.pRcvMsgBuff[5]) );

                  //float tmpActPow = HPMeterTx_data->ActivePower+475;    // to be analized deeply, sometimes -120Watts back to grid :-)
                  float tmpActPow = HPMeterTx_data->ActivePower+350;    // to be analized deeply, sometimes -80Watts back to grid :-)
                  //float tmpActPow = HPMeterTx_data->ActivePower+280;    // to be analized deeply, sometimes -140Watts back to grid :-)
                  //float tmpActPow = HPMeterTx_data->ActivePower+140;    // to be analized deeply :-)
                  //float tmpActPow = HPMeterTx_data->ActivePower+200;    // to be analized deeply :-)
                  //float tmpActPow = HPMeterTx_data->ActivePower*1.5+200;    // oscilla!
                  //float tmpActPow = HPMeterTx_data->ActivePower*1.1+280;    // oscilla!
                  //float tmpActPow = HPMeterTx_data->ActivePower*1.1+300;    // 
                  //float tmpActPow = HPMeterTx_data->ActivePower+350;    // to be analized deeply, sometimes -80Watts back to grid :-)
                  //float tmpActPow = HPMeterTx_data->ActivePower+350+70;
                  //float tmpActPow = HPMeterTx_data->ActivePower*15-200; // oscilla

                  UartDev.rcv_buff.pRcvMsgBuff[4] = (unsigned int)tmpActPow >> 8  & 0xFF;
                  UartDev.rcv_buff.pRcvMsgBuff[5] = (unsigned int)tmpActPow & 0xFF;
                  UartDev.rcv_buff.pRcvMsgBuff[7] = 264 - UartDev.rcv_buff.pRcvMsgBuff[4] - UartDev.rcv_buff.pRcvMsgBuff[5];  // new checksum
                  }

                espconn_connect(pHPMeterTxConn);
                espconn_set_opt(pHPMeterTxConn, ESPCONN_REUSEADDR|ESPCONN_NODELAY);
              //  }
              //else ResetRxBuff();
              }
            break;            

          case SM_DISABLE_SOCKET:
            espconn_disconnect(pHPMeterTxConn);
	          ETS_UART_INTR_DISABLE();
            pHPMeterTxConn=NULL;
            msleep(10000);
            break;
          }
          
        // boundary checks
        if ( UartDev.received > (RX_BUFF_SIZE-1) ) {
          ResetRxBuff();
          nHPMeterTxStatem=SM_WAITING_GTN1000_POLL;
          }

      }
}

int ICACHE_FLASH_ATTR housePowerMeterTxInit() {
  HPMeterTx_data = (HPMeterTx_t *)os_zalloc(sizeof(HPMeterTx_t));
  UartDev.baut_rate 	 = 4800;
  //UartDev.baut_rate 	 = 9000;
  UartDev.data_bits    = EIGHT_BITS;
  UartDev.flow_ctrl    = NONE_CTRL;
  UartDev.parity       = NONE_BITS;
  //UartDev.stop_bits    = ONE_HALF_STOP_BIT;
  UartDev.stop_bits    = ONE_STOP_BIT;
  //UartDev.rcv_buff.TrigLvl=50;
  uart_config(uart0_rx_handler);
  os_install_putc1((void *)uart0_tx_one_char);
  ResetRxBuff();

  createConnection();
  nHPMeterTxStatem=SM_WAITING_GTN1000_POLL;
	msleep(10);
	return TRUE;
}

void ICACHE_FLASH_ATTR pGTN1000_connect_cb(void *arg) {
  struct espconn * pCon = (struct espconn *)arg;
  //DBG("TCP connection received from "IPSTR":%d to local port %d\n", IP2STR(pCon->proto.tcp->remote_ip), pCon->proto.tcp->remote_port, pCon->proto.tcp->local_port);
  espconn_sent(pHPMeterTxConn, UartDev.rcv_buff.pRcvMsgBuff, UartDev.received );
  ResetRxBuff();
  espconn_disconnect(pHPMeterTxConn);
  nHPMeterTxStatem=SM_WAITING_GTN1000_POLL;
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

void ICACHE_FLASH_ATTR pGTN1000_rx_cb(void *arg, char *data, uint16_t len) {
  // Store the IP address from the sender of this data.
}

void ICACHE_FLASH_ATTR pGTN1000_recon_cb(void *arg, int8_t err) {
  HPMeterTx_data->IsWrong++;
  //system_restart();
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
    for (int nlen=0; nlen<len; nlen++) {
        uart0_tx_one_char(c[nlen]);
        }
}

void ICACHE_FLASH_ATTR createConnection() {
  char tmpbuf[20];

  os_sprintf(tmpbuf, IPSTR, IP2STR(&flashConfig.HPRx_IP));
  if ( strcmp("0.0.0.0", tmpbuf) ) {
    pHPMeterTxConn = (struct espconn *)os_zalloc(sizeof(struct espconn));    
    pHPMeterTxConn->type = ESPCONN_TCP;
    pHPMeterTxConn->state = ESPCONN_NONE;
    pHPMeterTxConn->proto.tcp = (esp_tcp *)os_zalloc(sizeof(esp_tcp));
    pHPMeterTxConn->proto.tcp->local_port = espconn_port();
    pHPMeterTxConn->proto.tcp->remote_port = 5001;
    //StrToIP(HPMETER_RX_IP, (void*)&pHPMeterTxConn->proto.tcp->remote_ip);
    os_memcpy(pHPMeterTxConn->proto.tcp->remote_ip, &flashConfig.HPRx_IP, 4);
    //pTCPConn->reverse = pMQTTclient;
    espconn_create(pHPMeterTxConn);
    espconn_tcp_set_max_con_allow(pHPMeterTxConn, 1);
    espconn_regist_time(pHPMeterTxConn, 15, 0);
    espconn_regist_connectcb(pHPMeterTxConn, pGTN1000_connect_cb);
    espconn_regist_recvcb(pHPMeterTxConn, pGTN1000_rx_cb);
    espconn_regist_reconcb(pHPMeterTxConn, pGTN1000_recon_cb);
    }
}
