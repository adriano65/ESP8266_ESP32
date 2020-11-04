#ifndef NANDID_HPP
#define NANDID_HPP

#include <string>
using namespace std;

class NandID {
public:
	NandID(unsigned char *idbytes);
	string getManufacturer();
	string getDesc();
	unsigned int getPageSize();
	unsigned int getSizeMB();
	unsigned int getOobSize();
  unsigned int getEraseSz();
	bool isLargePage();
	int getAddrByteCount();
  int getEraseAddrByteCount();
  unsigned int getfullPageSz();
  unsigned int getfullEraseSz();

private:
	typedef struct {
		const char *name;
		unsigned char id;
		unsigned int pagesize;
		unsigned int chipsizeMB;
		unsigned int erasesize;
		unsigned char addrByteCount;
		unsigned char eraseAddrByteCount;
		int options;
		unsigned int fullpagesize;
		unsigned int fullerasesize;
	} DevCodes;
	static const DevCodes m_devCodes[];
	char m_idBytes[5];

	string m_nandManuf;
	string m_nandDesc;
	int m_nandPageSz;
	int m_nandOobSz;
	int m_nandEraseSz;
	int m_nandChipSzMB;
	bool m_nandIsLP;
  unsigned char addrByteCount;
  unsigned char eraseAddrByteCount;
  unsigned int fullEraseSz;
  unsigned int fullPageSz;
};

#endif