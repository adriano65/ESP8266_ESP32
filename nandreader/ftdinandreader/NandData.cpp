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
#include "NandData.hpp"

//Generic NAND data interface.

NandData::NandData(FtdiNand *_pFtdiNand, NandID *_pNandID) {
	pFtdiNand=_pFtdiNand;
	pNandID=_pNandID;
}

int NandData::readPage(int pageno, unsigned char *buf, int len) {
	printf("readPage not supported for this device type.\n");
	exit(0);
}

int NandData::readOob(int pageno, unsigned char *buf){
	printf("readOob not supported for this device type.\n");
	exit(0);
}

int NandData::writePage(int pageno, unsigned char *buf, int len){
	printf("writePage not supported for this device type.\n");
	exit(0);
}

int NandData::erasePage(int page){
	printf("erasePage not supported for this device type.\n");
	exit(0);
}


