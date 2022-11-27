$(info Using environment conf $(CONF))
# --------------- toolchain configuration ---------------
# Base directory for the compiler. Needs a / at the end.
ifeq ($(CONF),esp8266)
XTENSA_TOOLS_ROOT := $(abspath ../esp-open-sdk/xtensa-lx106-elf/bin)/
endif
ifeq ($(CONF),esp8266_new)
XTENSA_TOOLS_ROOT := $(abspath ../esp/xtensa-lx106-elf/bin)/
endif
ifeq ($(CONF),esp8266_upd)
XTENSA_TOOLS_ROOT := /home/name/.espressif/tools/xtensa-lx106-elf/esp-2020r3-49-gd5524c1-8.4.0/xtensa-lx106-elf/bin/
endif

# select which tools to use as compiler, librarian and linker
CC	:= $(XTENSA_TOOLS_ROOT)xtensa-lx106-elf-gcc
AR	:= $(XTENSA_TOOLS_ROOT)xtensa-lx106-elf-ar
LD	:= $(XTENSA_TOOLS_ROOT)xtensa-lx106-elf-gcc
OBJCP	:= $(XTENSA_TOOLS_ROOT)xtensa-lx106-elf-objcopy
OBJDP	:= $(XTENSA_TOOLS_ROOT)xtensa-lx106-elf-objdump

# SDK version 
ifeq ($(CONF),esp8266)
SDK_VERS := esp_iot_sdk_v1.5.2
endif

ifeq ($(CONF),esp8266_upd)
SDK_VERS := ESP8266_NONOS_SDK-3.0.5
endif

$(info Using SDK_VERS $(SDK_VERS))

# SDK_BASE 
ifeq ($(CONF),esp8266)
SDK_BASE := $(wildcard $(XTENSA_TOOLS_ROOT)/../../$(SDK_VERS))
endif

ifeq ($(CONF),esp8266_upd)
SDK_BASE := /home/name/$(SDK_VERS)
endif
SDK_BASE := $(abspath $(SDK_BASE))

$(info Using SDK from $(SDK_BASE))

SDK_LDDIR	= ld
SDK_LDDIR 	:= $(addprefix $(SDK_BASE)/,$(SDK_LDDIR))

# Esptool.py path and port, only used for 1-time serial flashing
# Typically you'll use https://github.com/themadinventor/esptool
# Windows users use the com port i.e: ESPPORT := com3
ESPTOOL		:= $(abspath ../esp-open-sdk/esptool/esptool.py)
ESPPORT		:= /dev/ttyUSB0

#VERBOSE := 1
VERBOSE := 0

# -----------------------
#USE_DHCP := yes
USE_DHCP := no

# Future expansion to rboot by Richard A. Burton
USE_RBOOT := no
#USE_RBOOT := yes

include include_psw.mak

# GPIO pin for LED, active low --. GPIO13 is for sonoff-th10, sonoff_dual. GPIO15 is for sonoff-pow 
USE_RXD0       						:= no
USE_TXD0       						:= no
LED_CONN_PIN   						:= GPIO_13
LED_CONN_PIN_ACTIVELOW   	:= 0
DS18B20_PIN    						:= no
DHT22_PIN      						:= no
SI7021_PIN     						:= no
BUTTON0_PIN    						:= no
RELAY_PIN    							:= no
TEMP_OFFSET								:= 0
HUMI_OFFSET								:= 0
I2C_SCL_PIN     					:= no
I2C_SDA_PIN     					:= no
HPMETER_RX_IP   					:= no
TEST_IP_ADDRESS     			:= no
ANT_TEST     							:= no
REFRESHIO      						:= no
PWM0_PIN      						:= no

# error -- reset IP addresses on FW relaod !!!
# ----------------- test
SONOFFTH10a := 1
# ----------------- ?
#SONOFFTH10b := 1
# ----------------- fuori-garage
#SONOFFTH10c := 1
# ----------------- Cantina switch + temp
#SONOFFTH10d := 1
# ----------------- VerandaTemp
#SONOFFTH10e := 1

# ----------------- Linux Monitor and a lot more !
#MAINSa := 2

# ----------------- garage interno
#ARMTRONIXa := 2

# ----------------- AntTest
#MAINSc := 2

# ----------------- some day...
#MAINS_VMC := 2

# ----------------- gas injectors cleaner
#MAINSd := 2

# ----------------- GTN House power Transmitter
#MAINSe := 2

# ----------------- GTN House power Receiver (ESP8266 boot baud rate is 76800)
#MAINSf := 2

# --------------------GTN Sun power meter
#SONOFFPOWa := 3

# --------------------House Power Meter (ModBus) and external Bell!
#SONOFFPOWb := 3

# --------------------Test (House Power Meter (ModBus) and external Bell!)
#SONOFFPOWc := 3

# --------------------all house power backup
#SONOFFPOWd := 3

# --------------------TEST ModBus
#SONOFFPOWe := 3
#SONOFFPOWf := 3

#ESP01a := 4
# --------------------solar 2 batteries switch 1 and 2
#SONOFFDUALa  := 5
# --------------------solar panel switch 1 and 2
#SONOFFDUALb  := 5
#SONOFFDUALc  := 5
#SONOFFDUALd  := 5

include include_esptypes.mak

STA_NETMASK := "255.255.255.0"
STA_GATEWAY := "192.168.1.254"
AP_IPADDRESS := "192.168.4.1"
AP_NETMASK := "255.255.255.0"
AP_GATEWAY := "192.168.4.5"

MQTT_HOST := "192.168.1.6"
MQTT_PORT := 5800

ESP_FLASH_MAX       := 503808

include include_flash.mak

VERSION := "1.0.2"
BINDATE := "$(shell date '+%F %T')"
$(info PROJ_NAME $(PROJ_NAME), STA_IPADDRESS $(STA_IPADDRESS), Version $(VERSION), Flash $(FLASH_SIZE), Date $(BINDATE) )

# Output directors to store intermediate compiled files
# relative to the project directory
BUILD_BASE	= build
FW_BASE		= firmware

# name for the target project
TARGET		= $(PROJ_NAME)

# espressif tool to concatenate sections for OTA upload using bootloader v1.2+
APPGEN_TOOL	:= gen_appbin.py

ifeq ($(CONF),esp8266)
LD_SCRIPT1	    ?= $(SDK_LDDIR)/eagle.app.v6.new.1024.app1.ld
LD_SCRIPT2	    ?= $(SDK_LDDIR)/eagle.app.v6.new.1024.app2.ld
endif

ifeq ($(CONF),esp8266_upd)
LD_SCRIPT1	    ?= $(SDK_LDDIR)/eagle.app.v6.new.1024.app1.ld
LD_SCRIPT2	    ?= $(SDK_LDDIR)/eagle.app.v6.new.1024.app2.ld
endif

# which modules (subdirectories) of the project to include in compiling
LIBRARIES_DIR 	= libraries
# libraries used in this project, mainly provided by the SDK
#LIBS += c gcc hal pp phy net80211 lwip wpa pwm upgrade main ssl crypto
#LIBS += c gcc hal pp phy net80211 lwip wpa upgrade main ssl crypto
LIBS += c gcc hal pp phy net80211 lwip wpa main ssl crypto

MODULES		+= src mqtt rtc_ntp 

ifeq ($(PROJ_NAME),"sonoff_pow")
MODULES		+= hlw8012
#LIBS += m
endif

ifeq ($(PROJ_NAME),"sonoff_ex_pow")
MODULES		+= dds238-2
endif

ifeq ($(PROJ_NAME),"esp12e_housePowerMeterTx")
MODULES		+= housePowerMeterTx
endif

ifeq ($(PROJ_NAME),"esp12e_housePowerMeterRx")
MODULES		+= housePowerMeterRx
endif

ifeq ($(PROJ_NAME),"esp01")
MODULES		+= dds238-2
endif

ifeq ($(PROJ_NAME),"esp_mains_vmc")
#MODULES		+= ccs811
MODULES		+= ina226
#LIBS += m
endif

ifeq ($(PROJ_NAME),"sonoff_dual")
#MODULES		+= ccs811
MODULES		+= ina226
#LIBS += m
endif

ifeq ($(PROJ_NAME),"GasInjectorCleaner")
MODULES		+= injectorcleaner
endif

MODULES		+= $(foreach sdir,$(LIBRARIES_DIR),$(wildcard $(sdir)/*))

# compiler flags using during compilation of source files
CFLAGS	+= -Os -ggdb -std=c99 -Wpointer-arith -Wl,-EL -fno-inline-functions \
	   -nostdlib -mlongcalls -mtext-section-literals -ffunction-sections -fdata-sections \
	   -Wno-implicit-function-declaration \
	   -D__ets__ -DICACHE_FLASH -Wno-address -DESP_FLASH_MAX=$(ESP_FLASH_MAX) \
	   -DREAD_DELAY=$(READ_DELAY) -DSTA_SSID='$(STA_SSID)' -DSTA_PASS='$(STA_PASS)' -DAP_PSW='$(AP_PSW)' \
	   -DSTA_IPADDRESS='$(STA_IPADDRESS)' -DSTA_NETMASK='$(STA_NETMASK)' -DSTA_GATEWAY='$(STA_GATEWAY)' \
	   -DAP_IPADDRESS='$(AP_IPADDRESS)' -DAP_NETMASK='$(AP_NETMASK)' -DAP_GATEWAY='$(AP_GATEWAY)' \
	   -DMQTT_HOST='$(MQTT_HOST)' -DMQTT_PORT=$(MQTT_PORT) -DMQTT_STAT_TOPIC='$(MQTT_STAT_TOPIC)' -DMQTT_BTN_TOPIC='$(MQTT_BTN_TOPIC)' \
	   -DPROJ_NAME='$(PROJ_NAME)' -DVERSION='$(VERSION)' -DBINDATE='$(BINDATE)'

ifeq ("$(USE_DHCP)","yes")
CFLAGS += -DUSE_DHCP
endif

ifneq ("$(LED_CONN_PIN)","no")
CFLAGS	+= -DLED_CONN_PIN=$(LED_CONN_PIN)
CFLAGS	+= -DLED_CONN_PIN_ACTIVELOW=$(LED_CONN_PIN_ACTIVELOW)
endif

ifneq ("$(BUTTON0_PIN)","no")
CFLAGS	+= -DBUTTON0_PIN=$(BUTTON0_PIN)
endif

ifneq ("$(RELAY_PIN)","no")
CFLAGS	+= -DRELAY_PIN=$(RELAY_PIN)
endif

ifneq ("$(DS18B20_PIN)","no")
CFLAGS	+= -DDS18B20_PIN=$(DS18B20_PIN)
MODULES		+= ds18b20
endif

ifneq ("$(DHT22_PIN)","no")
CFLAGS	+= -DDHT22_PIN=$(DHT22_PIN)
MODULES		+= dht11_22
endif

ifneq ("$(SI7021_PIN)","no")
CFLAGS	+= -DSI7021_PIN=$(SI7021_PIN)
MODULES		+= si7021
endif

ifneq ("$(USE_TXD0)","no")
CFLAGS	+= -DUSE_TXD0
endif

ifneq ("$(USE_RXD0)","no")
CFLAGS	+= -DUSE_RXD0
endif

ifeq ("$(REFRESHIO)","yes")
CFLAGS	+= -DREFRESHIO=$(REFRESHIO)
endif

ifneq ("$(HPMETER_RX_IP)","no")
CFLAGS	+= -DHPMETER_RX_IP=$(HPMETER_RX_IP)
endif

ifneq ("$(TEST_IP_ADDRESS)","no")
CFLAGS	+= -DTEST_IP_ADDRESS=$(TEST_IP_ADDRESS)
endif

ifneq ("$(PWM0_PIN)","no")
$(info ******************************************** $(PWM0_PIN) )
CFLAGS	+= -DPWM0_PIN=$(PWM0_PIN)
LIBS		+= pwm
endif

ifneq ("$(OPENCOLLECTOR_PIN)","no")
CFLAGS	+= -DOPENCOLLECTOR_PIN=$(OPENCOLLECTOR_PIN)
endif

# linker flags used to generate the main object file
LDFLAGS		= -nostdlib -Wl,--no-check-sections -u call_user_start -Wl,-static -Wl,--gc-sections

# various paths from the SDK used in this project
SDK_LIBDIR	= lib
SDK_INCDIR	= include
SDK_INCDIR_THIRD	= third_party/include
SDK_TOOLSDIR	= tools

####
SRC_DIR		:= $(MODULES)
BUILD_DIR	:= $(addprefix $(BUILD_BASE)/,$(MODULES))

SDK_LIBDIR	:= $(addprefix $(SDK_BASE)/,$(SDK_LIBDIR))
SDK_INCDIR	:= $(addprefix -I$(SDK_BASE)/,$(SDK_INCDIR))
SDK_INCDIR_THIRD	:= $(addprefix -I$(SDK_BASE)/,$(SDK_INCDIR_THIRD))
SDK_TOOLS	:= $(addprefix $(SDK_BASE)/,$(SDK_TOOLSDIR))
APPGEN_TOOL	:= $(addprefix $(SDK_TOOLS)/,$(APPGEN_TOOL))

SRC		:= $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.c))
OBJ		:= $(patsubst %.c,$(BUILD_BASE)/%.o,$(SRC))
LIBS		:= $(addprefix -l,$(LIBS))
APP_AR		:= $(addprefix $(BUILD_BASE)/,$(TARGET)_app.a)
USER1_OUT 	:= $(addprefix $(BUILD_BASE)/,$(TARGET).user1.out)
USER2_OUT 	:= $(addprefix $(BUILD_BASE)/,$(TARGET).user2.out)

INCDIR		:= $(addprefix -I,$(SRC_DIR))
MODULE_INCDIR	:= $(addsuffix /include,$(INCDIR))


V := $(VERBOSE)
ifeq ("$(V)","1")
Q :=
vecho := @true
else
Q := @
vecho := @echo
endif

vpath %.c $(SRC_DIR)

define compile-objects
$1/%.o: %.c
	$(vecho) "CC $$<"
	$(Q)$(CC) $(INCDIR) $(MODULE_INCDIR) $(SDK_INCDIR) $(SDK_INCDIR_THIRD) $(CFLAGS)  -c $$< -o $$@
endef

.PHONY: all checkdirs clean wiflash

all: clean checkdirs $(FW_BASE)/user1.bin $(FW_BASE)/user2.bin include_esptypes.mak
	@echo "LED_CONN_PIN -> $(value LED_CONN_PIN)"
	@echo "BUTTON0_PIN -> $(value BUTTON0_PIN)"	
	@echo "DHT22_PIN -> $(value DHT22_PIN)"
	@echo "DS18B20_PIN -> $(value DS18B20_PIN)"
	@echo "SI7021_PIN -> $(value SI7021_PIN)"

$(USER1_OUT): $(APP_AR)
	$(vecho) "LD $@"
	$(Q) $(LD) -L$(SDK_LIBDIR) -T$(LD_SCRIPT1) $(LDFLAGS) -Wl,--start-group $(LIBS) $(APP_AR) -Wl,--end-group -o $@
	@echo Dump  : $(OBJDP) -x $(USER1_OUT)
	@echo Disass: $(OBJDP) -d -l -x $(USER1_OUT)

$(USER2_OUT): $(APP_AR)
	$(vecho) "LD $@"
	$(Q) $(LD) -L$(SDK_LIBDIR) -T$(LD_SCRIPT2) $(LDFLAGS) -Wl,--start-group $(LIBS) $(APP_AR) -Wl,--end-group -o $@

$(FW_BASE):
	$(vecho) "FW $@"
	$(Q) mkdir -p $@

# eagle.flash.bin     @ 0x00000 */
# eagle.irom0text.bin @ 0x20000 */
# Flash Map, support 512KB/1MB/2MB/4MB SPI Flash */
# |......|..............................|..........................|.....|....|                       */
# ^      ^                              ^                          ^     ^                            */
# |_flash.bin start(0x0000)             |_irom0text.bin start(0x20000)   |                            */
#        |_flash.bin end                                           |_irom0text.bin end                */
#                                                                        |_system param area(0x7b000) */

# 
ifeq ($(CONF),esp8266)
$(FW_BASE)/user1.bin: $(USER1_OUT) $(FW_BASE)
	$(Q) $(OBJCP) --only-section .text -O binary $(USER1_OUT) eagle.app.v6.text.bin
	$(Q) $(OBJCP) --only-section .data -O binary $(USER1_OUT) eagle.app.v6.data.bin
	$(Q) $(OBJCP) --only-section .rodata -O binary $(USER1_OUT) eagle.app.v6.rodata.bin
	$(Q) $(OBJCP) --only-section .irom0.text -O binary $(USER1_OUT) eagle.app.v6.irom0text.bin
	ls -ls eagle*bin
	$(Q) COMPILE=gcc PATH=$(XTENSA_TOOLS_ROOT):$(PATH) python $(APPGEN_TOOL) $(USER1_OUT) 2 $(ESP_FLASH_MODE) $(ESP_FLASH_FREQ_DIV) $(ESP_SPI_SIZE) 0
	$(Q) rm -f eagle.app.v6.*.bin
	$(Q) mv eagle.app.flash.bin $@
	@echo "** user1.bin uses $$(stat -c '%s' $@) bytes of" $(ESP_FLASH_MAX) "available"
	$(Q) if [ $$(stat -c '%s' $@) -gt $$(( $(ESP_FLASH_MAX) )) ]; then echo "$@ too big!"; false; fi
endif

ifeq ($(CONF),esp8266_upd)
$(FW_BASE)/user1.bin: $(USER1_OUT) $(FW_BASE)
	$(Q) $(OBJCP) --only-section .text -O binary $(USER1_OUT) eagle.app.v6.text.bin
	$(Q) $(OBJCP) --only-section .data -O binary $(USER1_OUT) eagle.app.v6.data.bin
	$(Q) $(OBJCP) --only-section .rodata -O binary $(USER1_OUT) eagle.app.v6.rodata.bin
	$(Q) $(OBJCP) --only-section .irom0.text -O binary $(USER1_OUT) eagle.app.v6.irom0text.bin
	ls -ls eagle*bin
	$(Q) COMPILE=gcc PATH=$(XTENSA_TOOLS_ROOT):$(PATH) python $(APPGEN_TOOL) $(USER1_OUT) 2 $(ESP_FLASH_MODE) $(ESP_FLASH_FREQ_DIV) $(ESP_SPI_SIZE) 0
	$(Q) rm -f eagle.app.v6.*.bin
	$(Q) mv eagle.app.flash.bin $@
	@echo "** user1.bin uses $$(stat -c '%s' $@) bytes of" $(ESP_FLASH_MAX) "available"
	$(Q) if [ $$(stat -c '%s' $@) -gt $$(( $(ESP_FLASH_MAX) )) ]; then echo "$@ too big!"; false; fi
endif

$(FW_BASE)/user2.bin: $(USER2_OUT) $(FW_BASE)
	$(Q) $(OBJCP) --only-section .text -O binary $(USER2_OUT) eagle.app.v6.text.bin
	$(Q) $(OBJCP) --only-section .data -O binary $(USER2_OUT) eagle.app.v6.data.bin
	$(Q) $(OBJCP) --only-section .rodata -O binary $(USER2_OUT) eagle.app.v6.rodata.bin
	$(Q) $(OBJCP) --only-section .irom0.text -O binary $(USER2_OUT) eagle.app.v6.irom0text.bin
	$(Q) COMPILE=gcc PATH=$(XTENSA_TOOLS_ROOT):$(PATH) python $(APPGEN_TOOL) $(USER2_OUT) 2 $(ESP_FLASH_MODE) $(ESP_FLASH_FREQ_DIV) $(ESP_SPI_SIZE) 0
	$(Q) rm -f eagle.app.v6.*.bin
	$(Q) mv eagle.app.flash.bin $@
	@echo "** user2.bin uses $$(stat -c '%s' $@) bytes of" $(ESP_FLASH_MAX) "available"
	$(Q) if [ $$(stat -c '%s' $@) -gt $$(( $(ESP_FLASH_MAX) )) ]; then echo "$@ too big!"; false; fi

$(APP_AR): $(OBJ)
	$(vecho) "AR $@"
	$(Q) $(AR) cru $@ $^

checkdirs: $(BUILD_DIR)

$(BUILD_DIR):
	$(Q) mkdir -p $@

read_mac:
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) read_mac

erase_flash:
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) erase_flash

read_flash:
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) read_flash 0x00000 0x01000 dump.bin


flash_id:
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) flash_id

run:
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) run

reset:
	/usr/local/src/rts-dtr/serial_rts_dtr

wiflash: all
# ---------- TOO dangerous for my memory :-(
#ifeq ("$(MAINSa)","2") 
#	./tcp_flash.py 192.168.4.1 $(FW_BASE)/user1.bin $(FW_BASE)/user2.bin
#else
#ifeq ("$(SONOFFPOWb)","3")
#	./tcp_flash.py 192.168.4.1 $(FW_BASE)/user1.bin $(FW_BASE)/user2.bin
#else
	./tcp_flash.py $(STA_IPADDRESS) $(FW_BASE)/user1.bin $(FW_BASE)/user2.bin
#endif
#endif

wiflash0: all
	./tcp_flash.py 192.168.1.118 $(FW_BASE)/user1.bin $(FW_BASE)/user2.bin

ifeq ($(CONF),esp8266)
flash: all
	@echo "--> connect GPIO0 to gnd (when poweron) to enable flash mode :-)"
	@echo "$(CONF) Loading user1.bin and user2.bin"
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) 0x01000 $(FW_BASE)/user1.bin 0x82000 $(FW_BASE)/user2.bin
endif

ifeq ($(CONF),esp8266_upd)
flash: all
	@echo "--> connect GPIO0 to gnd (when poweron) to enable flash mode :-)"
	@echo "$(CONF) Loading user1.bin and user2.bin"
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) 0x01000 $(FW_BASE)/user1.bin 0x82000 $(FW_BASE)/user2.bin
endif

user2: all
	@echo "Loading user2.bin"
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) 0x82000 $(FW_BASE)/user2.bin

ifeq ($(CONF),esp8266)
baseflash: all
	@echo "$(CONF) Loading Bootloader, user1.bin, user2.bin, blank.bin, blank.bin, esp_init_data_default.bin"
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) -fm $(ESPTOOL_FM) 0x00000 "$(SDK_BASE)/bin/boot_v1.5.bin" 0x01000 $(FW_BASE)/user1.bin 0x82000 $(FW_BASE)/user2.bin $(ET_INIT_DATA_DEF) "../esp-open-sdk/esp_iot_sdk_v1.5.2/bin/esp_init_data_default.bin" $(ET_BLANK) "$(SDK_BASE)/bin/blank.bin"
endif

ifeq ($(CONF),esp8266_upd)
baseflash: all
	@echo "$(CONF) Loading Bootloader, user1.bin, user2.bin, blank.bin, blank.bin, esp_init_data_default.bin"
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) -fm $(ESPTOOL_FM) 0x00000 "$(SDK_BASE)/bin/boot_v1.7.bin" 0x01000 $(FW_BASE)/user1.bin 0x82000 $(FW_BASE)/user2.bin $(ET_INIT_DATA_DEF) "$(SDK_BASE)/bin/esp_init_data_default_v08.bin" $(ET_BLANK) "$(SDK_BASE)/bin/blank.bin"
endif

#
#ifneq (,$(findstring no,$(USE_RBOOT)))
#	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) -fm $(ESPTOOL_FM) 0x00000 "$(SDK_BASE)/bin/boot_v1.5.bin" 0x01000 $(FW_BASE)/user1.bin 0x82000 $(FW_BASE)/user2.bin
#else
#	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) 0x00000 "../rboot/firmware/rboot.bin" 0x01000 $(FW_BASE)/user1.bin # $(ET_BLANK) $(SDK_BASE)/bin/blank.bin
#endif

blank: all
	@echo "Loading blank.bin"
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) -fm $(ESPTOOL_FM) $(ET_BLANK) "$(SDK_BASE)/bin/blank.bin"

ifeq ($(CONF),esp8266)
esp_init: all
	@echo "$(CONF) Loading esp_init_data_default.bin"
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) -fm $(ESPTOOL_FM) $(ET_INIT_DATA_DEF) "../esp-open-sdk/esp_iot_sdk_v1.5.2/bin/esp_init_data_default.bin"
endif

ifeq ($(CONF),esp8266_upd)
esp_init: all
	@echo "$(CONF) Loading esp_init_data_default_v08.bin"
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) -fm $(ESPTOOL_FM) $(ET_INIT_DATA_DEF) "$(SDK_BASE)/bin/esp_init_data_default_v08.bin"
endif

erase: all
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) erase_flash

ifeq ($(CONF),esp8266)
boot: all
	@echo "$(CONF) Loading Bootloader"
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) -fm $(ESPTOOL_FM) 0x00000 "$(SDK_BASE)/bin/boot_v1.5.bin"
endif

ifeq ($(CONF),esp8266_upd)
boot: all
	@echo "$(CONF) Loading Bootloader"
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs $(ET_FS) -ff $(ET_FF) -fm $(ESPTOOL_FM) 0x00000 "$(SDK_BASE)/bin/boot_v1.7.bin"
endif

clean:
	$(Q) rm -f $(APP_AR)
	$(Q) rm -f $(TARGET_OUT)
	$(Q) find $(BUILD_BASE) -type f | xargs rm -f
	$(Q) rm -rf $(FW_BASE)

tar:
	tar cvzf ../sonoff-$(VERSION).tar.gz *

$(foreach bdir,$(BUILD_DIR),$(eval $(call compile-objects,$(bdir))))
