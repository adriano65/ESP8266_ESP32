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
#include "ds18b20.h"

//#define DS18B20_DEBUG

#ifdef DS18B20_DEBUG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); } while(0)
#else
#define DBG(...)
#endif

#define DS18B20_DEBUG1

#ifdef DS18B20_DEBUG1
#define DBG1(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); } while(0)
#else
#define DBG1(...)
#endif

Sensor_Data sensor_data;
/*** 
 * CRC Table and code from Maxim AN 162:
 *  http://www.maximintegrated.com/en/app-notes/index.mvp/id/162
*/
unsigned const char dscrc_table[] = {
0, 94,188,226, 97, 63,221,131,194,156,126, 32,163,253, 31, 65,
157,195, 33,127,252,162, 64, 30, 95, 1,227,189, 62, 96,130,220,
35,125,159,193, 66, 28,254,160,225,191, 93, 3,128,222, 60, 98,
190,224, 2, 92,223,129, 99, 61,124, 34,192,158, 29, 67,161,255,
70, 24,250,164, 39,121,155,197,132,218, 56,102,229,187, 89, 7,
219,133,103, 57,186,228, 6, 88, 25, 71,165,251,120, 38,196,154,
101, 59,217,135, 4, 90,184,230,167,249, 27, 69,198,152,122, 36,
248,166, 68, 26,153,199, 37,123, 58,100,134,216, 91, 5,231,185,
140,210, 48,110,237,179, 81, 15, 78, 16,242,172, 47,113,147,205,
17, 79,173,243,112, 46,204,146,211,141,111, 49,178,236, 14, 80,
175,241, 19, 77,206,144,114, 44,109, 51,209,143, 12, 82,176,238,
50,108,142,208, 83, 13,239,177,240,174, 76, 18,145,207, 45,115,
202,148,118, 40,171,245, 23, 73, 8, 86,180,234,105, 55,213,139,
87, 9,235,181, 54,104,138,212,149,203, 41,119,244,170, 72, 22,
233,183, 85, 11,136,214, 52,106, 43,117,151,201, 74, 20,246,168,
116, 42,200,150, 21, 75,169,247,182,232, 10, 84,215,137,107, 53};

extern uint8_t pin_num[];
void ICACHE_FLASH_ATTR read_sens_timer_cb(void *arg);

unsigned char dowcrc = 0;

unsigned char ow_crc( unsigned char x){
    dowcrc = dscrc_table[dowcrc^x];
    return dowcrc;
}

//End of Maxim AN162 code

unsigned char ROM_NO[8];
uint8_t LastDiscrepancy;
uint8_t LastFamilyDiscrepancy;
uint8_t LastDeviceFlag;

bool SensorInit(DHTType senstype, uint8_t pin) {
  bool res=false;
  sensor_data.pin = pin;
  sensor_data.type = senstype;
}


void ICACHE_FLASH_ATTR write_bit(int bit) {
  os_delay_us(1);
  if (bit) {
	//5us low pulse
	gpio_write(sensor_data.pin, 0);
	os_delay_us(5);
	//let bus go high again (device should read about 30us later)
	set_gpio_mode(sensor_data.pin, GPIO_INPUT, GPIO_FLOAT, GPIO_PIN_INTR_DISABLE);
	os_delay_us(55);
	}
  else{
	//55us low
	gpio_write(sensor_data.pin, 0);
	os_delay_us(55);
	//5us high
	set_gpio_mode(sensor_data.pin, GPIO_INPUT, GPIO_FLOAT, GPIO_PIN_INTR_DISABLE);
	os_delay_us(5);
	}
 }

int ICACHE_FLASH_ATTR read_bit() {
  int bit=0;
  os_delay_us(1);
  //Pull bus low for 15us
  gpio_write(sensor_data.pin, 0);
  os_delay_us(15);
  
  //Allow device to control bus
  set_gpio_mode(sensor_data.pin, GPIO_INPUT, GPIO_FLOAT, GPIO_PIN_INTR_DISABLE);
  os_delay_us(5);
   
  //Read value
  bit = gpio_read(sensor_data.pin);
  //Wait for end of bit
  os_delay_us(40);
  return bit;
}

void ICACHE_FLASH_ATTR write_byte(uint8_t byte) {
  int i;
  for(i = 0; i < 8; i++)
  {
    write_bit(byte & 1);
    byte >>= 1;
  }
}

uint8_t ICACHE_FLASH_ATTR read_byte() {
  unsigned int i;
  uint8_t byte = 0;
  for(i = 0; i < 8; i++) {
    byte >>= 1;
    if (read_bit()) byte |= 0x80;
  }
  return byte;
}

int ICACHE_FLASH_ATTR reset(void) {
	int gpioin=0;
	
  //Hold the bus low for 500us
	set_gpio_mode(sensor_data.pin, GPIO_OUTPUT, GPIO_FLOAT, GPIO_PIN_INTR_DISABLE);
	gpio_write(sensor_data.pin, 0);
  os_delay_us(500);
    
    //Give control of the bus to device and wait for a  reply
	set_gpio_mode(sensor_data.pin, GPIO_INPUT, GPIO_FLOAT, GPIO_PIN_INTR_DISABLE);
	os_delay_us(65);

	//The bus should be low if the device is present:
	gpioin=gpio_read(sensor_data.pin);
  if (gpioin){	// is high ?
	  DBG("No device %d\n", gpioin);
	  return 0;
	  }
    
  //The device should have stopped pulling the bus now:
  os_delay_us(300);
	gpioin=gpio_read(sensor_data.pin);
  if (! gpioin) { 
	  DBG("Somethings wrong, the bus should be high %d\n", gpioin);
	  return 0;
	  }
    
  return 1;
}

bool ICACHE_FLASH_ATTR DS18B20setResolution() {
    uint8_t get[10];

    if (reset()) return false;
    write_byte(DS1820_SKIP_ROM);  // skip ROM command
    write_byte(DS1820_READ_SCRATCHPAD);
    for (int k=0;k<9;k++){
  	  get[k]=read_byte();
	    }
    DBG1("ScratchPAD DATA = %X %X %X %X %X %X %X %X %X\n",get[8],get[7],get[6],get[5],get[4],get[3],get[2],get[1],get[0]);
	
    if (reset()) return false;
    write_byte(DS1820_SKIP_ROM);		// skip ROM command
    write_byte(DS1820_WRITE_SCRATCHPAD);
    for (int k=0;k<3;k++){
	  write_byte(get[k]);
	  }
    
}

bool ICACHE_FLASH_ATTR DS18B20read() {
  uint8_t *pBuf, nRet=0;

	pBuf=(uint8_t *)os_malloc(12);
  if (reset()) {
	  write_byte(DS1820_SKIP_ROM);  // skip ROM command
	  write_byte(DS1820_CONVERT_T); // convert T command

	  msleep(800);				// 12 bit conversion time (750 ms)
	  //msleep(1600);				// 12 bit conversion time (750 ms)
    if (reset()) {
      write_byte(DS1820_SKIP_ROM);		// skip ROM command
      write_byte(DS1820_READ_SCRATCHPAD); // read scratchpad command
		
		for (int k=0;k<9;k++){
		  pBuf[k]=read_byte();
		  }
		//DBG("ScratchPAD DATA = %X %X %X %X %X %X %X %X %X\n",pBuf[8],pBuf[7],pBuf[6],pBuf[5],pBuf[4],pBuf[3],pBuf[2],pBuf[1],pBuf[0]);

		dowcrc = 0;
		for(int i = 0; i < 8; i++){
		  ow_crc(pBuf[i]);
		  }
		
		if(pBuf[8] == dowcrc){
		  uint8_t temp_msb = pBuf[1]; // Sign byte + lsbit
		  uint8_t temp_lsb = pBuf[0]; // Temp data plus lsb

		  uint16_t temp = temp_msb << 8 | temp_lsb;
		  
		  sensor_data.temperature = (temp * 625.0)/10000.0;		  
		  DBG("Got a DS18B20 Reading: %d.%d\n",  (int)sensor_data.temperature, (int)((sensor_data.temperature - (int)sensor_data.temperature) * 100));
		  if (sensor_data.temperature > -20 || sensor_data.temperature < 50) {
        sensor_data.HasBadTemp=NOBADREADING;
        nRet=true;
        }
		  else {
        sensor_data.HasBadTemp=SPIKEDETECTED;
        }
		  }
		else {
		  sensor_data.HasBadTemp=BADPROTOCRC;
		  DBG("CRC check failed: %02X %02X\n", pBuf[8], dowcrc);
		  }
		}
	  else {
		sensor_data.HasBadTemp=SECONDRESETFAILED;
		}
	  }
	else {
	  sensor_data.HasBadTemp=FIRSTRESETFAILED;
	  }
	os_free(pBuf);
	return nRet;
}


#if 0
void reset_search()  {
  // reset the search state
  LastDiscrepancy = 0;
  LastDeviceFlag = FALSE;
  LastFamilyDiscrepancy = 0;
  for(int i = 7; ; i--) {
    ROM_NO[i] = 0;
    if ( i == 0) break;
    }
  }

//
// Perform a search. If this function returns a '1' then it has
// enumerated the next device and you may retrieve the ROM from the
// OneWire::address variable. If there are no devices, no further
// devices, or something horrible happens in the middle of the
// enumeration then a 0 is returned.  If a new device is found then
// its address is copied to newAddr.  Use OneWire::reset_search() to
// start over.
//
// --- Replaced by the one from the Dallas Semiconductor web site ---
//--------------------------------------------------------------------------
// Perform the 1-Wire Search Algorithm on the 1-Wire bus using the existing
// search state.
// Return TRUE  : device found, ROM number in ROM_NO buffer
//        FALSE : device not found, end of search
//
uint8_t search(uint8_t *newAddr) {
   uint8_t id_bit_number;
   uint8_t last_zero, rom_byte_number, search_result;
   uint8_t id_bit, cmp_id_bit;
   uint8_t ii=0;
   unsigned char ROM_NO[8];
   unsigned char rom_byte_mask, search_direction;

   // initialize for search
   id_bit_number = 1;
   last_zero = 0;
   rom_byte_number = 0;
   rom_byte_mask = 1;
   search_result = 0;
	
   // if the last call was not the last one
   if (!LastDeviceFlag)
   {
      // 1-Wire reset
      ii=reset();
	  if (ii) // ii>0
      {
         // reset the search
         LastDiscrepancy = 0;
         LastDeviceFlag = FALSE;
         LastFamilyDiscrepancy = 0;
         return ii;	// Pass back the reset error status  gf***
      }
      // issue the search command

      write_byte(DS1820_SEARCHROM);

      // loop to do the search
      do {
         // read a bit and its complement
         id_bit = read_bit();
         cmp_id_bit = read_bit();

         // check for no devices on 1-wire
         if ((id_bit == 1) && (cmp_id_bit == 1))
            break;
         else {
            // all devices coupled have 0 or 1
            if (id_bit != cmp_id_bit)
               search_direction = id_bit;  // bit write value for search
            else {
               // if this discrepancy if before the Last Discrepancy
               // on a previous next then pick the same as last time
               if (id_bit_number < LastDiscrepancy)
                  search_direction = ((ROM_NO[rom_byte_number] & rom_byte_mask) > 0);
               else
                  // if equal to last pick 1, if not then pick 0
                  search_direction = (id_bit_number == LastDiscrepancy);

               // if 0 was picked then record its position in LastZero
               if (search_direction == 0)
               {
                  last_zero = id_bit_number;

                  // check for Last discrepancy in family
                  if (last_zero < 9)
                     LastFamilyDiscrepancy = last_zero;
               }
            }

            // set or clear the bit in the ROM byte rom_byte_number
            // with mask rom_byte_mask
            if (search_direction == 1)
              ROM_NO[rom_byte_number] |= rom_byte_mask;
            else
              ROM_NO[rom_byte_number] &= ~rom_byte_mask;

            // serial number search direction write bit
            write_bit(search_direction);

            // increment the byte counter id_bit_number
            // and shift the mask rom_byte_mask
            id_bit_number++;
            rom_byte_mask <<= 1;

            // if the mask is 0 then go to new SerialNum byte rom_byte_number and reset mask
            if (rom_byte_mask == 0)
            {
                rom_byte_number++;
                rom_byte_mask = 1;
            }
         }
      }
      while(rom_byte_number < 8);  // loop until through all ROM bytes 0-7

      // if the search was successful then
      if (!(id_bit_number < 65))
      {
         // search successful so set LastDiscrepancy,LastDeviceFlag,search_result
         LastDiscrepancy = last_zero;

         // check for last device
         if (LastDiscrepancy == 0)
            LastDeviceFlag = TRUE;

         search_result = TRUE;	// All OK status GF***
      }
   }

   // if no device found then reset counters so next 'search' will be like a first
   //if (search_result || !ROM_NO[0])
   //if (!ROM_NO[0])
   if (!search_result || !ROM_NO[0])
   {
      LastDiscrepancy = 0;
      LastDeviceFlag = FALSE;
      LastFamilyDiscrepancy = 0;
      search_result = FALSE;
   }
   for (int i = 0; i < 8; i++) newAddr[i] = ROM_NO[i];
   return search_result;
  }

#endif
