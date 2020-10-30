#ifndef NANDID_HPP
#define NANDID_HPP

#include <string>
using namespace std;

class NandID {
public:
	NandID(unsigned char *idbytes);
	string getManufacturer();
	string getDesc();
	int getPageSize();
	int getSizeMB();
	int getOobSize();
  int getEraseSz();
	bool isLargePage();
	int getAddrByteCount();
private:
	typedef struct {
		const char *name;
		unsigned char id;
		int pagesize;
		int chipsizeMB;
		int erasesize;
		int options;
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
};

#endif