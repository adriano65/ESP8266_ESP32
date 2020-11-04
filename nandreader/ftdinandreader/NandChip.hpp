#ifndef NANDCHIP_HPP
#define NANDCHIP_HPP

#include "FtdiNand_BB.hpp"
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
	  };
  AccessType accessType;
  unsigned int pageSize;
  unsigned int erasepageSize;
  unsigned int start_erasepageno;
  unsigned int end_erasepageno;
  unsigned long start_address;
  unsigned long end_address;
  bool doSlow;
  unsigned char *pageBuf;

	enum AddressCheck {
		OK=0,
		BadEraseStart=1,
		BadStart=2,
		BadEraseEnd=3,
		BadEnd=4,
	};
	NandChip::AddressCheck checkAddresses();
  #ifdef BITBANG_MODE
  int open(FtdiNand_BB *);
  #else
  int open(FtdiNand *fn);
  #endif
	int readPage(unsigned long );
	int writePage(unsigned long );
	int erasePage(unsigned int );
	NandID *getIdPtr();
private:
  #ifdef BITBANG_MODE
	FtdiNand_BB *pFtdiNand;
  #else
	FtdiNand *pFtdiNand;
  #endif
	NandID *pNandID;
	NandData *pNandData;
  unsigned int start_pageno;
  unsigned int end_pageno;
  void shift_half_byte(const uint8_t *src, uint8_t *dest, size_t sz);
  int brcm_nand(unsigned poly, unsigned char *data);
};

#endif