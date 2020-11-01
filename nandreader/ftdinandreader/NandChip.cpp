/*
Software to interface to a NAND-flash chip connected to a FT2232H IC.
(C) 2012 Jeroen Domburg (jeroen AT spritesmods.com)

This program is free software: you can redistribute it and/or modify
t under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h> // memcpy

#include "NandChip.hpp"
#include "NandData.hpp"
#include "NandDataLP.hpp"
#include "NandDataSP.hpp"
#include "NandCmds.h"
#include "bch.h"

NandChip::NandChip() {
  accessType=NandChip::accessMain;
  pageSize=0;
  erasepageSize=0;
  start_address=-1;
  end_address=-1;
	doSlow=false;
  }

int NandChip::open(FtdiNand *_pFtdiNand) {
	unsigned char id[5];
  
	pFtdiNand=_pFtdiNand;
	//Try to read the 5 NAND ID-bytes and create the ID-object
	pFtdiNand->sendCmd(NAND_CMD_RESET);
	pFtdiNand->sendAddr(0, 1);

	pFtdiNand->sendCmd(NAND_CMD_READID);
	pFtdiNand->sendAddr(0, 1);
	pFtdiNand->readData(id, 5);
	pNandID=new NandID(id);
	//We use a different data object for large- and small-page devices
	if (pNandID->isLargePage()) {
		pNandData=new NandDataLP(_pFtdiNand, pNandID);
	  }
  else {
		pNandData=new NandDataSP(_pFtdiNand, pNandID);
	  }

switch (accessType) {
  case accessMain:
    pageSize=pNandID->getPageSize();
    break;
  case recalcOOB:
    pageSize=pNandID->getOobSize()+pNandID->getPageSize();
    break;
  case accessBoth:
    pageSize=pNandID->getOobSize()+pNandID->getPageSize();
    break;

  default:
    break;
  }
  pageBuf=new unsigned char[pNandID->getOobSize()+pNandID->getPageSize()];

  if (start_address == -1) { 
    start_address=start_pageno=start_erasepageno = 0;
    }
  else { 
    start_pageno=start_address/pageSize;
    start_erasepageno=start_address/pNandID->getEraseSz();
    }
  if (end_address == -1) { 
    pages=(pNandID->getSizeMB()*1024L*1024L)/pNandID->getPageSize();
    end_address = pages*pageSize; 
    end_pageno=pages;
    }
  else { 
      end_pageno=end_address/pageSize;
      end_erasepageno=end_address/pNandID->getEraseSz();
      pages = end_pageno;
      }

}

NandChip::~NandChip() {
	delete pNandID;
}

void NandChip::showInfo() {
	//Dump some info.
	printf("Nand type: %s\n", pNandID->getDesc().c_str());
	printf("Manufacturer: %s\n", pNandID->getManufacturer().c_str());
	printf("Size: %iMB, pagesize %i bytes, OOB size %i bytes, erasepage size %i\n", pNandID->getSizeMB(), pNandID->getPageSize(), pNandID->getOobSize(), pNandID->getEraseSz());
	printf("%s page, needs %i addr bytes.\n", pNandID->isLargePage()?"Large":"Small",  pNandID->getAddrByteCount());
}

int NandChip::readPage(int page) {
  //r=pNandData->readOob(page, &pageBuf[r], pageSize);
	return pNandData->readPage(page, pageBuf, pageSize);;
}

int NandChip::writePage(int page) {
	//Can't read/writeback main or OOB data here because the erase size usually is bigger than the page size...
	//if (access != NandChip::accessBoth) {
	//	printf("Writing of only main / OOB data isn't supported yet.\n");
	//	exit(0);
	//}
  if (accessType=NandChip::recalcOOB) {   // original file must have old OOB !!
    brcm_nand(0, pageBuf);   //default polynomial
    }
	return pNandData->writePage(page, pageBuf, pageSize);
}

int NandChip::erasePage(int page) {
	pNandData->erasePage(page);
}

NandID *NandChip::getIdPtr() {
	return pNandID;
}



/**
 *
 * This program reads raw NAND image from standard input and updates ECC bytes in the OOB block for each sector.
 * Data layout is as following:
 *
 * 2 KB page, consisting of 4 x 512 B sectors
 * 64 bytes OOB, consisting of 4 x 16 B OOB regions, one for each sector
 *
 * In each OOB region, the first 9 1/2 bytes are user defined and the remaining 6 1/2 bytes are ECC.
 *
 */

#define BCH_T 4
#define BCH_N 13
#define SECTOR_SZ 512
#define OOB_SZ 16
#define SECTORS_PER_PAGE 4
#define OOB_ECC_OFS 9
#define OOB_ECC_LEN 7

// Wide right shift by 4 bits. Preserves the very first 4 bits of the output.
void NandChip::shift_half_byte(const uint8_t *src, uint8_t *dest, size_t sz){
	// go right to left since input and output may overlap
	unsigned j;
	dest[sz] = src[sz - 1] << 4;
	for (j = sz; j != 0; --j)
		dest[j] = src[j] >> 4 | src[j - 1] << 4;
	dest[0] |= src[0] >> 4;
}

int NandChip::brcm_nand(unsigned poly, unsigned char *data) {
	struct bch_control *bch = init_bch(BCH_N, BCH_T, poly);
	if (!bch)
		return -1;

	uint8_t page_buffer[(SECTOR_SZ + OOB_SZ) * SECTORS_PER_PAGE];

  memcpy(page_buffer, data, (SECTOR_SZ + OOB_SZ) * SECTORS_PER_PAGE);
  // Erased pages have ECC = 0xff .. ff even though there may be user bytes in the OOB region
  int erased_block = 1;
  unsigned i;
  for (i = 0; i != SECTOR_SZ * SECTORS_PER_PAGE; ++i)
    if (page_buffer[i] != 0xff)	{
      erased_block = 0;
      break;
    }

  for (i = 0; i != SECTORS_PER_PAGE; ++i)	{
    const uint8_t *sector_data = page_buffer + SECTOR_SZ * i;
    uint8_t *sector_oob = page_buffer + SECTOR_SZ * SECTORS_PER_PAGE + OOB_SZ * i;
    if (erased_block)	{
      // erased page ECC consumes full 7 bytes, including high 4 bits set to 0xf
      memset(sector_oob + OOB_ECC_OFS, 0xff, OOB_ECC_LEN);
      }
    else	{
      // concatenate input data
      uint8_t buffer[SECTOR_SZ + OOB_ECC_OFS + 1];
      buffer[0] = 0;
      shift_half_byte(sector_data, buffer, SECTOR_SZ);
      shift_half_byte(sector_oob, buffer + SECTOR_SZ, OOB_ECC_OFS);
      // compute ECC
      uint8_t ecc[OOB_ECC_LEN];
      memset(ecc, 0, OOB_ECC_LEN);
      encode_bch(bch, buffer, SECTOR_SZ + OOB_ECC_OFS + 1, ecc);
      // copy the result in its OOB block, shifting right by 4 bits
      shift_half_byte(ecc, sector_oob + OOB_ECC_OFS, OOB_ECC_LEN - 1);
      sector_oob[OOB_ECC_OFS + OOB_ECC_LEN - 1] |= ecc[OOB_ECC_LEN - 1] >> 4;
      }
    }
  memcpy(data, page_buffer, (SECTOR_SZ + OOB_SZ) * SECTORS_PER_PAGE);

  return 0;
}
