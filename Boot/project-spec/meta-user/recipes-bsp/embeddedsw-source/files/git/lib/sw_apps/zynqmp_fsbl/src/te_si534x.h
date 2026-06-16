/*
-- Company: 		Trenz Electronic
-- Engineer: 		Oleksandr Kiyenko / John Hartfiel
 */
#ifndef SI534X_H
#define SI534X_H

#include "te_iic_platform.h"
#ifdef CLOCK_SI5345

/* Si5345 default address is 0x69 */
//#define SI534X_CHIP_ADDR	0x68
//#define SI534X_CHIP_ADDR	0x69
//#define SI534X_CHIP_ADDR	0x6A
//#define SI534X_CHIP_ADDR	0x6B


/* Registers used for NVM Programming */
#define ACTIVE_NVM_BANK		0x00E2
#define NVM_WRITE			0x00E3
#define NVM_READ_BANK		0x00E4
#define DEVICE_READY		0x00FE

//enable register read back and printf
//#define DEBUG_REG	

//max delay for calibration from SI documentation 300ms
#define TIME_CHECK_PLL_CONFIG_US	0x50000U
//delay
#define DELAY_AFTER_PLL_CONFIG_US	0x20000U 

int si534x_version(unsigned char chip_addr);
int si534x_status_wait(unsigned char chip_addr);
// #define NVM_CODE
int si534x_init(unsigned char chip_addr);
#ifdef NVM_CODE
int si534x_write_nvm(unsigned char chip_addr);
// #define NVM_REALY
#endif

#endif /* CLOCK_SI5345 */

#endif /* SI534X_H */
