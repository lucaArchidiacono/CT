/* ------------------------------------------------------------------
 * --  _____       ______  _____                                    -
 * -- |_   _|     |  ____|/ ____|                                   -
 * --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
 * --   | | | '_ \|  __|  \___ \   Zurich University of             -
 * --  _| |_| | | | |____ ____) |  Applied Sciences                 -
 * -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
 * ------------------------------------------------------------------
 * --
 * -- Description:  Implementation of module lcd
 * --               Performs all the interactions with the lcd
 * --
 * -- $Id: lcd.c 5144 2020-09-01 06:17:21Z ruan $
 * ------------------------------------------------------------------
 */

/* standard includes */
#include <stdio.h>

/* user includes */
#include "lcd.h"
#include "reg_ctboard.h"

/* macros */
#define LCD_ADDR_LINE1      0u
#define LCD_ADDR_LINE2      20u

#define NR_OF_CHAR_PER_LINE 20u

#define LCD_CLEAR           "                    "
#define MAX_SLOT_OFFSET	3

/// STUDENTS: To be programmed
void lcd_write_value(uint8_t slot_nr, uint8_t value)
{
	//lcd contains 20 positions. 6 numbers need to be displayed (with spaces in between)
	//for that reason min. of 5 spaces between the numbers are required.
	//20-5=15 free positions can be used to display numbers.
	//15/6=2 REST 3. So maximum of 2 digits per slot_nr
	char buffer[MAX_SLOT_OFFSET];
	uint8_t offset = (slot_nr-1)*MAX_SLOT_OFFSET;
	
	//format int-value to string
	uint8_t string_size = snprintf(buffer, MAX_SLOT_OFFSET, "%02d ", value);
	
	//print string to LCD
	int i;
	for (i = 0; i < string_size; i++)
	{
		CT_LCD->ASCII[offset] = buffer[i];
		offset++;
	}
}

void lcd_write_total(uint8_t total_value)
{
	//"total throws " => 13 characters
	//LCD has an offset of 20. 20-13 = 7 fields remaining which we can use to display the total_value
	char buffer[NR_OF_CHAR_PER_LINE];
	uint8_t string_size= snprintf(buffer, NR_OF_CHAR_PER_LINE, "total throws %06d", total_value);
	
	//assign 'total throws xy' to the LCD
	int i;
	for (i = 0; i < NR_OF_CHAR_PER_LINE; i++)
	{
		CT_LCD->ASCII[LCD_ADDR_LINE2+i] = buffer[i];
	}
}

void hal_ct_lcd_clear(void)
{
	
	//LCD contains an offset of 20. Thus we need to clear 20 positions
	int i;
	for(i = 0; i < NR_OF_CHAR_PER_LINE; i++){
		CT_LCD->ASCII[LCD_ADDR_LINE1+i] = LCD_CLEAR[i];
		CT_LCD->ASCII[LCD_ADDR_LINE2+i] = LCD_CLEAR[i];
	}
	
	//set LCD to green
	CT_LCD->BG.GREEN = 65535;
	CT_LCD->BG.RED = 0;
	CT_LCD->BG.BLUE = 0;
}

/// END: To be programmed
