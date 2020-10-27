#ifndef CONFIG_H
#define CONFIG_H

#define MAX_HOSTNAME_LEN		4*8

#include <user_interface.h>

// magic number to recognize thet these are our flash settings as opposed to some random stuff
#define FLASH_MAGIC  (0xAA55)

// size of the setting sector
#define FLASH_SECT   (4096)

// Flash configuration settings. When adding new items always add them at the end and formulate
// them such that a value of zero is an appropriate default or backwards compatible. Existing
// modules that are upgraded will have zero in the new fields. This ensures that an upgrade does
// not wipe out the old settings.
typedef struct __attribute__((aligned(4))) {
  uint32_t crc;
  struct station_config __attribute__((aligned(4))) stat_conf;
  struct ip_info __attribute__((aligned(4))) ip0;
  struct softap_config __attribute__((aligned(4))) apconf;
  struct ip_info __attribute__((aligned(4))) ip1;
  char     hostname[MAX_HOSTNAME_LEN]; // if using DHCP
  uint32_t staticip, netmask, gateway; // using DHCP if staticip==0
  uint8_t  mqtt_status_enable,         // MQTT status reporting
           mqtt_timeout,               // MQTT send timeout
           mqtt_clean_session;         // MQTT clean session
  uint32_t  mqtt_port, mqtt_keepalive;  // MQTT Host port, MQTT Keepalive timer
  char      mqtt_host[MAX_HOSTNAME_LEN], 
            mqtt_clientid[MAX_HOSTNAME_LEN];
  uint8_t   IOPort_bit0: 1;
  uint8_t   IOPort_bit1: 1;
  uint8_t   IOPort_bit2: 1;
  uint8_t   IOPort_bit3: 1;
  uint8_t   IOPort_bit4: 1;
  uint8_t   IOPort_bit5: 1;
  uint8_t   IOPort_bit6: 1;
  uint8_t   IOPort_bit7: 1;
  #if defined(SONOFFPOW)
  float     AmpMul;
  float     VoltMul;
  float     Watt_Mul;
  #endif
  #if defined(HOUSE_POW_METER_RX)
  uint16_t   WattOffset;
  #endif
  #if defined(HOUSE_POW_METER_TX) || defined(SONOFFPOW_DDS238_2)
  ip_addr_t HPRx_IP;
  #endif
} FlashConfig;

extern FlashConfig flashConfig;

bool ICACHE_FLASH_ATTR parse_ip(char *buff, ip_addr_t *ip_ptr);
bool ICACHE_FLASH_ATTR configSave();
void ICACHE_FLASH_ATTR LoadDefaultConfig();
void ICACHE_FLASH_ATTR LoadConfigFromFlash();
void ICACHE_FLASH_ATTR LoadDefaultAPConfig(void);
const size_t getFlashSize();

#include <lwip/sys.h>
//void ICACHE_FLASH_ATTR set_blink_timer(uint16_t interval);
//#define msleep(n) sys_msleep(n);
#define msleep(n) os_delay_us(n*1000);

extern MQTT_Client mqttClient;

#endif
