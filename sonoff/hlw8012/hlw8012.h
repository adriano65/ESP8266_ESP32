#ifndef HLW8012_h
#define HLW8012_h
#include <c_types.h>

typedef struct {
    uint8_t sel_pin_val;

    unsigned long A_pulse_width;
    unsigned long last_A_intr;

    unsigned long V_pulse_width;
    unsigned long last_V_intr;

    unsigned long Watt_pulse_width;
    unsigned long last_Watt_intr;

    float actualcurrent;
    float actualvoltage;
    float actualRMSPower;
} HLW8012;


// Internal voltage reference value
#define V_REF               2.43

// The factor of a 1mOhm resistor
// as per recomended circuit in datasheet
// A 1mOhm resistor allows a ~30A max measurement
#define R_CURRENT           0.001

// This is the factor of a voltage divider of 6x 470K upstream and 1k downstream
// as per recomended circuit in datasheet
#define R_VOLTAGE           2821

// Frequency of the HLW8012 internal clock
#define F_OSC               3579000

// Maximum pulse with in microseconds
// If longer than this pulse width is reset to 0
// This value is purely experimental.
// Higher values allow for a better precision but reduce sampling rate and response speed to change
// Lower values increase sampling rate but reduce precision
// Values below 0.5s are not recommended since current and voltage output will have no time to stabilise
//#define PULSE_TIMEOUT       1500000
#define PULSE_TIMEOUT       160000
//#define PULSE_TIMEOUT       1600000


// Set SEL_PIN to HIGH to sample current
// This is the case for Itead's Sonoff POW, where a
// the SEL_PIN drives a transistor that pulls down
// the SEL pin in the HLW8012 when closed
// CF1 mode
enum {
    CF1_VOLTAGE_MEASURE,
    CF1_AMPERE_MEASURE
};

// GPIOs
#define SEL_PIN                         GPIO_5
#define AMP_VOLT_PIN                    GPIO_13
#define ACTIVE_POWER_PIN                GPIO_14

// These are the nominal values for the resistors in the circuit
#define CURRENT_RESISTOR                0.001
#define VOLTAGE_RESISTOR_UPSTREAM       ( 5 * 470000 ) // Real: 2280k
#define VOLTAGE_RESISTOR_DOWNSTREAM     ( 1000 ) // Real 1.009k

#define VOLTAGE_RESISTOR				((VOLTAGE_RESISTOR_UPSTREAM + VOLTAGE_RESISTOR_DOWNSTREAM) / VOLTAGE_RESISTOR_DOWNSTREAM)

void calculateDefaultMultipliers();
void ICACHE_FLASH_ATTR HLW8012Init(void);

void ICACHE_FLASH_ATTR updateCurrent();
void ICACHE_FLASH_ATTR updateVoltage();
void ICACHE_FLASH_ATTR updateActivePower();

float ICACHE_FLASH_ATTR getApparentPower();

void ICACHE_FLASH_ATTR calibrate();
void ICACHE_FLASH_ATTR showData();
gpio_intr_handler amp_volt_intr(unsigned pin, unsigned level);
gpio_intr_handler Watt_intr(unsigned pin, unsigned level);

extern HLW8012 * hlw8012;

#endif
