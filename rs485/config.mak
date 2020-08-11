#####################################################

CC:=gcc

#CCOPTS+= -DDEBUG -Wl,-strip-all
#CFLAGS:=-Wl,-strip-all -std=gnu99 -D_REENTRANT -fPIC -DRUNONLINUX
CFLAGS:=-Wl,-strip-all -std=gnu99 -D_REENTRANT -fPIC

#ifdef DEBUG
#CFLAGS:=$(CFLAGS) -g -DUSE_GDB
#DBG:=DEBUG=1
#endif

#ifdef FIXME
SDK_PATH:=/opt/Hi3520D_SDK_V1.0.5.1
DRV_ROOT:=$(SDK_PATH)/drv
MPP_PATH:=$(SDK_PATH)/mpp

INC_FLAGS := -I$(MPP_PATH)/include -I$(MPP_PATH)/common -I$(MPP_PATH)/extdrv
REL_LIB := $(MPP_PATH)/lib
HELPER_LIB := $(MPP_PATH)/common

CPP_INC_FLAGS := -I$(MPP_PATH)/include
#endif

