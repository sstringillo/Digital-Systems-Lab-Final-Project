//io_handler.c
#include "io_handler.h"
#include <stdio.h>
#include "alt_types.h"
#include "system.h"

#define otg_hpi_address		(volatile int*) 	OTG_HPI_ADDRESS_BASE
#define otg_hpi_data		(volatile int*)	    OTG_HPI_DATA_BASE
#define otg_hpi_r			(volatile char*)	OTG_HPI_R_BASE
#define otg_hpi_cs			(volatile char*)	OTG_HPI_CS_BASE //FOR SOME REASON CS BASE BEHAVES WEIRDLY MIGHT HAVE TO SET MANUALLY
#define otg_hpi_w			(volatile char*)	OTG_HPI_W_BASE


void IO_init(void)
{
	*otg_hpi_cs = 1;
	*otg_hpi_r = 1;
	*otg_hpi_w = 1;
	*otg_hpi_address = 0;
	*otg_hpi_data = 0;
}

void IO_write(alt_u8 Address, alt_u16 Data)
{
	*otg_hpi_cs = 0;
	//set address
	*otg_hpi_address = Address;
	//turn write signal on
	*otg_hpi_r = 1;
	*otg_hpi_w = 0;
	*(otg_hpi_data + 1) |= 0x00FF;
	//write data to address
	*otg_hpi_data = Data;
	*(otg_hpi_data + 1) &= 0x0000;
	//turn signals off
	*otg_hpi_w = 1;
	*otg_hpi_cs = 1;
}

alt_u16 IO_read(alt_u8 Address)
{
	alt_u16 temp;
	*otg_hpi_cs = 0;
	//set address
	*otg_hpi_address = Address;
	//turn read signal on
	*otg_hpi_r = 0;
	*otg_hpi_w = 1;
	//get data from address
	temp = *otg_hpi_data;
	//printf("%x\n",temp);
	//turn signals off
	*otg_hpi_r = 1;
	*otg_hpi_cs = 1;
	//return data
	return temp;
}
