#ifndef __INA226_H
#define __INA226_H

//#include "stdint.h"
//#include "stdbool.h"

/* Define slave address and internal register of ina226 */
#define         INA226_ADD                         0x45
#define         INA226_CONFREG                     0x00
// Max shunt voltage is 82 mV -------------------
#define         INA226_SHUNT_VOLTAGE               0x01
#define         SHUNT_VOLTAGE_MAX                  0.08192F
// Max bus voltage is 36 V ----------------------
#define         INA226_BUS_VOLTAGE                 0x02
#define         BUS_VOLTAGE_MAX                    36
#define         INA226_POWER_SCALE                 0x03
#define         INA226_CURRENT_SCALE               0x04
#define         INA226_CALIBRATION                 0x05
#define         INA226_MANFID                      0xFE
#define         INA226_DIEID                       0xFF

typedef struct {
	uint32_t current_lsb; // Current LSB in 10E-7 amps
	uint32_t power_lsb;
	uint16_t cal_value; 
	uint16_t shunt_amps;
	uint16_t shunt_mv;
    float actualcurrent;
    float actualvoltage;
    float actualPower;
	uint16_t nCounter;
} ina226_t;

bool ICACHE_FLASH_ATTR ina226Init();
bool ICACHE_FLASH_ATTR ina226_get_results();
bool ICACHE_FLASH_ATTR ina226_reg_read(uint8_t reg, uint8_t *data, uint32_t len);
bool ICACHE_FLASH_ATTR ina226_reg_write(uint8_t reg, uint8_t *data, uint32_t len);

extern ina226_t * ina226_data;

#endif

