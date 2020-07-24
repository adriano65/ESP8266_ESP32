#ifndef BLINKLED_H
#define BLINKLED_H
#include <c_types.h>
#include <lwip/sys.h>

enum state_machine {
	LED_ON = 0,
	LED_OFF,
    LED_ON2_BLINKS,
    LED_ON3_BLINKS,
    LED_OFF2_BLINKS_WAIT,
    LED_OFF2_BLINKS_WAIT2,
    LED_OFF3_BLINKS_WAIT,
    LED_OFF3_BLINKS_WAIT3,
    LED_OFF2_BLINKS,
	LED_WAIT
};
typedef unsigned char state_machine_t;

enum led_delays {
    LED_BLINK_INIT = 600/50,
    LED_BLINK_STAMODE_CONNECTED	= 800/50,
    LED_BLINK_STAMODE_GOT_IP = 1000/50,
    LED_BLINK_STAMODE_DISCONNECTED = 1200/50,
    LED_BLINK_SOFTAPMODE_STACONNECTED = 1500/50,
    LED_BLINK_SOFTAPMODE_STADISCONNECTED = 2500/50,
    LED_BLINK_SOFTAPMODE = 1800/50,
};

typedef struct {
    unsigned int intervals_50mS;
    unsigned char nBlinks;
    state_machine_t state_machine;
    unsigned int nCounter;
} Blink_Data;

#include <user_interface.h>

void ICACHE_FLASH_ATTR blink_timercb(Blink_Data *);
void ICACHE_FLASH_ATTR set_blink_timer_delay(uint16_t delay, unsigned char nBlinks);
void ICACHE_FLASH_ATTR blink_timer_init();

#endif
