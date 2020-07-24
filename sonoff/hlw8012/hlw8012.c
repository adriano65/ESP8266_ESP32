#include <ets_sys.h>
//remember math library too in makefile
#include <math.h>
//#include <real.h>
//#include <fastmath.h>
#include <c_types.h>
#include <mem.h>
//#include <lwip/sys.h>

#include <osapi.h>
#include "mqtt_client.h"
#include "config.h"
#include "gpio16.h"
#include "network.h"
#include "../rtc_ntp/ntp.h"
#include "hlw8012.h"

#define HWL8012_DEBUG

#ifdef HWL8012_DEBUG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(...)
#endif

HLW8012 * hlw8012;
sys_mutex_t hlw8012_lock;

void ICACHE_FLASH_ATTR showData(){
    TXdatalen=os_sprintf(pTXdata, "actualcurrent %d.%d\n", (int)hlw8012->actualcurrent, (int)((hlw8012->actualcurrent-(int)hlw8012->actualcurrent)/100.0));
    TXdatalen+=os_sprintf(pTXdata+TXdatalen, "A_pulse_width %u\n", hlw8012->A_pulse_width);
    TXdatalen+=os_sprintf(pTXdata+TXdatalen, "actualvoltage %d.%d\n", (int)hlw8012->actualvoltage, (int)((hlw8012->actualvoltage-(int)hlw8012->actualvoltage)/100.0));
    TXdatalen+=os_sprintf(pTXdata+TXdatalen, "V_pulse_width %u\n", hlw8012->V_pulse_width);
    TXdatalen+=os_sprintf(pTXdata+TXdatalen, "actualRMSPower %d.%d\n", (int)hlw8012->actualRMSPower, (int)((hlw8012->actualRMSPower-(int)hlw8012->actualRMSPower)/100.0));
    TXdatalen+=os_sprintf(pTXdata+TXdatalen, "Watt_pulse_width %u\n", hlw8012->Watt_pulse_width );
    /*
    // Show default (as per datasheet) multipliers
    TXdatalen+=os_sprintf(pTXdata+TXdatalen, "AmpMul %d.%d\n", (int)flashConfig.AmpMul, (int)((flashConfig.AmpMul-(int)flashConfig.AmpMul)/100));
    TXdatalen+=os_sprintf(pTXdata+TXdatalen, "VoltMul %d.%d\n", (int)flashConfig.VoltMul, (int)((flashConfig.VoltMul-(int)flashConfig.VoltMul)/100));
    TXdatalen+=os_sprintf(pTXdata+TXdatalen, "Watt_Mul %d.%d\n", (int)flashConfig.Watt_Mul, (int)((flashConfig.Watt_Mul-(int)flashConfig.Watt_Mul)/100));
    */
}

void ICACHE_FLASH_ATTR updateCurrent() {
    sys_mutex_lock(&hlw8012_lock);
    hlw8012->actualcurrent=((hlw8012->A_pulse_width > 0) && (hlw8012->Watt_pulse_width > 0)) ? flashConfig.AmpMul / hlw8012->A_pulse_width : 0;
    //hlw8012->actualcurrent=(hlw8012->A_pulse_width > 0) ? flashConfig.AmpMul / hlw8012->A_pulse_width : 0;
    hlw8012->A_pulse_width=0;
    sys_mutex_unlock(&hlw8012_lock);
}

void ICACHE_FLASH_ATTR updateVoltage() {
    sys_mutex_lock(&hlw8012_lock);
    hlw8012->actualvoltage=(hlw8012->V_pulse_width > 0) ? flashConfig.VoltMul / hlw8012->V_pulse_width : 0;
    hlw8012->V_pulse_width=0;
    sys_mutex_unlock(&hlw8012_lock);
}

void ICACHE_FLASH_ATTR updateActivePower() {
    sys_mutex_lock(&hlw8012_lock);
    hlw8012->actualRMSPower=(hlw8012->Watt_pulse_width > 0) ? flashConfig.Watt_Mul / hlw8012->Watt_pulse_width : 0;
    hlw8012->Watt_pulse_width=0;
    sys_mutex_unlock(&hlw8012_lock);
}

gpio_intr_handler Watt_intr(unsigned pin, unsigned level) {
    uint32 now;
    int32 uSperiod;

    now=NOW();
    //now=system_get_rtc_time();
    sys_mutex_lock(&hlw8012_lock);
    uSperiod=(now - hlw8012->last_Watt_intr);
    hlw8012->Watt_pulse_width = ((uSperiod > PULSE_TIMEOUT) || uSperiod<0) ? 0 : uSperiod;
    hlw8012->last_Watt_intr = now;
    sys_mutex_unlock(&hlw8012_lock);
}

gpio_intr_handler amp_volt_intr(unsigned pin, unsigned level) {
    uint32 now;
    int32 uSperiod;

    now=NOW();
    //now=system_get_rtc_time();
    sys_mutex_lock(&hlw8012_lock);
    switch (hlw8012->sel_pin_val) {
    //switch ( gpio_read(SEL_PIN) ) {  // DO NOT USE
        case CF1_AMPERE_MEASURE:
            uSperiod=(now - hlw8012->last_A_intr);
            hlw8012->A_pulse_width = ((uSperiod > PULSE_TIMEOUT) || uSperiod<0) ? 0 : uSperiod;
            hlw8012->last_A_intr = now;
            break;

        case CF1_VOLTAGE_MEASURE:
            uSperiod=(now - hlw8012->last_V_intr);
            hlw8012->V_pulse_width = ((uSperiod > PULSE_TIMEOUT) || uSperiod<0) ? 0 : uSperiod;
            hlw8012->last_V_intr = now;
            break;
        }
    sys_mutex_unlock(&hlw8012_lock);
}


// Library expects an interrupt on both edges
void ICACHE_FLASH_ATTR setInterrupts() {
    if (! set_gpio_mode(AMP_VOLT_PIN, GPIO_INT, GPIO_PULLUP, GPIO_PIN_INTR_NEGEDGE)) { DBG("AMP_VOLT_PIN not set to INT"); return; }
    gpio_intr_attach(AMP_VOLT_PIN, (gpio_intr_handler)amp_volt_intr);
	if (! set_gpio_mode(ACTIVE_POWER_PIN, GPIO_INT, GPIO_PULLUP, GPIO_PIN_INTR_NEGEDGE)) { DBG("ACTIVE_POWER_PIN not set to INT"); return; }
    gpio_intr_attach(ACTIVE_POWER_PIN, (gpio_intr_handler)Watt_intr);
}

// Initialize HLW8012
// * cf_pin, cf1_pin and sel_pin are GPIOs to the HLW8012 IC
// * currentWhen is the value in sel_pin to select current sampling
// * set use_interrupts to true to use interrupts to monitor pulse widths
// * leave pulse_timeout to the default value, recommended when using interrupts
void ICACHE_FLASH_ATTR HLW8012Init(void) {
    hlw8012 = (HLW8012 *)os_zalloc(sizeof(HLW8012));

    set_gpio_mode(SEL_PIN, GPIO_OUTPUT, GPIO_FLOAT, GPIO_PIN_INTR_DISABLE);
    //gpio_write(SEL_PIN, CF1_AMPERE_MEASURE);
    //hlw8012->sel_pin_val=CF1_AMPERE_MEASURE;
    gpio_write(SEL_PIN, CF1_VOLTAGE_MEASURE);
    hlw8012->sel_pin_val=CF1_VOLTAGE_MEASURE;
    

    // These values are used to calculate current, voltage and power factors as per datasheet formula
    // These are the nominal values for the Sonoff POW resistors:
    // * The CURRENT_RESISTOR is the 1milliOhm copper-manganese resistor in series with the main line
    // * The VOLTAGE_RESISTOR_UPSTREAM are the 5 470kOhm resistors in the voltage divider that feeds the V2P pin in the HLW8012
    // * The VOLTAGE_RESISTOR_DOWNSTREAM is the 1kOhm resistor in the voltage divider that feeds the V2P pin in the HLW8012
    // These are the multipliers for current, voltage and power as per datasheet
    // These values divided by output period (in useconds) give the actual value
    // For power a frequency of 1Hz means around 12W
    // For current a frequency of 1Hz means around 15mA
    // For voltage a frequency of 1Hz means around 0.5V
    //#define A_TRIM_VALUE  1
    //#define A_TRIM_VALUE  67.6139240506
    // 8171 == 632 mA   144 W
    //#define V_TRIM_VALUE  2.86
    flashConfig.AmpMul = ( 1000000.0 * 512 * V_REF / R_CURRENT / (F_OSC/1000) / A_TRIM_VALUE );
    flashConfig.VoltMul = ( 1000000.0 * 512 * V_REF * VOLTAGE_RESISTOR / 2.0 / F_OSC / V_TRIM_VALUE );
    flashConfig.Watt_Mul = ( 1000000.0 * 128 * V_REF * V_REF * VOLTAGE_RESISTOR / R_CURRENT / 48.0 / F_OSC / W_TRIM_VALUE );

    setInterrupts();
}

float ICACHE_FLASH_ATTR getApparentPower() {
    updateCurrent();
    updateVoltage();
    return hlw8012->actualvoltage * hlw8012->actualcurrent;
}

/*
unsigned int ICACHE_FLASH_ATTR getReactivePower() {
    updateActivePower();
    unsigned int apparent = getApparentPower();
    if (apparent > hlw8012->actualRMSPower) {
	  //return __ieee754_sqrt(apparent * apparent - active * active);
	  //return real_sqrt(apparent * apparent - active * active);
	  //return fast_sqrtf(apparent * apparent - active * active);
	  return sqrt(apparent * apparent - hlw8012->actualRMSPower * hlw8012->actualRMSPower);	  
	  //return 1;
	  } 
	else {
	  return 0;
	  }
}
*/

float ICACHE_FLASH_ATTR getPowerFactor() {
    updateActivePower();
    unsigned int apparent = getApparentPower();
    if (hlw8012->actualRMSPower > apparent) return 1;
    if (apparent == 0) return 0;
    return (float) hlw8012->actualRMSPower / apparent;
}

void ICACHE_FLASH_ATTR expectedCurrent(float value) {
  flashConfig.AmpMul *= (value / hlw8012->actualcurrent );
}

void ICACHE_FLASH_ATTR expectedVoltage(unsigned int value) {
    if (hlw8012->actualvoltage > 0) flashConfig.VoltMul *= ((float) value / hlw8012->actualvoltage );
}

void ICACHE_FLASH_ATTR expectedActivePower(unsigned int value) {
    updateActivePower();
    flashConfig.Watt_Mul *= ((float) value / hlw8012->actualRMSPower);
}

/*
void ICACHE_FLASH_ATTR calibrate() {
    // Let some time to register values
    unsigned long timeout = millis();
    while ((millis() - timeout) < 10000) {
	  msleep(1);;
	  }

    // Calibrate using a 60W bulb (pure resistive) on a 230V line
    expectedActivePower(60.0);
    expectedVoltage(230.0);
    expectedCurrent(60.0 / 230.0);

    // Show corrected factors
    DBG("New current multiplier : %d", flashConfig.AmpMul);
    DBG("New voltage multiplier : %d", flashConfig.VoltMul);
    DBG("New power multiplier   : %d", flashConfig.Watt_Mul);

}
*/