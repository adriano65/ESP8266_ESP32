TARGET=bitbang_ft2232
CC=gcc
CFLAGS=-Wall -g -I/usr/include/libftdi1/
LDFLAGS=-L/usr/lib/ -lftdi1 -lusb-1.0
OBJS=bitbang_ft2232.o

$(TARGET): bitbang_ft2232.o
	$(CC) -o $@ $(LDFLAGS) $(OBJS)
	#gcc bitbang_ft2232.o -o bitbang_ft2232 $(LIBS)

clean:
	rm -f $(TARGET) $(TARGET).o
