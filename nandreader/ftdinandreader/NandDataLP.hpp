#ifndef NANDDATALP_HPP
#define NANDDATALP_HPP

#include "NandData.hpp"

using namespace std;

class NandDataLP: public NandData {
public:
	NandDataLP(FtdiNand *ftdi, NandID *id);
	virtual int readPage(int pageno, unsigned char *buf, int len);
	virtual int readOob(int pageno, unsigned char *buf);
	virtual int writePage(int pageno, unsigned char *buf, int len);
	virtual int erasePage(int block);
};


#endif