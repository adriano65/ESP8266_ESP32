/* Configuration stored in flash */

#include <osapi.h>
#include "mqtt_client.h"
#include "network.h"
#include "injectorcleaner.h"
#include "config.h"

//#define CONFIG_DBG

#ifdef CONFIG_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif
#define PRINTNET(format, ...) do { if (pTXdata) { TXdatalen+=os_sprintf(pTXdata+TXdatalen, format, ## __VA_ARGS__ ); TXdatalen+=os_sprintf(pTXdata+TXdatalen, "\n");} } while(0)


FlashConfig flashConfig;

/* CITT CRC16 polynomial ^16 + ^12 + ^5 + 1 */
/*---------------------------------------------------------------------------*/
unsigned short ICACHE_FLASH_ATTR crc16_add(unsigned char b, unsigned short acc) {
  /*
    acc  = (unsigned char)(acc >> 8) | (acc << 8);
    acc ^= b;
    acc ^= (unsigned char)(acc & 0xff) >> 4;
    acc ^= (acc << 8) << 4;
    acc ^= ((acc & 0xff) << 4) << 1;
  */

  acc ^= b;
  acc  = (acc >> 8) | (acc << 8);
  acc ^= (acc & 0xff00) << 4;
  acc ^= (acc >> 8) >> 4;
  acc ^= (acc & 0xff00) >> 5;
  return acc;
}
/*---------------------------------------------------------------------------*/
unsigned short ICACHE_FLASH_ATTR crc16_data(const unsigned char *data, int len, unsigned short acc){
  int i;
  
  for(i = 0; i < len; ++i) {
    acc = crc16_add(*data, acc);
    ++data;
  }
  return acc;
}
/*---------------------------------------------------------------------------*/

bool ICACHE_FLASH_ATTR parse_ip(char *buff, ip_addr_t *ip_ptr) {
  char *next = buff; // where to start parsing next integer
  int found = 0;     // number of integers parsed
  uint32_t ip = 0;   // the ip addres parsed
  for (int i=0; i<32; i++) { // 32 is just a safety limit
    char c = buff[i];
    if (c == '.' || c == 0) {
      // parse the preceding integer and accumulate into IP address
      bool last = c == 0;
      buff[i] = 0;
      uint32_t v = atoi(next);
      ip = ip | ((v&0xff)<<(found*8));
      next = buff+i+1; // next integer starts after the '.'
      found++;
      if (last) { // if at end of string we better got 4 integers
        ip_ptr->addr = ip;
        return found == 4;
      }
      continue;
    }
    if (c < '0' || c > '9') return false;
  }
  return false;
}

// address where to flash the settings: if we have >512KB flash then there are 16KB of reserved
// space at the end of the first flash partition, we use the upper 8KB (2 sectors). If we only
// have 512KB then that space is used by the SDK and we use the 8KB just before that.
static uint32_t ICACHE_FLASH_ATTR flashAddr(void) {
  enum flash_size_map map = system_get_flash_size_map();
  return map >= FLASH_SIZE_8M_MAP_512_512
    ? FLASH_SECT + ESP_FLASH_MAX + FLASH_SECT // bootloader + maxfirmwaresize + 4KB free
    : FLASH_SECT + ESP_FLASH_MAX - FLASH_SECT;// bootloader + firmware - 4KB (risky...)
}

#ifdef CONFIG_MEMDBG
static void memDump(void *addr, int len) {
  os_printf("cksum of: ");
  for (int i=0; i<len; i++) {
    os_printf("0x%02x", ((uint8_t *)addr)[i]);
	}
  os_printf("\n");
}
#else
static void memDump(void *addr, int len) {}
#endif

bool ICACHE_FLASH_ATTR configSave() {
  uint16_t crc;
  crc=crc16_data((unsigned char*)&flashConfig+sizeof(crc), sizeof(FlashConfig)-sizeof(crc), 0);	
  flashConfig.crc=crc;
	//disable global interrupt
	ETS_GPIO_INTR_DISABLE();

  if (spi_flash_erase_sector(flashAddr()>>12) == SPI_FLASH_RESULT_OK) {
    if (spi_flash_write(flashAddr(), (uint32 *)&flashConfig, sizeof(FlashConfig)) != SPI_FLASH_RESULT_OK) {
      PRINTNET("Failed to save config.");
      return false;
      }
    PRINTNET("config saved, crc 0x%04X..", flashConfig.crc);
    }
  else DBG("Failed to erase.");

	//enable global interrupt
	ETS_GPIO_INTR_ENABLE();

  return true;
}

void ICACHE_FLASH_ATTR LoadDefaultAPConfig(void) {
  os_sprintf(flashConfig.apconf.ssid, "%s", AP_SSID);
  flashConfig.apconf.ssid_len = 0;
  os_sprintf(flashConfig.apconf.password, AP_PSW);
  parse_ip(AP_IPADDRESS, &flashConfig.ip1.ip);
  parse_ip(AP_NETMASK, &flashConfig.ip1.netmask);
  parse_ip(AP_GATEWAY, &flashConfig.ip1.gw);
  //flashConfig.apconf.authmode = AUTH_WPA2_PSK;
  flashConfig.apconf.authmode = AUTH_WPA_WPA2_PSK;  
  flashConfig.apconf.beacon_interval = 200;
  flashConfig.apconf.channel=5;
  flashConfig.apconf.max_connection=2;
  flashConfig.apconf.ssid_hidden = 0;
}

void ICACHE_FLASH_ATTR LoadDefaultConfig(void) {
  uint16_t crc;
  os_memset(&flashConfig, 0, sizeof(FlashConfig));	
  PRINTNET("Setting defaults in flashConfig..."); 
  os_sprintf(flashConfig.hostname, PROJ_NAME"_%06x", system_get_chip_id());
  
  LoadDefaultAPConfig();
  DBG("ssid %s, FlashConfig size %d", AP_SSID, sizeof(FlashConfig));

  os_sprintf(flashConfig.stat_conf.ssid, STA_SSID);
  os_sprintf(flashConfig.stat_conf.password, STA_PASS);
  parse_ip(STA_IPADDRESS, &flashConfig.ip0.ip);
  parse_ip(STA_NETMASK, &flashConfig.ip0.netmask);
  parse_ip(STA_GATEWAY, &flashConfig.ip0.gw);

  flashConfig.netmask      = 0x00ffffff,
  flashConfig.mqtt_timeout = 4, 
  
  flashConfig.mqtt_clean_session = 1,
  flashConfig.mqtt_port    = MQTT_PORT, 
  flashConfig.mqtt_keepalive = 60,
  os_sprintf(flashConfig.mqtt_host, MQTT_HOST);
  os_sprintf(flashConfig.mqtt_clientid, flashConfig.hostname);  
  #if defined(HOUSE_POW_METER_RX)
  flashConfig.WattOffset=200;
  #endif
  #if defined(HOUSE_POW_METER_TX) || defined(SONOFFPOW_DDS238_2)
  parse_ip(HPMETER_RX_IP, &flashConfig.HPRx_IP);
  #endif
  #if defined(GASINJECTORCLEANER)
    flashConfig.interval=INJECTION_PERIOD;
  #endif

  crc=crc16_data((unsigned char*)&flashConfig+sizeof(crc), sizeof(FlashConfig)-sizeof(crc), 0);	
  flashConfig.crc=crc;
  PRINTNET("Defaults settled, crc 0x%04X..", flashConfig.crc);
}
  
void ICACHE_FLASH_ATTR LoadConfigFromFlash(void) {
  uint16_t crc;
	//disable global interrupt
	ETS_GPIO_INTR_DISABLE();

  if (spi_flash_read(flashAddr(), (uint32 *)&flashConfig, sizeof(FlashConfig)) == SPI_FLASH_RESULT_OK ) {
    crc=crc16_data((unsigned char*)&flashConfig+sizeof(crc), sizeof(FlashConfig)-sizeof(crc), 0);	
    if ( flashConfig.crc == crc ) {
      DBG("crc 0x%04X", flashConfig.crc);
      }
    else {
      DBG("FlashConfig CRC 0x%04X, crc 0x%04X. Clearing Flash...", flashConfig.crc, crc);
      if (spi_flash_erase_sector(flashAddr()>>12) != SPI_FLASH_RESULT_OK) {
        DBG("Cant erase flash!");
        }
      LoadDefaultConfig();
      }
    }
	//enable global interrupt
	ETS_GPIO_INTR_ENABLE();
  
  PRINTNET("config loaded.");
}

// returns the flash chip's size, in BYTES
const size_t ICACHE_FLASH_ATTR getFlashSize() {
  uint32_t id = spi_flash_get_id();
  uint8_t mfgr_id = id & 0xff;
  //uint8_t type_id = (id >> 8) & 0xff; // not relevant for size calculation
  uint8_t size_id = (id >> 16) & 0xff; // lucky for us, WinBond ID's their chips as a form that lets us calculate the size
  if (mfgr_id != 0xEF) // 0xEF is WinBond; that's all we care about (for now)
    return 0;
  return 1 << size_id;
}


bool ICACHE_FLASH_ATTR isFlashconfig_actual() {
  uint16_t crc;
  crc=crc16_data((unsigned char*)&flashConfig+sizeof(crc), sizeof(FlashConfig)-sizeof(crc), 0);	
  if (flashConfig.crc==crc) return true;
  return false;
}