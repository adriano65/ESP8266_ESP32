TARGET=rs485

include config.mak
CFLAGS+= -DDEBUG -g -DUSE_GDB

LLOPTS=-fPIC -shared -Wl,-soname,lib$(TARGET).so

doall: lib$(TARGET).so

lib$(TARGET).so: $(TARGET).c $(TARGET).h stub.c stub.h
		$(CC) $(CFLAGS) $(TARGET).c $(LLOPTS) -o lib$(TARGET).so

install:
	@echo "cp $(TARGET) to nothing :-)"
	
clean:
	rm -f *.o
	rm -f *.so

