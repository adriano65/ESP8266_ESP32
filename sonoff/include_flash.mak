
ifeq ("$(FLASH_SIZE)","512KB")
# Winbond 25Q40 512KB flash, typ for esp-01 thru esp-11
ESP_SPI_SIZE        := 0       # 0->512KB (256KB+256KB)
ESP_FLASH_MODE      := 0       # 0->QIO
ESP_FLASH_FREQ_DIV  := 0       # 0->40Mhz
ET_FS               := 4m      # 4Mbit flash size in esptool flash command
ET_FF               := 40m     # 40Mhz flash speed in esptool flash command
ET_BLANK            := 0x7E000 # where to flash blank.bin to erase wireless settings
ESPBAUD		    := 230400

else ifeq ("$(FLASH_SIZE)","1MB")
# ESP-01E
ESP_SPI_SIZE        := 2       # 2->1MB (512KB+512KB)
ESP_FLASH_MODE      := 0       # 0->QIO, 2->DIO	--> ori
ESP_FLASH_FREQ_DIV  := 15      # 15->80MHz
ET_FS               := 8m      # 8Mbit flash size in esptool flash command
ET_FF               := 80m     # 80Mhz flash speed in esptool flash command
ET_BLANK            := 0xFE000
ET_INIT_DATA_DEF    := 0xFC000
ESPBAUD		    := 460800

else ifeq ("$(FLASH_SIZE)","1MBb")
ESP_SPI_SIZE        := 2
ESP_FLASH_MODE      := 0
ESPTOOL_FM	    := qio
ESP_FLASH_FREQ_DIV  := 0
ET_FS               := 8m
#ET_FF               := 80m
ET_FF               := 40m
ET_BLANK            := 0xFE000
ET_INIT_DATA_DEF    := 0xFC000
#ESPBAUD		    := 230400
ESPBAUD		    := 460800

else ifeq ("$(FLASH_SIZE)","1MBc")
ESP_SPI_SIZE        := 2       # 2->1MB (512KB spiffs)
# 0->QIO, 1-> QOUT, 2->DIO, 3-> DOUT
ESP_FLASH_MODE      := 3
#ESPTOOL_FM	    := qio
#ESPTOOL_FM	    := qout
#ESPTOOL_FM	    := dio
ESPTOOL_FM	    := dout
#ESP_FLASH_MODE      := 0
#flash_clk_div
#     0 :  80m / 2 	->40Mhz
#     1 :  80m / 3	
#     2 :  80m / 4	-> 20Mhz
#    0xf:  80m / 1
ESP_FLASH_FREQ_DIV  := 0
ET_FS               := 8m      # 8Mbit flash size in esptool flash command
ET_FF               := 40m     # 40Mhz flash speed in esptool flash command
ET_BLANK            := 0xFE000
ET_INIT_DATA_DEF    := 0xFC000
#Manufacturer: 5e
#Device: 4014
LD_SCRIPT1	    := $(SDK_LDDIR)/eagle.app.v6.new.1024.app1.ld
LD_SCRIPT2	    := $(SDK_LDDIR)/eagle.app.v6.new.1024.app2.ld
ESPBAUD		:= 230400
#ESPBAUD		    := 460800 ! NOT WORKING with THIS DUAL (8285?) !!
else ifeq ("$(FLASH_SIZE)","2MB")
# Manuf 0xA1 Chip 0x4015 found on wroom-02 modules
# Here we're using two partitions of approx 0.5MB because that's what's easily available in terms
# of linker scripts in the SDK. Ideally we'd use two partitions of approx 1MB, the remaining 2MB
# cannot be used for code (esp8266 limitation).
ESP_SPI_SIZE        := 4       # 6->4MB (1MB+1MB) or 4->4MB (512KB+512KB)
ESP_FLASH_MODE      := 0       # 0->QIO, 2->DIO
ESP_FLASH_FREQ_DIV  := 15      # 15->80Mhz
ET_FS               := 16m     # 16Mbit flash size in esptool flash command
#ET_FF               := 80m     # 80Mhz flash speed in esptool flash command
ET_FF               := 40m     # 40Mhz flash speed in esptool flash command
# where to flash blank.bin to erase wireless settings
ET_BLANK            := 0x1FE000

else ifeq ("$(FLASH_SIZE)","4MB")
#flash_size_map=
    #     0 : 512 KB (256 KB + 256 KB)
    #     1 : 256 KB
    #     2 : 1024 KB (512 KB + 512 KB)
    #     3 : 2048 KB (512 KB + 512 KB)
    #     4 : 4096 KB (512 KB + 512 KB)
    #     5 : 2048 KB (1024 KB + 1024 KB)
    #     6 : 4096 KB (1024 KB + 1024 KB)
ESP_SPI_SIZE        := 4
#ESP_SPI_SIZE        := 6
ESP_FLASH_MODE      := 0
ESPTOOL_FM	    := qio
# 15->80Mhz
ESP_FLASH_FREQ_DIV  := 15
# 32Mbit flash size in esptool flash command
ET_FS               := 32m     
# 40m, 26m, 20m, 80m flash speed in esptool flash command
ET_FF               := 80m
# where to flash blank.bin to erase wireless settings
# old ET_BLANK            := 0x3FC000
ET_BLANK            := 0x3FE000
ET_INIT_DATA_DEF    := 0x3FC000
ESPBAUD		    := 460800

else ifeq ("$(FLASH_SIZE)","4MBb")
#flash_size_map=
    #     0 : 512 KB (256 KB + 256 KB)
    #     1 : 256 KB
    #     2 : 1024 KB (512 KB + 512 KB)
    #     3 : 2048 KB (512 KB + 512 KB)
    #     4 : 4096 KB (512 KB + 512 KB)
    #     5 : 2048 KB (1024 KB + 1024 KB)
    #     6 : 4096 KB (1024 KB + 1024 KB)
ESP_SPI_SIZE        := 4
#ESP_SPI_SIZE        := 6
ESP_FLASH_MODE      := 0
#ESPTOOL_FM	    := qio
#ESPTOOL_FM	    := qout
ESPTOOL_FM	    := dout
#ESPTOOL_FM	    := dio
# 15->80Mhz
ESP_FLASH_FREQ_DIV  := 0
# 32Mbit flash size in esptool flash command
ET_FS               := 32m
#ET_FS               := 32m-c1
#ET_FS               := 32m-c2
# 40m, 26m, 20m, 80m flash speed in esptool flash command
ET_FF               := 80m
# where to flash blank.bin to erase wireless settings
ET_BLANK            := 0x3FE000
ET_INIT_DATA_DEF    := 0x3FC000
#ESPBAUD		    := 230400
ESPBAUD		    := 460800

else ifeq ("$(FLASH_SIZE)","4MBc")
#flash_size_map=
    #     0 : 512 KB (256 KB + 256 KB)
    #     1 : 256 KB
    #     2 : 1024 KB (512 KB + 512 KB)
    #     3 : 2048 KB (512 KB + 512 KB)
    #     4 : 4096 KB (512 KB + 512 KB)
    #     5 : 2048 KB (1024 KB + 1024 KB)
    #     6 : 4096 KB (1024 KB + 1024 KB)
ESP_SPI_SIZE        := 4
#ESP_SPI_SIZE        := 6
ESP_FLASH_MODE      := 0
ESPTOOL_FM	    := qio
#ESPTOOL_FM	    := qout
#ESPTOOL_FM	    := dout
#ESPTOOL_FM	    := dio
# 15->80Mhz
ESP_FLASH_FREQ_DIV  := 0
# 32Mbit flash size in esptool flash command
ET_FS               := 32m
#ET_FS               := 32m-c1
#ET_FS               := 32m-c2
# 40m, 26m, 20m, 80m flash speed in esptool flash command
ET_FF               := 80m
# where to flash blank.bin to erase wireless settings
ET_BLANK            := 0x3FE000
ET_INIT_DATA_DEF    := 0x3FC000
ESPBAUD		    := 460800
else ifeq ("$(FLASH_SIZE)","4MBd")
ESP_SPI_SIZE        := 4
ESP_FLASH_MODE      := 0
#ESPTOOL_FM	    := qio
#ESPTOOL_FM	    := qout
#ESPTOOL_FM	    := dout
ESPTOOL_FM	    := dio
# 15->80Mhz
ESP_FLASH_FREQ_DIV  := 0
# 32Mbit flash size in esptool flash command
ET_FS               := 32m
ET_FF               := 80m
# where to flash blank.bin to erase wireless settings
ET_BLANK            := 0x3FE000
ET_INIT_DATA_DEF    := 0x3FC000
#ESPBAUD		    := 230400
ESPBAUD		    := 460800
else
	$(error Bad flash size )
endif

