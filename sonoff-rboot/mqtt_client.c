#include <ets_sys.h>
#include <osapi.h>
#include <gpio.h>
#include <os_type.h>
#include <ip_addr.h>
#include <espconn.h>
#include <mem.h>

#include "pktbuf.h"
#include "mqtt_msg.h"
#include "mqtt.h"
#include "config.h"

#define MQTTCLIENT_DBG

#ifdef MQTTCLIENT_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); } while(0)
#else
#define DBG(format, ...) do { } while(0)
#endif

MQTT_Client mqttClient;

static MqttCallback connected_cb;
static MqttCallback disconnected_cb;
static MqttCallback published_cb;
static MqttDataCallback data_cb;

void ICACHE_FLASH_ATTR mqttConnectedCb(MQTT_Client* client) {
  //MQTT_Subscribe(client, "system/time", 0); // handy for testing
  if (connected_cb)
    connected_cb(client);
}

void ICACHE_FLASH_ATTR mqttDisconnectedCb(MQTT_Client* client) {
  if (disconnected_cb)
    disconnected_cb(client);
}

void ICACHE_FLASH_ATTR mqttPublishedCb(MQTT_Client* client) {
  if (published_cb)
    published_cb(client);
}

void ICACHE_FLASH_ATTR mqttDataCb(MQTT_Client* client, const char* topic, uint32_t topic_len, const char *data, uint32_t data_len) {
  #ifdef MQTTCLIENT_DBG
  char *topicBuf = (char*)os_zalloc(topic_len + 1);
  char *dataBuf = (char*)os_zalloc(data_len + 1);

  os_memcpy(topicBuf, topic, topic_len);
  topicBuf[topic_len] = 0;

  os_memcpy(dataBuf, data, data_len);
  dataBuf[data_len] = 0;

  DBG("Received topic: %s, data: %s\n", topicBuf, dataBuf);
  os_free(topicBuf);
  os_free(dataBuf);
  #endif

  if (data_cb)
    data_cb(client, topic, topic_len, data, data_len);
}

void ICACHE_FLASH_ATTR mqtt_client_init() {
//  MQTT_Init(&mqttClient, ESP_MQTT_HOST, ESP_MQTT_PORT, 0, flashConfig.mqtt_timeout,
//			flashConfig.mqtt_clientid, flashConfig.mqtt_username, flashConfig.mqtt_password, 
//			flashConfig.mqtt_keepalive);
  MQTT_Init(&mqttClient, ESP_MQTT_HOST, ESP_MQTT_PORT, 0, 5,
			flashConfig.mqtt_clientid, flashConfig.mqtt_username, flashConfig.mqtt_password, 
			flashConfig.mqtt_keepalive);
  MQTT_OnConnected(&mqttClient, mqttConnectedCb);
  MQTT_OnDisconnected(&mqttClient, mqttDisconnectedCb);
  MQTT_OnPublished(&mqttClient, mqttPublishedCb);
  MQTT_OnData(&mqttClient, mqttDataCb);
}

void ICACHE_FLASH_ATTR mqtt_client_on_connected(MqttCallback connectedCb) {
  connected_cb = connectedCb;
}

void ICACHE_FLASH_ATTR mqtt_client_on_disconnected(MqttCallback disconnectedCb) {
  disconnected_cb = disconnectedCb;
}

void ICACHE_FLASH_ATTR mqtt_client_on_published(MqttCallback publishedCb) {
  published_cb = publishedCb;
}

void ICACHE_FLASH_ATTR mqtt_client_on_data(MqttDataCallback dataCb) {
  data_cb = dataCb;
}
