/*
-- Company: 		Trenz Electronic
-- Engineer: 		Oleksandr Kiyenko / John Hartfiel
 */
#include "te_si534x.h"

#ifdef CLOCK_SI5345

#include "te_uart.h"
#include "te_Si5345-Registers.h"



int si534x_version(unsigned char chip_addr){
	unsigned char val;
	int Status;
	  Status = iic_read16(chip_addr, 0x0003, &val);
	  xil_printf("SI%x",val);

	  Status = iic_read16(chip_addr, 0x0002, &val);
	  xil_printf("%x",val);

	  Status = iic_read16(chip_addr, 0x0005, &val);
    if (val==0) {
      xil_printf("-A\r\n");
    } else if (val==1) {
      xil_printf("-B\r\n");
    } else if (val==2) {
      xil_printf("-C\r\n");
    } else if (val==3) {
      xil_printf("-D\r\n");
    } else {
      xil_printf("-%x\r\n",val);
    }

	  return Status;
}

int si534x_status_wait(unsigned char chip_addr){
	unsigned char valF,valC,valE,valD,val11;
	unsigned int  cnt=0, tmp;
	int Status;
  
  (void)usleep(0x5U);
  
  Status = iic_read16(chip_addr, 0x000C, &valC);
  Status = iic_read16(chip_addr, 0x000E, &valE);
  Status = iic_read16(chip_addr, 0x000D, &valD);
  Status = iic_read16(chip_addr, 0x0011, &val11);
  tmp = 1;
  // Wait until internal calibration is not busy
  while (tmp ==1) {
    cnt=cnt+0x100U ;
    (void)usleep(0x100U);
    Status = iic_read16(chip_addr, 0x000C, &valC);
    Status = iic_read16(chip_addr, 0x000F, &valF);
    tmp =((((valF) & (0x10))>>5) | (valC) & (0x01));
    if ((cnt % 0x100U) == 0) {
      xil_printf("Status   0xC:0x%x, 0xE:0x%x, 0xD:0x%x, 0x11:%x, 0xF:%x (...waiting for calibration...%i us).\r",valC,valE,valD,val11,valF,cnt);
    }
    
    if (cnt >= TIME_CHECK_PLL_CONFIG_US) {
        xil_printf("Status   0xC:0x%x, 0xE:0x%x, 0xD:0x%x, 0x11:%x, 0xF:%x (...calibration not finished after %i us...exit...).\r\n",valC,valE,valD,val11,valF,cnt);
        xil_printf("Status 0xC:0x%x(cal bit0:%i) and 0xF:%x(cal bit5:%i) will be checked one time again after %i us\r\n",valC,((valC) & (0x01)),valF,tmp,DELAY_AFTER_PLL_CONFIG_US);
        tmp = 0;
    }
  }
   //sleep need for PCIe
  (void)usleep(DELAY_AFTER_PLL_CONFIG_US);
    
  Status = iic_read16(chip_addr, 0x000F, &valF);
  Status = iic_read16(chip_addr, 0x000C, &valC);
  Status = iic_read16(chip_addr, 0x000E, &valE);
  Status = iic_read16(chip_addr, 0x000D, &valD);
  Status = iic_read16(chip_addr, 0x0011, &val11);
  xil_printf("PLL Status Register   0xC:0x%x, 0xE:0x%x, 0xD:0x%x, 0x11:%x, 0xF:%x.\r\n",valC,valE,valD,val11,valF);

	return Status;
}

int si534x_init(unsigned char chip_addr){
	int i, Status;
	unsigned char val;
	unsigned short addr;

    // p_printf(("Si534x Init Start.\r\n"));
    // iic_init();
    p_printf(("Si534x Init Registers Write.\r\n"));
#ifdef DEBUG_REG
  unsigned char readback_test;
#endif
  
#ifdef SI5345_REVB_REG_CONFIG_NUM_REGS

    for (i=0; i<SI5345_REVB_REG_CONFIG_NUM_REGS; ++i) {
      val = si5345_revb_registers[i].value;
      addr = si5345_revb_registers[i].address;
      Status = iic_write16(chip_addr, addr, val);
      if(Status != XST_SUCCESS) {
          p_printf(("Couldn't write value 0x%02X to address 0x%04X.\n", val, addr));
          p_printf(("There were %d succesful I2C writes so far.\n", i));
          return Status;
      }
      #ifdef DEBUG_REG
        Status = iic_read16(chip_addr, addr, &readback_test);
        if(Status != XST_SUCCESS) {
            p_printf(("Couldn't write value 0x%02X to address 0x%04X.\n", val, addr));
            p_printf(("There were %d successful I2C writes so far.\n", i));
            return Status;
        }

        if (val != readback_test) {
        	p_printf(("address 0x%04X: Write 0x%02X to  and read 0x%02X  ----- Difference detected please check.\r\n",addr, val, readback_test));
        } else {
        	p_printf(("address 0x%04X: Write 0x%02X to  and read 0x%02X.\r\n",addr, val, readback_test));
        }
      #endif
    }
#endif

#ifdef SI5345_REVD_REG_CONFIG_NUM_REGS
	for (i=0; i<SI5345_REVD_REG_CONFIG_NUM_REGS; ++i) {
		val = si5345_revd_registers[i].value;
		addr = si5345_revd_registers[i].address;
		Status = iic_write16(chip_addr, addr, val);
		if(Status != 0) {
			p_printf(("Couldn't write value 0x%02X to address 0x%04X.\n", val, addr));
			p_printf(("There were %d succesful I2C writes so far.\n", i));
			return Status;
		}
    #ifdef DEBUG_REG
      Status = iic_read16(chip_addr, addr, &readback_test);
      if(Status != XST_SUCCESS) {
          p_printf(("Couldn't write value 0x%02X to address 0x%04X.\n", val, addr));
          p_printf(("There were %d successful I2C writes so far.\n", i));
          return Status;
      }

      if (val != readback_test) {
        p_printf(("address 0x%04X: Write 0x%02X to  and read 0x%02X  ----- Difference detected please check.\r\n",addr, val, readback_test));
      } else {
        p_printf(("address 0x%04X: Write 0x%02X to  and read 0x%02X.\r\n",addr, val, readback_test));
      }
    #endif
	}
#endif
	
    p_printf(("Si534x Init Complete.\r\n"));
#ifdef NVM_CODE
    p_printf(("Write this configuration to the Si5345 NVM? (y/N)\r\n"));
    if(uart_read_char() == 'y'){
        si534x_write_nvm(chip_addr)
    }
#endif
	return XST_SUCCESS;
}

#ifdef NVM_CODE
int si534x_write_nvm(unsigned char chip_addr){
	#ifndef NVM_REALY
	#error "To relase NVM write function please define NVM_REALY in te_si534x.h. You do it on your own risk!"
	#endif

#ifdef NVM_REALY
	int Status;
	unsigned char val;
	unsigned char active_nvm_bank;

    p_printf(("Si534x NVM Programming Start.\r\n"));

    Status = iic_read16(chip_addr, ACTIVE_NVM_BANK, &val);
    if(Status != XST_SUCCESS){
    	p_printf(("Error: Si534x Register read failed.\r\n"));
    	return Status;
    }
    active_nvm_bank = val;
    if(!((active_nvm_bank == 3) | (active_nvm_bank == 15))){
    	p_printf(("Error: Wrong ACTIVE_NVM_BANK d (should be 3 or 15).\r\n", active_nvm_bank));
    	return XST_FAILURE;
    }

    p_printf(("Write NVM_WRITE register.\r\n"));
    Status = iic_write16(chip_addr, NVM_WRITE, 0xC7);
    if(Status != XST_SUCCESS){
    	p_printf(("Error: Si534x Register write failed\r\n"));
    	return Status;
    }

    p_printf(("Poll DEVICE_READY.\r\n"));
    do{
    	Status = iic_read16(chip_addr, DEVICE_READY, &val);
    	if(Status != XST_SUCCESS){
    		p_printf(("Error: Si534x Register read failed\r\n"));
    		return Status;
    	}
    }
	while(val != 0x0F);

    p_printf(("Load the NVM contents into non-volatile memory.\r\n"));
    Status = iic_write16(chip_addr, NVM_READ_BANK, 0x01);
    if(Status != XST_SUCCESS){
    	p_printf(("Error: Si534x Register write failed\r\n"));
    	return Status;
    }

    p_printf(("Poll DEVICE_READY.\r\n"));
    do {
    	Status = iic_read16(chip_addr, DEVICE_READY, &val);
    	if(Status != XST_SUCCESS){
    		p_printf(("Error: Si534x Register read failed.\r\n"));
    		return Status;
    	}
    }
    while(val != 0x0F);

    p_printf(("Read ACTIVE_NVM_BANK.\r\n"));
    Status = iic_read16(chip_addr, ACTIVE_NVM_BANK, &val);
    if(Status != XST_SUCCESS){
    	p_printf(("Error: Si534x Register read failed.\r\n"));
    	return Status;
    }
    if(((active_nvm_bank << 2) | 0x03) != val){
    	p_printf(("Error: Wrong ACTIVE_NVM_BANK %d (was %d next should be %d).\r\n", val, active_nvm_bank, ((active_nvm_bank << 2) | 0x03)));
    	return XST_FAILURE;
    }

    p_printf(("Si534x NVM Programming Complete.\r\n"));
	#endif
	return XST_SUCCESS;
}
#endif
#endif /*Clock chip*/
