#ifndef CMD_H
#define CMD_H
#include <user_interface.h>

void ICACHE_FLASH_ATTR cmdParser(char *, unsigned short);
void ICACHE_FLASH_ATTR a_cmd_interpreter(char *);
void ICACHE_FLASH_ATTR C_cmd_interpreter(char);
void ICACHE_FLASH_ATTR c_cmd_interpreter(char );
void ICACHE_FLASH_ATTR D_cmd_interpreter(char *);
void ICACHE_FLASH_ATTR d_cmd_interpreter(char *);
void ICACHE_FLASH_ATTR F_cmd_interpreter(char);
void ICACHE_FLASH_ATTR I_cmd_interpreter(char);
void ICACHE_FLASH_ATTR i_cmd_interpreter(char *);
void ICACHE_FLASH_ATTR O_cmd_interpreter(char);
void ICACHE_FLASH_ATTR P_cmd_interpreter(char);
void ICACHE_FLASH_ATTR p_cmd_interpreter(char * pInbuf);
void ICACHE_FLASH_ATTR T_cmd_interpreter(char);
void ICACHE_FLASH_ATTR t_cmd_interpreter(char *);
void ICACHE_FLASH_ATTR power_cmd_parser(char *);
void ICACHE_FLASH_ATTR S_cmd_interpreter(char);
void ICACHE_FLASH_ATTR x_cmd_interpreter(char *);

void ICACHE_FLASH_ATTR m_cmd_interpreter(char *);

void ICACHE_FLASH_ATTR Stat_cmd(char);
void ICACHE_FLASH_ATTR W_cmd_interpreter(char *);
void ICACHE_FLASH_ATTR w_cmd_interpreter(char *);

#endif
