
#ifndef __SI7021_H__
#define __SI7021_H__

#include <c_types.h>

#define SI7021_I2C_ADDR 0x40
// list of commands SI7021
#define SI7021_RH_READ             0xE5 
#define SI7021_TEMP_READ           0xE3 
#define SI7021_POST_RH_TEMP_READ   0xE0 
#define SI7021_RESET               0xFE 
#define SI7021_USER1_READ          0xE7 
#define SI7021_USER1_WRITE 			   0xE6 

static bool ICACHE_FLASH_ATTR waitState(uint8_t expectedstate);
bool ICACHE_FLASH_ATTR SI7021read(void);
bool SISensorInit(DHTType senstype, uint8_t pin);
#endif
