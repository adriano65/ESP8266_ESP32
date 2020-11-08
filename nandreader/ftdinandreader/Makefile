OBJS=main.o FtdiNand.o FtdiNand_BB.o NandChip.o NandID.o NandData.o bch.o
CXXFLAGS=-ggdb -std=c++11
LDFLAGS=-L/usr/local/lib -lftdi1
TARGET=ftdinandreader
$(TARGET): $(OBJS) *.h
	$(CXX) -o $@ $(LDFLAGS) $(OBJS)

clean:
	rm -f $(TARGET) $(OBJS)