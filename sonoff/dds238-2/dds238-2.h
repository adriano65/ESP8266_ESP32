#ifndef DDS238_DRV_H_
#define DDS238_DRV_H_

void ICACHE_FLASH_ATTR prepare_buff(unsigned char *TXbuf);

typedef struct {
	unsigned char nSequencer;
  float voltage;
  float current;
  float EnergyToGrid;
  float EnergyFromGrid;
  float ActivePower;
  unsigned int reg;
  unsigned char IsValid;
  unsigned char spare_char;
} dds238_2_t;

extern dds238_2_t * dds238_2_data;
extern unsigned int nDDS238Statem;
extern struct espconn * pGTN1000Conn;


#define ANY_ADDRESS 0xFE

// ------------------------ DDS238
#define DDS238_ADDRESS 0x01
#define READ_HOLDING_REGISTERS 0x03
#define READ_INPUT_REGISTERS   0x04
#define WRITE_SINGLE_REGISTER  0x06

#define DDS238_VOLTAGE                0x000C
#define DDS238_VOLTAGE_DIVIDER  10

#define DDS238_CURRENT                0x000D
#define DDS238_CURRENT_DIVIDER  100

#define DDS238_IMPORT_ENERGY1  0x0008

#define DDS238_IMPORT_ENERGY2  0x0009

#define DDS238_IMPORT_ENERGY2_DIVIDER  100
#define DDS238_EXPORT_ENERGY1  0x000A

#define DDS238_EXPORT_ENERGY2  0x000B
#define DDS238_EXPORT_ENERGY2_DIVIDER  100

#define DDS238_ACTIVE_POWER           0x000E
#define DDS238_ACTIVE_POWER_DIVIDER  1

#define DDS238_REACTIVE_POWER         0x000F

#define DDS238_FREQUENCY              0x0011
#define DDS238_FREQUENCY_DIVIDER  100

#define DDS238_RX_MSG_LEN  7    // including CRC

// ------------------------ GTN1000
//#define GTN1000_ADDRESS 0x00
#define GTN1000_ADDRESS 0x60
//#define GTN1000_ADDRESS 0x06
//#define GTN1000_RX_MSG_LEN  12
#define GTN1000_RX_MSG_LEN  10

// ------------------------ State Machine
#define SM_NULL                       0
#define SM_WAITING_MERDANERA          4
#define SM_WAITING_DDS238_ANSWER      1
#define SM_WAITING_GTN1000_POLL       2
#define SM_FILL_GTNRXBUFFER           3
#define SM_SEND_BUFFER2DDS238         6
#define SM_SEND_BUFFER2GTN            7
#define SM_DISABLE_SOCKET             8


int ICACHE_FLASH_ATTR dds238Init();
void dds238End(void);
static void ICACHE_FLASH_ATTR uart0_rx_handler(void *para);
int ICACHE_FLASH_ATTR uart0_tx_one_char(uint8 TxChar);
void ICACHE_FLASH_ATTR uart0_write(char *c, int len);

void ICACHE_FLASH_ATTR pGTN1000_connect_cb(void *arg);
void ICACHE_FLASH_ATTR pGTN1000_rx_cb(void *arg, char *data, uint16_t len);
void ICACHE_FLASH_ATTR ResetRxBuff();
void ICACHE_FLASH_ATTR ManageDDSanswer(void *para);

//void ICACHE_FLASH_ATTR start_TCPSend_timer(uint16_t interval);
void ICACHE_FLASH_ATTR buildFrame( unsigned char slaveAddress, unsigned char functionCode, short startAddress, short parameter, unsigned char* frame);
int ICACHE_FLASH_ATTR validCRC(unsigned char buf[], int len);

unsigned int ICACHE_FLASH_ATTR ModRTU_CRC(unsigned char* buf, int len, unsigned char* checksumHi, unsigned char* checksumLo);
int processRegister(char slaveAddress, char functionCode, short startAddress, short parameter);
int SerialTMOManager();

#endif


