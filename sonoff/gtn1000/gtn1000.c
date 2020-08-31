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
#include "gtn1000.h"

//#define GTN1000_DBG

#ifdef GTN1000_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#define PRINTNET(format, ...) do { if (pTXdata) { TXdatalen+=os_sprintf(pTXdata+TXdatalen, format, ## __VA_ARGS__ ); TXdatalen+=os_sprintf(pTXdata+TXdatalen, "\n");} } while(0)
#else
#define DBG(format, ...) do { } while(0)
#define PRINTNET(format, ...) do { } while(0)
#endif


// UartDev is defined and initialized in rom code.
extern UartDevice UartDev;

gtn1000_t * gtn1000_data;
unsigned int nGTN1000Statem;
struct espconn * pGTN1000Conn;
sys_mutex_t RxBuf_lock;

//mosquitto_sub -v -p 5800 -h 192.168.1.6 -t 'esp_pw2gtn/116/+'
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

        switch (nGTN1000Statem) {
          case SM_WAITING_GTN1000_POLL:
            if ( UartDev.received == GTN1000_RX_MSG_LEN) { 
              //if (pRxBuff->pRcvMsgBuff[0]==GTN1000_ADDRESS) {
                ETS_UART_INTR_DISABLE();
                gtn1000_data->IsWrong++;
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

                gtn1000_data->checksum=UartDev.rcv_buff.pRcvMsgBuff[7];    //checksum
                uint8_t my_checksum = 264 - UartDev.rcv_buff.pRcvMsgBuff[4] - UartDev.rcv_buff.pRcvMsgBuff[5];    //checksum
                if (gtn1000_data->checksum==my_checksum) {
                  gtn1000_data->IsWrong=0;
                  gtn1000_data->ActivePower = (float)( (UartDev.rcv_buff.pRcvMsgBuff[4] << 8) | (UartDev.rcv_buff.pRcvMsgBuff[5]) );

                  //float tmpActPow = gtn1000_data->ActivePower+475;    // to be analized deeply, sometimes -120Watts back to grid :-)
                  //float tmpActPow = gtn1000_data->ActivePower+350;    // to be analized deeply, sometimes -80Watts back to grid :-)
                  //float tmpActPow = gtn1000_data->ActivePower+280;    // to be analized deeply, sometimes -140Watts back to grid :-)
                  //float tmpActPow = gtn1000_data->ActivePower+140;    // to be analized deeply :-)
                  float tmpActPow = gtn1000_data->ActivePower+200;    // to be analized deeply :-)
                  UartDev.rcv_buff.pRcvMsgBuff[4] = (unsigned int)tmpActPow >> 8  & 0xFF;
                  UartDev.rcv_buff.pRcvMsgBuff[5] = (unsigned int)tmpActPow & 0xFF;
                  UartDev.rcv_buff.pRcvMsgBuff[7] = 264 - UartDev.rcv_buff.pRcvMsgBuff[4] - UartDev.rcv_buff.pRcvMsgBuff[5];  // new checksum
                  }

                espconn_connect(pGTN1000Conn);
                espconn_set_opt(pGTN1000Conn, ESPCONN_REUSEADDR|ESPCONN_NODELAY);
              //  }
              //else ResetRxBuff();
              }
            break;            

          case SM_DISABLE_SOCKET:
            espconn_disconnect(pGTN1000Conn);
	          ETS_UART_INTR_DISABLE();
            pGTN1000Conn=NULL;
            msleep(10000);
            break;
              
        }
        // boundary checks
        if ( UartDev.received > (RX_BUFF_SIZE-1) ) {
          ResetRxBuff();
          nGTN1000Statem=SM_WAITING_GTN1000_POLL;
          }

      }
}

int ICACHE_FLASH_ATTR gtn1000Init() {
  gtn1000_data = (gtn1000_t *)os_zalloc(sizeof(gtn1000_t));
  UartDev.baut_rate 	 = 4800;
  //UartDev.baut_rate 	 = BIT_RATE_9600;
  //UartDev.baut_rate 	 = 9000;
  UartDev.data_bits    = EIGHT_BITS;
  //UartDev.data_bits    = SEVEN_BITS;
  UartDev.flow_ctrl    = NONE_CTRL;
  UartDev.parity       = NONE_BITS;
  //UartDev.parity       = EVEN_BITS;
  //UartDev.stop_bits    = ONE_HALF_STOP_BIT;
  UartDev.stop_bits    = ONE_STOP_BIT;
  //UartDev.stop_bits    = TWO_STOP_BIT;
  //UartDev.rcv_buff.TrigLvl=50;
  uart_config(uart0_rx_handler);
  os_install_putc1((void *)uart0_tx_one_char);
  ResetRxBuff();

  pGTN1000Conn = (struct espconn *)os_zalloc(sizeof(struct espconn));  
  pGTN1000Conn->type = ESPCONN_TCP;
  pGTN1000Conn->state = ESPCONN_NONE;
  pGTN1000Conn->proto.tcp = (esp_tcp *)os_zalloc(sizeof(esp_tcp));
  pGTN1000Conn->proto.tcp->local_port = espconn_port();
  pGTN1000Conn->proto.tcp->remote_port = 5001;
  StrToIP(GTN_IP_ADDRESS, (void*)&pGTN1000Conn->proto.tcp->remote_ip);
  //pTCPConn->reverse = pMQTTclient;
  espconn_create(pGTN1000Conn);
  espconn_tcp_set_max_con_allow(pGTN1000Conn, 1);
  espconn_regist_time(pGTN1000Conn, 15, 0);
  espconn_regist_connectcb(pGTN1000Conn, pGTN1000_connect_cb);
  espconn_regist_recvcb(pGTN1000Conn, pGTN1000_rx_cb);
  espconn_regist_reconcb(pGTN1000Conn, pGTN1000_recon_cb);

  nGTN1000Statem=SM_WAITING_MERDANERA;
	msleep(10);
  DBG("sent");
  espconn_sent(pGTN1000Conn, "telnet in and restart!!", 24 );
	return TRUE;
}

void ICACHE_FLASH_ATTR pGTN1000_connect_cb(void *arg) {
  struct espconn * pCon = (struct espconn *)arg;
  //DBG("TCP connection received from "IPSTR":%d to local port %d\n", IP2STR(pCon->proto.tcp->remote_ip), pCon->proto.tcp->remote_port, pCon->proto.tcp->local_port);
  espconn_sent(pGTN1000Conn, UartDev.rcv_buff.pRcvMsgBuff, UartDev.received );
  ResetRxBuff();
  espconn_disconnect(pGTN1000Conn);
  nGTN1000Statem=SM_WAITING_GTN1000_POLL;
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
  system_restart();
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
