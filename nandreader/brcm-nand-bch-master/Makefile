TARGET=brcm-nand-bch
CC=gcc
CFLAGS=-Wall -g2 -I/usr/include/libftdi1/
LDFLAGS=-L/usr/lib/ -lftdi1 -lusb-1.0
OBJS=$(TARGET).o bch.o

$(TARGET): $(TARGET).o bch.o
	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) $(OBJS)

clean:
	rm -f $(TARGET) $(OBJS)
