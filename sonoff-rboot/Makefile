# The name of the project being built.
PROJ_NAME ?= sonoff_th10
VERSION ?= "1.0.1"

#USE_DHCP ?= yes
USE_DHCP 	?= no
include ../sonoff/include_psw.mak

# IP address for OTA flashing -- Double quotes are mandatory!
#SONOFFTH10 ?= 0
SONOFFTH10 ?= 1
ifeq ("$(SONOFFTH10)","0")
  ESP_MQTT_TOPIC ?= "sonoff_th10/215/temp"
  ESP_IPADDRESS ?= "192.168.1.215"
  READ_DELAY 	?= "20000" 		# milliseconds
else
  ESP_MQTT_TOPIC ?= "sonoff_th10/216/temp"
  ESP_IPADDRESS ?= "192.168.1.216"
  READ_DELAY 	?= "5000" 		# milliseconds
endif

ESP_NETMASK ?= "255.255.255.0"
ESP_GATEWAY ?= "192.168.1.254"
CHIP_IN_HOSTNAME ?= no

ESP_MQTT_HOST ?= "192.168.1.6"
ESP_MQTT_PORT ?= 5800

# GPIO pin for blue LED, active low --. GPIO2 is for esp12e
# GPIO pin for blue LED, active low --. GPIO13 is for sonoff
# NodeMCU Pinouts
#    Pin number:
#    -----------
#    Pin 0 = GPIO16
#    Pin 1 = GPIO5
#    Pin 2 = GPIO4
#    Pin 3 = GPIO0
#    Pin 4 = GPIO2
#    Pin 5 = GPIO14
#    Pin 6 = GPIO12
#    Pin 7 = GPIO13
#    Pin 8 = GPIO15
#    Pin 9 = GPIO3
#    Pin 10 = GPIO1
#    Pin 11 = GPIO9
#    Pin 12 = GPIO10

# Pick your flash size: "512KB", "1MB", or "4MB"
# esp12e --> 4M
FLASH_SIZE ?= 4MB
# sonoff-th10 --> 1M
#FLASH_SIZE ?= 1MBb

ifeq ("$(FLASH_SIZE)","512KB")
# Winbond 25Q40 512KB flash, typ for esp-01 thru esp-11
ESP_SPI_SIZE        ?= 0       # 0->512KB (256KB+256KB)
ESP_FLASH_MODE      ?= 0       # 0->QIO
ESP_FLASH_FREQ_DIV  ?= 0       # 0->40Mhz
ET_FS               ?= 4m      # 4Mbit flash size in esptool flash command
ET_FF               ?= 40m     # 40Mhz flash speed in esptool flash command
ET_BLANK            ?= 0x7E000 # where to flash blank.bin to erase wireless settings
ESPBAUD		    ?= 115200
else ifeq ("$(FLASH_SIZE)","1MB")
# ESP-01E
ESP_SPI_SIZE        ?= 2       # 2->1MB (512KB+512KB)
ESP_FLASH_MODE      ?= 0       # 0->QIO, 2->DIO	--> ori
ESP_FLASH_FREQ_DIV  ?= 15      # 15->80MHz
ET_FS               ?= 8m      # 8Mbit flash size in esptool flash command
ET_FF               ?= 80m     # 80Mhz flash speed in esptool flash command
ET_BLANK            ?= 0xFE000 # where to flash blank.bin to erase wireless settings
ESPBAUD		    ?= 115200
else ifeq ("$(FLASH_SIZE)","1MBb")	# sonoff-th, Manufacturer: e0, Device: 4014 
RELE1_PIN	?= 6
LED_CONN_PIN	?= 7
DS18B20_PIN	?= 5
ESP_SPI_SIZE	?= 2       # 2->1MB (512KB spiffs)
ESP_FLASH_MODE      ?= 0       # 0->QIO, 2->DIO	--> ori
#ESP_FLASH_MODE      ?= 2       # 0->QIO, 2->DIO
ESP_FLASH_FREQ_DIV  ?= 15      # 15->80MHz		--> ori
#ESP_FLASH_FREQ_DIV  ?= 0       # 0->40Mhz
ET_FS               ?= 8m      # 8Mbit flash size in esptool flash command
ET_FF               ?= 80m     # 80Mhz flash speed in esptool flash command --> ori
#ET_FF               ?= 40m     # 40Mhz flash speed in esptool flash command
ET_BLANK            ?= 0xFE000 # where to flash blank.bin to erase wireless settings
ESPBAUD		    ?= 230400
else ifeq ("$(FLASH_SIZE)","1MBc")	# sonoff-th, Manufacturer: e0, Device: 4014 
RELE1_PIN	?= 6
LED_CONN_PIN	?= 7
DS18B20_PIN	?= 5
ESP_SPI_SIZE	?= 2       # 2->1MB (512KB spiffs)
ESP_FLASH_MODE      ?= 0       # 0->QIO, 2->DIO	--> ori
#ESP_FLASH_MODE      ?= 2       # 0->QIO, 2->DIO
ESP_FLASH_FREQ_DIV  ?= 15      # 15->80MHz		--> ori
#ESP_FLASH_FREQ_DIV  ?= 0       # 0->40Mhz
ET_FS               ?= 8m      # 8Mbit flash size in esptool flash command
ET_FF               ?= 80m     # 80Mhz flash speed in esptool flash command --> ori
#ET_FF               ?= 40m     # 40Mhz flash speed in esptool flash command
ET_BLANK            ?= 0xFE000 # where to flash blank.bin to erase wireless settings
ESPBAUD		    ?= 230400
else ifeq ("$(FLASH_SIZE)","2MB")
# Manuf 0xA1 Chip 0x4015 found on wroom-02 modules
# Here we're using two partitions of approx 0.5MB because that's what's easily available in terms
# of linker scripts in the SDK. Ideally we'd use two partitions of approx 1MB, the remaining 2MB
# cannot be used for code (esp8266 limitation).
ESP_SPI_SIZE        ?= 4       # 6->4MB (1MB+1MB) or 4->4MB (512KB+512KB)
ESP_FLASH_MODE      ?= 0       # 0->QIO, 2->DIO
ESP_FLASH_FREQ_DIV  ?= 15      # 15->80Mhz
ET_FS               ?= 16m     # 16Mbit flash size in esptool flash command
#ET_FF               ?= 80m     # 80Mhz flash speed in esptool flash command
ET_FF               ?= 40m     # 40Mhz flash speed in esptool flash command
ET_BLANK            ?= 0x1FE000 # where to flash blank.bin to erase wireless settings
ESPBAUD		?= 230400
else
# Winbond 25Q32 4MB flash, typ for esp-12
# Here we're using two partitions of approx 0.5MB because that's what's easily available in terms
# of linker scripts in the SDK. Ideally we'd use two partitions of approx 1MB, the remaining 2MB
# cannot be used for code (esp8266 limitation).
RELE1_PIN	?= 6
LED_CONN_PIN	?= 4
DS18B20_PIN	?= 5
ESP_SPI_SIZE        ?= 4       # 6->4MB (1MB+1MB) or 4->4MB (512KB+512KB)
ESP_FLASH_MODE      ?= 0       # 0->QIO, 2->DIO
ESP_FLASH_FREQ_DIV  ?= 15      # 15->80Mhz
ET_FS               ?= 32m     # 32Mbit flash size in esptool flash command
#ET_FF               ?= 80m     # 80Mhz flash speed in esptool flash command
ET_FF               ?= 40m     # 40Mhz flash speed in esptool flash command
ET_BLANK            ?= 0x3FE000 # where to flash blank.bin to erase wireless settings
ESPBAUD		    ?= 460800
endif

# Firmware version 
SDK_VERS ?= esp_iot_sdk_v1.5.2

# Try to find the firmware manually extracted, e.g. after downloading from Espressif's BBS,
# http://bbs.espressif.com/viewforum.php?f=46
SDK_BASE ?= $(wildcard ../$(SDK_VERS))

XTENSA_TOOLS_ROOT ?= $(abspath ../esp-open-sdk/xtensa-lx106-elf/bin)/

# If the firmware isn't there, see whether it got downloaded as part of esp-open-sdk
ifeq ($(SDK_BASE),)
SDK_BASE := $(wildcard $(XTENSA_TOOLS_ROOT)/../../$(SDK_VERS))
endif
# Clean up SDK path
SDK_BASE := $(abspath $(SDK_BASE))
$(warning Using SDK from $(SDK_BASE))


ESPTOOL		?= $(abspath ../esp-open-sdk/esptool/esptool.py)
ESPPORT		?= /dev/ttyUSB0
ESP_FLASH_MAX   ?= 503808  # max bin file

ESPTOOL2     ?= ../esptool2/esptool2
FW_SECTS      = .text .data .rodata
FW_USER_ARGS  = -quiet -bin -boot2

# select which tools to use as compiler, librarian and linker
CC	:= $(XTENSA_TOOLS_ROOT)xtensa-lx106-elf-gcc
AR	:= $(XTENSA_TOOLS_ROOT)xtensa-lx106-elf-ar
LD	:= $(XTENSA_TOOLS_ROOT)xtensa-lx106-elf-gcc
OBJCP	:= $(XTENSA_TOOLS_ROOT)xtensa-lx106-elf-objcopy
OBJDP	:= $(XTENSA_TOOLS_ROOT)xtensa-lx106-elf-objdump

BUILD_DIR = build
FIRMW_DIR = firmware

SDK_LIBDIR  = lib
SDK_INCDIR  = include
SDK_LIBDIR := $(addprefix $(SDK_BASE)/,$(SDK_LIBDIR))
SDK_INCDIR := $(addprefix -I$(SDK_BASE)/,$(SDK_INCDIR))

LIBS    = c gcc hal phy net80211 lwip wpa main pp crypto
CFLAGS  = -Os -g -O2 -std=gnu99 -Wpointer-arith -Wundef -Werror -Wno-implicit -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls  -mtext-section-literals
LDFLAGS = -nostdlib -Wl,--no-check-sections -u call_user_start -Wl,-static

SRC	:= $(wildcard *.c)
OBJ	:= $(patsubst %.c,$(BUILD_DIR)/%.o,$(SRC))
LIBS	:= $(addprefix -l,$(LIBS))

ifneq (,$(findstring yes,$(USE_DHCP)))
	CFLAGS		+= -DUSE_DHCP
endif

CFLAGS += -DVERSION="\"$(VERSION)\"" -DRELE1_PIN=$(RELE1_PIN) -DLED_CONN_PIN=$(LED_CONN_PIN) 
CFLAGS += -DDS18B20_PIN=$(DS18B20_PIN)
CFLAGS += -DWIFI_SSID=\"$(WIFI_SSID)\" -D__ets__ -DICACHE_FLASH
CFLAGS += -DWIFI_PASSWD=\"$(WIFI_PASSWD)\" -DREAD_DELAY=$(READ_DELAY)
CFLAGS += -DESP_IPADDRESS="\"$(ESP_IPADDRESS)\"" -DESP_NETMASK="\"$(ESP_NETMASK)\"" -DESP_GATEWAY="\"$(ESP_GATEWAY)\""
CFLAGS += -DESP_MQTT_HOST="\"$(ESP_MQTT_HOST)\"" -DESP_MQTT_PORT=$(ESP_MQTT_PORT) -DESP_MQTT_TOPIC="\"$(ESP_MQTT_TOPIC)\""
CFLAGS += -DFIRMWARE_SIZE=$(ESP_FLASH_MAX) -DPROJ_NAME="\"$(PROJ_NAME)\""

.SECONDARY:
.PHONY: all clean

C_FILES = $(wildcard *.c)
O_FILES = $(patsubst %.c,$(BUILD_DIR)/%.o,$(C_FILES))

all: $(BUILD_DIR) $(FIRMW_DIR) $(FIRMW_DIR)/rom0.bin $(FIRMW_DIR)/rom1.bin

$(BUILD_DIR)/%.o: %.c %.h
	@echo "CC $<"
	@$(CC) -I. $(SDK_INCDIR) $(CFLAGS) -o $@ -c $<

$(BUILD_DIR)/%.elf: $(O_FILES)
	@echo "LD $(notdir $@)"
	@$(LD) -L$(SDK_LIBDIR) -T$(notdir $(basename $@)).ld $(LDFLAGS) -Wl,--start-group $(LIBS) $^ -Wl,--end-group -o $@

$(FIRMW_DIR)/%.bin: $(BUILD_DIR)/%.elf
	@echo "FW $(notdir $@)"
	@$(ESPTOOL2) $(FW_USER_ARGS) $^ $@ $(FW_SECTS)

$(BUILD_DIR):
	@mkdir -p $@

$(FIRMW_DIR):
	@mkdir -p $@

wiflash: all
	./tcp_flash.py $(ESP_IPADDRESS) $(FIRMW_DIR)/rom0.bin $(FIRMW_DIR)/rom1.bin

flashr: all
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) 0x00000 ../rboot/$(FIRMW_DIR)/rboot.bin

flash0: all
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) 0x02000 $(FIRMW_DIR)/rom0.bin

flash1: all
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) 0x82000 $(FIRMW_DIR)/rom1.bin

baseflash: all
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) 0x00000 ../rboot/$(FIRMW_DIR)/rboot.bin 0x02000 $(FIRMW_DIR)/rom0.bin 0x82000 $(FIRMW_DIR)/rom1.bin 0xfc000 ../esp-open-sdk/esp_iot_sdk_v1.5.2/bin/esp_init_data_default.bin

reset:
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) run

clean:
	@echo "RM $(BUILD_DIR) $(FIRMW_DIR)"
	@rm -rf $(BUILD_DIR)
	@rm -f $(FIRMW_DIR)/rom0.bin $(FIRMW_DIR)/rom1.bin
