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
#include "stdlib.h"
#include "string.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include "FtdiNand.hpp"
#include "NandChip.hpp"

//Windows needs O_BINARY to open binary files, but the flag is undefined
//on Unix. Hack around that. (Thanks, Shawn Hoffman)
#ifndef O_BINARY
#define O_BINARY 0
#endif

int main(int argc, char **argv) {
	int x, r;
  int start_pageno = -1, end_pageno = -1;
  long start_address=-1, end_address=-1;
	int vid=0, pid=0;
	bool err=false;
	bool doSlow=false;
	string file="";
	enum Action {
		actionNone=0,
		actionID,
		actionRead,
		actionWrite,
		actionVerify,
    actionErase
	};

	printf("FT2232H-based NAND reader\n");
	//Parse command line options
	Action action=actionNone;
	NandChip::AccessType access=NandChip::accessBoth;
	for (x=1; x<argc; x++) {
		if (strcmp(argv[x],"-i")==0) {
			action=actionID;
		} else if (strcmp(argv[x],"-e")==0 && x<=(argc-2)) {
			action=actionErase;
		} else if (strcmp(argv[x],"-r")==0 && x<=(argc-2)) {
			action=actionRead;
			file=argv[++x];
		} else if (strcmp(argv[x],"-w")==0 && x<=(argc-2)) {
			action=actionWrite;
			file=argv[++x];
		} else if (strcmp(argv[x],"-v")==0 && x<=(argc-2)) {
			action=actionVerify;
			file=argv[++x];
		} else if (strcmp(argv[x],"-u")==0 && x<=(argc-2)) {
			action=actionVerify;
			char *endp;
			x++;
			vid=strtol(argv[x], &endp, 16);
			if (*endp!=':') {
				err=true;
			} else {
				endp++;
				pid=strtol(endp, NULL, 16);
			}
		} else if (strcmp(argv[x],"-t")==0 && x<=(argc-2)) {
			x++;
			if (strcmp(argv[x],"main")==0) {
				access=NandChip::accessMain;
			} else if (strcmp(argv[x], "oob")==0) {
				access=NandChip::accessOob;
			} else if (strcmp(argv[x], "both")==0) {
				access=NandChip::accessBoth;
			} else {
				printf("Must be 'main' 'oob' or 'both': %s\n", argv[x]);
				err=true;
			}
		} else if (strcmp(argv[x],"-s")==0) {
			doSlow=true;
		} 
    else if (strcmp(argv[x], "-p") == 0 && x <= (argc - 3)) {
                        x++;
                        start_address = strtol(argv[x], NULL, 16);
                        x++;
                        end_address = strtol(argv[x], NULL, 16);
                }    
    else {
			printf("Unknown option or missing argument: %s\n", argv[x]);
			err=true;
		}
	}

	if (action==actionNone || err) {
		printf("Usage: %s [-i|-r file|-v file] [-t main|oob|both] [-s]\n");
		printf("  -i      - Identify chip\n");
		printf("  -r file - Read chip to file\n");
    printf("  -p 0x<start address> 0x<end address>  - Select address to operate\n");    
		printf("  -w file - Write chip from file (set pages!!)\n");
		printf("  -v file - Verify chip from file data\n");
		printf("  -t reg  - Select region to read/write (main mem, oob ('spare') data or both, interleaved)\n");
		printf("  -s      - clock FTDI chip at 12MHz instead of 60MHz\n");
		printf("  -u vid:pid - use different FTDI USB vid/pid. Vid and pid are in hex.\n");
		exit(0);
	  }


	FtdiNand ftdi;
	ftdi.open(vid,pid,doSlow);
	NandChip nand(&ftdi);

	if (action==actionID) {
		nand.showInfo();
	  }
  else 
    if (action==actionRead || action==actionVerify) {
      int f;
      if (action==actionRead) {
        f=open(file.c_str(), O_WRONLY|O_CREAT|O_TRUNC|O_BINARY, 0644);
        } 
      else {
			  f=open(file.c_str(), O_RDONLY|O_BINARY);
		    }
      if (f<0) {
        perror(file.c_str());
        exit(1);
        }
      NandID *id=nand.getIdPtr();
      long pages=(id->getSizeMB()*1024L*1024L)/id->getPageSize();
      int size=0;
      if (access==NandChip::accessMain) size=id->getPageSize();
      if (access==NandChip::accessOob) size=id->getOobSize();
      if (access==NandChip::accessBoth) size=id->getOobSize()+id->getPageSize();
      char *pageBuf=new char[size];
      char *verifyBuf=new char[size];
      int verifyErrors=0;
      if (start_address == -1) { start_address=start_pageno = 0; }
      else { start_pageno=start_address/size; }
      if (end_address == -1) { end_address = pages*size; end_pageno=pages; }
      else { end_pageno=end_address/size; }
      nand.showInfo();

      printf("%sing 0x%08X bytes of 0x%04X bytes...\n", action==actionRead?"Read":"Verify", end_address-start_address, size);


      for (x=start_pageno; x<end_pageno; x++) {
        nand.readPage(x, pageBuf, size, access);
        if (action==actionRead) {
          r=write(f, pageBuf, size);
          if (r!=size) {
            perror("writing data to file");
            exit(1);
          }
        } else {
          r=read(f, verifyBuf, size);
          if (r!=size) {
            perror("reading data from file");
            exit(1);
          }
          for (int y=0; y<size; y++) {
            if (verifyBuf[y]!=pageBuf[y]) {
              verifyErrors++;
              printf("Verify error: Page %i, byte %i: file 0x%02hhX flash 0x%02hhX\n", x, y, verifyBuf[y], pageBuf[y]);
            }
          }
        }
        #if 1
          printf("%i/%i\n\033[A", x, pages);
        #else
        if ((x&0xF)==0) {
          printf("%i/%i\n\033[A", x, pages);
          }
        #endif
      }
		if (action==actionVerify) {
			printf("Verify: %i bytes differ between NAND and file.\n", verifyErrors);
		  }
	  } 
  else { 
      if (action==actionWrite) {
        int f;
        f = open(file.c_str(), O_RDONLY | O_BINARY);
        if (f<0) {
          perror(file.c_str());
          exit(1);
          }

        NandID *id = nand.getIdPtr();
        long pages = (id->getSizeMB() * 1024LL * 1024LL) / id->getPageSize();
        int size = 0;
        if (access == NandChip::accessMain) size = id->getPageSize();
        if (access == NandChip::accessOob) size = id->getOobSize();
        if (access == NandChip::accessBoth) size = id->getOobSize() + id->getPageSize();
        char *pageBuf = new char[size];

        if (start_address == -1) { start_address=start_pageno = 0; }
        else { start_pageno=start_address/size; }
        if (end_address == -1) { end_address = pages*size; end_pageno=pages; }
        else { end_pageno=end_address/size; }

        nand.showInfo();
        printf("Writing %li pages of %i bytes...\n", pages, id->getPageSize());

        for (x = start_pageno; x<end_pageno; x++) {
          r = read(f, pageBuf, size);
          if (r != size) { perror("reading data from file"); exit(1); }        

          //if (x % 32 == 0) { nand.eraseBlock(x); }
          if (x % 64 == 0) { nand.eraseBlock(x); }

          int err = nand.writePage(x, pageBuf, size, access);
          #if 0
          printf("%i/%i\n", x, pages);
          #else
          if ((x & 15) == 0) {
            printf("%i/%li\n\033[A", x, pages);
            }
          #endif
	        }
        }
        
      else if (action==actionErase) {
        for (x = 256; x<16384; x+=64) {
          nand.eraseBlock(x);
          }
      }
      else printf("Boh???\n");
   }
	
	printf("\nAll done.\n");
}