#
# Makefile for rBoot
# https://github.com/raburton/esp8266
#
# Firmware version 
SDK_VERS ?= esp_iot_sdk_v1.5.2

# Try to find the firmware manually extracted, e.g. after downloading from Espressif's BBS,
# http://bbs.espressif.com/viewforum.php?f=46
SDK_BASE ?= $(wildcard ../$(SDK_VERS))

# If the firmware isn't there, see whether it got downloaded as part of esp-open-sdk
ifeq ($(SDK_BASE),)
SDK_BASE := $(wildcard $(XTENSA_TOOLS_ROOT)/../../$(SDK_VERS))
endif

# Clean up SDK path
SDK_BASE := $(abspath $(SDK_BASE))
$(warning Using SDK from $(SDK_BASE))

XTENSA_TOOLS_ROOT ?= $(abspath ../esp-open-sdk/xtensa-lx106-elf/bin)/

ESPTOOL		?= $(abspath ../esp-open-sdk/esptool/esptool.py)
ESPPORT		?= /dev/ttyUSB0
#ESPBAUD	?= 115200
ESPBAUD		?= 230400

FLASH_SIZE ?= 4MB
# sonoff-th10 --> 1M
#FLASH_SIZE ?= 1MBb

ifeq ("$(FLASH_SIZE)","1MBb")
SPI_SIZE	?= 1M
SPI_MODE	?= qio
SPI_SPEED	?= 40
ET_FS           ?= 8m
else ifeq ("$(FLASH_SIZE)","4MB")
SPI_SIZE	?= 4M
SPI_MODE	?= qio
SPI_SPEED	?= 40
#SPI_SPEED	?= 80
# 32Mbit flash size in esptool flash command
ET_FS          ?= 32m
endif

ESPTOOL2     ?= ../esptool2/esptool2

RBOOT_BAUDRATE ?= 115200

RBOOT_BUILD_BASE ?= build
RBOOT_FW_BASE    ?= firmware

CC := $(addprefix $(XTENSA_TOOLS_ROOT)/,xtensa-lx106-elf-gcc)
LD := $(addprefix $(XTENSA_TOOLS_ROOT)/,xtensa-lx106-elf-gcc)

ifeq ($(V),1)
Q :=
else
Q := @
endif

CFLAGS    = -Os -O3 -Wpointer-arith -Wundef -Werror -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals  -D__ets__ -DICACHE_FLASH
LDFLAGS   = -nostdlib -Wl,--no-check-sections -u call_user_start -Wl,-static
LD_SCRIPT = eagle.app.v6.ld

E2_OPTS = -quiet -bin -boot0

ifeq ($(RBOOT_BIG_FLASH),1)
	CFLAGS += -DBOOT_BIG_FLASH
endif
ifneq ($(RBOOT_DELAY_MICROS),)
	CFLAGS += -DBOOT_DELAY_MICROS=$(RBOOT_DELAY_MICROS)
endif
ifneq ($(RBOOT_BAUDRATE),)
	CFLAGS += -DBOOT_BAUDRATE=$(RBOOT_BAUDRATE)
endif
ifeq ($(RBOOT_INTEGRATION),1)
	CFLAGS += -DRBOOT_INTEGRATION
endif
ifeq ($(RBOOT_RTC_ENABLED),1)
	CFLAGS += -DBOOT_RTC_ENABLED
endif
ifeq ($(RBOOT_CONFIG_CHKSUM),1)
	CFLAGS += -DBOOT_CONFIG_CHKSUM
endif
ifeq ($(RBOOT_GPIO_ENABLED),1)
	CFLAGS += -DBOOT_GPIO_ENABLED
endif
ifeq ($(RBOOT_GPIO_SKIP_ENABLED),1)
	CFLAGS += -DBOOT_GPIO_SKIP_ENABLED
endif
ifneq ($(RBOOT_GPIO_NUMBER),)
	CFLAGS += -DBOOT_GPIO_NUM=$(RBOOT_GPIO_NUMBER)
endif
ifeq ($(RBOOT_IROM_CHKSUM),1)
	CFLAGS += -DBOOT_IROM_CHKSUM
endif
ifneq ($(RBOOT_EXTRA_INCDIR),)
	CFLAGS += $(addprefix -I,$(RBOOT_EXTRA_INCDIR))
endif
CFLAGS += $(addprefix -I,.)

ifeq ($(SPI_SIZE), 256K)
	E2_OPTS += -256
else ifeq ($(SPI_SIZE), 512K)
	E2_OPTS += -512
else ifeq ($(SPI_SIZE), 1M)
	E2_OPTS += -1024
else ifeq ($(SPI_SIZE), 2M)
	E2_OPTS += -2048
else ifeq ($(SPI_SIZE), 4M)
	E2_OPTS += -4096
endif

ifeq ($(SPI_MODE), qio)
	E2_OPTS += -qio
else ifeq ($(SPI_MODE), dio)
	E2_OPTS += -dio
else ifeq ($(SPI_MODE), qout)
	E2_OPTS += -qout
else ifeq ($(SPI_MODE), dout)
	E2_OPTS += -dout
endif

ifeq ($(SPI_SPEED), 20)
	E2_OPTS += -20
else ifeq ($(SPI_SPEED), 26)
	E2_OPTS += -26.7
else ifeq ($(SPI_SPEED), 40)
	E2_OPTS += -40
else ifeq ($(SPI_SPEED), 80)
	E2_OPTS += -80
endif

.SECONDARY:

all: $(RBOOT_BUILD_BASE) $(RBOOT_FW_BASE) $(RBOOT_FW_BASE)/rboot.bin $(RBOOT_FW_BASE)/testload1.bin $(RBOOT_FW_BASE)/testload2.bin
#all: $(RBOOT_BUILD_BASE) $(RBOOT_FW_BASE) $(RBOOT_FW_BASE)/rboot.bin

$(RBOOT_BUILD_BASE):
	mkdir -p $@

$(RBOOT_FW_BASE):
	mkdir -p $@

$(RBOOT_BUILD_BASE)/rboot-stage2a.o: rboot-stage2a.c rboot-private.h rboot.h
	@echo "CC $<"
	$(Q) $(CC) $(CFLAGS) -c $< -o $@

$(RBOOT_BUILD_BASE)/rboot-stage2a.elf: $(RBOOT_BUILD_BASE)/rboot-stage2a.o
	@echo "LD $@"
	$(Q) $(LD) -Trboot-stage2a.ld $(LDFLAGS) -Wl,--start-group $^ -Wl,--end-group -o $@

$(RBOOT_BUILD_BASE)/rboot-hex2a.h: $(RBOOT_BUILD_BASE)/rboot-stage2a.elf
	@echo "E2 $@"
	$(Q) $(ESPTOOL2) -quiet -header $< $@ .text

$(RBOOT_BUILD_BASE)/rboot.o: rboot.c rboot-private.h rboot.h $(RBOOT_BUILD_BASE)/rboot-hex2a.h
	@echo "CC $<"
	$(Q) $(CC) $(CFLAGS) -I$(RBOOT_BUILD_BASE) -c $< -o $@

$(RBOOT_BUILD_BASE)/%.o: %.c %.h
	@echo "CC $<"
	$(Q) $(CC) $(CFLAGS) -c $< -o $@

$(RBOOT_BUILD_BASE)/%.elf: $(RBOOT_BUILD_BASE)/%.o
	@echo "LD $@"
	$(Q) $(LD) -T$(LD_SCRIPT) $(LDFLAGS) -Wl,--start-group $^ -Wl,--end-group -o $@

$(RBOOT_FW_BASE)/%.bin: $(RBOOT_BUILD_BASE)/%.elf
	@echo "E2 $@"
	$(Q) $(ESPTOOL2) $(E2_OPTS) $< $@ .text .rodata

flash: all
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fm $(SPI_MODE) -fs $(ET_FS) 0x0000 $(RBOOT_FW_BASE)/rboot.bin
	#$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fm $(SPI_MODE) -fs $(ET_FS) 0x0000 $(RBOOT_FW_BASE)/rboot.bin 0x02000 $(RBOOT_FW_BASE)/testload1.bin 0x82000 $(RBOOT_FW_BASE)/testload2.bin 0xfc000 ../esp-open-sdk/esp_iot_sdk_v1.5.2/bin/esp_init_data_default.bin

testflash: all
	$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fm $(SPI_MODE) -fs $(ET_FS) 0x0000 $(RBOOT_FW_BASE)/rboot.bin 0x02000 $(RBOOT_FW_BASE)/testload1.bin 0x82000 $(RBOOT_FW_BASE)/testload2.bin 0xfc000 blank4.bin
	#$(Q) $(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) write_flash -fm $(SPI_MODE) -fs $(ET_FS) 0x0000 $(RBOOT_FW_BASE)/rboot.bin 0x02000 $(RBOOT_FW_BASE)/testload1.bin 0x82000 $(RBOOT_FW_BASE)/testload2.bin 0xfc000 ../esp-open-sdk/esp_iot_sdk_v1.5.2/bin/esp_init_data_default.bin

erase: all
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) erase_flash

run:
	$(ESPTOOL) --port $(ESPPORT) --baud $(ESPBAUD) run
clean:
	@echo "RM $(RBOOT_BUILD_BASE) $(RBOOT_FW_BASE)"
	$(Q) rm -rf $(RBOOT_BUILD_BASE)
	$(Q) rm -rf $(RBOOT_FW_BASE)
