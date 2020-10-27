TARGET=analyzetag
CC=gcc
CFLAGS=-Wall -g -I/usr/include/libftdi1/
LDFLAGS=-L/usr/lib/ -lftdi1 -lusb-1.0
OBJS=$(TARGET).o

$(TARGET): $(TARGET).o
	$(CC) -o $@ $(LDFLAGS) $(OBJS)

clean:
	rm -f $(TARGET) $(TARGET).o
