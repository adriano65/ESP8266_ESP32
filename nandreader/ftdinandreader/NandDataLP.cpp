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


#include "NandDataLP.hpp"
#include "NandCmds.h"

//Data interface for large-page NAND chips

NandDataLP::NandDataLP(FtdiNand *ftdi, NandID *id) :
 NandData(ftdi, id) {
}

int NandDataLP::readPage(int pageno, unsigned char *buff, int len) {
	char status=0;
	pFtdiNand->sendCmd(NAND_CMD_READ0);
	//pFtdiNand->sendAddr((pageno<<16L)+len, pNandID->getAddrByteCount());    // read page + OOB but only OOB are filled
	pFtdiNand->sendAddr(pageno<<16L, pNandID->getAddrByteCount());
	pFtdiNand->sendCmd(NAND_CMD_READSTART);
	pFtdiNand->waitReady();
	return pFtdiNand->readData(buff, len);
}

int NandDataLP::readOob(int pageno, unsigned char *buff) {
	//Read the OOB for a page
	pFtdiNand->sendCmd(NAND_CMD_READ0);
	pFtdiNand->sendAddr((pageno<<16L)+pNandID->getPageSize(), pNandID->getAddrByteCount());
	pFtdiNand->sendCmd(NAND_CMD_READSTART);
	pFtdiNand->waitReady();
	return pFtdiNand->readData(buff, pNandID->getOobSize());
}

int NandDataLP::writePage(int pageno, unsigned char *buff, int len) {
	pFtdiNand->sendCmd(NAND_CMD_SEQIN);
	pFtdiNand->sendAddr(pageno<<16L, pNandID->getAddrByteCount());
	pFtdiNand->writeData(buff, len);
	pFtdiNand->sendCmd(NAND_CMD_PAGEPROG);
	pFtdiNand->waitReady();
	return !(pFtdiNand->status() & NAND_STATUS_FAIL);
}

int NandDataLP::erasePage(int pageno) {
	pFtdiNand->sendCmd(NAND_CMD_ERASE1);
	pFtdiNand->sendAddr(pageno, pNandID->getEraseAddrByteCount());
	pFtdiNand->sendCmd(NAND_CMD_ERASE2);
	pFtdiNand->waitReady();
	pFtdiNand->status();
	return !( pFtdiNand->status() & NAND_STATUS_FAIL );
}

