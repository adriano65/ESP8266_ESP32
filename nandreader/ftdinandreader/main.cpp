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
#include "FtdiNand_BB.hpp"
#include "NandChip.hpp"
#include "NandCmds.h"

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
  unsigned long address;
	int x, r, lenght;
	int vid=0, pid=0;
	string file="";
  #ifdef BITBANG_MODE
	FtdiNand_BB ftdiNand;
  #else
	FtdiNand ftdiNand;
  #endif
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
			} else {
				printf("Must be 'main' or 'oob' (recalc OOB) %s\n", argv[x]);
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
		  //nandChip.showInfo(&ftdiNand);
      break;

    case actionRead:
      ftdiNand.open(vid,pid, nandChip.doSlow);
      if (nandChip.open(&ftdiNand)==0) {
        if ((fp=fopen(file.c_str(), "wb+")) == NULL) { perror(file.c_str()); exit(1); }
        printf("Reading from 0x%08X to 0x%08X (%s)\n", nandChip.start_address, nandChip.end_address, nandChip.accessType==NandChip::accessMain ? "Main+OOB" : "rMain+ecalc OOB" );
        for (address=nandChip.start_address; address<nandChip.end_address; address+=nandChip.pageSize) {
          lenght=nandChip.readPage(address);
          r=fwrite(nandChip.pageBuf, 1, lenght, fp);
          if (r!=lenght) { printf("Error writing data to file\n"); break; }
          //printf("0x%08X / 0x%08X\n", address, (nandChip.start_address-nandChip.end_address)*nandChip.pageSize);
          if ((address&0xF)==0) {
            printf("0x%08X / 0x%08X\n\033[A", address, nandChip.end_address);
            }
          }
        fclose(fp);
        }
      break;

    case actionVerify:
      ftdiNand.open(vid,pid, nandChip.doSlow);
      nandChip.open(&ftdiNand);
      verifyBuf=new char[nandChip.pageSize];

      if ((fp=fopen(file.c_str(), "rb")) == NULL) { perror(file.c_str()); exit(1); }
      printf("Verifying 0x%08X bytes of 0x%04X bytes (%s)\n", nandChip.end_address-nandChip.start_address, nandChip.pageSize, nandChip.accessType==NandChip::accessMain ? "Main+OOB" : "Main+recalc OOB" );
      unsigned int page;
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
      if (nandChip.open(&ftdiNand)==0) {
        if ((fp=fopen(file.c_str(), "rb")) == NULL) { perror(file.c_str()); exit(1); }
        printf("Writing from 0x%08X to 0x%08X (%s)\n", nandChip.start_address, nandChip.end_address, nandChip.accessType==NandChip::accessMain ? "Main+OOB" : "rMain+ecalc OOB" );
        for (address=nandChip.start_address; address<nandChip.end_address; address+=nandChip.pageSize) {
          r = fread(nandChip.pageBuf, 1, nandChip.pageSize, fp);
          if (r != nandChip.pageSize) { printf("\nInsufficient data from file\n"); break; }        

          if (address % nandChip.erasepageSize == 0) {
            if ( ! nandChip.erasePage(address/nandChip.erasepageSize) ) { printf("Erasing page %i FAILS", address); }
            }

          int err = nandChip.writePage(address);

          printf("0x%08X / 0x%08X\n\033[A", address, nandChip.end_address);
          }
        fclose(fp);
        }
      break;

    case actionErase:   // 131072 == 128 kiB
      ftdiNand.open(vid,pid,nandChip.doSlow);
      if (nandChip.open(&ftdiNand)==0) {
        unsigned int erasepage;
        printf("Erasing %u pages of %i bytes\n", nandChip.end_address-nandChip.start_erasepageno, nandChip.pageSize);
        for (erasepage=nandChip.start_erasepageno; erasepage<nandChip.end_erasepageno; erasepage++) {
          if (nandChip.erasePage(erasepage)) { printf("page from 0x%02X (0x%08X) erased\n", erasepage, erasepage*nandChip.erasepageSize); }
          else { printf("address from 0x%02X (0x%08X) NOT erased\n", erasepage, erasepage*nandChip.erasepageSize); }
          }
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