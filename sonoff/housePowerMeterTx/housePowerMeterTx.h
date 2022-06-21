#ifndef GTN1000_DRV_H_
#define GTN1000_DRV_H_

typedef struct {
  float ActivePower;
  uint8_t IsWrong;
  uint8_t pTmpBuff[8];
} HPMeterTx_t;

extern HPMeterTx_t * HPMeterTx_data;

extern unsigned int nHPMeterTxStatem;
extern struct espconn * pHPMeterTxConn;

#define ANY_ADDRESS 0xFE

// ------------------------ GTN1000
#define GTN1000_ADDRESS 0x24
#define GTN1000_RX_MSG_LEN  8

// ------------------------ State Machine
#define SM_NULL                       0
#define SM_WAITING_GTN1000_POLL       2
#define SM_FILL_GTNRXBUFFER           3
#define SM_SEND_BUFFER2GTN            7
#define SM_DISABLE_SOCKET             8


int ICACHE_FLASH_ATTR housePowerMeterTxInit();
void ICACHE_FLASH_ATTR housePowerMeterTxEnd(void);
static void ICACHE_FLASH_ATTR uart0_rx_handler(void *para);
int ICACHE_FLASH_ATTR uart0_tx_one_char(uint8 TxChar);
void ICACHE_FLASH_ATTR uart0_write(char *c, int len);

void ICACHE_FLASH_ATTR createConnection();
void ICACHE_FLASH_ATTR pGTN1000_connect_cb(void *arg);
void ICACHE_FLASH_ATTR pGTN1000_recon_cb(void *arg, int8_t err);
void ICACHE_FLASH_ATTR pGTN1000_rx_cb(void *arg, char *data, uint16_t len);
void ICACHE_FLASH_ATTR ResetRxBuff();

#endif


