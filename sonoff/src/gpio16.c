#include <ets_sys.h>
#include <osapi.h>
#include "gpio16.h"

//#define GPIO16_DBG
#ifdef GPIO16_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif

uint32_t pin_mux[TOT_GPIO_PINS] = {PAD_XPD_DCDC_CONF,  PERIPHS_IO_MUX_GPIO5_U,  PERIPHS_IO_MUX_GPIO4_U, 	 PERIPHS_IO_MUX_GPIO0_U,
								  PERIPHS_IO_MUX_GPIO2_U, PERIPHS_IO_MUX_MTMS_U, PERIPHS_IO_MUX_MTDI_U, PERIPHS_IO_MUX_MTCK_U,
								  PERIPHS_IO_MUX_MTDO_U, PERIPHS_IO_MUX_U0RXD_U, PERIPHS_IO_MUX_U0TXD_U, PERIPHS_IO_MUX_SD_DATA2_U,
								  PERIPHS_IO_MUX_SD_DATA3_U };
uint8_t pin_num[TOT_GPIO_PINS] = {16,  5,  4,  0,
								   2, 14, 12, 13,
								  15,  3,  1,  9,
								  10};
uint8_t pin_func[TOT_GPIO_PINS] = {0,           FUNC_GPIO5,  FUNC_GPIO4,  FUNC_GPIO0,
								  FUNC_GPIO2,  FUNC_GPIO14, FUNC_GPIO12, FUNC_GPIO13,
								  FUNC_GPIO15,  FUNC_GPIO3,  FUNC_GPIO1,  FUNC_GPIO9,
								  FUNC_GPIO10};
GPIO_INT_TYPE pin_int_type[TOT_GPIO_PINS] = {
								GPIO_PIN_INTR_DISABLE, GPIO_PIN_INTR_DISABLE, GPIO_PIN_INTR_DISABLE, GPIO_PIN_INTR_DISABLE,
								GPIO_PIN_INTR_DISABLE, GPIO_PIN_INTR_DISABLE, GPIO_PIN_INTR_DISABLE, GPIO_PIN_INTR_DISABLE,
								GPIO_PIN_INTR_DISABLE, GPIO_PIN_INTR_DISABLE, GPIO_PIN_INTR_DISABLE, GPIO_PIN_INTR_DISABLE,
								GPIO_PIN_INTR_DISABLE};

gpio_intr_handler gpio_intr_handl[TOT_GPIO_PINS] = { NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};

void ICACHE_FLASH_ATTR gpio16_output_conf(void) {
	WRITE_PERI_REG(PAD_XPD_DCDC_CONF,
                   (READ_PERI_REG(PAD_XPD_DCDC_CONF) & 0xffffffbc) | (uint32)0x1); 	// mux configuration for XPD_DCDC to output rtc_gpio0

	WRITE_PERI_REG(RTC_GPIO_CONF,
                   (READ_PERI_REG(RTC_GPIO_CONF) & (uint32)0xfffffffe) | (uint32)0x0);	//mux configuration for out enable

	WRITE_PERI_REG(RTC_GPIO_ENABLE,
                   (READ_PERI_REG(RTC_GPIO_ENABLE) & (uint32)0xfffffffe) | (uint32)0x1);	//out enable
}

void ICACHE_FLASH_ATTR gpio16_output_set(uint8 value) {
	WRITE_PERI_REG(RTC_GPIO_OUT, (READ_PERI_REG(RTC_GPIO_OUT) & (uint32)0xfffffffe) | (uint32)(value & 1));
}

void ICACHE_FLASH_ATTR gpio16_input_conf(void) {
	WRITE_PERI_REG(PAD_XPD_DCDC_CONF,
                   (READ_PERI_REG(PAD_XPD_DCDC_CONF) & 0xffffffbc) | (uint32)0x1); 	// mux configuration for XPD_DCDC and rtc_gpio0 connection

	WRITE_PERI_REG(RTC_GPIO_CONF,
                   (READ_PERI_REG(RTC_GPIO_CONF) & (uint32)0xfffffffe) | (uint32)0x0);	//mux configuration for out enable

	WRITE_PERI_REG(RTC_GPIO_ENABLE,
                   READ_PERI_REG(RTC_GPIO_ENABLE) & (uint32)0xfffffffe);	//out disable
}

uint8 ICACHE_FLASH_ATTR gpio16_input_get(void) {
	return (uint8)(READ_PERI_REG(RTC_GPIO_IN_DATA) & 1);
}

int ICACHE_FLASH_ATTR set_gpio_mode(unsigned pin, unsigned mode, unsigned pull, GPIO_INT_TYPE type) {
	if (pin >= TOT_GPIO_PINS)
		return -1;
	if(pin == 0) {
		if(mode == GPIO_INPUT)
			gpio16_input_conf();
		else
			gpio16_output_conf();
		return 1;
		}

	switch(pull) {
		case GPIO_PULLUP:
			PIN_PULLUP_EN(pin_mux[pin]);
			break;
		case GPIO_FLOAT:
			PIN_PULLUP_DIS(pin_mux[pin]);
			break;
		default:
			PIN_PULLUP_DIS(pin_mux[pin]);
			break;
	}

	switch(mode) {
		case GPIO_INPUT:
			GPIO_DIS_OUTPUT(pin_num[pin]);
			break;
		case GPIO_OUTPUT:
			ETS_GPIO_INTR_DISABLE();
			pin_int_type[pin] = GPIO_PIN_INTR_DISABLE;
			PIN_FUNC_SELECT(pin_mux[pin], pin_func[pin]);
			//disable interrupt
			gpio_pin_intr_state_set(GPIO_ID_PIN(pin_num[pin]), GPIO_PIN_INTR_DISABLE);
			//clear interrupt status
			GPIO_REG_WRITE(GPIO_STATUS_W1TC_ADDRESS, BIT(pin_num[pin]));
			GPIO_REG_WRITE(GPIO_PIN_ADDR(GPIO_ID_PIN(pin_num[pin])), GPIO_REG_READ(GPIO_PIN_ADDR(GPIO_ID_PIN(pin_num[pin]))) & (~ GPIO_PIN_PAD_DRIVER_SET(GPIO_PAD_DRIVER_ENABLE))); //disable open drain;
			ETS_GPIO_INTR_ENABLE();
			break;
		case GPIO_INT:
			ETS_GPIO_INTR_DISABLE();
			PIN_FUNC_SELECT(pin_mux[pin], pin_func[pin]);
			GPIO_DIS_OUTPUT(pin_num[pin]);
			gpio_register_set(GPIO_PIN_ADDR(GPIO_ID_PIN(pin_num[pin])), GPIO_PIN_INT_TYPE_SET(GPIO_PIN_INTR_DISABLE)
                        | GPIO_PIN_PAD_DRIVER_SET(GPIO_PAD_DRIVER_DISABLE)
                        | GPIO_PIN_SOURCE_SET(GPIO_AS_PIN_SOURCE));
			GPIO_REG_WRITE(GPIO_STATUS_W1TC_ADDRESS, BIT(pin_num[pin]));
			pin_int_type[pin] = type;
			gpio_pin_intr_state_set(GPIO_ID_PIN(pin_num[pin]), type);			
			ETS_GPIO_INTR_ENABLE();
			break;
		default:
			break;
	}
	return 1;
}

int ICACHE_FLASH_ATTR gpio_write(unsigned pin, unsigned level) {
	if (pin >= TOT_GPIO_PINS)
		return -1;
	if (pin == 0){
	  gpio16_output_conf();
	  gpio16_output_set(level);
	  return 1;
	  }
	GPIO_OUTPUT_SET(GPIO_ID_PIN(pin_num[pin]), level);
	return 1;
}

int ICACHE_FLASH_ATTR gpio_read(unsigned pin) {
	if (pin >= TOT_GPIO_PINS)
		return -1;
	if(pin == 0){
		return 0x1 & gpio16_input_get();
	}
	// GPIO_DIS_OUTPUT(pin_num[pin]);
	return 0x1 & GPIO_INPUT_GET(GPIO_ID_PIN(pin_num[pin]));
}

void ICACHE_FLASH_ATTR gpio_intr_dispatcher(gpio_intr_handler cb) {
	uint8 i, level;
	//disable global interrupt
	ETS_GPIO_INTR_DISABLE();
	// clear gpio status
	uint32 gpio_status = GPIO_REG_READ(GPIO_STATUS_ADDRESS);

	for (i = 0; i < TOT_GPIO_PINS; i++) {
		if (pin_int_type[i] && (gpio_status & BIT(pin_num[i])) ) {
			DBG("%d", i);
			//disable interrupt
			gpio_pin_intr_state_set(GPIO_ID_PIN(pin_num[i]), GPIO_PIN_INTR_DISABLE);
			//clear interrupt status
			GPIO_REG_WRITE(GPIO_STATUS_W1TC_ADDRESS, gpio_status & BIT(pin_num[i]));
			level = 0x1 & GPIO_INPUT_GET(GPIO_ID_PIN(pin_num[i]));
			if(gpio_intr_handl[i]){
				DBG("level %d", level);
				gpio_intr_handl[i](i, level);
				}
			//enable interrupt
			gpio_pin_intr_state_set(GPIO_ID_PIN(pin_num[i]), pin_int_type[i]);
			}
		}
	//enable global interrupt
	ETS_GPIO_INTR_ENABLE();
}

void ICACHE_FLASH_ATTR gpio_intr_attach(unsigned pin, gpio_intr_handler cb) {
	gpio_intr_handl[pin]=cb;
	ETS_GPIO_INTR_ATTACH(gpio_intr_dispatcher, cb);
}

int ICACHE_FLASH_ATTR gpio_intr_deattach(unsigned pin) {
	if (pin >= TOT_GPIO_PINS)
		return -1;
	//disable global interrupt
	ETS_GPIO_INTR_DISABLE();
	//clear interrupt status
	GPIO_REG_WRITE(GPIO_STATUS_W1TC_ADDRESS, BIT(pin_num[pin]));
	pin_int_type[pin] = GPIO_PIN_INTR_DISABLE;
	gpio_intr_handl[pin]=NULL;
	//disable interrupt
	gpio_pin_intr_state_set(GPIO_ID_PIN(pin_num[pin]), pin_int_type[pin]);
	//enable global interrupt
	ETS_GPIO_INTR_ENABLE();
	return 1;
}

/* Measures the length (in microseconds) of a pulse on the pin; state is HIGH
* or LOW, the type of pulse to measure.  Works on pulses from 2-3 microseconds
* to 3 minutes in length, but must be called at least a few dozen microseconds
* before the start of the pulse. */
unsigned long pulseIn(uint8_t pin, uint8_t state, unsigned long timeout) {
  /*
	// cache the port and bit of the pin in order to speed up the
	// pulse width measuring loop and achieve finer resolution.  calling
	// digitalRead() instead yields much coarser resolution.
	uint8_t bit = digitalPinToBitMask(pin);
	uint8_t port = digitalPinToPort(pin);
	uint8_t stateMask = (state ? bit : 0);
	unsigned long width = 0; // keep initialization out of time critical area
	
	// convert the timeout from microseconds to a number of times through
	// the initial loop; it takes 16 clock cycles per iteration.
	unsigned long numloops = 0;
	unsigned long maxloops = microsecondsToClockCycles(timeout) / 16;
	
	// wait for any previous pulse to end
	while ((gpio_read(pin) & bit) == stateMask)
		if (numloops++ == maxloops)
			return 0;
	
	// wait for the pulse to start
	while ((gpio_read(pin) & bit) != stateMask)
		if (numloops++ == maxloops)
			return 0;
	
	// wait for the pulse to stop
	while ((gpio_read(pin) & bit) == stateMask) {
		if (numloops++ == maxloops)
			return 0;
		width++;
	}

	// convert the reading to microseconds. The loop has been determined
	// to be 20 clock cycles long and have about 16 clocks between the edge
	// and the start of the loop. There will be some error introduced by
	// the interrupt handlers.
	return clockCyclesToMicroseconds(width * 21 + 16);
  */
	return (21 + 16);
}
