#ifndef DDS238_DRV_H_
#define DDS238_DRV_H_

#if defined(RUNONLINUX)

#define ICACHE_FLASH_ATTR 
#define TRUE 1
#define FALSE 0
#define uint8 unsigned char

int tty_open(char * pname, struct termios * pnewtio, struct termios * poldtio, int brate);
void tty_close(int fd, struct termios * pnewtio, struct termios * poldtio);
void halfduplex_write(unsigned char *TXbuf);
void prepare_buff(unsigned char *loop, unsigned char *TXbuf);

#else
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
} dds238_2_t;

extern dds238_2_t * dds238_2_data;

#endif


#define ANY_ADDRESS 0xFE

#define DDS238_ADDRESS 0x01
#define READ_HOLDING_REGISTERS 0x03
#define READ_INPUT_REGISTERS   0x04
#define WRITE_SINGLE_REGISTER  0x06

#define DDS238_VOLTAGE                0x000C
#define DDS238_VOLTAGE_DIVIDER  10

#define DDS238_CURRENT                0x000D
#define DDS238_CURRENT_DIVIDER  100

#define DDS238_ACTUAL_IMPORT_ENERGY1  0x0008

#define DDS238_ACTUAL_IMPORT_ENERGY2  0x0009

#define DDS238_IMPORT_ENERGY2_DIVIDER  100
#define DDS238_ACTUAL_EXPORT_ENERGY2  0x000A

#define DDS238_ACTUAL_EXPORT_ENERGY2  0x000B
#define DDS238_EXPORT_ENERGY2_DIVIDER  100

#define DDS238_ACTIVE_POWER           0x000E
#define DDS238_ACTIVE_POWER_DIVIDER  1

#define DDS238_REACTIVE_POWER         0x000F

#define DDS238_FREQUENCY              0x0011
#define DDS238_FREQUENCY_DIVIDER  100

int ICACHE_FLASH_ATTR dds238Init();
void dds238End(void);
void ICACHE_FLASH_ATTR uart0_rx_handler(void *);
void ICACHE_FLASH_ATTR uart0_write(char *c, int len);
void ICACHE_FLASH_ATTR buildFrame( unsigned char slaveAddress, unsigned char functionCode, short startAddress, short parameter, unsigned char* frame);
int ICACHE_FLASH_ATTR validChecksum(unsigned char buf[], int len);

unsigned int ICACHE_FLASH_ATTR ModRTU_CRC(unsigned char* buf, int len, unsigned char* checksumHi, unsigned char* checksumLo);
int processRegister(char slaveAddress, char functionCode, short startAddress, short parameter);
int SerialTMOManager();

#endif


