#ifndef NANDCHIP_HPP
#define NANDCHIP_HPP

#include "FtdiNand.hpp"
#include "NandID.hpp"
#include "NandData.hpp"

using namespace std;

class NandChip {
public:
  NandChip();
	~NandChip();
	enum AccessType {
		accessNone=0,
		accessMain=1,
		recalcOOB=2,
		accessBoth=3
	};
  AccessType accessType;
  int pageSize;
  int erasepageSize;
  int start_pageno;
  int end_pageno;
  int start_erasepageno;
  int end_erasepageno;
  long start_address;
  long end_address;
  long pages;
	bool doSlow;
  unsigned char *pageBuf;

	void showInfo();
	int open(FtdiNand *fn);
	int readPage(int page);
	int writePage(int page);
	int erasePage(int page);
	NandID *getIdPtr();
private:
	FtdiNand *pFtdiNand;
	NandID *pNandID;
	NandData *pNandData;
  void shift_half_byte(const uint8_t *src, uint8_t *dest, size_t sz);
  int brcm_nand(unsigned poly, unsigned char *data);
};

#endif