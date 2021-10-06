/* -----------------------------------------------------------------
 * --  _____       ______  _____                                    -
 * -- |_   _|     |  ____|/ ____|                                   -
 * --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
 * --   | | | '_ \|  __|  \___ \   Zurich University of             -
 * --  _| |_| | | | |____ ____) |  Applied Sciences                 -
 * -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
 * ------------------------------------------------------------------
 * --
 * -- main.c
 * --
 * -- main for Computer Engineering "Bit Manipulations"
 * --
 * -- $Id: main.c 744 2014-09-24 07:48:46Z ruan $
 * ------------------------------------------------------------------
 */
//#include <reg_ctboard.h>
#include "utils_ctboard.h"

#define ADDR_DIP_SWITCH_31_0 0x60000200
#define ADDR_DIP_SWITCH_7_0  0x60000200
#define ADDR_LED_31_24       0x60000103
#define ADDR_LED_23_16       0x60000102
#define ADDR_LED_15_8        0x60000101
#define ADDR_LED_7_0         0x60000100
#define ADDR_BUTTONS         0x60000210

// define your own macros for bitmasks below (#define)
/// STUDENTS: To be programmed

// 0xC0 -> 11000000	Is responsible to be used in the beginning with the OR bit operator (1 OR 0 = 1, 1 OR 1 = 1, 0 OR 0 = 0) to set the first two LED's S7 and S6 into BRIGHT mode
#define LED_BRIGHT	0xC0

// 0xCF -> 11001111 Is responsible to be used in the second step with the AND bit operator (1 AND 0 = 0, 1 AND 1 = 1, 0 AND 0 = 0) to keep the first two LED's S7 and S6 in BRIGHT mode and to keep the middle LED's S5 and S4 in Dark Mode. 
// If the last Switche's (S3 - S0) are ON then the LED should be BRIGHT -> 1 AND 1 = 1
// If the last Switche's (S3 - S0) are OFF then the LED should be DARK -> 1 AND 0 = 0
#define LED_DARK		0xCF

// 0xF -> Mask for upper 4 bits = 11110000
#define MASK				0xF0

/// END: To be programmed

int main(void)
{
    uint8_t led_value = 0;

    // add variables below
    /// STUDENTS: To be programmed
		uint8_t button_0_counter 							= 0;
		uint8_t button_value 									= 0;
		uint8_t button_0_value 								= 0;
	  uint8_t button_1_value 								= 0;
    uint8_t button_2_value 								= 0;
    uint8_t button_3_value 								= 0;
		uint8_t push_event_counter						= 0;
		uint8_t button_0_previous_value 			= 0;
	  uint8_t button_1_previous_value 			= 0;
    uint8_t button_2_previous_value 			= 0;
    uint8_t button_3_previous_value 			= 0;
		uint8_t task_3_3_value								= 0;
    /// END: To be programmed

    while (1) {
        // ---------- Task 3.1 ----------
        led_value = read_byte(ADDR_DIP_SWITCH_7_0);

			/*
			 *	S7				S6				S5				S4				S3				S2				S1
			 *	ON				ON				OFF				OFF				ON/OFF		ON/OFF		ON/OFF
			 *	1					1					0					0					1/0				1/0				1/0
			 */
				//alle switch ON					= 11111111
				//alle switch OFF 				= 00000000
				//switch S7 und S6 an			= 11000000
				//switch S7, S6 und S0 an	= 11000001
			
        /// STUDENTS: To be programmed

				led_value |= LED_BRIGHT;
				led_value &= LED_DARK;

        /// END: To be programmed
			
        write_byte(ADDR_LED_7_0, led_value);

        // ---------- Task 3.2 and 3.3 ----------
        /// STUDENTS: To be programmed
				
				//If only the button T0 is in a "pressed" state, then the read value (from T3 till T0) looks like following		->	11110001
				//If none button is in a "pressed" state, then the read value (from T3 till T0) looks like following					->	11110000
				//	-		-		-		-		T3	T2	T1	T0
				//	1		1		1		1		0		0		0		0
				button_value = read_byte(ADDR_BUTTONS);
				

				
				//Here we mask the upper 4 bits, so that we can see fast if the buttons T3-T0 were pressed or not.
				//For example:
				//	11110001 XOR 11110000 = 00000001
				//	11110000 XOR 11110000 = 00000000
				//	11110010 XOR 11110000 = 00000010
				button_value ^= MASK;
				
				
				//We check if the button T0 was pressed or not by using this mask -> 00000001 in an AND-Bit operation
				button_0_value = button_value & 0x01;
				
				//In C the value 0 is equals FALSE. This means if button_0_value == 0, then we don't go inside the if.
				if (button_0_value)
				{
					button_0_counter++;
				}
				
				//Task 3.2 a)
				write_byte(ADDR_LED_15_8, button_0_counter);
				
				button_1_value = button_value & 0x02;
				button_2_value = button_value & 0x04;
				button_3_value = button_value & 0x08;
				
				//Task 3.2 c) and 3.3
				if (
					button_0_value != button_0_previous_value &&
					button_0_value & ~button_0_previous_value) {
						task_3_3_value >>= 1;
            push_event_counter++;
        } else if (
					button_1_value !=  button_1_previous_value &&
					button_1_value & ~button_1_previous_value) {
						task_3_3_value <<= 1;
            push_event_counter++;
        } else if (
					button_2_value != button_2_previous_value&&
          button_2_value & ~button_2_previous_value) {
						task_3_3_value = ~task_3_3_value;
            push_event_counter++;
        } else if (
					button_3_value != button_3_previous_value&&
          button_3_value & ~button_3_previous_value) {
						task_3_3_value = read_byte(ADDR_DIP_SWITCH_7_0);
            push_event_counter++;
        }
					
				button_0_previous_value = button_0_value;
        button_1_previous_value = button_1_value;
        button_2_previous_value = button_2_value;
        button_3_previous_value = button_3_value;
				
				write_byte(ADDR_LED_31_24, push_event_counter);
				write_byte(ADDR_LED_23_16, task_3_3_value);
        /// END: To be programmed
    }
}
