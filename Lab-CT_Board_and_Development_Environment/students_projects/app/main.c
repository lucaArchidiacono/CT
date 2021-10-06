#include "utils_ctboard.h"

#define DIPSW_ADDR					0x60000200
#define LED_ADDR						0x60000100
#define HEX_ROT_ADDR				0x60000211
#define SEV_SEG_DISP_ADDR		0x60000110

//#define TASK42
#define TASK51
#define TASK52

int main()
{
	const uint8_t numbers[16] = {0xC0, 0xF9, 0xA4, 0xB0, 0x99, 0x92, 0x82, 0xF8, 0x80, 0x90, 0x88, 0x83, 0xC6, 0xA1, 0x86, 0x8E};
	
	while(1) {
		
		#ifdef TASK42
		uint8_t value = read_byte(DIPSW_ADDR);
		write_byte(LED_ADDR, value);
		#endif
		
		#ifdef TASK51
		uint32_t value = read_word(DIPSW_ADDR);
		write_word(LED_ADDR, value);
		#endif
		
		#ifdef TASK52
		uint8_t rot_value = read_byte(HEX_ROT_ADDR);
		rot_value= rot_value& 0x0F;
		write_byte(SEV_SEG_DISP_ADDR, numbers[rot_value]);
		#endif
	}
}
