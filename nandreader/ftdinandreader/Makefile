OBJS=main.o FtdiNand.o NandChip.o NandID.o NandData.o NandDataSP.o NandDataLP.o bch.o
CXXFLAGS=-ggdb 
LDFLAGS=-L/usr/local/lib/ -lftdi1
TARGET=ftdinandreader
$(TARGET): $(OBJS)
	$(CXX) -o $@ $(LDFLAGS) $(OBJS)

clean:
	rm -f $(TARGET) $(OBJS)