TARGET=rs485

include config.mak
CFLAGS+= -DDEBUG -g -DUSE_GDB

LLOPTS=-lm -lpthread -Wl,--build-id=md5

all: $(TARGET)
#	rm -f *.o
#	rm $(TARGET)

lib$(TARGET).so: $(TARGET).c $(TARGET).h stub.c stub.h
		$(CC) $(CFLAGS) $(TARGET).c $(LLOPTS) -o $(TARGET)

install:
	@echo "cp $(TARGET) to nothing :-)"
	
clean:
	rm -f *.o
	rm -f $(TARGET)

