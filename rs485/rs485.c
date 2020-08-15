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

#define RUNONLINUX 1

#if defined(RUNONLINUX)
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <pthread.h>
#include <syslog.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/msg.h>
#include <sys/ioctl.h>
#include <sys/stat.h>  
#include <fcntl.h>
#include <dirent.h>

#else
#include <osapi.h>
#include <ets_sys.h>
#include <c_types.h>
#include <mem.h>

#include "mqtt_client.h"
#include "config.h"
#include "uart.h"
#include "dds238-2.h"

// UartDev is defined and initialized in rom code.
extern UartDevice UartDev;

void uart0_rx_handler(void *para);

dds238_2_t * dds238_2_data;

#endif

#include <errno.h>
#include "rs485.h"

#if defined(RUNONLINUX)
static struct termios oldtio, newtio;    // main port settings, before/after
static char gpsport[80]="/dev/ttyUSB0";
static char run=TRUE;
static volatile int idComDev;

void dds_HandleSig(int signo) {
  if (signo==SIGINT || signo==SIGTERM) {
    dds238End();
    }
  exit(0);
}

//ioctl(idComDev, TIOCMBIS, &DTR_flag); //Set DTR pin
//ioctl(idComDev, TIOCMBIC, &DTR_flag); //Clear DTR pin
int main(int argc, char *argv[]) {
	fd_set rdset;
	struct timeval timeout;
	int retval, nbyte, n, DTR_flag, RTS_flag;
	unsigned char pTXbuf[12] = { 0x60, 0x86, 0x78, 0x66, 0x00, 0x06, 0x86, 0x00, 0x00, 0x00, 0x80, 0x80 };
	unsigned char RXbuf[32];
	unsigned int loop=0;
  
	int i=0;

	signal(SIGINT, dds_HandleSig);
	signal(SIGTERM, dds_HandleSig);
  	//newtio.c_cc[VMIN] = 15;
  	//newtio.c_cc[VMIN] = 14;
  	//newtio.c_cc[VMIN] = 13;
  	newtio.c_cc[VMIN] = 12; // ModBus
  	//newtio.c_cc[VMIN] = 10;       // blocking read until x chars received
  	//newtio.c_cc[VMIN] = 8;       // blocking read until x chars received
  	//newtio.c_cc[VMIN] = 6;       // blocking read until x chars received
  	//newtio.c_cc[VMIN] = 5;       // blocking read until x chars received
  	//newtio.c_cc[VMIN] = 1;
	dds238Init();

	while(run) {
		FD_ZERO(&rdset);
		FD_SET(idComDev, &rdset);      // input serial may wakeup
		// Initialize the timeout data structure.
		timeout.tv_sec = 0;
		timeout.tv_usec = 500000;

		//prepare_buff(&loop, pTXbuf);
		//halfduplex_write(pTXbuf);

		//printf("--> RX\n");
		retval = select(FD_SETSIZE, &rdset, NULL, NULL, &timeout);
		if (!retval) {          	// select exited due to timeout
		  SerialTMOManager(loop);
		  }
		else if (FD_ISSET(idComDev, &rdset)) {
				nbyte = read(idComDev, RXbuf, newtio.c_cc[VMIN]);
				//nbyte = read(idComDev, RXbuf, 12);
				printf("\nRXbuf %d\n", nbyte);
				for (n=0; n<nbyte; n++) {
					printf("%02X ", RXbuf[n]);
					}
				printf("\n");
				
				//validChecksum(RXbuf+3, nbyte-3);
				
				float value21 = ( (RXbuf[2] << 8) | (RXbuf[1]) )/10;
				float value43 = ( (RXbuf[4] << 8) | (RXbuf[3]) )/10;
				float value65 = ( (RXbuf[6] << 8) | (RXbuf[5]) )/10;
				float value87 = ( (RXbuf[8] << 8) | (RXbuf[7]) )/10;
				float value109 = ( (RXbuf[10] << 8) | (RXbuf[9]) )/10;
				printf("value21 %.2f, value43 %.2f, value65 %.2f, value87 %.2f, value109 %.2f\n", value21, value43, value65, value87, value109);
				
				}
		loop++;
		//printf("getchar\n"); getchar();
	}

	tty_close(idComDev, &newtio, &oldtio);
    printf("end.\n", gpsport) ;

	return 0;
}

int ICACHE_FLASH_ATTR dds238Init() {
  //idComDev = tty_open(gpsport, &newtio, &oldtio, B2400);
  idComDev = tty_open(gpsport, &newtio, &oldtio, B9600);
  
  
  if (idComDev < 0) {    // some error
    printf("open error on %s\n", gpsport) ;
    return(-1) ;
    }
	
	return TRUE;
}

void dds238End(void) {
  run = FALSE;
  usleep(100*1000);
}

int ICACHE_FLASH_ATTR uart0_tx_one_char(uint8 TxChar) {
	int status;
	
	if (write(idComDev, &TxChar, 1) != 1)
		printf("--> write err !!!\n");
		
	return TRUE;
}

void ICACHE_FLASH_ATTR uart0_write(char *c, int len) {
    int nlen;

    for (nlen=0; nlen<len; nlen++) {
        uart0_tx_one_char(c[nlen]);
        }
}

void halfduplex_write_withDTR_or_RTS(unsigned char *TXbuf) {
	int DTR_flag, RTS_flag;
	//struct rs485_ctrl ctrl485;
	
    DTR_flag = TIOCM_DTR;
    RTS_flag = TIOCM_RTS;
	
	//#define RTS_SET_CLEAR
	#define USE_RTS
	//ioctl(idComDev, TIOCSERSETRS485, &ctrl485);
	
	#if defined (RTS_SET_CLEAR)
		#if defined (USE_RTS)
		ioctl(idComDev, TIOCMBIS, &RTS_flag);	// Set RTS
		#else
		ioctl(idComDev, TIOCMBIS, &DTR_flag);	// Set DTR
		#endif
	#else
		#if defined (USE_RTS)
		ioctl(idComDev, TIOCMBIC, &RTS_flag);	// Clear RTS
		#else
		ioctl(idComDev, TIOCMBIC, &DTR_flag);	// Clear DTR
		#endif
	#endif
	
	uart0_write(TXbuf, 8);		// 16,6 ms @ 4800 bps
	tcdrain(idComDev);
	#if defined (USE_RTS)
	usleep(4000);
	#else
	usleep(28000);
	//usleep(22000);
	//usleep(18000);
	//usleep(15000);
	//usleep(10000);
	//usleep(8000);
	#endif
	
	#if defined (RTS_SET_CLEAR)
		#if defined (USE_RTS)
		ioctl(idComDev, TIOCMBIC, &RTS_flag);	// Clear RTS
		#else
		ioctl(idComDev, TIOCMBIC, &DTR_flag);	// Clear DTR
		#endif
	#else
		#if defined (USE_RTS)
		ioctl(idComDev, TIOCMBIS, &RTS_flag);	// Set RTS
		#else
		ioctl(idComDev, TIOCMBIS, &DTR_flag);	// Set DTR
		#endif
	#endif
}

void halfduplex_write(unsigned char *TXbuf) {	
	uart0_write(TXbuf, 12);		// 16,6 ms @ 4800 bps
	tcdrain(idComDev);
}

void prepare_buff(unsigned char *loop, unsigned char *TXbuf) {
	
	switch (*loop) {
		case 0:
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, DDS238_VOLTAGE, 0x0001, TXbuf);
			break;
			
		case 1:
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, DDS238_CURRENT, 0x0001, TXbuf);
			break;
			
		case 2:
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, DDS238_FREQUENCY, 0x0001, TXbuf);
			break;
			
		case 3:
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, DDS238_ACTUAL_IMPORT_ENERGY1, 0x0001, TXbuf);
			break;
			
		case 4:
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, DDS238_ACTUAL_IMPORT_ENERGY2, 0x0001, TXbuf);
			break;
			
		case 5:
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, DDS238_ACTUAL_EXPORT_ENERGY1, 0x0001, TXbuf);
			break;
			
		case 6:
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, DDS238_ACTUAL_EXPORT_ENERGY2, 0x0001, TXbuf);
			break;
			
		case 7:
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, DDS238_ACTIVE_POWER, 0x0001, TXbuf);
			break;
			
		case 8:
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, DDS238_REACTIVE_POWER, 0x0001, TXbuf);
			break;
			
		default:
			*loop=0;
			return;
		}
	printf("loop %1d, TXbuf %02X %02X %02X %02X %02X %02X %02X %02X\n", *loop, TXbuf[0], TXbuf[1], TXbuf[2], TXbuf[3], TXbuf[4], TXbuf[5], TXbuf[6], TXbuf[7]);
	return;		
}
// -----------------------------------------------------------------------
int tty_open(char * pname, struct termios * pnewtio, struct termios * poldtio, int brate) {
	int fd;

	// Open device for reading and writing and not as controlling tty
	// because we don't want to get killed if linenoise sends CTRL-C.

	fd = open(pname, O_RDWR | O_NOCTTY ) ;
	if (fd < 0) {
		return(fd);
		}

	if ( tcgetattr(fd, poldtio) ) {
		printf("tcgetattr\n");
		return -1;
		}
	poldtio->c_cc[VMIN]=pnewtio->c_cc[VMIN];
	
	memcpy(pnewtio, poldtio, sizeof(struct termios));
	
	// BAUDRATE: Set bps rate. You could also use cfsetispeed and cfsetospeed.
	// CRTSCTS : output hardware flow control (only used if the cable has all necessary lines. See sect. 7 of Serial-HOWTO)
	// CS8     : 8n1 (8bit, no parity, 1 stopbit)
	// CSTOPB  : 2 stop bit
	// CLOCAL  : local connection, no modem contol
	// CREAD   : enable receiving characters
	// HUPCL   : lower modem control lines after last process closes the device (hang up).

	//cfsetispeed(pnewtio, brate);
	//cfsetospeed(pnewtio, brate);
	////pnewtio->c_cflag = CS8 | HUPCL | CLOCAL | CREAD;
	//pnewtio->c_cflag = CS8 | HUPCL | CLOCAL | CREAD | ~CRTSCTS;
	
	// ----------------------------------------------------------------
	//pnewtio->c_cflag = brate | CS8 | CSTOPB | HUPCL | CLOCAL | CREAD;
	pnewtio->c_cflag = brate | CS8 | HUPCL | CLOCAL | CREAD;
	//pnewtio->c_cflag = brate | CS8 | PARENB | HUPCL | CLOCAL | CREAD;

	// IGNBRK  : ignore breaks
	// IGNPAR  : ignore bytes with parity errors
	// otherwise make device raw (no other input processing)
	pnewtio->c_iflag = IGNPAR | IGNBRK ;
	//pnewtio->c_iflag = 0;

	// Raw output.
	pnewtio->c_oflag = 0 ;

	// Set input mode (non-canonical, no echo,...)
	pnewtio->c_lflag &= ~(ECHO | ECHONL | ICANON | IEXTEN | ISIG);

	// initialize all control characters
	// default values can be found in /usr/include/termios.h, and are given
	// in the comments, but we don't need them here

	pnewtio->c_cc[VINTR]    = 0 ;       // Ctrl-c
	pnewtio->c_cc[VQUIT]    = 0 ;       // Ctrl-bkslash
	pnewtio->c_cc[VERASE]   = 0 ;       // del
	pnewtio->c_cc[VKILL]    = 0 ;       // @
	pnewtio->c_cc[VEOF]     = 0 ;       // Ctrl-d
	pnewtio->c_cc[VSWTC]    = 0 ;       // '0'
	pnewtio->c_cc[VSTART]   = 0 ;       // Ctrl-q
	pnewtio->c_cc[VSTOP]    = 0 ;       // Ctrl-s
	pnewtio->c_cc[VSUSP]    = 0 ;       // Ctrl-z
	pnewtio->c_cc[VEOL]     = 0 ;       // '0'
	pnewtio->c_cc[VREPRINT] = 0 ;       // Ctrl-r
	pnewtio->c_cc[VDISCARD] = 0 ;       // Ctrl-u
	pnewtio->c_cc[VWERASE]  = 0 ;       // Ctrl-w
	pnewtio->c_cc[VLNEXT]   = 0 ;       // Ctrl-v
	pnewtio->c_cc[VEOL2]    = 0 ;       // '0'

	//pnewtio->c_cc[VTIME]    = 1 ;       // inter-character timer unused 0.1 sec
	pnewtio->c_cc[VTIME]    = 0 ;       // no timeout (use select)
	//pnewtio->c_cc[VMIN]     = 1 ;       // blocking read until x chars received

	//  now clean the modem line and activate the settings for the port

	tcflush(fd, TCIFLUSH);
	tcsetattr(fd, TCSANOW, pnewtio);

	usleep(10*1000) ;         // settling time

	return(fd) ;
}

// *********************************************************************
void tty_close(int fd, struct termios * pnewtio, struct termios * poldtio) {
  tcflush(fd, TCIOFLUSH) ;            // buffer flush
  tcsetattr(fd, TCSANOW, poldtio) ;
  close(fd) ;
}

int SerialTMOManager(unsigned int loop) {
    tcflush(idComDev,TCIOFLUSH);
	printf("RX TMO %u\n", loop);
    /*
    pthread_mutex_lock(&gps_mutex);
    // ADD here
    pthread_mutex_unlock(&gps_mutex);
    */
	return 0;
}

#else 						// ------------------------------------------------------------------------ RUNONESP
//mosquitto_sub -v -p 5800 -h 192.168.1.6 -t 'sonoff_pow/221/+' 
void ICACHE_FLASH_ATTR uart0_rx_handler(void *para) {
    #define RX_MSG_LEN  7
    /* uart0 and uart1 intr combine together, when interrupt occur, see reg 0x3ff20020, bit2, bit0 represents uart1 and uart0 respectively */
    RcvMsgBuff *pRxBuff = (RcvMsgBuff *)para;

    if (UART_RXFIFO_FULL_INT_ST != (READ_PERI_REG(UART_INT_ST(UART0)) & UART_RXFIFO_FULL_INT_ST)) { return; }
    WRITE_PERI_REG(UART_INT_CLR(UART0), UART_RXFIFO_FULL_INT_CLR);

    while (READ_PERI_REG(UART_STATUS(UART0)) & (UART_RXFIFO_CNT << UART_RXFIFO_CNT_S)) {
        if ( (pRxBuff->pWritePos - pRxBuff->pRcvMsgBuff) == RX_MSG_LEN) {
          if (validChecksum(pRxBuff->pRcvMsgBuff, RX_MSG_LEN)) {
						switch (dds238_2_data->reg) {
							case DDS238_VOLTAGE:						
								dds238_2_data->voltage = ( (pRxBuff->pRcvMsgBuff[3] << 8) | (pRxBuff->pRcvMsgBuff[4]) )/DDS238_VOLTAGE_DIVIDER;
								dds238_2_data->nSequencer++;
								break;
							case DDS238_IMPORT_ENERGY1:
								dds238_2_data->ImportEnergy = ( (pRxBuff->pRcvMsgBuff[3] << 8) | (pRxBuff->pRcvMsgBuff[4]) )/10;
								dds238_2_data->nSequencer++;
								break;
							case DDS238_EXPORT_ENERGY1:
								dds238_2_data->ExportEnergy = ( (pRxBuff->pRcvMsgBuff[3] << 8) | (pRxBuff->pRcvMsgBuff[4]) )/10;
								dds238_2_data->nSequencer++;
								break;
							case DDS238_FREQUENCY:
								dds238_2_data->ExportEnergy = ( (pRxBuff->pRcvMsgBuff[3] << 8) | (pRxBuff->pRcvMsgBuff[4]) )/DDS238_FREQUENCY_DIVIDER;
								dds238_2_data->nSequencer=0;
								break;
							default:
								dds238_2_data->nSequencer=0;
								dds238_2_data->IsValid=22;
								break;
							}
							dds238_2_data->IsValid=1;
						}
					else {
            dds238_2_data->IsValid=0;
            }
					// reset position write pointer and stop queueing chars
					pRxBuff->pWritePos = pRxBuff->pRcvMsgBuff;
					READ_PERI_REG(UART_FIFO(UART0)) & 0xFF;
					//break;
          }
        else {  // keep storing chars
          *(pRxBuff->pWritePos++) = READ_PERI_REG(UART_FIFO(UART0)) & 0xFF;
          }
        }
}

int ICACHE_FLASH_ATTR dds238Init() {
    dds238_2_data = (dds238_2_t *)os_zalloc(sizeof(dds238_2_t));
    UartDev.baut_rate 	 = BIT_RATE_9600;
		UartDev.data_bits    = EIGHT_BITS;
    UartDev.flow_ctrl    = NONE_CTRL;
    UartDev.parity       = NONE_BITS;
    //UartDev.stop_bits    = TWO_STOP_BIT;
    UartDev.stop_bits    = ONE_STOP_BIT;

    uart_config(uart0_rx_handler);
    ETS_UART_INTR_ENABLE();
		msleep(10);
	return TRUE;
}

void ICACHE_FLASH_ATTR prepare_buff(unsigned char *TXbuf) {
	switch (dds238_2_data->nSequencer) {		
		case 0:
			dds238_2_data->reg=DDS238_VOLTAGE;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			//if (dds238_2_data->IsValid)	dds238_2_data->nSequencer++;
			break;
			
		case 1:
			dds238_2_data->reg=DDS238_IMPORT_ENERGY1;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			//if (dds238_2_data->IsValid)	dds238_2_data->nSequencer++;
			break;
			
		case 2:
			dds238_2_data->reg=DDS238_EXPORT_ENERGY1;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			//if (dds238_2_data->IsValid)	dds238_2_data->nSequencer++;
			break;

		case 3:
			dds238_2_data->reg=DDS238_FREQUENCY;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		/// end of game ;-)			
		case 4:
			dds238_2_data->reg=DDS238_CURRENT;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		case 5:
			dds238_2_data->reg=DDS238_IMPORT_ENERGY2;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		case 6:
			dds238_2_data->reg=DDS238_EXPORT_ENERGY2;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		case 7:
			dds238_2_data->reg=DDS238_ACTIVE_POWER;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		case 8:
			dds238_2_data->reg=DDS238_REACTIVE_POWER;
			buildFrame( DDS238_ADDRESS, READ_HOLDING_REGISTERS, dds238_2_data->reg, 0x0001, TXbuf);
			break;
			
		default:
			dds238_2_data->nSequencer=0;
		}
	return;		
}

int ICACHE_FLASH_ATTR uart0_tx_one_char(uint8 TxChar) {
    while (TRUE) {
		uint32 fifo_cnt = READ_PERI_REG(UART_STATUS(UART0)) & (UART_TXFIFO_CNT<<UART_TXFIFO_CNT_S);
		if ((fifo_cnt >> UART_TXFIFO_CNT_S & UART_TXFIFO_CNT) < 126) {
			break;
		    }
	    }
	WRITE_PERI_REG(UART_FIFO(UART0), TxChar);
	return TRUE;
}

#endif

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
int ICACHE_FLASH_ATTR validChecksum(unsigned char buf[], int len) {
  unsigned char checksumHi = 0;
  unsigned char checksumLo = 0;
  unsigned int checksum = 0;
  if (len < 4) { return FALSE; }
  
	for (int n=0; n<len; n++) {
		checksum+=buf[n];
		}

  printf("Checksum %04X\n", checksum);
  return FALSE;
}


// Check crc in buffer with buffer length len
int ICACHE_FLASH_ATTR validCRC(unsigned char buf[], int len) {
  if (len < 4) { return FALSE; }
  unsigned char checksumHi = 0;
  unsigned char checksumLo = 0;
  ModRTU_CRC(buf, (len - 2), &checksumHi, &checksumLo);
  printf("CRC %02X %02X\n", checksumHi, checksumLo);
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
