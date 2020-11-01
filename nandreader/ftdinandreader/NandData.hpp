#ifndef NANDDATA_HPP
#define NANDDATA_HPP

#include "FtdiNand.hpp"
#include "NandID.hpp"

using namespace std;

class NandData {
public:
	NandData(FtdiNand *, NandID *);
	virtual int readPage(int pageno, unsigned char *buf, int len);
	virtual int readOob(int pageno, unsigned char *buf);
	virtual int writePage(int pageno, unsigned char *buf, int len);
	virtual int erasePage(int page);
protected:
	FtdiNand *pFtdiNand;
	NandID *pNandID;
};

#endif
