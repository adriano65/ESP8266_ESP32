/* mqtt.c
*  Protocol: http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html
*
*/

// TODO:
// Handle SessionPresent=0 in CONNACK and rexmit subscriptions
// Improve timeout for CONNACK, currently only has keep-alive timeout (maybe send artificial ping?)
// Allow messages that don't require ACK to be sent even when pending_buffer is != NULL
// Set dup flag in retransmissions

#include <ets_sys.h>
#include <osapi.h>
#include <gpio.h>
#include <os_type.h>
#include <ip_addr.h>
#include <mem.h>
#include <espconn.h>
#include "user_interface.h"

#include "mqtt_client.h"
#include "config.h"
#include "network.h"
#include "pktbuf.h"

//#define MQTT_DBG

#ifdef MQTT_DBG
#define DBG(format, ...) do { os_printf("%s: ", __FUNCTION__); os_printf(format, ## __VA_ARGS__); os_printf("\n"); } while(0)
#define PRINTNET(format, ...) do { if (pTXdata) { TXdatalen+=os_sprintf(pTXdata+TXdatalen, format, ## __VA_ARGS__ ); TXdatalen+=os_sprintf(pTXdata+TXdatalen, "\n");} } while(0)
static ICACHE_FLASH_ATTR char* mqtt_msg_type[] = {
  "NULL", "TYPE_CONNECT", "CONNACK", "PUBLISH", "PUBACK", "PUBREC", "PUBREL", "PUBCOMP",
  "SUBSCRIBE", "SUBACK", "UNSUBSCRIBE", "UNSUBACK", "PINGREQ", "PINGRESP", "DISCONNECT", "RESV",
};
#else
#define DBG(format, ...) do { } while(0)
#define PRINTNET(format, ...) do { } while(0)
#endif

// HACK
sint8 espconn_secure_connect(struct espconn *espconn) {
  return espconn_connect(espconn);
}
sint8 espconn_secure_disconnect(struct espconn *espconn) {
  return espconn_disconnect(espconn);
}
sint8 espconn_secure_sent(struct espconn *espconn, uint8 *psent, uint16 length) {
  return espconn_sent(espconn, psent, length);
}

uint8_t ICACHE_FLASH_ATTR StrToIP(const char* str, void *ip){
  /* The count of the number of bytes processed. */
  int i;
  /* A pointer to the next digit to process. */
  const char * start;

  start = str;
  for (i = 0; i < 4; i++) {
    /* The digit being processed. */
    char c;
    /* The value of this byte. */
    int n = 0;
    while (1) {
      c = *start;
      start++;
      if (c >= '0' && c <= '9') {
        n *= 10;
        n += c - '0';
      }
      /* We insist on stopping at "." if we are still parsing
      the first, second, or third numbers. If we have reached
      the end of the numbers, we will allow any character. */
      else if ((i < 3 && c == '.') || i == 3) {
        break;
      }
      else {
        return 0;
      }
    }
    if (n >= 256) {
      return 0;
    }
    ((uint8_t*)ip)[i] = n;
  }
  return 1;
}


// Deliver a publish message to the client
static void ICACHE_FLASH_ATTR deliver_publish(MQTT_Client* pMQTTclient, uint8_t* message, uint16_t length) {

  // parse the message into topic and data
  uint16_t topic_length = length;
  const char *topic = mqtt_get_publish_topic(message, &topic_length);
  uint16_t data_length = length;
  const char *data = mqtt_get_publish_data(message, &data_length);

  // callback to client
  if (pMQTTclient->dataCb)
    pMQTTclient->dataCb(pMQTTclient, topic, topic_length, data, data_length);
  if (pMQTTclient->cmdDataCb)
    pMQTTclient->cmdDataCb(pMQTTclient, topic, topic_length, data, data_length);
}

/**
* @brief  Client received callback function.
* @param  arg: contain the ip link information
* @param  pdata: received data
* @param  len: the length of received data
* @retval None
*/
static void ICACHE_FLASH_ATTR mqtt_tcpclient_recv(void* arg, char* pdata, unsigned short len) {
  uint8_t msg_type;
  uint16_t msg_id;
  uint16_t msg_len;

  struct espconn* pCon = (struct espconn*)arg;
  MQTT_Client* pMQTTclient = (MQTT_Client *)pCon->reverse;
  if (pMQTTclient == NULL) {
	DBG("aborted connection");
	return;
	}

  DBG("Data received %d bytes", len);

  do {
    // append data to our buffer
    int avail = pMQTTclient->in_buffer_size - pMQTTclient->in_buffer_filled;
    if (len <= avail) {
      os_memcpy(pMQTTclient->in_buffer + pMQTTclient->in_buffer_filled, pdata, len);
      pMQTTclient->in_buffer_filled += len;
      len = 0;
    } else {
      os_memcpy(pMQTTclient->in_buffer + pMQTTclient->in_buffer_filled, pdata, avail);
      pMQTTclient->in_buffer_filled += avail;
      len -= avail;
      pdata += avail;
    }

    // check out what's at the head of the buffer
    msg_type = mqtt_get_type(pMQTTclient->in_buffer);
    msg_id = mqtt_get_id(pMQTTclient->in_buffer, pMQTTclient->in_buffer_size);
    msg_len = mqtt_get_total_length(pMQTTclient->in_buffer, pMQTTclient->in_buffer_size);

    if (msg_len > pMQTTclient->in_buffer_size) {
      // oops, too long a message for us to digest, disconnect and hope for a miracle
      os_printf("MQTT: Too long a message (%d bytes)", msg_len);
      mqtt_doAbort(pMQTTclient);
      return;
    }

    // check whether what's left in the buffer is a complete message
    if (msg_len > pMQTTclient->in_buffer_filled) break;

    if (pMQTTclient->connState != MQTT_CONNECTED) {
      // why are we receiving something??
      DBG("ERROR: recv in invalid state %d", pMQTTclient->connState);
      mqtt_doAbort(pMQTTclient);
      return;
    }

    // we are connected and are sending/receiving data messages
    uint8_t pending_msg_type = 0;
    uint16_t pending_msg_id = 0;
    if (pMQTTclient->pending_buffer != NULL) {
      pending_msg_type = mqtt_get_type(pMQTTclient->pending_buffer->data);
      pending_msg_id = mqtt_get_id(pMQTTclient->pending_buffer->data, pMQTTclient->pending_buffer->filled);
	    }
    DBG("Recv type=%s id=%04X len=%d; Pend type=%s id=%02X", mqtt_msg_type[msg_type], msg_id, msg_len, mqtt_msg_type[pending_msg_type],pending_msg_id);

    switch (msg_type) {
      case MQTT_MSG_TYPE_CONNACK:
        DBG("Connect successful");
        // callbacks for internal and external clients
        if (pMQTTclient->connectedCb) pMQTTclient->connectedCb(pMQTTclient);
        if (pMQTTclient->cmdConnectedCb) pMQTTclient->cmdConnectedCb(pMQTTclient);
        //pMQTTclient->reconTimeout = 1;
        pMQTTclient->reconTimeout = 3;
        break;

      case MQTT_MSG_TYPE_SUBACK:
        if (pending_msg_type == MQTT_MSG_TYPE_SUBSCRIBE && pending_msg_id == msg_id) {
          DBG("Subscribe successful");
          pMQTTclient->pending_buffer = PktBuf_ShiftFree(pMQTTclient->pending_buffer);
        }
        break;

      case MQTT_MSG_TYPE_UNSUBACK:
        if (pending_msg_type == MQTT_MSG_TYPE_UNSUBSCRIBE && pending_msg_id == msg_id) {
          DBG("Unsubscribe successful");
          pMQTTclient->pending_buffer = PktBuf_ShiftFree(pMQTTclient->pending_buffer);
          }
        break;

	  case MQTT_MSG_TYPE_PUBACK: // ack for a publish we sent
		if (pending_msg_type == MQTT_MSG_TYPE_PUBLISH && pending_msg_id == msg_id) {
		  DBG("QoS1 Publish successful");
		  pMQTTclient->pending_buffer = PktBuf_ShiftFree(pMQTTclient->pending_buffer);
		}
		break;

	  case MQTT_MSG_TYPE_PUBREC: // rec for a publish we sent
		if (pending_msg_type == MQTT_MSG_TYPE_PUBLISH && pending_msg_id == msg_id) {
		  DBG("MQTT: QoS2 publish cont");
		  pMQTTclient->pending_buffer = PktBuf_ShiftFree(pMQTTclient->pending_buffer);
		  // we need to send PUBREL
		  mqtt_msg_pubrel(&pMQTTclient->mqtt_connection, msg_id);
		  mqtt_enq_message(pMQTTclient, pMQTTclient->mqtt_connection.message.data,
			  pMQTTclient->mqtt_connection.message.length);
		}
		break;

	  case MQTT_MSG_TYPE_PUBCOMP: // comp for a pubrel we sent (originally publish we sent)
		if (pending_msg_type == MQTT_MSG_TYPE_PUBREL && pending_msg_id == msg_id) {
		  //DBG_MQTT("MQTT: QoS2 Publish successful");
		  pMQTTclient->pending_buffer = PktBuf_ShiftFree(pMQTTclient->pending_buffer);
		}
		break;

    case MQTT_MSG_TYPE_PUBLISH: { // incoming publish
        // we may need to ACK the publish
        uint8_t msg_qos = mqtt_get_qos(pMQTTclient->in_buffer);
        //DBG("Recv PUBLISH qos=%d", msg_qos, mqtt_get_publish_topic(pMQTTclient->in_buffer));
        if (msg_qos == 1) mqtt_msg_puback(&pMQTTclient->mqtt_connection, msg_id);
        if (msg_qos == 2) mqtt_msg_pubrec(&pMQTTclient->mqtt_connection, msg_id);
        if (msg_qos == 1 || msg_qos == 2) {
          mqtt_enq_message(pMQTTclient, pMQTTclient->mqtt_connection.message.data, pMQTTclient->mqtt_connection.message.length);
        }
        // send the publish message to clients
        deliver_publish(pMQTTclient, pMQTTclient->in_buffer, msg_len);
      }
      break;

    case MQTT_MSG_TYPE_PUBREL: // rel for a rec we sent (originally publish received)
      if (pending_msg_type == MQTT_MSG_TYPE_PUBREC && pending_msg_id == msg_id) {
        //DBG("MQTT: Cont QoS2 recv");
        pMQTTclient->pending_buffer = PktBuf_ShiftFree(pMQTTclient->pending_buffer);
        // we need to send PUBCOMP
        mqtt_msg_pubcomp(&pMQTTclient->mqtt_connection, msg_id);
        mqtt_enq_message(pMQTTclient, pMQTTclient->mqtt_connection.message.data,
            pMQTTclient->mqtt_connection.message.length);
      }
      break;

    case MQTT_MSG_TYPE_PINGRESP:
      pMQTTclient->keepAliveAckTick = 0;
      break;
    }

    // Shift out the message and see whether we have another one
    if (msg_len < pMQTTclient->in_buffer_filled)
      os_memcpy(pMQTTclient->in_buffer, pMQTTclient->in_buffer+msg_len, pMQTTclient->in_buffer_filled-msg_len);
    pMQTTclient->in_buffer_filled -= msg_len;
  } while(pMQTTclient->in_buffer_filled > 0 || len > 0);

  // Send next packet out, if possible
  if (!pMQTTclient->sending && pMQTTclient->pending_buffer == NULL && pMQTTclient->msgQueue != NULL) {
    mqtt_send_message(pMQTTclient);
  }
}

/**
* @brief  Callback from TCP that previous send completed
* @param  arg: contain the ip link information
* @retval None
*/
static void ICACHE_FLASH_ATTR mqtt_tcpclient_sent_cb(void* arg) {
  struct espconn* pCon = (struct espconn *)arg;
  MQTT_Client* pMQTTclient = (MQTT_Client *)pCon->reverse;
  if (pMQTTclient == NULL) {
	DBG("aborted connection ?");
	return;	
	}

  // if the message we sent is not a "pending" one, we need to free the buffer
  if (pMQTTclient->sending_buffer != NULL) {
    PktBuf *buf = pMQTTclient->sending_buffer;
	//DBG("PktBuf free %p l=%d", buf, buf->filled);
    os_free(buf);
    pMQTTclient->sending_buffer = NULL;
	}
  pMQTTclient->sending = false;

  // send next message if one is queued and we're not expecting an ACK
  if (pMQTTclient->connState == MQTT_CONNECTED && pMQTTclient->pending_buffer == NULL && pMQTTclient->msgQueue != NULL) {
    mqtt_send_message(pMQTTclient);
  }
}

/*
 * @brief: Timer function to handle timeouts
 */
static void ICACHE_FLASH_ATTR mqtt_timer(void* arg) {
  uint8 nRet=0;
  MQTT_Client* pMQTTclient = (MQTT_Client*)arg;
  
  os_timer_disarm(&pMQTTclient->mqttTimer);  

  switch (pMQTTclient->connState) {
    case MQTT_CONNECTED:
      if (pMQTTclient->pending_buffer != NULL && --pMQTTclient->timeoutTick == 0) {
        DBG("pMQTTclient->pending_buffer %d, looks like we're not getting a response in time, abort the connection", pMQTTclient->pending_buffer);
        mqtt_doAbort(pMQTTclient);
        pMQTTclient->timeoutTick = 0; // trick to make reconnect happen in 1 second
        nRet=1;
        }
      else if (pMQTTclient->keepAliveAckTick > 0 && --pMQTTclient->keepAliveAckTick == 0) {	// check whether our last keep-alive timed out
          DBG("Keep-alive timed out");
          mqtt_doAbort(pMQTTclient);
          nRet=2;
          }
        else if (pMQTTclient->keepAliveTick > 0 && --pMQTTclient->keepAliveTick == 0) {	// check whether we need to send a keep-alive message
            // timeout: we need to send a ping message
            DBG("Send keepalive");
            mqtt_msg_pingreq(&pMQTTclient->mqtt_connection);
            PktBuf *buf = PktBuf_New(pMQTTclient->mqtt_connection.message.length);
            os_memcpy(buf->data, pMQTTclient->mqtt_connection.message.data, pMQTTclient->mqtt_connection.message.length);
            buf->filled = pMQTTclient->mqtt_connection.message.length;
            pMQTTclient->msgQueue = PktBuf_Unshift(pMQTTclient->msgQueue, buf);
            mqtt_send_message(pMQTTclient);
            pMQTTclient->keepAliveTick = pMQTTclient->connect_info.keepalive;
            pMQTTclient->keepAliveAckTick = pMQTTclient->sendTimeout;
            }
        break;

	  case TCP_RECONNECT_REQ:
      if (pMQTTclient->timeoutTick == 0 || --pMQTTclient->timeoutTick == 0) {
        DBG("it's time to reconnect! start by re-enqueueing anything pending");
        if (pMQTTclient->pending_buffer != NULL) {
        pMQTTclient->msgQueue = PktBuf_Unshift(pMQTTclient->msgQueue, pMQTTclient->pending_buffer);
        pMQTTclient->pending_buffer = NULL;
        }
        pMQTTclient->connect_info.clean_session = 0; // ask server to keep state
        MQTT_Connect(pMQTTclient);
        }
      break;
		
	  case MQTT_DISCONNECTED:
      PRINTNET("MQTT_DISCONNECTED");
      break;
		
	  default: 
      PRINTNET("unexpected connState %d", pMQTTclient->connState);
      break;
	}
  os_timer_arm(&pMQTTclient->mqttTimer, 1000, 1);
}

/**
 * @brief  Callback from SDK that socket is disconnected
 * @param  arg: contain the ip link information
 * @retval None
 */
void ICACHE_FLASH_ATTR mqtt_tcpclient_discon_cb(void* arg) {
  struct espconn* pespconn = (struct espconn *)arg;
  MQTT_Client* pMQTTclient = (MQTT_Client *)pespconn->reverse;
  DBG("freeing espconn %p", arg);
  if (pespconn->proto.tcp) os_free(pespconn->proto.tcp);
  os_free(pespconn);

  // if this is an aborted connection we're done
  if (pMQTTclient == NULL) return;
  DBG("Disconnected from %s:%d", pMQTTclient->host, pMQTTclient->port);
  if (pMQTTclient->disconnectedCb) pMQTTclient->disconnectedCb(pMQTTclient);
  if (pMQTTclient->cmdDisconnectedCb) pMQTTclient->cmdDisconnectedCb(pMQTTclient);

  // reconnect unless we're in a permanently disconnected state
  if (pMQTTclient->connState == MQTT_DISCONNECTED) 
	return;
  
  pMQTTclient->timeoutTick = pMQTTclient->reconTimeout;
  if (pMQTTclient->reconTimeout < 128) pMQTTclient->reconTimeout <<= 1;
  pMQTTclient->connState = TCP_RECONNECT_REQ;
}

/**
* @brief  Callback from SDK that socket got reset, note that no discon_cb will follow
* @param  arg: contain the ip link information
* @retval None
*/
static void ICACHE_FLASH_ATTR mqtt_tcpclient_recon_cb(void* arg, int8_t err) {
  struct espconn* pespconn = (struct espconn *)arg;
  MQTT_Client* pMQTTclient = (MQTT_Client *)pespconn->reverse;
  //DBG("MQTT: Reset CB, freeing espconn %p (err=%d)", arg, err);
  if (pespconn->proto.tcp) os_free(pespconn->proto.tcp);
  os_free(pespconn);
  DBG("Connection reset from %s:%d", pMQTTclient->host, pMQTTclient->port);
  if (pMQTTclient->disconnectedCb) pMQTTclient->disconnectedCb(pMQTTclient);
  if (pMQTTclient->cmdDisconnectedCb) pMQTTclient->cmdDisconnectedCb(pMQTTclient);

  // reconnect unless we're in a permanently disconnected state
  if (pMQTTclient->connState == MQTT_DISCONNECTED) return;
  pMQTTclient->timeoutTick = pMQTTclient->reconTimeout;
  if (pMQTTclient->reconTimeout < 128) pMQTTclient->reconTimeout <<= 1;
  pMQTTclient->connState = TCP_RECONNECT_REQ;
  DBG("timeoutTick=%d reconTimeout=%d", pMQTTclient->timeoutTick, pMQTTclient->reconTimeout);
}


/**
* @brief  Callback from SDK that socket is connected
* @param  arg: contain the ip link information
* @retval None
*/
static void ICACHE_FLASH_ATTR mqtt_tcpclient_connect_cb(void* arg) {
  struct espconn* pCon = (struct espconn *)arg;
  MQTT_Client* pMQTTclient = (MQTT_Client *)pCon->reverse;
  if (pMQTTclient == NULL) return; // aborted connection

  espconn_regist_disconcb(pMQTTclient->pCon, mqtt_tcpclient_discon_cb);
  espconn_regist_recvcb(pMQTTclient->pCon, mqtt_tcpclient_recv);
  espconn_regist_sentcb(pMQTTclient->pCon, mqtt_tcpclient_sent_cb);
  DBG("TCP connected to %s:%d", pMQTTclient->host, pMQTTclient->port);

  // send MQTT connect message to broker
  mqtt_msg_connect(&pMQTTclient->mqtt_connection, &pMQTTclient->connect_info);
  PktBuf *buf = PktBuf_New(pMQTTclient->mqtt_connection.message.length);
  os_memcpy(buf->data, pMQTTclient->mqtt_connection.message.data, pMQTTclient->mqtt_connection.message.length);
  buf->filled = pMQTTclient->mqtt_connection.message.length;
  pMQTTclient->msgQueue = PktBuf_Unshift(pMQTTclient->msgQueue, buf); // prepend to send (rexmit) queue
  mqtt_send_message(pMQTTclient);
  pMQTTclient->connState = MQTT_CONNECTED; // v3.1.1 allows publishing while still connecting
  DBG("pMQTTclient->connState = MQTT_CONNECTED");
}

/**
 * @brief  Allocate and enqueue mqtt message, kick sending, if appropriate
 */
static void ICACHE_FLASH_ATTR mqtt_enq_message(MQTT_Client *pMQTTclient, const uint8_t *data, uint16_t len) {
  PktBuf *buf = PktBuf_New(len);
  os_memcpy(buf->data, data, len);
  buf->filled = len;
  pMQTTclient->msgQueue = PktBuf_Push(pMQTTclient->msgQueue, buf);

  if (pMQTTclient->connState == MQTT_CONNECTED && !pMQTTclient->sending && pMQTTclient->pending_buffer == NULL) {
    mqtt_send_message(pMQTTclient);
  }
}

/**
 * @brief  Send out top message in queue onto socket
 */
static void ICACHE_FLASH_ATTR mqtt_send_message(MQTT_Client* pMQTTclient) {
  PktBuf *buf = pMQTTclient->msgQueue;
  if (buf == NULL || pMQTTclient->sending) {
    DBG("buf == NULL %d || pMQTTclient->sending %d", buf == NULL, pMQTTclient->sending);
    return;
    }
  pMQTTclient->msgQueue = PktBuf_Shift(pMQTTclient->msgQueue);

  // get some details about the message
  uint16_t msg_type = mqtt_get_type(buf->data);
  uint8_t  msg_id = mqtt_get_id(buf->data, buf->filled);
  msg_id = msg_id;
  DBG("Send type=%s id=%04X len=%d", mqtt_msg_type[msg_type], msg_id, buf->filled);

  // send the message out
  if (pMQTTclient->security) {
    DBG("pMQTTclient->security");
    espconn_secure_sent(pMQTTclient->pCon, buf->data, buf->filled);
	  }
  else {
    DBG("no pMQTTclient->security");
    espconn_sent(pMQTTclient->pCon, buf->data, buf->filled);
  	}
  pMQTTclient->sending = true;

  // depending on whether it needs an ack we need to hold on to the message
  bool needsAck =
    (msg_type == MQTT_MSG_TYPE_PUBLISH && mqtt_get_qos(buf->data) > 0) ||
    msg_type == MQTT_MSG_TYPE_PUBREL || msg_type == MQTT_MSG_TYPE_PUBREC ||
    msg_type == MQTT_MSG_TYPE_SUBSCRIBE || msg_type == MQTT_MSG_TYPE_UNSUBSCRIBE ||
    msg_type == MQTT_MSG_TYPE_PINGREQ;
  if (msg_type == MQTT_MSG_TYPE_PINGREQ) {
    DBG("msg_type == MQTT_MSG_TYPE_PINGREQ");
    pMQTTclient->pending_buffer = NULL; // we don't need to rexmit this one
    pMQTTclient->sending_buffer = buf;
	  } 
  else if (needsAck) {
		  DBG("needsAck");
		  pMQTTclient->pending_buffer = buf;  // remeber for rexmit on disconnect/reconnect
		  pMQTTclient->sending_buffer = NULL;
		  pMQTTclient->timeoutTick = pMQTTclient->sendTimeout+1; // +1 to ensure full sendTireout seconds
		  } 
	   else {
		  DBG("no needsAck");
		  pMQTTclient->pending_buffer = NULL;
		  pMQTTclient->sending_buffer = buf;
		  pMQTTclient->timeoutTick = 0;
		  }
  pMQTTclient->keepAliveTick = pMQTTclient->connect_info.keepalive > 0 ? pMQTTclient->connect_info.keepalive+1 : 0;
}

/*  DNS lookup for broker hostname completed, move to next phase */
static void ICACHE_FLASH_ATTR mqtt_dns_found(const char* name, ip_addr_t* ipaddr, void* arg) {
  struct espconn* pConn = (struct espconn *)arg;
  MQTT_Client* pMQTTclient = (MQTT_Client *)pConn->reverse;

  if (ipaddr == NULL) {
    os_printf("MQTT: DNS lookup failed");
    pMQTTclient->timeoutTick = pMQTTclient->reconTimeout;
    if (pMQTTclient->reconTimeout < 128) pMQTTclient->reconTimeout <<= 1;
    pMQTTclient->connState = TCP_RECONNECT_REQ; // the timer will kick-off a reconnection
    return;
  }
  DBG("MQTT: ip %d.%d.%d.%d", *((uint8 *)&ipaddr->addr),
            *((uint8 *)&ipaddr->addr + 1),
            *((uint8 *)&ipaddr->addr + 2),
            *((uint8 *)&ipaddr->addr + 3));

  if (pMQTTclient->ip.addr == 0 && ipaddr->addr != 0) {
    os_memcpy(pMQTTclient->pCon->proto.tcp->remote_ip, &ipaddr->addr, 4);
    uint8_t err;
    if (pMQTTclient->security)
      err = espconn_secure_connect(pMQTTclient->pCon);
    else
      err = espconn_connect(pMQTTclient->pCon);
    if (err != 0) {
      os_printf("MQTT ERROR: Failed to connect");
      pMQTTclient->timeoutTick = pMQTTclient->reconTimeout;
      if (pMQTTclient->reconTimeout < 128) pMQTTclient->reconTimeout <<= 1;
      pMQTTclient->connState = TCP_RECONNECT_REQ;
	  } 
	  else {
      DBG("MQTT: connecting...");
    }
  }
}

//===== publish / subscribe

static void ICACHE_FLASH_ATTR msg_conn_init(mqtt_connection_t *new_msg, mqtt_connection_t *old_msg, uint8_t *buf, uint16_t buflen) {
  new_msg->message_id = old_msg->message_id;
  new_msg->buffer = buf;
  new_msg->buffer_length = buflen;
}

/**
* @brief  MQTT publish function.
* @param  pMQTTclient: MQTT_Client reference
* @param  topic:  string topic will publish to
* @param  data:   buffer data send point to
* @param  data_length: length of data
* @param  qos:    qos
* @param  retain: retain
* @retval TRUE if success queue
*/
bool ICACHE_FLASH_ATTR MQTT_Publish(MQTT_Client* pMQTTclient, const char* topic, const char* data, uint16_t data_length, uint8_t qos, uint8_t retain) {
  // estimate the packet size to allocate a buffer
  uint16_t topic_length = os_strlen(topic);
  // estimate: fixed hdr, pkt-id, topic length, topic, data, fudge
  uint16_t buf_len = 3 + 2 + 2 + topic_length + data_length + 16;
  PktBuf *buf = PktBuf_New(buf_len);
  if (buf == NULL) {
    os_printf("Cannot allocate buffer for %d byte publish", buf_len);
    return FALSE;
	}
  // use a temporary mqtt_message_t pointing to our buffer, this is a bit of a mess because we
  // need to keep track of the message_id that is embedded in it
  mqtt_connection_t msg;
  msg_conn_init(&msg, &pMQTTclient->mqtt_connection, buf->data, buf_len);
  uint16_t msg_id;
  if (!mqtt_msg_publish(&msg, topic, data, data_length, qos, retain, &msg_id)){
    os_printf("%s: Queuing Publish failed", __FUNCTION__);
    os_free(buf);
    return FALSE;
	}
  pMQTTclient->mqtt_connection.message_id = msg.message_id;
  if (msg.message.data != buf->data)
    os_memcpy(buf->data, msg.message.data, msg.message.length);
  buf->filled = msg.message.length;

  DBG("topic: \"%s\", data: %s", topic, data);	// DO NOT USE PRINTNET: IT SHARES pTxData
  pMQTTclient->msgQueue = PktBuf_Push(pMQTTclient->msgQueue, buf);

  if (!pMQTTclient->sending && pMQTTclient->pending_buffer == NULL) {
    mqtt_send_message(pMQTTclient);
	}
  else {
	DBG("mqtt_send_message fail %d", pMQTTclient->sending);
    return FALSE;
	}

  return TRUE;
}

/**
* @brief  MQTT subscribe function.
* @param  pMQTTclient: MQTT_Client reference
* @param  topic:  string topic will subscribe
* @param  qos:    qos
* @retval TRUE if success queue
*/
bool ICACHE_FLASH_ATTR MQTT_Subscribe(MQTT_Client* pMQTTclient, char* topic, uint8_t qos) {
  uint16_t msg_id;
  if (!mqtt_msg_subscribe(&pMQTTclient->mqtt_connection, topic, 0, &msg_id)) {
    os_printf("MQTT ERROR: Queuing Subscribe failed (too long)");
    return FALSE;
  }
  DBG("%s: topic: \"%s\"", __FUNCTION__, topic);
  mqtt_enq_message(pMQTTclient, pMQTTclient->mqtt_connection.message.data, pMQTTclient->mqtt_connection.message.length);
  return TRUE;
}

/**
* @brief  MQTT initialization mqtt client function
* @param  client:        MQTT_Client reference
* @param  host:   		 Domain or IP string
* @param  port:   		 Port to connect
* @param  security:      1 for ssl, 0 for none
* @param  sendTimeout:   
* @param  clientid:      MQTT client id
* @param  client_user:   MQTT client user
* @param  client_pass:   MQTT client password
* @param  keepAliveTime: MQTT keep alive timer, in second
* @param  cleanSession:  On connection, a client sets the "clean session" flag, which is sometimes also known as the "clean start" flag.
*                        If clean session is set to false, then the connection is treated as durable. This means that when the client
*                        disconnects, any subscriptions it has will remain and any subsequent QoS 1 or 2 messages will be stored until
*                        it connects again in the future. If clean session is true, then all subscriptions will be removed for the client
*                        when it disconnects.
* @retval None
*/
void ICACHE_FLASH_ATTR MQTT_Init(MQTT_Client* pMQTTclient, char* host, uint32 port, uint8_t security, uint8_t sendTimeout, char* client_id, uint8_t keepAliveTime) {
  os_memset(pMQTTclient, 0, sizeof(MQTT_Client));

  pMQTTclient->host = (char*)os_zalloc(os_strlen(host) + 1);
  os_strcpy(pMQTTclient->host, host);

  pMQTTclient->port = port;
  pMQTTclient->security = !!security;

  // timeouts with sanity checks
  pMQTTclient->sendTimeout = sendTimeout == 0 ? 1 : sendTimeout;
  pMQTTclient->reconTimeout = 1; 		// reset reconnect back-off

  os_memset(&pMQTTclient->connect_info, 0, sizeof(mqtt_connect_info_t));

  pMQTTclient->connect_info.client_id = (char*)os_zalloc(os_strlen(client_id) + 1);
  os_strcpy(pMQTTclient->connect_info.client_id, client_id);

  pMQTTclient->connect_info.keepalive = keepAliveTime;
  pMQTTclient->connect_info.clean_session = 1;

  pMQTTclient->in_buffer = (uint8_t *)os_zalloc(MQTT_MAX_RCV_MESSAGE);
  pMQTTclient->in_buffer_size = MQTT_MAX_RCV_MESSAGE;

  uint8_t *out_buffer = (uint8_t *)os_zalloc(MQTT_MAX_SHORT_MESSAGE);
  mqtt_msg_init(&pMQTTclient->mqtt_connection, out_buffer, MQTT_MAX_SHORT_MESSAGE);
}

/**
 * @brief  MQTT Set Last Will Topic, must be called before MQTT_Connect
 */
void ICACHE_FLASH_ATTR MQTT_InitLWT(MQTT_Client* pMQTTclient, char* will_topic, char* will_msg,
    uint8_t will_qos, uint8_t will_retain) {

  pMQTTclient->connect_info.will_topic = (char*)os_zalloc(os_strlen(will_topic) + 1);
  os_strcpy((char*)pMQTTclient->connect_info.will_topic, will_topic);

  pMQTTclient->connect_info.will_message = (char*)os_zalloc(os_strlen(will_msg) + 1);
  os_strcpy((char*)pMQTTclient->connect_info.will_message, will_msg);

  pMQTTclient->connect_info.will_qos = will_qos;
  pMQTTclient->connect_info.will_retain = will_retain;

  // TODO: if we're connected we should disconnect and reconnect to establish the new LWT
}

/**
* @brief  Begin connect to MQTT broker
* @param  client: MQTT_Client reference
* @retval None
*/
void ICACHE_FLASH_ATTR MQTT_Connect(MQTT_Client* pMQTTclient) {
  pMQTTclient->pCon = (struct espconn *)os_zalloc(sizeof(struct espconn));  
  pMQTTclient->pCon->type = ESPCONN_TCP;
  pMQTTclient->pCon->state = ESPCONN_NONE;
  pMQTTclient->pCon->proto.tcp = (esp_tcp *)os_zalloc(sizeof(esp_tcp));
  pMQTTclient->pCon->proto.tcp->local_port = espconn_port();
  pMQTTclient->pCon->proto.tcp->remote_port = pMQTTclient->port;
  pMQTTclient->pCon->reverse = pMQTTclient;
  espconn_regist_connectcb(pMQTTclient->pCon, mqtt_tcpclient_connect_cb);
  espconn_regist_reconcb(pMQTTclient->pCon, mqtt_tcpclient_recon_cb);

  // start timer function to tick every second
  os_timer_disarm(&pMQTTclient->mqttTimer);
  os_timer_setfn(&pMQTTclient->mqttTimer, (os_timer_func_t *)mqtt_timer, pMQTTclient);
  os_timer_arm(&pMQTTclient->mqttTimer, 1000, 1);

  // initiate the TCP connection
  DBG("to %s:%d %p", pMQTTclient->host, pMQTTclient->port, pMQTTclient->pCon);
  if (StrToIP((const char *)pMQTTclient->host, (void*)&pMQTTclient->pCon->proto.tcp->remote_ip)) {
    int8_t err;
    if (pMQTTclient->security)
      err = espconn_secure_connect(pMQTTclient->pCon);
    else
      err = espconn_connect(pMQTTclient->pCon);
    if (err != 0) {
      switch (err) {
        case ESPCONN_ISCONN:
          DBG("Failed to connect (ESPCONN_ISCONN) %d", err);
          break;
        case ESPCONN_RTE:
          DBG("Failed to connect (ESPCONN_RTE) %d", err);
          break;
          
        default:
          DBG("Failed to connect %d", err);
          break;
          }
      os_free(pMQTTclient->pCon->proto.tcp);
      os_free(pMQTTclient->pCon);
      pMQTTclient->pCon = NULL;
      return;
	    }
	  } 
  else {
    //espconn_gethostbyname(pMQTTclient->pCon, (const char *)pMQTTclient->host, &pMQTTclient->ip, mqtt_dns_found);
	}

  pMQTTclient->connState = TCP_CONNECTING;
  pMQTTclient->timeoutTick = 20; // generous timeout to allow for DNS, etc
  pMQTTclient->sending = FALSE;
}

static void ICACHE_FLASH_ATTR mqtt_doAbort(MQTT_Client* pMQTTclient) {
  DBG("Disconnecting from %s:%d (%p)", pMQTTclient->host, pMQTTclient->port, pMQTTclient->pCon);
  pMQTTclient->pCon->reverse = NULL; // ensure we jettison this pCon...
  if (pMQTTclient->security)
    espconn_secure_disconnect(pMQTTclient->pCon);
  else
    espconn_disconnect(pMQTTclient->pCon);

  if (pMQTTclient->disconnectedCb) pMQTTclient->disconnectedCb(pMQTTclient);
  if (pMQTTclient->cmdDisconnectedCb) pMQTTclient->cmdDisconnectedCb(pMQTTclient);

  if (pMQTTclient->sending_buffer != NULL) {
    os_free(pMQTTclient->sending_buffer);
    pMQTTclient->sending_buffer = NULL;
	}
  pMQTTclient->pCon = NULL;         // it will be freed in disconnect callback
  pMQTTclient->connState = TCP_RECONNECT_REQ;
  pMQTTclient->timeoutTick = pMQTTclient->reconTimeout;     // reconnect in a few seconds
  if (pMQTTclient->reconTimeout < 128) pMQTTclient->reconTimeout <<= 1;
}

void ICACHE_FLASH_ATTR MQTT_Reconnect(MQTT_Client* pMQTTclient) {
  switch (pMQTTclient->connState) {
	case MQTT_DISCONNECTED:
	  PRINTNET("connState is MQTT_DISCONNECTED");
	  MQTT_Connect(pMQTTclient);
	  break;
	  
	case MQTT_CONNECTED:
	  PRINTNET("connState is MQTT_CONNECTED");
	  mqtt_doAbort(pMQTTclient);
	  break;
	  
	default:
	  PRINTNET("in other cases we're already in the reconnecting process %d", pMQTTclient->connState);
	  break;
	}
}

void ICACHE_FLASH_ATTR MQTT_Disconnect(MQTT_Client* pMQTTclient) {
  DBG("Disconnect requested");
  os_timer_disarm(&pMQTTclient->mqttTimer);
  if (pMQTTclient->connState == MQTT_DISCONNECTED) return;
  if (pMQTTclient->connState == TCP_RECONNECT_REQ) {
    pMQTTclient->connState = MQTT_DISCONNECTED;
    return;
  }
  mqtt_doAbort(pMQTTclient);
  pMQTTclient->connState = MQTT_DISCONNECTED; // ensure we don't automatically reconnect
}

void ICACHE_FLASH_ATTR MQTT_Free(MQTT_Client* pMQTTclient) {
  DBG("Free requested");
  MQTT_Disconnect(pMQTTclient);

  if (pMQTTclient->host) os_free(pMQTTclient->host);
  pMQTTclient->host = NULL;

  if (pMQTTclient->connect_info.client_id) os_free(pMQTTclient->connect_info.client_id);
  os_memset(&pMQTTclient->connect_info, 0, sizeof(mqtt_connect_info_t));

  if (pMQTTclient->in_buffer) os_free(pMQTTclient->in_buffer);
  pMQTTclient->in_buffer = NULL;

  if (pMQTTclient->mqtt_connection.buffer) os_free(pMQTTclient->mqtt_connection.buffer);
  os_memset(&pMQTTclient->mqtt_connection, 0, sizeof(pMQTTclient->mqtt_connection));
}

void ICACHE_FLASH_ATTR MQTT_OnConnected(MQTT_Client* pMQTTclient, MqttCallback connectedCb) {
  pMQTTclient->connectedCb = connectedCb;
}

void ICACHE_FLASH_ATTR MQTT_OnDisconnected(MQTT_Client* pMQTTclient, MqttCallback disconnectedCb) {
  pMQTTclient->disconnectedCb = disconnectedCb;
}

void ICACHE_FLASH_ATTR MQTT_OnData(MQTT_Client* pMQTTclient, MqttDataCallback dataCb) {
  pMQTTclient->dataCb = dataCb;
}
/*
 * DO NOT USE os_printf OR DBG ! ! ! !!
*/
void ICACHE_FLASH_ATTR MQTT_OnPublished(MQTT_Client* pMQTTclient, MqttCallback publishedCb) {
  pMQTTclient->publishedCb = publishedCb;
}
