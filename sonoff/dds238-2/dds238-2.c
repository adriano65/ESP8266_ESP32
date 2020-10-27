/*
collegamento a Sonoff.
Occorre prestare attenzione che il modulo funziona solo a 5V quindi per utilizzarlo con Raspberry Pi occorre utilizzare un convertitore di 
livello in modo tale da non danneggiare irrimediabilmente il pin GPIO di raspberry che funzionano a 3.3V e non sono %5V tollerant.
Personalmente ho preferito utilizzare due convertitori di livello uno alimentato a 3.3V direttamente dal pin presente su 
Raspberry per abbassare il livello del segnale che va dal pin RO al pin RX del Raspberry (in modo da non dannggiarlo come già indicato in precedenza) e un 
altro convertitore di livello alimentato a 5V per innalzare il livello dei pin
TX di Raspberry che va al pin DI
due PIN GPIO a piacere del Raspberry che vanno rispettivamente ai pin DE e RE (Settano il dispositivo in invio o ricezione)
Ricapitolando i pin del dispositivo vanno collegati così:
DE = trasmissione o ricezione ad un pin GPIO di raspberry a piacere o ad un pin di Arduino a piacere
RE = trasmissione o ricezione ad un pin GPIO di raspberry a piacere o ad un pin di Arduino a piacere
DI = Ricezione dati al pin TX di Rasberry o Arduino
RO = Trasmissione al pin RX di Raspberry o Arduino
i pin DE e RE possono essere collegati al medesimo pin GPIO tanto sono mutualmente esclusivi.
Ancora più semplice collgarlo ad Arduino Uno in quando funzionando a +5V non ha bisogno di hardware aggiuntivo.
Veniamo ai motivi cha mi hanno portato a dare quattro stelle anziché cinque:
il led rosso di alimentazione non è possibile escluderlo
la resistenza R7 (da 120ohm) non è possibile escluderla se non rimuovendola, questa resistenza va messa solo ai due capi estremi del bus, collegando più di un dispositivo occorre rimuoverla dissaldandola.
*/

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
#include "dds238-2.h"

//#define DDS238_DBG

#ifdef DDS238_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#define PRINTNET(format, ...) do { if (pTXdata) { TXdatalen+=os_sprintf(pTXdata+TXdatalen, format, ## __VA_ARGS__ ); TXdatalen+=os_sprintf(pTXdata+TXdatalen, "\n");} } while(0)
#else
#define DBG(format, ...) do { } while(0)
#define PRINTNET(format, ...) do { } while(0)
#endif


// UartDev is defined and initialized in rom code.
extern UartDevice UartDev;

dds238_2_t * dds238_2_data;
unsigned int nDDS238Statem;
struct espconn * pHPMeterTxConn;
sys_mutex_t RxBuf_lock;
uint8_t pPowerDataBuff[8];

//mosquitto_sub -v -p 5800 -h 192.168.1.6 -t 'sonoff_pow/221/+'
static void ICACHE_FLASH_ATTR uart0_rx_handler(void *para) {
	  /* uart0 and uart1 intr combine together, when interrupt occur, see reg 0x3ff20020, bit2, bit0 represents uart1 and uart0 respectively */
    RcvMsgBuff *pRxBuff = (RcvMsgBuff *)para;
    uint8 RcvChar;

    if (UART_RXFIFO_FULL_INT_ST != (READ_PERI_REG(UART_INT_ST(UART0)) & UART_RXFIFO_FULL_INT_ST)) { return; }
    WRITE_PERI_REG(UART_INT_CLR(UART0), UART_RXFIFO_FULL_INT_CLR);

    while (READ_PERI_REG(UART_STATUS(UART0)) & (UART_RXFIFO_CNT << UART_RXFIFO_CNT_S)) {
		    RcvChar = READ_PERI_REG(UART_FIFO(UART0)) & 0xFF;
        sys_mutex_lock(&RxBuf_lock);
        *(pRxBuff->pWritePos++)=RcvChar;
        UartDev.received=pRxBuff->pWritePos - pRxBuff->pRcvMsgBuff;
        sys_mutex_unlock(&RxBuf_lock);

        switch (nDDS238Statem) {
          case SM_WAITING_DDS238_ANSWER:
            if ( UartDev.received == DDS238_RX_MSG_LEN) {
                //if ( (pRxBuff->pWritePos[0]==DDS238_ADDRESS) && (pRxBuff->pWritePos[1]==READ_HOLDING_REGISTERS)) {
                  ETS_UART_INTR_DISABLE();
                  if ( ManageDDSanswer(pRxBuff) ) { 
                    ResetRxBuff();
                    }
                  else {
                    system_restart();
                    }
                 // }
              }
            break;

          case SM_DISABLE_SOCKET:
	          ETS_UART_INTR_DISABLE();
            msleep(10000);
            break;
              
          }
        // boundary checks
        if ( UartDev.received > (RX_BUFF_SIZE-1) ) {
          ResetRxBuff();
          nDDS238Statem=SM_WAITING_DDS238_ANSWER;
          }

      }
}

int ICACHE_FLASH_ATTR dds238Init() {
  dds238_2_data = (dds238_2_t *)os_zalloc(sizeof(dds238_2_t));
  UartDev.baut_rate 	 = BIT_RATE_9600;
  UartDev.data_bits    = EIGHT_BITS;
  UartDev.flow_ctrl    = NONE_CTRL;
  UartDev.parity       = NONE_BITS;
  UartDev.stop_bits    = ONE_STOP_BIT;
  //UartDev.rcv_buff.TrigLvl=50;
  uart_config(uart0_rx_handler);
  os_install_putc1((void *)uart0_tx_one_char);
  ResetRxBuff();

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

	msleep(10);
  nDDS238Statem=SM_WAITING_DDS238_ANSWER;
	return TRUE;
}

void ICACHE_FLASH_ATTR pGTN1000_connect_cb(void *arg) {
  struct espconn * pCon = (struct espconn *)arg;
  espconn_sent(pCon, pPowerDataBuff, 8 );
  ResetRxBuff();
  espconn_disconnect(pCon);
  nDDS238Statem=SM_WAITING_DDS238_ANSWER;
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
  //system_restart();
}

uint8_t ICACHE_FLASH_ATTR ManageDDSanswer(void *para) {
    RcvMsgBuff *pRxBuff = (RcvMsgBuff *)para;
		unsigned int i;
		int m;

    if (validCRC(pRxBuff->pRcvMsgBuff, DDS238_RX_MSG_LEN)) {
      switch (dds238_2_data->reg) {
        case DDS238_ACTIVE_POWER:		// NOTE: could be negative
          m = *(signed char *)(&(pRxBuff->pRcvMsgBuff[3]));
          m *= 1 << CHAR_BIT;
          m |= pRxBuff->pRcvMsgBuff[4];
          dds238_2_data->ActivePower = (float)(m)/DDS238_ACTIVE_POWER_DIVIDER;
          // now send data to GTN1000 (On receiver 700 ms minimum cycle!!) ----------------------------------------------
          pPowerDataBuff[0]=0x24;
          pPowerDataBuff[1]=0x56;
          pPowerDataBuff[2]=0x00;
          pPowerDataBuff[3]=0x21;
          pPowerDataBuff[4] = (unsigned int)dds238_2_data->ActivePower >> 8  & 0xFF;
          pPowerDataBuff[5] = (unsigned int)dds238_2_data->ActivePower & 0xFF;
          pPowerDataBuff[6]=0x80;
          pPowerDataBuff[7] = 264 - pPowerDataBuff[4] - pPowerDataBuff[5];  // new checksum
          espconn_connect(pHPMeterTxConn);
          espconn_set_opt(pHPMeterTxConn, ESPCONN_REUSEADDR|ESPCONN_NODELAY);
          break;

        case DDS238_CURRENT:
          i = *(unsigned char *)(&(pRxBuff->pRcvMsgBuff[3]));
          i *= 1 << CHAR_BIT;
          i |= pRxBuff->pRcvMsgBuff[4];
          dds238_2_data->current = (float)(i)/DDS238_CURRENT_DIVIDER;
          break;

        case DDS238_IMPORT_ENERGY2:
          dds238_2_data->EnergyToGrid = (float)( (pRxBuff->pRcvMsgBuff[3] << 8) | (pRxBuff->pRcvMsgBuff[4]) )/DDS238_IMPORT_ENERGY2_DIVIDER;
          break;
          
        case DDS238_EXPORT_ENERGY2:
          dds238_2_data->EnergyFromGrid = (float)( (pRxBuff->pRcvMsgBuff[3] << 8) | (pRxBuff->pRcvMsgBuff[4]) )/DDS238_EXPORT_ENERGY2_DIVIDER;
          break;
        }
      dds238_2_data->IsWrong=0;
      }
    else {
      if ((dds238_2_data->IsWrong++) > 5 ) { return FALSE; }
      }
    if ((++dds238_2_data->nSequencer) > 3 ) { dds238_2_data->nSequencer=0; }

    return TRUE;
}


void ICACHE_FLASH_ATTR prepare_buff(unsigned char *TXbuf) {
	switch (dds238_2_data->nSequencer) {
		case 0:
			dds238_2_data->reg=DDS238_ACTIVE_POWER;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;

		case 1:
			dds238_2_data->reg=DDS238_CURRENT;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		case 2:
			dds238_2_data->reg=DDS238_IMPORT_ENERGY2;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		case 3:
			dds238_2_data->reg=DDS238_EXPORT_ENERGY2;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;

		case 4:
			dds238_2_data->reg=DDS238_FREQUENCY;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		case 5:
			dds238_2_data->reg=DDS238_IMPORT_ENERGY1;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		case 6:
			dds238_2_data->reg=DDS238_EXPORT_ENERGY1;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		case 7:
			dds238_2_data->reg=DDS238_VOLTAGE;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		case 8:
			dds238_2_data->reg=DDS238_REACTIVE_POWER;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		default:
			dds238_2_data->nSequencer=0;
		}
  nDDS238Statem=SM_WAITING_DDS238_ANSWER;
	return;		
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

void ICACHE_FLASH_ATTR buildFrame( unsigned char slaveAddress, unsigned char functionCode, short startAddress, short parameter, unsigned char* frame) {
  frame[0] = slaveAddress;
  frame[1] = functionCode;
  frame[2] = (char)(startAddress >> 8);
  frame[3] = (char)(startAddress);
  frame[4] = (char)(parameter >> 8);
  frame[5] = (char)(parameter);
  // CRC-calculation
  char checksumHi = 0;
  char checksumLo = 0;
  unsigned int crc = ModRTU_CRC(frame, 6, &checksumHi, &checksumLo);
  frame[6] = checksumLo;
  frame[7] = checksumHi;
}

// Check checksum in buffer with buffer length len
int ICACHE_FLASH_ATTR validCRC(unsigned char buf[], int len) {
  if (len < 4) { return FALSE; }
  unsigned char checksumHi = 0;
  unsigned char checksumLo = 0;
  ModRTU_CRC(buf, (len - 2), &checksumHi, &checksumLo);
  //printf("Checksum %02X %02X\n", checksumHi, checksumLo);
  if (buf[len - 2] == checksumLo && buf[len - 1] == checksumHi) {
    return TRUE;
    }
  return FALSE;
}

// Compute the MODBUS RTU CRC
unsigned int ICACHE_FLASH_ATTR ModRTU_CRC(unsigned char* buf, int len, unsigned char* checksumHi, unsigned char* checksumLo) {
  unsigned int crc = 0xFFFF;

  for (int pos = 0; pos < len; pos++) {
    crc ^= (unsigned int)buf[pos];          // XOR byte into least sig. byte of crc

    for (int i = 8; i != 0; i--) {    // Loop over each bit
      if ((crc & 0x0001) != 0) {      // If the LSB is set
        crc >>= 1;                    // Shift right and XOR 0xA001
        crc ^= 0xA001;
      }
      else                            // Else LSB is not set
        crc >>= 1;                    // Just shift right
    }
  }
  // Note, this number has low and high bytes swapped, so use it accordingly (or swap bytes)
  *checksumHi = (unsigned char)((crc >> 8) & 0xFF);
  *checksumLo = (unsigned char)(crc & 0xFF);
  return crc;
}

