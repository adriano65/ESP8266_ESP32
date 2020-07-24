// Copyright 2015 by Thorsten von Eicken, see LICENSE.txt
//
// Adapted from: github.com/tuanpmt/esp_bridge, Created on: Jan 9, 2015, Author: Minh

#ifndef __CMD_H
#define __CMD_H

void ICACHE_FLASH_ATTR cmdParser(char *, unsigned short, char *, int *);
void ICACHE_FLASH_ATTR O_cmd_interpreter(char, char *, int *);
void ICACHE_FLASH_ATTR F_cmd_interpreter(char, char *, int *);
void ICACHE_FLASH_ATTR T_cmd_interpreter(char, char *, int *);
void ICACHE_FLASH_ATTR S_cmd_interpreter(char , char *, int *);
void ICACHE_FLASH_ATTR D_cmd_interpreter(char *, char *, int *);
void ICACHE_FLASH_ATTR M_cmd_interpreter(char *, char *, int *);
void ICACHE_FLASH_ATTR C_cmd_interpreter(char , char *, int *);
void ICACHE_FLASH_ATTR Stat_cmd(char, char *, int *);

#endif
