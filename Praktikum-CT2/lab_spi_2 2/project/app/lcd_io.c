/* ------------------------------------------------------------------
 * --  _____       ______  _____                                    -
 * -- |_   _|     |  ____|/ ____|                                   -
 * --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
 * --   | | | '_ \|  __|  \___ \   Zuercher Hochschule Winterthur   -
 * --  _| |_| | | | |____ ____) |  (University of Applied Sciences) -
 * -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
 * ------------------------------------------------------------------
 * --
 * -- Project     : CT2 lab - SPI Display
 * -- Description : Contains the implementations of the functions
 * --               to write and read frames from and to the TFT-LCD
 * --               display EAeDIPTFT43-A.
 * --
 * -- $Id: lcd_io.c 4720 2019-03-04 10:11:31Z akdi $
 * ------------------------------------------------------------------
 */
#include "lcd_io.h"
#include "hal_spi.h"
#include "hal_sbuf.h"

#define ACK_CHAR         (uint8_t)0x06
#define DC1_CHAR         (uint8_t)0x11
#define DC2_CHAR         (uint8_t)0x12
#define ESC_CHAR         (uint8_t)0x1B
#define ONE_CHAR         (uint8_t)0x01
#define S_CHAR					 (uint8_t)0x53

#define NOTHING_RECEIVED (uint8_t)0
enum { SUCCESS = 0, ERRORCODE = 1 };

/* ------------------------------------------------------------------
 * -- Function prototypes
 * ------------------------------------------------------------------
 */
static void send_read_display_buffer_request(void);

/* ------------------------------------------------------------------
 * -- Function implementations
 * ------------------------------------------------------------------
 */

/*
 * according to description in header file
 */
void init_display_interface(void)
{
    hal_spi_init();
    hal_sbuf_init();
}

/*
 * according to description in header file
 */
uint8_t read_display_buffer(uint8_t *readBuffer)
{
  /// STUDENTS: To be programmed
	uint8_t display_response = 0;
	uint8_t DC1_value = 0;
	uint8_t len_value = 0;
	uint8_t bcc_local_value = 0;
	uint8_t i = 0;
	
	if (hal_sbuf_get_state() == NOTHING_RECEIVED) {
		return ERRORCODE;
	}
	
	send_read_display_buffer_request();
	display_response = hal_spi_read_write(0x00);
	if(display_response != ACK_CHAR) {
		return ERRORCODE;
	}
	
	DC1_value = hal_spi_read_write(0);
	bcc_local_value += DC1_value;
	if (DC1_value != DC1_CHAR) {
		return ERRORCODE;
	}
	
	len_value = hal_spi_read_write(0);
	bcc_local_value += len_value;
	
	for(i = 0; i < len_value; i++) {
		readBuffer[i] = hal_spi_read_write(0);
		bcc_local_value += readBuffer[i];
	}

	if (bcc_local_value != hal_spi_read_write(0)) {
		return ERRORCODE;
	}
	
	
	return len_value;
    /// END: To be programmed
}

/*
 * according to description in header file
 */
uint8_t write_cmd_to_display(const uint8_t *cmdBuffer, uint8_t length)
{
  /// STUDENTS: To be programmed
	uint8_t result = 0;
	uint8_t bcc = 0;
	uint8_t display_response = 0;
	int i = 0;
	
	hal_spi_read_write(DC1_CHAR);
	bcc += DC1_CHAR;
	hal_spi_read_write(length+1);
	bcc += length+1;
	hal_spi_read_write(ESC_CHAR);
	bcc += ESC_CHAR;
	
	while (i < length) {
		hal_spi_read_write(cmdBuffer[i]);
		bcc += cmdBuffer[i];
		i++;
	}
	
	hal_spi_read_write(bcc);
	
	display_response = hal_spi_read_write(0x00);
	
	if(display_response == ACK_CHAR) {
		return SUCCESS;
	}
	
	return ERRORCODE;
  /// END: To be programmed
}

/*
 * Assemble and send a packet to trigger the reading of the display buffer
 * Uses the sequence "<DC2>, 0x01, 0x53, checksum" according to datasheet
 */
static void send_read_display_buffer_request()
{
    /// STUDENTS: To be programmed
	uint8_t bcc = 0;
	
	hal_spi_read_write(DC2_CHAR);
	bcc += DC2_CHAR;
	
	hal_spi_read_write(ONE_CHAR);
	bcc += ONE_CHAR;
	
	hal_spi_read_write(S_CHAR);
	bcc += S_CHAR;
	
	hal_spi_read_write(bcc);
    /// END: To be programmed
}
