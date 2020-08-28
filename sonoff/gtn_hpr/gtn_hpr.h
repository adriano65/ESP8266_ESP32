#ifndef GTN1000_DRV_H_
#define GTN1000_DRV_H_

extern unsigned int nGTN_HPRStatem;
extern struct espconn * pGTN_HPRConn;

#define ANY_ADDRESS 0xFE

// ------------------------ GTN1000
//#define GTN1000_ADDRESS 0x00
#define GTN1000_ADDRESS 0x60
//#define GTN1000_ADDRESS 0x06
//#define GTN1000_RX_MSG_LEN  12
#define GTN1000_RX_MSG_LEN  10

// ------------------------ State Machine
#define SM_NULL                       0
#define SM_WAITING_MERDANERA          4
#define SM_WAITING_GTN1000_POLL       2
#define SM_FILL_GTNRXBUFFER           3
#define SM_SEND_BUFFER2GTN            7
#define SM_DISABLE_SOCKET             8


int ICACHE_FLASH_ATTR gtn_hprInit();
static void ICACHE_FLASH_ATTR uart0_rx_handler(void *para);
int ICACHE_FLASH_ATTR uart0_tx_one_char(uint8 TxChar);
void ICACHE_FLASH_ATTR uart0_write(char *c, int len);

void ICACHE_FLASH_ATTR pGTN_HPR_connect_cb(void *arg);
void ICACHE_FLASH_ATTR pGTN_HPR_rx_cb(void *arg, char *data, uint16_t len);
void ICACHE_FLASH_ATTR pGTN_HPR_disc_cb(void *arg);
void ICACHE_FLASH_ATTR pGTN_HPR_recon_cb(void *arg);

void ICACHE_FLASH_ATTR ResetRxBuff();

#endif


