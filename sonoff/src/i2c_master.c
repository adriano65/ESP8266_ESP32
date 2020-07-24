/******************************************************************************
 * Copyright 2013-2014 Espressif Systems (Wuxi)
 *
 * FileName: i2c_master.c
 *
 * Description: i2c master API
 *
 * Modification history:
 *     2014/3/12, v1.0 create this file.
*******************************************************************************/
#include "ets_sys.h"
#include "osapi.h"

#include "gpio16.h"
#include "i2c_master.h"

#define I2C_DBG

#ifdef I2C_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#define PRINTNET(format, ...) do { if (pTXdata) { *TXdatalen=os_sprintf(pTXdata, format, ## __VA_ARGS__ ); *TXdatalen+=os_sprintf(pTXdata+*TXdatalen, "\n");} } while(0)
#else
#define DBG(format, ...) do { } while(0)
#define PRINTNET(format, ...) do { } while(0)
#endif


LOCAL uint8 m_nLastSDA;
LOCAL uint8 m_nLastSCL;

bool ICACHE_FLASH_ATTR beginTransmission(uint8_t i2c_addr) {
    uint8_t i2c_addr_write = (i2c_addr << 1);
    
    i2c_master_start();
    i2c_master_writeByte(i2c_addr_write);
    
    return i2c_master_checkAck();
}

void ICACHE_FLASH_ATTR endTransmission()
{
    i2c_master_stop();
}

bool ICACHE_FLASH_ATTR write(uint8_t i2c_data)
{
    i2c_master_writeByte(i2c_data);
    
    return i2c_master_checkAck();
}

bool ICACHE_FLASH_ATTR requestFrom(uint8_t i2c_addr)
{
    uint8_t i2c_addr_read = (i2c_addr << 1) + 1;
    
    i2c_master_start();
    i2c_master_writeByte(i2c_addr_read);
    
    return i2c_master_checkAck();
}

bool ICACHE_FLASH_ATTR read(uint8_t num_bytes, int8_t* data)
{
    if (num_bytes < 1 || data == NULL) return false;

    int i;
    for(i = 0; i < num_bytes - 1; i++)
    {
        data[i] = i2c_master_readByte();
        i2c_master_send_ack();
    }
    // nack the final packet so that the slave releases SDA
    data[num_bytes - 1] = i2c_master_readByte();
    i2c_master_send_nack();

    return true;
}
/******************************************************************************
 * FunctionName : i2c_master_setDC
 * Description  : Internal used function -
 *                    set i2c SDA and SCL bit value for half clk cycle
 * Parameters   : uint8 SDA
 *                uint8 SCL
 * Returns      : NONE
*******************************************************************************/
LOCAL void ICACHE_FLASH_ATTR i2c_master_setDC(uint8 SDA, uint8 SCL) {
    SDA	&= 0x01;
    SCL	&= 0x01;
    m_nLastSDA = SDA;
    m_nLastSCL = SCL;

    if ((0 == SDA) && (0 == SCL)) {
        I2C_MASTER_SDA_LOW_SCL_LOW();
    } else if ((0 == SDA) && (1 == SCL)) {
        I2C_MASTER_SDA_LOW_SCL_HIGH();
    } else if ((1 == SDA) && (0 == SCL)) {
        I2C_MASTER_SDA_HIGH_SCL_LOW();
    } else {
        I2C_MASTER_SDA_HIGH_SCL_HIGH();
    }
}

/******************************************************************************
 * FunctionName : i2c_master_getDC
 * Description  : Internal used function -
 *                    get i2c SDA bit value
 * Parameters   : NONE
 * Returns      : uint8 - SDA bit value
*******************************************************************************/
LOCAL uint8 ICACHE_FLASH_ATTR i2c_master_getDC(void){
    uint8 sda_out;
    set_gpio_mode(I2C_MASTER_SDA_GPIO, GPIO_INPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);        //SDA
    os_delay_us(5);
    sda_out = gpio_read(I2C_MASTER_SDA_GPIO);
    set_gpio_mode(I2C_MASTER_SDA_GPIO, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);        //SDA
    //DBG("0x%02X", sda_out);
    return sda_out;
}

/******************************************************************************
 * FunctionName : i2c_master_init
 * Description  : initialize I2C bus to enable i2c operations
 * Parameters   : NONE
 * Returns      : NONE
*******************************************************************************/
void ICACHE_FLASH_ATTR i2c_master_init(void) {
    uint8 i;

    i2c_master_setDC(1, 0);
    os_delay_us(5);

    // when SCL = 0, toggle SDA to clear up
    i2c_master_setDC(0, 0) ;
    os_delay_us(5);
    i2c_master_setDC(1, 0) ;
    os_delay_us(5);

    // set data_cnt to max value
    for (i = 0; i < 28; i++) {
        i2c_master_setDC(1, 0);
        os_delay_us(5);	// sda 1, scl 0
        i2c_master_setDC(1, 1);
        os_delay_us(5);	// sda 1, scl 1
    }

    // reset all
    i2c_master_stop();
    return;
}

/******************************************************************************
 * FunctionName : i2c_master_gpio_init
 * Description  : config SDA and SCL gpio to open-drain output mode,
 *                mux and gpio num defined in i2c_master.h
 * Parameters   : NONE
 * Returns      : NONE
*******************************************************************************/
void ICACHE_FLASH_ATTR i2c_master_gpio_init(void) {
    ETS_GPIO_INTR_DISABLE() ;

    set_gpio_mode(I2C_MASTER_SCL_GPIO, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    set_gpio_mode(I2C_MASTER_SDA_GPIO, GPIO_OUTPUT, GPIO_PULLUP, GPIO_PIN_INTR_DISABLE);
    ETS_GPIO_INTR_ENABLE() ;

    i2c_master_init();
}

/******************************************************************************
 * FunctionName : i2c_master_start
 * Description  : set i2c to send state
 * Parameters   : NONE
 * Returns      : NONE
*******************************************************************************/
void ICACHE_FLASH_ATTR i2c_master_start(void) {
    i2c_master_setDC(1, m_nLastSCL);
    os_delay_us(5);
    i2c_master_setDC(1, 1);
    os_delay_us(5);	// sda 1, scl 1
    i2c_master_setDC(0, 1);
    os_delay_us(5);	// sda 0, scl 1
}

/******************************************************************************
 * FunctionName : i2c_master_stop
 * Description  : set i2c to stop sending state
 * Parameters   : NONE
 * Returns      : NONE
*******************************************************************************/
void ICACHE_FLASH_ATTR i2c_master_stop(void) {
    os_delay_us(5);

    i2c_master_setDC(0, m_nLastSCL);
    os_delay_us(5);	// sda 0
    i2c_master_setDC(0, 1);
    os_delay_us(5);	// sda 0, scl 1
    i2c_master_setDC(1, 1);
    os_delay_us(5);	// sda 1, scl 1
}

/******************************************************************************
 * FunctionName : i2c_master_setAck
 * Description  : set ack to i2c bus as level value
 * Parameters   : uint8 level - 0 or 1
 * Returns      : NONE
*******************************************************************************/
void ICACHE_FLASH_ATTR i2c_master_setAck(uint8 level) {
    i2c_master_setDC(m_nLastSDA, 0);
    os_delay_us(5);
    i2c_master_setDC(level, 0);
    os_delay_us(5);	// sda level, scl 0
    i2c_master_setDC(level, 1);
    os_delay_us(8);	// sda level, scl 1
    i2c_master_setDC(level, 0);
    os_delay_us(5);	// sda level, scl 0
    i2c_master_setDC(1, 0);
    os_delay_us(5);
}

/******************************************************************************
 * FunctionName : i2c_master_getAck
 * Description  : confirm if peer send ack
 * Parameters   : NONE
 * Returns      : uint8 - ack value, 0 or 1
*******************************************************************************/
uint8 ICACHE_FLASH_ATTR i2c_master_getAck(void) {
    uint8 retVal;
    i2c_master_setDC(m_nLastSDA, 0);
    os_delay_us(5);
    i2c_master_setDC(1, 0);
    os_delay_us(5);
    i2c_master_setDC(1, 1);
    os_delay_us(5);

    retVal = i2c_master_getDC();
    os_delay_us(5);
    i2c_master_setDC(1, 0);
    os_delay_us(5);

    return retVal;
}

/******************************************************************************
* FunctionName : i2c_master_checkAck
* Description  : get dev response
* Parameters   : NONE
* Returns      : true : get ack ; false : get nack
*******************************************************************************/
bool ICACHE_FLASH_ATTR i2c_master_checkAck(void) {
    if(i2c_master_getAck()){
        return FALSE;
    }else{
        return TRUE;
    }
}

/******************************************************************************
* FunctionName : i2c_master_send_ack
* Description  : response ack
* Parameters   : NONE
* Returns      : NONE
*******************************************************************************/
void ICACHE_FLASH_ATTR i2c_master_send_ack(void) {
    i2c_master_setAck(0x0);
}
/******************************************************************************
* FunctionName : i2c_master_send_nack
* Description  : response nack
* Parameters   : NONE
* Returns      : NONE
*******************************************************************************/
void ICACHE_FLASH_ATTR i2c_master_send_nack(void) {
    i2c_master_setAck(0x1);
}

/******************************************************************************
 * FunctionName : i2c_master_readByte
 * Description  : read Byte from i2c bus
 * Parameters   : NONE
 * Returns      : uint8 - readed value
*******************************************************************************/
uint8 ICACHE_FLASH_ATTR i2c_master_readByte(void) {
    uint8 retVal = 0;
    uint8 k, i;

    os_delay_us(5);
    i2c_master_setDC(m_nLastSDA, 0);
    os_delay_us(5);	// sda 1, scl 0

    for (i = 0; i < 8; i++) {
        os_delay_us(5);
        i2c_master_setDC(1, 0);
        os_delay_us(5);	// sda 1, scl 0
        i2c_master_setDC(1, 1);
        os_delay_us(5);	// sda 1, scl 1

        k = i2c_master_getDC();
        os_delay_us(5);

        if (i == 7) {
            os_delay_us(3);   ////
        }

        k <<= (7 - i);
        retVal |= k;
    }

    i2c_master_setDC(1, 0);
    os_delay_us(5);	// sda 1, scl 0

    return retVal;
}

/******************************************************************************
 * FunctionName : i2c_master_writeByte
 * Description  : write wrdata value(one byte) into i2c
 * Parameters   : uint8 wrdata - write value
 * Returns      : NONE
*******************************************************************************/
void ICACHE_FLASH_ATTR i2c_master_writeByte(uint8 wrdata) {
    uint8 dat;
    sint8 i;

    os_delay_us(5);

    i2c_master_setDC(m_nLastSDA, 0);
    os_delay_us(5);

    for (i = 7; i >= 0; i--) {
        dat = wrdata >> i;
        i2c_master_setDC(dat, 0);
        os_delay_us(5);
        i2c_master_setDC(dat, 1);
        os_delay_us(5);

        if (i == 0) {
            os_delay_us(3);   ////
        }

        i2c_master_setDC(dat, 0);
        os_delay_us(5);
    }
}

bool i2c_slave_write(uint8_t slave_addr, uint8_t *data, uint8_t len) {
    bool success = false;
    do {
        i2c_master_start();
        i2c_master_writeByte(slave_addr << 1);
        while (len--) {
            i2c_master_writeByte(*data++);
            }
        i2c_master_stop();
        success = true;
    } while(0);
    return success;
}

bool i2c_slave_read(uint8_t slave_addr, uint8_t data, uint8_t *buf, uint32_t len) {
    bool success = false;
    do {
        i2c_master_start();
        i2c_master_writeByte(slave_addr << 1);
        i2c_master_writeByte(data);
        i2c_master_stop();
        i2c_master_start();
        i2c_master_writeByte(slave_addr << 1 | 1);  // Slave address + read
        while(len) {
            //*buf = i2c_master_readByte(len == 1);
            *buf = i2c_master_readByte();
            buf++;
            len--;
            }
        success = true;
        } while(0);
    i2c_master_stop();
    if (!success) {
        DBG("read error slave_addr 0x%02X", slave_addr);
        }
    return success;
}

/*
bool i2c_write(uint8_t byte) {
    bool nack;
    uint8_t bit;
    for (bit = 0; bit < 8; bit++) {
        i2c_write_bit((byte & 0x80) != 0);
        byte <<= 1;
    }
    nack = i2c_read_bit();
    return !nack;
}

uint8_t i2c_read(bool ack) {
    uint8_t byte = 0;
    uint8_t bit;
    for (bit = 0; bit < 8; bit++) {
        byte = (byte << 1) | i2c_read_bit();
    }
    i2c_write_bit(ack);
    return byte;
}

*/