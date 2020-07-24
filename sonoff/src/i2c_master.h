#ifndef __I2C_MASTER_H__
#define __I2C_MASTER_H__
#include <c_types.h>

//#define I2C_MASTER_SDA_GPIO GPIO_5
//#define I2C_MASTER_SCL_GPIO GPIO_0
#define I2C_MASTER_SDA_GPIO GPIO_1
//#define I2C_MASTER_SCL_GPIO GPIO_9
#define I2C_MASTER_SCL_GPIO GPIO_3

#define I2C_MASTER_SDA_HIGH_SCL_HIGH() gpio_write(I2C_MASTER_SDA_GPIO, 1); gpio_write(I2C_MASTER_SCL_GPIO, 1);

#define I2C_MASTER_SDA_HIGH_SCL_LOW() gpio_write(I2C_MASTER_SDA_GPIO, 1); gpio_write(I2C_MASTER_SCL_GPIO, 0);

#define I2C_MASTER_SDA_LOW_SCL_HIGH() gpio_write(I2C_MASTER_SDA_GPIO, 0); gpio_write(I2C_MASTER_SCL_GPIO, 1);

#define I2C_MASTER_SDA_LOW_SCL_LOW()  gpio_write(I2C_MASTER_SDA_GPIO, 0); gpio_write(I2C_MASTER_SCL_GPIO, 0);

bool ICACHE_FLASH_ATTR beginTransmission(uint8_t i2c_addr);
bool ICACHE_FLASH_ATTR requestFrom(uint8_t i2c_addr);
bool ICACHE_FLASH_ATTR read(uint8_t num_bytes, int8_t* data);
bool ICACHE_FLASH_ATTR write(uint8_t i2c_data);
void ICACHE_FLASH_ATTR endTransmission();

void ICACHE_FLASH_ATTR i2c_master_gpio_init(void);
void ICACHE_FLASH_ATTR i2c_master_init(void);

void ICACHE_FLASH_ATTR i2c_master_stop(void);
void ICACHE_FLASH_ATTR i2c_master_start(void);
void ICACHE_FLASH_ATTR i2c_master_setAck(uint8 level);
uint8 ICACHE_FLASH_ATTR i2c_master_getAck(void);
uint8 ICACHE_FLASH_ATTR i2c_master_readByte(void);
void ICACHE_FLASH_ATTR i2c_master_writeByte(uint8 wrdata);

bool ICACHE_FLASH_ATTR i2c_master_checkAck(void);
void ICACHE_FLASH_ATTR i2c_master_send_ack(void);
void ICACHE_FLASH_ATTR i2c_master_send_nack(void);

#endif
