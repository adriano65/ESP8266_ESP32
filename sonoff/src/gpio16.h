#ifndef __GPIO16_H__
#define __GPIO16_H__

#include "gpio.h"
#include <c_types.h>

#define TOT_GPIO_PINS 13

#define GPIO_16 0
#define GPIO_5  1
#define GPIO_4  2
#define GPIO_0  3
#define GPIO_2  4
#define GPIO_14 5
#define GPIO_12 6
#define GPIO_13 7
#define GPIO_15 8
#define GPIO_3  9
#define GPIO_1  10
#define GPIO_9  11
#define GPIO_10 12

#define GPIO_FLOAT 0
#define GPIO_PULLUP 1

#define GPIO_INPUT 0
#define GPIO_OUTPUT 1
#define GPIO_INT 2

typedef void (* gpio_intr_handler)(unsigned pin, unsigned level);

void gpio16_output_conf(void);
void gpio16_output_set(uint8 value);
void gpio16_input_conf(void);
uint8 gpio16_input_get(void);
int ICACHE_FLASH_ATTR set_gpio_mode(unsigned pin, unsigned mode, unsigned pull, GPIO_INT_TYPE type);
int ICACHE_FLASH_ATTR gpio_write(unsigned pin, unsigned level);
int ICACHE_FLASH_ATTR gpio_read(unsigned pin);
void ICACHE_FLASH_ATTR gpio_intr_attach(unsigned pin, gpio_intr_handler cb);
int ICACHE_FLASH_ATTR gpio_intr_deattach(unsigned pin);

#endif
