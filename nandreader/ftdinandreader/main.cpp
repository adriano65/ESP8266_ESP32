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

int setParam(NandID *id, long *start_address, long *end_address, int *start_pageno, int *end_pageno, int *size );
int usage();

int main(int argc, char **argv) {
  FILE *fp;
  bool doSlow=false;
  NandChip::AccessType accessType=NandChip::PageplusOOB;
  unsigned long start_address, end_address, address;
	int x, r, lenght, vid=0, pid=0;
	string file="";
  int verifyErrors=0;
  char *verifyBuf;

  //nand = new NandChip();
	printf("FT2232H-based NAND reader\n");
	NandChip::Action action=NandChip::actionNone;
	for (x=1; x<argc; x++) {
		if (strcmp(argv[x],"-i")==0) { action=NandChip::getID;}
    else if (strcmp(argv[x],"-e")==0 && x<=(argc-2)) { action=NandChip::actionErase; }
    else if (strcmp(argv[x],"-r")==0 && x<=(argc-2)) { action=NandChip::actionRead;	file=argv[++x]; }
    else if (strcmp(argv[x],"-w")==0 && x<=(argc-2)) { action=NandChip::actionWrite; file=argv[++x]; }
    else if (strcmp(argv[x],"-v")==0 && x<=(argc-2)) { action=NandChip::actionVerify;	file=argv[++x];	}
    else if (strcmp(argv[x],"-u")==0 && x<=(argc-2)) { action=NandChip::actionVerify;
			char *endp;
			x++;
			vid=strtol(argv[x], &endp, 16);
			if (*endp!=':') {
        action=NandChip::actionNone;
			  }
      else {
				endp++;
				pid=strtol(endp, NULL, 16);
			  }
		  }
    else if (strcmp(argv[x],"-t")==0 && x<=(argc-2)) {
			x++;
			if (strcmp(argv[x],"main")==0) {
				accessType=NandChip::Page;
			} else if (strcmp(argv[x], "mainoob")==0) {
				accessType=NandChip::PageplusOOB;
			} else if (strcmp(argv[x], "oob")==0) {
				accessType=NandChip::recalcOOB;
			} else if (strcmp(argv[x], "bb")==0) {
				accessType=NandChip::useBitBang;
			} else {
				printf("Must be 'main', 'oob' (recalc OOB) or bb (Bitbang mode)%s\n", argv[x]);
			}
		  }
    else if (strcmp(argv[x],"-s")==0) { doSlow=true;	} 
    else if (strcmp(argv[x], "-p")==0 && x <= (argc - 3)) {
                        x++;
                        start_address = strtol(argv[x], NULL, 16);
                        x++;
                        end_address = strtol(argv[x], NULL, 16);
                }    
    else {
			printf("Unknown option or missing argument: %s\n", argv[x]);
      action=NandChip::actionNone;
		  }
	  }
  if (action==NandChip::actionNone) { usage(); exit(0);}

  NandChip nandChip(vid, pid, doSlow, accessType, start_address, end_address);

  switch (action) {
    case NandChip::getID:
      break;

    case NandChip::actionRead:
      if (nandChip.checkAddresses(action)==0) {
        if ((fp=fopen(file.c_str(), "wb+")) == NULL) { perror(file.c_str()); exit(1); }
        printf("Reading from 0x%08X to 0x%08X (%s)\n", nandChip.start_address, nandChip.end_address, nandChip.accessType==NandChip::Page ? "Page" : "Page+OOB" );
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

    case NandChip::actionVerify:
      verifyBuf=new char[nandChip.pageSize];

      if (nandChip.checkAddresses(action)) {
        if ((fp=fopen(file.c_str(), "rb")) == NULL) { perror(file.c_str()); exit(1); }
        printf("Verifying 0x%08X bytes of 0x%04X bytes (%s)\n", nandChip.end_address-nandChip.start_address, nandChip.pageSize, nandChip.accessType==NandChip::Page ? "Page" : "Page+OOB" );
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
        }
      break;

    case NandChip::actionWrite:
      if (nandChip.checkAddresses(action)==0) {
        if ((fp=fopen(file.c_str(), "rb")) == NULL) { perror(file.c_str()); exit(1); }
        printf("Writing from 0x%08X to 0x%08X (%s)\n", nandChip.start_address, nandChip.end_address, nandChip.accessType==NandChip::Page ? "Page" : "Page+OOB" );
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

    case NandChip::actionErase:   // 131072 == 128 kiB
      if (nandChip.checkAddresses(action)==0) {
        unsigned int erasepage;
        printf("Erasing %u pages of %i bytes\n", nandChip.end_erasepageno-nandChip.start_erasepageno, nandChip.pageSize);
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
  printf("  -t reg  - Select region to read/write (main, oob recalculate or bb (Bitbang mode))\n");
  printf("  -s      - clock FTDI chip at 12MHz instead of 60MHz\n");
  printf("  -u vid:pid - use different FTDI USB vid/pid. Vid and pid are in hex.\n");
  exit(0);
}