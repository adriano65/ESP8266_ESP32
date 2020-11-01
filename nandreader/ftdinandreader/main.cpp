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

	enum Action {
		actionNone=0,
		actionID,
		actionRead,
		actionWrite,
		actionVerify,
    actionErase
	};

int setParam(NandID *id, long *start_address, long *end_address, int *start_pageno, int *end_pageno, int *size );
int usage();

int main(int argc, char **argv) {
  FILE *fp;
	int x, page=0, r, lenght;
	int vid=0, pid=0;
	string file="";
	FtdiNand ftdiNand;
  NandChip nandChip;
  int verifyErrors=0;
  char *verifyBuf;

  //nand = new NandChip();
	printf("FT2232H-based NAND reader\n");
	Action action=actionNone;
	for (x=1; x<argc; x++) {
		if (strcmp(argv[x],"-i")==0) { action=actionID;}
    else if (strcmp(argv[x],"-e")==0 && x<=(argc-2)) { action=actionErase; }
    else if (strcmp(argv[x],"-r")==0 && x<=(argc-2)) { action=actionRead;	file=argv[++x]; }
    else if (strcmp(argv[x],"-w")==0 && x<=(argc-2)) { action=actionWrite; file=argv[++x]; }
    else if (strcmp(argv[x],"-v")==0 && x<=(argc-2)) { action=actionVerify;	file=argv[++x];	}
    else if (strcmp(argv[x],"-u")==0 && x<=(argc-2)) { action=actionVerify;
			char *endp;
			x++;
			vid=strtol(argv[x], &endp, 16);
			if (*endp!=':') {
				action=actionNone;
			  }
      else {
				endp++;
				pid=strtol(endp, NULL, 16);
			  }
		  }
    else if (strcmp(argv[x],"-t")==0 && x<=(argc-2)) {
			x++;
			if (strcmp(argv[x],"main")==0) {
				nandChip.accessType=NandChip::accessMain;
			} else if (strcmp(argv[x], "oob")==0) {
				nandChip.accessType=NandChip::recalcOOB;
			} else if (strcmp(argv[x], "both")==0) {
				nandChip.accessType=NandChip::accessBoth;
			} else {
				printf("Must be 'main' 'oob' or 'both': %s\n", argv[x]);
				action=actionNone;
			}
		  }
    else if (strcmp(argv[x],"-s")==0) { nandChip.doSlow=true;	} 
    else if (strcmp(argv[x], "-p")==0 && x <= (argc - 3)) {
                        x++;
                        nandChip.start_address = strtol(argv[x], NULL, 16);
                        x++;
                        nandChip.end_address = strtol(argv[x], NULL, 16);
                }    
    else {
			printf("Unknown option or missing argument: %s\n", argv[x]);
			action=actionNone;
		  }
	  }

  switch (action) {
    case actionNone:
      usage();
      break;
    
    case actionID:
      ftdiNand.open(vid, pid, nandChip.doSlow);
      nandChip.open(&ftdiNand);
		  nandChip.showInfo();
      //delete nand;
      break;

    case actionRead:
      ftdiNand.open(vid,pid,nandChip.doSlow);
      nandChip.open(&ftdiNand);
      nandChip.showInfo();
      if ((fp=fopen(file.c_str(), "wb+")) == NULL) { perror(file.c_str()); exit(1); }
      printf("Reading 0x%08X bytes of 0x%04X bytes (%s)\n", nandChip.end_address-nandChip.start_address, nandChip.pageSize, nandChip.accessType==NandChip::accessBoth ? "Main+OOB" : "Main only" );
      for (page=nandChip.start_pageno; page<nandChip.end_pageno; page++) {
        lenght=nandChip.readPage(page);
        r=fwrite(nandChip.pageBuf, 1, lenght, fp);
        if (r!=lenght) { printf("Error writing data to file\n"); break; }
        //printf("0x%08X / 0x%08X\n", page*nandChip.pageSize, (nandChip.end_pageno-nandChip.start_pageno)*nandChip.pageSize);
        if ((page&0xF)==0) {
          printf("0x%08X/0x%08X\n\033[A", page*nandChip.pageSize, nandChip.end_pageno*nandChip.pageSize);
          }
        }
      fclose(fp);
      break;

    case actionVerify:
      ftdiNand.open(vid,pid,nandChip.doSlow);
      nandChip.open(&ftdiNand);
      nandChip.showInfo();
      verifyBuf=new char[nandChip.pageSize];

      if ((fp=fopen(file.c_str(), "rb")) == NULL) { perror(file.c_str()); exit(1); }
      printf("Verifying 0x%08X bytes of 0x%04X bytes (%s)\n", nandChip.end_address-nandChip.start_address, nandChip.pageSize, nandChip.accessType==NandChip::accessBoth ? "Main+OOB" : "Main only" );
      while (!feof(fp)) {
        r=fread(verifyBuf, 1, nandChip.pageSize, fp);
        if (r!=nandChip.pageSize) { perror("reading data from file"); exit(1); }
        for (int y=0; y<nandChip.pageSize; y++) {
          if (verifyBuf[y]!=nandChip.pageBuf[y]) {
            verifyErrors++;
            printf("Verify error: Page %i, byte %i: file 0x%02hhX flash 0x%02hhX\n", page, y, verifyBuf[y], nandChip.pageBuf[y]);
            }
          }
        page++;
        }
      fclose(fp);
      break;

    case actionWrite:
      ftdiNand.open(vid,pid,nandChip.doSlow);
      nandChip.open(&ftdiNand);
      nandChip.showInfo();

      if ((fp=fopen(file.c_str(), "rb")) == NULL) { perror(file.c_str()); exit(1); }
      printf("Writing %li pages of %i bytes (%s)\n", nandChip.end_pageno-nandChip.start_pageno, nandChip.pageSize, nandChip.accessType==NandChip::accessBoth ? "Main+OOB" : (nandChip.accessType==NandChip::recalcOOB ? "recalc OOB" : "Main"));
      for (page = nandChip.start_pageno; page<nandChip.end_pageno; page++) {
        r = fread(nandChip.pageBuf, 1, nandChip.pageSize, fp);
        if (r != nandChip.pageSize) { printf("\nInsufficient data from file\n"); break; }        

        if (page % 64 == 0) {
          nandChip.erasePage(page); 
          //printf("Erasing page %i", x);
          }

        int err = nandChip.writePage(page);
        #if 0
        printf("%i/%i\n", page, (nandChip.end_pageno-nandChip.start_pageno));
        #else
        if ((x & 15) == 0) {
          printf("%i/%i\n\033[A", page, (nandChip.end_pageno-nandChip.start_pageno));
          }
        #endif
        }
      fclose(fp);
      break;

    case actionErase:   // 131072 == 128 kiB
      ftdiNand.open(vid,pid,nandChip.doSlow);
      nandChip.open(&ftdiNand);
      nandChip.showInfo();

      printf("Erasing from page %i to %i (erasepageSize %i)\n", nandChip.start_erasepageno, nandChip.end_erasepageno, nandChip.erasepageSize);
      // erase userfs  start_pageno = 256; end_pageno = 16384; x+=64) {
      for (page = nandChip.start_erasepageno; page<nandChip.end_erasepageno; page++) {
        nandChip.erasePage(page);
        printf("page %i erased\n", page);
        }
      break;

    default:
      printf("Boh???\n");
      break;
    }

	printf("\nAll done.\n");
}

int usage(){
  printf("Usage: %s [-i|-r file|-v file] [-t main|oob|both] [-s]\n");
  printf("  -i      - Identify chip\n");
  printf("  -r file - Read chip to file\n");
  printf("  -p 0x<start address> 0x<end address>  - Select address to operate\n");    
  printf("  -w file - Write chip from file (set addresses!!)\n");
  printf("  -v file - Verify chip from file data\n");
  printf("  -e      - Erase chip (set addresses!!)\n");
  printf("  -t reg  - Select region to read/write (main, oob recalculate or both)\n");
  printf("  -s      - clock FTDI chip at 12MHz instead of 60MHz\n");
  printf("  -u vid:pid - use different FTDI USB vid/pid. Vid and pid are in hex.\n");
  exit(0);
}