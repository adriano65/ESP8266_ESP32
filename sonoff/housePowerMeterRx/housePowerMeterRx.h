#ifndef GTN1000_DRV_H_
#define GTN1000_DRV_H_

#define TX_DELAY 700

typedef struct {
  float batVolts;
  float batAmps;
  float HousePowerReq;
  float HousePowerPrevReq;
  uint8_t IsWrong;
} HPMeterRx_t;

extern HPMeterRx_t * HPMeterRx_data;

extern unsigned int nGTN_HPRStatem;
extern struct espconn * pGTN_HPRConn;

#define ANY_ADDRESS 0xFE

// ------------------------ GTN1000
#define GTN1000_ADDRESS 0x23
//#define GTN_HPRX_MSG_LEN  15
#define GTN_HPRX_MSG_LEN  14

// ------------------------ State Machine
#define SM_NULL                       0
#define SM_WAITING_GTNPOW_DATA        2
#define SM_FILL_GTNRXBUFFER           3
#define SM_SEND_BUFFER2GTN            7
#define SM_DISABLE_SOCKET             8


int ICACHE_FLASH_ATTR housePowerMeterRxInit();
static void ICACHE_FLASH_ATTR uart0_rx_handler(void *para);
int ICACHE_FLASH_ATTR uart0_tx_one_char(uint8 TxChar);
void ICACHE_FLASH_ATTR uart0_write(char *c, int len);

void ICACHE_FLASH_ATTR pGTN_HPR_rx_cb(void *arg, char *data, uint16_t len);
void ICACHE_FLASH_ATTR pGTN_HPR_disc_cb(void *arg);
void ICACHE_FLASH_ATTR pGTN_HPR_recon_cb(void *arg, int8_t err);

void ICACHE_FLASH_ATTR pGTN_HPRTest_connect_cb(void *arg);

void ICACHE_FLASH_ATTR ResetRxBuff();

void ICACHE_FLASH_ATTR start_rs485_timer(uint16_t interval);
static void ICACHE_FLASH_ATTR rs485_timer_cb(uint16_t interval);

#endif


