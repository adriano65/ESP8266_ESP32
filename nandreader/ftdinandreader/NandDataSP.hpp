#ifndef NANDDATASP_HPP
#define NANDDATASP_HPP

#include "NandData.hpp"

using namespace std;

class NandDataSP: public NandData {
public:
	NandDataSP(FtdiNand *ftdi, NandID *id);
	virtual int readPage(int pageno, unsigned char *buf);
	virtual int readOob(int pageno, unsigned char *buf);
	virtual int writePage(int pageno, unsigned char *buf, int len);
	virtual int erasePage(int block);
};


#endif