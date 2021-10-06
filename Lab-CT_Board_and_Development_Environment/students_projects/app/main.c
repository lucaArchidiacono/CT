#include "utils_ctboard.h"

#define DIPSW_ADDR	0x60000200
#define LED_ADDR		0x60000100

int main()
{
	while(1) {
		uint8_t value = read_byte(DIPSW_ADDR);
		write_byte(LED_ADDR, value);
	}
}
