#ifndef __BUTTON_H__
#define __BUTTON_H__
#include <c_types.h>

gpio_intr_handler gpio0_press_intr_callback(unsigned pin, unsigned level);
gpio_intr_handler gpio0_release_intr_callback(unsigned pin, unsigned level); 
void ICACHE_FLASH_ATTR SendButton();

#endif
