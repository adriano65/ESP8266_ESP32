#
# Makefile for rBoot sample project
# https://github.com/raburton/esp8266
#

include ../sonoff/include_psw.mak

#SDK_BASE   ?= /opt/esp-open-sdk/sdk

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
#ESPBAUD		?= 115200
ESPBAUD		?= 230400
# max bin file
ESP_FLASH_MAX   ?= 503808
# # 0->QIO, 1-> QOUT, 2->DIO, 3-> DOUT
ESP_FLASH_MODE  ?= qio
#flash_clk_div
#     0 :  80m / 2 	->40Mhz
#     1 :  80m / 3	
#     2 :  80m / 4	-> 20Mhz
#    0xf:  80m / 1
ESP_FLASH_FREQ_DIV  ?= 0xf
# flash speed in esptool flash command
#ET_FF               ?= 40m
ET_FF               ?= 80m

#'4m', '2m', '8m', '16m', '32m', '16m-c1', '32m-c1', '32m-c2'
#ESP_FLASH_SIZE		?= 32m-c2
ESP_FLASH_SIZE		?= 32m

SDK_LIBDIR  = lib
SDK_INCDIR  = include

ESPTOOL2     ?= ../esptool2/esptool2
FW_SECTS      = .text .data .rodata
FW_USER_ARGS  = -quiet -bin -boot2

ifndef XTENSA_BINDIR
CC := xtensa-lx106-elf-gcc
LD := xtensa-lx106-elf-gcc
else
CC := $(addprefix $(XTENSA_BINDIR)/,xtensa-lx106-elf-gcc)
LD := $(addprefix $(XTENSA_BINDIR)/,xtensa-lx106-elf-gcc)
endif

BUILD_DIR = build
FIRMW_DIR = firmware

SDK_LIBDIR := $(addprefix $(SDK_BASE)/,$(SDK_LIBDIR))
SDK_INCDIR := $(addprefix -I$(SDK_BASE)/,$(SDK_INCDIR))

LIBS    = c gcc hal phy net80211 lwip wpa main pp crypto
CFLAGS  = -Os -g -O2 -Wpointer-arith -Wundef -Werror -Wno-implicit -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls  -mtext-section-literals  -D__ets__ -DICACHE_FLASH
LDFLAGS = -nostdlib -Wl,--no-check-sections -u call_user_start -Wl,-static

SRC		:= $(wildcard *.c)
OBJ		:= $(patsubst %.c,$(BUILD_DIR)/%.o,$(SRC))
LIBS		:= $(addprefix -l,$(LIBS))

ifneq ($(WIFI_SSID), "")
	CFLAGS += -DWIFI_SSID=\"$(WIFI_SSID)\"
endif
ifneq ($(WIFI_PWD), "")
	CFLAGS += -DWIFI_PWD=\"$(WIFI_PWD)\"
endif

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

flash: all
#	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs 32m 0x00000 ../rboot/$(FIRMW_DIR)/rboot.bin 0x02000 $(FIRMW_DIR)/rom0.bin 0x82000 $(FIRMW_DIR)/rom1.bin 0xfc000 blank4.bin
#	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs 8m 0x00000 ../rboot/$(FIRMW_DIR)/rboot.bin 0x02000 $(FIRMW_DIR)/rom0.bin 0x82000 $(FIRMW_DIR)/rom1.bin 0xfc000 blank4.bin
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fm $(ESP_FLASH_MODE) -fs $(ESP_FLASH_SIZE) -ff $(ET_FF) 0x00000 ../rboot/$(FIRMW_DIR)/rboot.bin 0x02000 $(FIRMW_DIR)/rom0.bin 0x82000 $(FIRMW_DIR)/rom1.bin # 0xfc000 blank4.bin
#	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fs 32m 0x02000 $(FIRMW_DIR)/rom0.bin 0xfc000 blank4.bin

flash0: all
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fm $(ESP_FLASH_MODE) -fs $(ESP_FLASH_SIZE) -ff $(ET_FF) 0x00000 ../rboot/$(FIRMW_DIR)/rboot.bin

erase: all
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) erase_flash

run:
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) run

reset:
	/usr/local/src/rts-dtr/serial_rts_dtr

clean:
	@echo "RM $(BUILD_DIR) $(FIRMW_DIR)"
	@rm -rf $(BUILD_DIR)
	@rm -rf $(FIRMW_DIR)
