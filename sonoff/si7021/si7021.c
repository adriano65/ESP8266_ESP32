#include <ets_sys.h>
#include <osapi.h>
#include <c_types.h>
#include <user_interface.h>
#include <mem.h>
#include <gpio.h>

#include "gpio16.h"
#include "mqtt_client.h"
#include "config.h"
#include "network.h"
#include "sensor.h"
#include "si7021.h"

//#define SI7021_DEBUG

#ifdef SI7021_DEBUG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(...)
#endif

unsigned char * pBuf;
Sensor_Data sensor_data;

bool SISensorInit(DHTType senstype, uint8_t pin) {
  bool res=false;
  sensor_data.pin = pin;
  sensor_data.type = senstype;
  pBuf = (unsigned char *)os_zalloc(6);
  
  return res;
}


static uint8_t ICACHE_FLASH_ATTR read_byte() {
  unsigned int i;
  uint8_t byte = 0;
  for(i = 0; i < 8; i++) {
    if (waitState(1)) {
      DBG("1. No device");
      return 0;
      }
    os_delay_us(35);
    //os_delay_us(40);
    
    if (gpio_read(sensor_data.pin))
      byte |= (1 << (7 - i));
      
    if (waitState(0)) {
      DBG("2. No device");
      return 0;
      }
    }
  return byte;
}

static bool ICACHE_FLASH_ATTR waitState(uint8_t expectedstate) {
  uint8_t nTent=0;
  
  while ((expectedstate!=gpio_read(sensor_data.pin)) && (nTent<100)){
    os_delay_us(1);
    nTent++;
    }
   
	return (nTent<100) ? FALSE : TRUE;
}

bool ICACHE_FLASH_ATTR SI7021read() {
  bool bRet=FALSE;
  sensor_data.HasBadTemp=NOBADREADING;

  //set_gpio_mode(sensor_data.pin, GPIO_OUTPUT, GPIO_PULLUP);
  set_gpio_mode(sensor_data.pin, GPIO_OUTPUT, GPIO_FLOAT, GPIO_PIN_INTR_DISABLE);
  // low pulse of 0.5ms
  gpio_write(sensor_data.pin, 0);
	os_delay_us(500);
  //Give control of the bus to device and wait for a  reply
  set_gpio_mode(sensor_data.pin, GPIO_INPUT, GPIO_FLOAT, GPIO_PIN_INTR_DISABLE);
  os_delay_us(50);
  // wait start bit
  if (waitState(0)) { 
    DBG("1. No device"); 
    sensor_data.HasBadTemp=FIRSTRESETFAILED;
    }
  else if (waitState(1)) { 
          DBG("2. No device"); 
          sensor_data.HasBadTemp=SECONDRESETFAILED;
          }
        else if (waitState(0)) { 
                DBG("3. No device");
                sensor_data.HasBadTemp=THIRDRESETFAILED;                
                }
             else {
                for (int k=0; k<5; k++){
                  pBuf[k]=read_byte();
                  }
                //pBuf[0] &= 0x7F;
                DBG("ScratchPAD DATA = 0x%02X 0x%02X 0x%02X 0x%02X, chksum 0x%02X", pBuf[0], pBuf[1], pBuf[2], pBuf[3], pBuf[4]);
                
                unsigned char chksum = (pBuf[0] + pBuf[1] + pBuf[2] + pBuf[3]) & 0xFF;
                if (pBuf[4] != chksum) {
                  DBG("checksum error! pBuf[4] 0x%02X, chksum 0x%02X", pBuf[4], chksum);
                  sensor_data.HasBadTemp=BADPROTOCRC;
                  bRet=FALSE;
                  }
                else {
                  /*
                  sensor_data.humidity = (pBuf[0] * 10 + pBuf[1])/10.0;
                  sensor_data.temperature = (pBuf[2] * 10  +  (pBuf[3] & 0x7F))/10.0;		  
                  if (pBuf[3] & 0x80) { sensor_data.temperature = -sensor_data.temperature; }
                  */
                  sensor_data.humidity = ((pBuf[0] << 8) | pBuf[1])/10.0;
                  /* Humidity correction */
                  sensor_data.humidity += HUMI_OFFSET;

                  unsigned char temp_msb = (pBuf[2] & 0x80) ? (pBuf[2] & 0x7F) : pBuf[2]; // Sign byte + lsbit
                  unsigned char temp_lsb = pBuf[3]; // Temp data plus lsb
                  sensor_data.temperature = ((temp_msb << 8) | temp_lsb)/10.0;
                  /* Temperature correction */
                  sensor_data.temperature += TEMP_OFFSET;

                  DBG("humidity %d.%d, temperature %d.%d", (int)sensor_data.humidity, (int)((sensor_data.humidity-(int)sensor_data.humidity)*100), 
                                                                (int)sensor_data.temperature, (int)((sensor_data.temperature-(int)sensor_data.temperature)*100) );
                  bRet=TRUE;
                  }
                }
  return bRet;
}
  
