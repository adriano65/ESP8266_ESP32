ifdef SONOFFTH10a
#mosquitto_sub -v -p 5800 -h 192.168.1.6 -t 'sonoff_th10/#'
PROJ_NAME      :=  "sonoff_th10"
LED_CONN_PIN_ACTIVELOW   := 1
BUTTON0_PIN	   := GPIO_0
RELAY_PIN		   := GPIO_12
SI7021_PIN     := GPIO_14
STA_IPADDRESS  := "192.168.1.215"
READ_DELAY     := 200
PING_DELAY     := 1200			# 1/10 seconds timer (1200 == 2 minute) -> OR see user_main.c
#PING_DELAY     := 150
TEST_IP_ADDRESS:= "8.8.8.8"
REFRESHIO      := yes
MQTT_STAT_TOPIC := "sonoff_th10/215/temp"
MQTT_BTN_TOPIC := "sonoff_th10/215/button"
FLASH_SIZE     := 1MBb
CFLAGS	       := -DSONOFFTH10_WATCHDOG -DAP_SSID='"RouterWatchDog"' -DTEMP_OFFSET=0 -DHUMI_OFFSET=0

else ifdef SONOFFTH10b
# ---------------------- 16 Ampere
PROJ_NAME      := "sonoff_th10"
LED_CONN_PIN_ACTIVELOW   := 1
BUTTON0_PIN	   := GPIO_0
RELAY_PIN		   := GPIO_12
SI7021_PIN     := GPIO_14
STA_IPADDRESS  := "192.168.1.216"
READ_DELAY     := 100
MQTT_STAT_TOPIC := "sonoff_th10/216/temp"
MQTT_BTN_TOPIC := "sonoff_th10/216/button"
FLASH_SIZE     := 1MBb
CFLAGS	       := -DSONOFFTH10 -DAP_SSID='"16Amp"' -DTEMP_OFFSET=2 -DHUMI_OFFSET=-2.8

else ifdef SONOFFTH10c
# ---------------------------------- garage
PROJ_NAME      := "sonoff_th10"
LED_CONN_PIN_ACTIVELOW   := 1
BUTTON0_PIN	   := GPIO_0
RELAY_PIN		   := GPIO_12
DHT22_PIN	     := GPIO_14
STA_IPADDRESS  := "192.168.1.217"
READ_DELAY     := 200
MQTT_STAT_TOPIC := "sonoff_th10/217/temp"
MQTT_BTN_TOPIC := "sonoff_th10/217/button"
FLASH_SIZE     := 1MBb
CFLAGS	       := -DSONOFFTH10  -DAP_SSID='"OutsideTemp"'

else ifdef SONOFFTH10d
# --------------------------------- cantina
PROJ_NAME      := "sonoff_th10"
LED_CONN_PIN_ACTIVELOW   := 1
BUTTON0_PIN	   := GPIO_0
RELAY_PIN		   := GPIO_12
SI7021_PIN     := GPIO_14
STA_IPADDRESS  := "192.168.1.218"
USE_DHCP       := no
READ_DELAY     := 200
REFRESHIO      := yes
MQTT_STAT_TOPIC := "sonoff_th10/218/temp"
MQTT_BTN_TOPIC := "sonoff_th10/218/button"
FLASH_SIZE     := 1MBc
CFLAGS	       := -DSONOFFTH10 -DAP_SSID='"CantinaTemp"' -DTEMP_OFFSET=0 -DHUMI_OFFSET=0

else ifdef SONOFFTH10e
# ----------------------------------- veranda
PROJ_NAME      := "sonoff_th10"
LED_CONN_PIN_ACTIVELOW   := 1
BUTTON0_PIN	   := GPIO_0
RELAY_PIN		   := GPIO_12
SI7021_PIN     := GPIO_14
STA_IPADDRESS  := "192.168.1.219"
READ_DELAY     := 200
REFRESHIO      := yes
MQTT_STAT_TOPIC := "sonoff_th10/219/temp"
MQTT_BTN_TOPIC := "sonoff_th10/219/button"
FLASH_SIZE     := 1MBb
CFLAGS	       := -DSONOFFTH10 -DAP_SSID='"Veranda"' -DTEMP_OFFSET=0 -DHUMI_OFFSET=0

else ifdef MAINSa
#mosquitto_sub -v -p 5800 -h 192.168.1.6 -t 'esp_mains/#'
PROJ_NAME      := "esp_mains"
LED_CONN_PIN   := GPIO_2
LED_CONN_PIN_ACTIVELOW   := 1
USE_RXD0 			 := no
USE_TXD0       := yes
STA_IPADDRESS  := "192.168.1.11"
USE_DHCP       := no
READ_DELAY     := 100
MQTT_STAT_TOPIC := "esp_mains/11/status"
FLASH_SIZE     := 4MB
CFLAGS	       := -DMAINS -DAP_SSID='"CantinaMains"'

else ifdef ARMTRONIXa
PROJ_NAME      := "Armtronix"
LED_CONN_PIN   := GPIO_5
STA_IPADDRESS  := "192.168.1.111"
READ_DELAY     := 200
REFRESHIO      := yes
MQTT_STAT_TOPIC := "Armtronix/111/status"
FLASH_SIZE     := 4MBc
CFLAGS	       := -DARMTRONIX -DAP_SSID='"Armtronix"'

else ifdef MAINSc
PROJ_NAME      := "esp_mains"
LED_CONN_PIN   := GPIO_2
LED_CONN_PIN_ACTIVELOW   := 1
USE_TXD0       := yes
STA_IPADDRESS  := "192.168.1.112"
USE_DHCP       := no
READ_DELAY     := 100
MQTT_STAT_TOPIC := "esp_mains/112/status"
FLASH_SIZE     := 4MB
CFLAGS	       := -DMAINS -DANT_TEST -DAP_SSID='"AntennaTester"'

else ifdef MAINS_VMC
PROJ_NAME      := "esp_mains_vmc"
LED_CONN_PIN   := GPIO_2
LED_CONN_PIN_ACTIVELOW   := 1
I2C_SCL_PIN 	:= no
I2C_SDA_PIN		:= GPIO_0
STA_IPADDRESS  := "192.168.1.113"
USE_DHCP       := yes
READ_DELAY     := 100
MQTT_STAT_TOPIC := "'$(PROJ_NAME)'/113/status"
FLASH_SIZE     := 4MBb
#FLASH_SIZE     := 4MBd
CFLAGS	       := -DMAINS_VMC -DAP_SSID='"esp_mains_vmc"'

else ifdef ESP01a
PROJ_NAME      := "esp01"
LED_CONN_PIN   := GPIO_2    # really there is no led (only vcc led and tx led)
USE_DHCP       := no
STA_IPADDRESS  := "192.168.1.114"
READ_DELAY     := 100
MQTT_STAT_TOPIC := "esp01/114/status"
FLASH_SIZE     := 512KB
CFLAGS	       := -DESP01 -DAP_SSID='"ESP01"'

else ifdef MAINSd
PROJ_NAME      := "GasInjectorCleaner"
LED_CONN_PIN   := GPIO_2
LED_CONN_PIN_ACTIVELOW   := 1
PWM0_PIN	   := GPIO_16
OPENCOLLECTOR_PIN	   := GPIO_1
STA_IPADDRESS  := "192.168.1.115"
USE_DHCP       := no
READ_DELAY     := 100
MQTT_STAT_TOPIC := "GasInjectorCleaner/115/status"
FLASH_SIZE     := 4MB
CFLAGS	       := -DGASINJECTORCLEANER -DAP_SSID='"GasInjectorCleaner"'

else ifdef MAINSe
PROJ_NAME      := "esp12e_housePowerMeterTx"
LED_CONN_PIN   := GPIO_2
LED_CONN_PIN_ACTIVELOW   := 1
STA_IPADDRESS  := "192.168.1.116"
#HPMETER_RX_IP := '"192.168.1.242"'
HPMETER_RX_IP := '"192.168.1.5"'
USE_DHCP       := no
READ_DELAY     := 50
MQTT_STAT_TOPIC := "housePowerMeterTx/116/status"
FLASH_SIZE     := 4MB
CFLAGS	       := -DMAINS -DHOUSE_POW_METER_TX -DAP_SSID='"housePowerMeterTx"'

else ifdef MAINSf
PROJ_NAME      := "esp12e_housePowerMeterRx"
LED_CONN_PIN   := GPIO_2
LED_CONN_PIN_ACTIVELOW   := 1
STA_IPADDRESS  := "192.168.1.242"
USE_DHCP       := no
READ_DELAY     := 20
MQTT_STAT_TOPIC := "housePowerMeterRx/242/status"
FLASH_SIZE     := 4MBb
CFLAGS	       := -DMAINS -DHOUSE_POW_METER_RX -DAP_SSID='"housePowerMeterRx"'

# ---------------------------------- Sun Power Meter
else ifdef SONOFFPOWa
PROJ_NAME      := "sonoff_pow"
LED_CONN_PIN   := GPIO_15
BUTTON0_PIN	   := GPIO_0
RELAY_PIN		   := GPIO_12
STA_IPADDRESS  := "192.168.1.220"
READ_DELAY     := 20
MQTT_STAT_TOPIC := "sonoff_pow/220/status"
MQTT_BTN_TOPIC := "sonoff_pow/220/button"
FLASH_SIZE     := 1MBb
CFLAGS	       := -DSONOFFPOW -DAP_SSID='"sun_power"' -DA_TRIM_VALUE=67.6139240506 -DV_TRIM_VALUE=2.86 -DW_TRIM_VALUE=2.61341630821

else ifdef SONOFFPOWb
# ---------------------------------- ModBus and bell
PROJ_NAME      := "sonoff_ex_pow"
LED_CONN_PIN   := GPIO_15
BUTTON0_PIN	   := GPIO_0
RELAY_PIN		   := GPIO_12
USE_TXD0       := yes
STA_IPADDRESS  := "192.168.1.221"
HPMETER_RX_IP  := '"192.168.1.242"'
READ_DELAY     := 20
MQTT_STAT_TOPIC := "sonoff_pow/221/status"
MQTT_BTN_TOPIC := "sonoff_pow/221/button"
FLASH_SIZE     := 1MBb
CFLAGS	       := -DSONOFFPOW_DDS238_2 -DAP_SSID='"ModBus"'

# ---------------------------------- ModBus and bell backup
else ifdef SONOFFPOWc
# ------------------------------------ DEBUG
PROJ_NAME      := "sonoff_ex_pow"
CFLAGS	       := -DSONOFFPOW_DDS238_2 -DAP_SSID='"ModBus2"'
USE_TXD0       := yes
# ------------------------------------ PRUDU
#PROJ_NAME      := "sonoff_pow"
#CFLAGS	       := -DSONOFFPOW -DAP_SSID='"ModBus2"' -DA_TRIM_VALUE=67.6139240506 -DV_TRIM_VALUE=2.86 -DW_TRIM_VALUE=2.61341630821
#USE_TXD0       := no
# ------------------------------------ END
LED_CONN_PIN   := GPIO_15
BUTTON0_PIN	   := GPIO_0
RELAY_PIN		   := GPIO_12
STA_IPADDRESS  := "192.168.1.222"
HPMETER_RX_IP  := '"192.168.1.242"'
READ_DELAY     := 20
MQTT_STAT_TOPIC := "sonoff_pow/222/status"
MQTT_BTN_TOPIC := "sonoff_pow/222/button"
FLASH_SIZE     := 1MBb

else ifdef SONOFFPOWd
# PROJ_NAME      := "sonoff_pow"
PROJ_NAME      := "sonoff_ex_pow"   # to enable dds238 !!
LED_CONN_PIN   := GPIO_15
BUTTON0_PIN	   := GPIO_0
RELAY_PIN		    := GPIO_12
STA_IPADDRESS  := "192.168.1.223"
READ_DELAY     := 40
MQTT_STAT_TOPIC := "sonoff_pow/223/status"
MQTT_BTN_TOPIC := "sonoff_pow/223/button"
FLASH_SIZE     := 1MBb
CFLAGS	       := -DSONOFFPOW -DAP_SSID='"POWTest223"' -DA_TRIM_VALUE=67.6139240506 -DV_TRIM_VALUE=2.86 -DW_TRIM_VALUE=3.5

# ---------------------------------- TEST ModBus
else ifdef SONOFFPOWe
PROJ_NAME      := "sonoff_pow"
LED_CONN_PIN   := GPIO_15
BUTTON0_PIN	   := GPIO_0
RELAY_PIN			 := GPIO_12
STA_IPADDRESS  := "192.168.1.224"
READ_DELAY     := 40
MQTT_STAT_TOPIC := "sonoff_pow/224/status"
MQTT_BTN_TOPIC := "sonoff_pow/224/button"
FLASH_SIZE     := 1MBb
CFLAGS	       := -DSONOFFPOW -DAP_SSID='"POWTest224"' -DA_TRIM_VALUE=67.6139240506 -DV_TRIM_VALUE=2.86 -DW_TRIM_VALUE=2.61341630821
# ---------------------------------- end TEST ModBus
else ifdef SONOFFPOWf
PROJ_NAME      := "sonoff_pow"
LED_CONN_PIN   := GPIO_15
BUTTON0_PIN	   := GPIO_0
RELAY_PIN		:= GPIO_12
STA_IPADDRESS  := "192.168.1.225"
READ_DELAY     := 100
MQTT_STAT_TOPIC := "sonoff_pow/225/status"
MQTT_BTN_TOPIC := "sonoff_pow/225/button"
FLASH_SIZE     := 1MB
CFLAGS	       := -DSONOFFPOW -DAP_SSID='"POWTest225"' -DA_TRIM_VALUE=0.0723351851852 -DV_TRIM_VALUE=2.92397827919 -DW_TRIM_VALUE=2.61341630821

else ifdef SONOFFDUALa
PROJ_NAME      := "sonoff_dual"
LED_CONN_PIN_ACTIVELOW   := 1
BUTTON0_PIN	   := GPIO_10
RELAY_PIN		:= GPIO_12
# Serial TXD and Optional sensor
I2C_SCL_PIN     := GPIO_3
# Serial RXD and Optional sensor
I2C_SDA_PIN     := GPIO_1
USE_TXD0       := yes
STA_IPADDRESS  := "192.168.1.230"
READ_DELAY     := 200
MQTT_STAT_TOPIC := "sonoff_dual/230/voltage"
MQTT_BTN_TOPIC := "sonoff_dual/230/button"
FLASH_SIZE     := 1MBc
CFLAGS	       := -DSONOFFDUAL -DAP_SSID='"SONOFFDUALa"'

else ifdef SONOFFDUALb
PROJ_NAME      := "sonoff_dual"
LED_CONN_PIN_ACTIVELOW   := 1
BUTTON0_PIN	   	:= GPIO_10
RELAY_PIN		:= GPIO_12
# Serial TXD and Optional sensor
I2C_SCL_PIN     := GPIO_3
# Serial RXD and Optional sensor
I2C_SDA_PIN     := GPIO_1
USE_TXD0       := yes
STA_IPADDRESS  := "192.168.1.231"
READ_DELAY     := 200
MQTT_STAT_TOPIC := "sonoff_dual/231/voltage"
MQTT_BTN_TOPIC := "sonoff_dual/231/button"
FLASH_SIZE     := 1MBc
#FLASH_SIZE     := 1MBb
CFLAGS	       := -DSONOFFDUAL -DAP_SSID='"SONOFFDUALb"'

else ifdef SONOFFDUALc
PROJ_NAME      := "sonoff_dual"
LED_CONN_PIN_ACTIVELOW   := 1
BUTTON0_PIN	   	:= GPIO_10
RELAY_PIN		:= GPIO_12
# Serial TXD and Optional sensor
I2C_SCL_PIN     := GPIO_3
# Serial RXD and Optional sensor
I2C_SDA_PIN     := GPIO_1
USE_TXD0       := yes
STA_IPADDRESS  := "192.168.1.232"
READ_DELAY     := 200
MQTT_STAT_TOPIC := "sonoff_th10/232/temp"
MQTT_BTN_TOPIC := "sonoff_th10/232/button"
FLASH_SIZE     := 1MBb
CFLAGS	       := -DSONOFFDUAL -DAP_SSID='"SONOFFDUALc"'

else ifdef SONOFFDUALd
PROJ_NAME      := "sonoff_dual"
LED_CONN_PIN_ACTIVELOW   := 1
BUTTON0_PIN	   	:= GPIO_10
RELAY_PIN		:= GPIO_12
SI7021_PIN     := GPIO_9
STA_IPADDRESS  := "192.168.1.233"
READ_DELAY     := 200
MQTT_STAT_TOPIC := "sonoff_th10/233/temp"
MQTT_BTN_TOPIC := "sonoff_th10/233/button"
FLASH_SIZE     := 1MBb
CFLAGS	       := -DSONOFFDUAL -DAP_SSID='"SONOFFDUALd"'
else 
	$(error "ESPTYPE undefined!")
endif

