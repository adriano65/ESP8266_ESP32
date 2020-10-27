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
	//NA
}

int NandDataSP::readPage(int pageno, char *buff, int max) {
	//Read a page
	char status=0;
	int n;
	m_ft->sendCmd(NAND_CMD_READ0);
	m_ft->sendAddr(pageno<<8L, m_id->getAddrByteCount());
	m_ft->waitReady();
	n=m_ft->readData(buff, max>256?256:max);
	max-=256;
	m_ft->sendCmd(NAND_CMD_READ1);
	m_ft->sendAddr(pageno<<8L, m_id->getAddrByteCount());
	m_ft->waitReady();
	n+=m_ft->readData(buff+256, max>256?256:max);
	return n;
}

int NandDataSP::readOob(int pageno, char *buff, int max) {
	//Read the OOB for a page
	m_ft->sendCmd(NAND_CMD_READOOB);
	m_ft->sendAddr(pageno<<8L, m_id->getAddrByteCount());
	m_ft->waitReady();
	return m_ft->readData(buff, max);
}

int NandDataSP::writePage(int pageno, char *buff, int len) {
	//ToDo
}

int NandDataSP::eraseBlock(int block) {
	//ToDo
}

