#ifndef FTDINAND
#define FTDINAND

#include <libftdi1/ftdi.h>

using namespace std;

class FtdiNand {
public:
	FtdiNand();
	~FtdiNand();
	int open(int vid, int pid, bool doslow);
  void EnableRead(bool bEnable);
  void EnableWrite(bool bEnable);
	int sendCmd(unsigned char cmd);
	int sendAddr(long long addr, int noBytes);
	int writeData(unsigned char *data, int count);
	int readData(unsigned char *data, int count);
	int waitReady();
	unsigned char status();
private:
	int error(const char *err);
	int nandRead(int cl, int al, unsigned char *buf, int count);
	int nandWrite(int cl, int al, unsigned char *buf, int count);
	int nandRead_ori(int cl, int al, unsigned char *buf, int count);
	int nandWrite_ori(int cl, int al, unsigned char *buf, int count);
	struct ftdi_context m_ftdi;
	bool m_slowAccess;
	int m_rbErrorCount;
};

#endif
