#ifndef MQTT_H_
#define MQTT_H_

#include <ets_sys.h>
#include <ip_addr.h>
#include "mqtt_msg.h"
#include "pktbuf.h"

uint8_t StrToIP(const char* str, void *ip);

// State of MQTT connection
typedef enum {
  MQTT_DISCONNECTED,    // we're in disconnected state
  TCP_RECONNECT_REQ,    // connect failed, needs reconnecting
  TCP_CONNECTING,       // in TCP connection process
  MQTT_CONNECTED,       // conneted (or connecting)
} tConnState;

typedef struct MQTT_Client MQTT_Client; // forward definition

// Simple notification callback
typedef void (*MqttCallback)(MQTT_Client *pMQTTclient);
// Callback with data messge
typedef void (*MqttDataCallback)(MQTT_Client *pMQTTclient, const char* topic, uint32_t topic_len, const char* data, uint32_t data_len);

// MQTT client data structure
struct MQTT_Client {
  struct espconn*     pCon;                   // socket
  // connection information
  char*               host;                   // MQTT server
  uint16_t            port;
  uint8_t             security;               // 0=tcp, 1=ssl
  ip_addr_t           ip;                     // MQTT server IP address
  mqtt_connect_info_t connect_info;           // info to connect/reconnect
  // protocol state and message assembly
  tConnState          connState;              // connection state
  bool                sending;                // espconn_send is pending
  mqtt_connection_t   mqtt_connection;        // message assembly descriptor
  PktBuf*             msgQueue;               // queued outbound messages
  // TCP input buffer
  uint8_t*            in_buffer;
  int                 in_buffer_size;         // length allocated
  int                 in_buffer_filled;       // number of bytes held
  // outstanding message when we expect an ACK
  PktBuf*             pending_buffer;         // buffer sent and awaiting ACK
  PktBuf*             sending_buffer;         // buffer sent not awaiting ACK
  // timer and associated timeout counters
  ETSTimer            mqttTimer;              // timer for this connection
  uint8_t             keepAliveTick;          // seconds 'til keep-alive is required (0=no k-a)
  uint8_t             keepAliveAckTick;       // seconds 'til keep-alive ack is overdue (0=no k-a)
  uint8_t             timeoutTick;            // seconds 'til other timeout
  uint8_t             sendTimeout;            // value of send timeout setting
  uint8_t             reconTimeout;           // timeout to reconnect (back-off)
  // callbacks
  MqttCallback        connectedCb;
  MqttCallback        cmdConnectedCb;
  MqttCallback        disconnectedCb;
  MqttCallback        cmdDisconnectedCb;
  MqttCallback        publishedCb;
  MqttCallback        cmdPublishedCb;
  MqttDataCallback    dataCb;
  MqttDataCallback    cmdDataCb;
};

// Initialize client data structure
void MQTT_Init(MQTT_Client* pMQTTclient, char* host, uint32 port, uint8_t security, uint8_t sendTimeout,
    char* client_id, uint8_t keepAliveTime);

// Completely free buffers associated with client data structure
// This does not free the mqttClient struct itself, it just readies the struct so
// it can be freed or MQTT_Init can be called on it again
void MQTT_Free(MQTT_Client* pMQTTclient);

// Set Last Will Topic on client, must be called before MQTT_InitConnection
void MQTT_InitLWT(MQTT_Client* pMQTTclient, char* will_topic, char* will_msg,  uint8_t will_qos, uint8_t will_retain);

// Disconnect and reconnect in order to change params (such as LWT)
void MQTT_Reconnect(MQTT_Client* mqttClient);

// Kick of a persistent connection to the broker, will reconnect anytime conn breaks
void MQTT_Connect(MQTT_Client* mqttClient);

// Kill persistent connection
void MQTT_Disconnect(MQTT_Client* mqttClient);

// Subscribe to a topic
bool MQTT_Subscribe(MQTT_Client* client, char* topic, uint8_t qos);

// Publish a message
bool MQTT_Publish(MQTT_Client* client, const char* topic, const char* data, uint16_t data_len, uint8_t qos, uint8_t retain);

// Callback when connected
void MQTT_OnConnected(MQTT_Client* mqttClient, MqttCallback connectedCb);
// Callback when disconnected
void MQTT_OnDisconnected(MQTT_Client* mqttClient, MqttCallback disconnectedCb);
// Callback when publish succeeded
void MQTT_OnPublished(MQTT_Client* mqttClient, MqttCallback publishedCb);
// Callback when data arrives for subscription
void MQTT_OnData(MQTT_Client* mqttClient, MqttDataCallback dataCb);

// max message size supported for receive
#define MQTT_MAX_RCV_MESSAGE 2048
// max message size for sending (except publish)
#define MQTT_MAX_SHORT_MESSAGE 128

static void mqtt_enq_message(MQTT_Client *pMQTTclient, const uint8_t *data, uint16_t len);
static void mqtt_send_message(MQTT_Client* pMQTTclient);
static void mqtt_doAbort(MQTT_Client* pMQTTclient);


#endif /* USER_AT_MQTT_H_ */
