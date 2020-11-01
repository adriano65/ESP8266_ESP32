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


#include "NandDataSP.hpp"
#include "NandCmds.h"

//Data handler for a small-page flash.

NandDataSP::NandDataSP(FtdiNand *ftdi, NandID *id) :
 NandData(ftdi, id) {
}

int NandDataSP::readPage(int pageno, unsigned char *buff) {
	char status=0;
	int n, max;
	pFtdiNand->sendCmd(NAND_CMD_READ0);
	pFtdiNand->sendAddr(pageno<<8L, pNandID->getAddrByteCount());
	pFtdiNand->waitReady();
	n=pFtdiNand->readData(buff, max>256 ? 256 : max);
	max-=256;
	pFtdiNand->sendCmd(NAND_CMD_READ1);
	pFtdiNand->sendAddr(pageno<<8L, pNandID->getAddrByteCount());
	pFtdiNand->waitReady();
	n+=pFtdiNand->readData(buff+256, max>256?256:max);
	return n;
}

int NandDataSP::readOob(int pageno, unsigned char *buff) {
	//Read the OOB for a page
	pFtdiNand->sendCmd(NAND_CMD_READOOB);
	pFtdiNand->sendAddr(pageno<<8L, pNandID->getAddrByteCount());
	pFtdiNand->waitReady();
	return pFtdiNand->readData(buff, pNandID->getOobSize());
}

int NandDataSP::writePage(int pageno, unsigned char *buff, int len) {
	unsigned char err=0;
	/*
	pFtdiNand->sendCmd(NAND_CMD_SEQIN);
	pFtdiNand->sendAddr(pageno << 8L, pNandID->getAddrByteCount());
	printf("writePage len=%x\n", len);
	pFtdiNand->writeData(buff, len);
	pFtdiNand->sendCmd(NAND_CMD_PAGEPROG);
	if ((err = pFtdiNand->status()) & NAND_STATUS_FAIL) return err;
	printf("writePage err=%x\n", err);
  */

	
	pFtdiNand->sendCmd(NAND_CMD_READ0);
	pFtdiNand->sendCmd(NAND_CMD_SEQIN);
	pFtdiNand->sendAddr(pageno<<8L, pNandID->getAddrByteCount());
	pFtdiNand->writeData(buff, len>256 ? 256 : len);
	len-=256;
	pFtdiNand->sendCmd(NAND_CMD_PAGEPROG);
	if ((err=pFtdiNand->status()) & NAND_STATUS_FAIL) return err;

	pFtdiNand->sendCmd(NAND_CMD_READ1);
	pFtdiNand->sendCmd(NAND_CMD_SEQIN);
	pFtdiNand->sendAddr(pageno<<8L, pNandID->getAddrByteCount());
	pFtdiNand->writeData(buff+256,len>256?256:len);
	len-=256;
	pFtdiNand->sendCmd(NAND_CMD_PAGEPROG);
	if ((err=pFtdiNand->status()) & NAND_STATUS_FAIL) return err;

	pFtdiNand->sendCmd(NAND_CMD_READOOB);
	pFtdiNand->sendCmd(NAND_CMD_SEQIN);
	pFtdiNand->sendAddr(pageno<<8L, pNandID->getAddrByteCount());
	pFtdiNand->writeData(buff+512,len>16?16:len);
	pFtdiNand->sendCmd(NAND_CMD_PAGEPROG);
	return !(pFtdiNand->status() & NAND_STATUS_FAIL);
}

int NandDataSP::erasePage(int pageno) {
	pFtdiNand->sendCmd(NAND_CMD_ERASE1);
	pFtdiNand->sendAddr(pageno, pNandID->getAddrByteCount());
	pFtdiNand->sendCmd(NAND_CMD_ERASE2);
	pFtdiNand->waitReady();
	int status = pFtdiNand->status();
	return !(status & NAND_STATUS_FAIL);
}

