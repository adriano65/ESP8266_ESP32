#include <osapi.h>
#include <ets_sys.h>
#include <c_types.h>
#include <errno.h>
#include <mem.h>

#include <i2c_master.h>
#include "mqtt_client.h"
#include "config.h"
#include "ina226.h"

#define INA226_DBG

#ifdef INA226_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif
#define PRINTNET(format, ...) do { if (pTXdata) { TXdatalen+=os_sprintf(pTXdata+TXdatalen, format, ## __VA_ARGS__ ); TXdatalen+=os_sprintf(pTXdata+TXdatalen, "\n");} } while(0)

ina226_t * ina226_data;

bool ICACHE_FLASH_ATTR ina226Init() {
    ina226_data = (ina226_t *)os_zalloc(sizeof(ina226_t));
    uint8_t reg_data[2];

    if (ina226_reg_read(INA226_MANFID, reg_data, 2)) {
        if ((reg_data[0] == 0x54) && (reg_data[1] == 0x49)) {
            DBG("hardware ID (MSB) 0x%02x", reg_data[0]);
            DBG("hardware ID (LSB) 0x%02x", reg_data[1]);

            reg_data[0]=0x4F;
            reg_data[1]=0xFF;
            ina226_reg_write(INA226_CONFREG, reg_data, 2);
            msleep(50);
            ina226_reg_read(INA226_CONFREG, reg_data, 2);
            DBG("INA226_CONFREG (MSB) 0x%02x", reg_data[0]);
            DBG("INA226_CONFREG (LSB) 0x%02x", reg_data[1]);
            /*
            INA226_CURRENT_SCALE
            reg_data[0]=0x4F;
            reg_data[1]=0xFF;
            ina226_reg_write(INA226_CALIBRATION, reg_data, 2);
            msleep(50);
            */
            return true;
            }
        DBG("Bad manufact hardware id reg_data[0] 0x%02x, reg_data[1] 0x%02x", reg_data[0], reg_data[1]);
        return false;
        } 
    DBG("Bad I2C hardware/connection");
    return false;
}

bool ICACHE_FLASH_ATTR ina226_get_results() {
    uint8_t reg_data[2];
    if (ina226_reg_read(INA226_SHUNT_VOLTAGE, reg_data, 2)) {
        uint16_t svolt = reg_data[0] << 8 | reg_data[1];
        ina226_data->shunt_mv=(reg_data[0] & 0x80) ? 0 : svolt*2.5/1000;
        DBG("INA226_SHUNT_VOLTAGE 0x%02x, 0x%02x, shunt_mv %d", reg_data[0], reg_data[1], ina226_data->shunt_mv);
        }
    if (ina226_reg_read(INA226_BUS_VOLTAGE, reg_data, 2)) {
        uint16_t bvolt = reg_data[0] << 8 | reg_data[1];
        ina226_data->actualvoltage=bvolt*1.25;
        DBG("INA226_BUS_VOLTAGE 0x%02x, 0x%02x, actualvoltage %d", reg_data[0], reg_data[1], ina226_data->actualvoltage);
        }
    ina226_data->nCounter++;
}

/*
bool INA226::calibrate(float rShuntValue, float iMaxExpected) {
    uint16_t calibrationValue;
    rShunt = rShuntValue;

    float iMaxPossible, minimumLSB;

    iMaxPossible = vShuntMax / rShunt;

    minimumLSB = iMaxExpected / 32767;

    currentLSB = (uint16_t)(minimumLSB * 100000000);
    currentLSB /= 100000000;
    currentLSB /= 0.0001;
    currentLSB = ceil(currentLSB);
    currentLSB *= 0.0001;

    powerLSB = currentLSB * 25;

    calibrationValue = (uint16_t)((0.00512) / (currentLSB * rShunt));

    writeRegister16(INA226_REG_CALIBRATION, calibrationValue);

    return true;
}
*/

bool ICACHE_FLASH_ATTR ina226_reg_read(uint8_t reg, uint8_t *data, uint32_t len) {
    beginTransmission(INA226_ADD);
    write(reg);
    endTransmission();

    requestFrom(INA226_ADD);
    os_delay_us(10);
    read(len, data);
    endTransmission();    
    return true;
}

bool ICACHE_FLASH_ATTR ina226_reg_write(uint8_t reg, uint8_t *data, uint32_t len) {
    beginTransmission(INA226_ADD);
    write(reg);
    for(int i=0; i<len;i++) {
        write(data[i]);
        }
    endTransmission();

    return true;
}


