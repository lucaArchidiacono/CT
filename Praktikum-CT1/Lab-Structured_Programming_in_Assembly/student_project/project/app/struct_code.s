; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- main.s
; --
; -- CT1 P08 "Strukturierte Codierung" mit Assembler
; --
; -- $Id: struct_code.s 3787 2016-11-17 09:41:48Z kesr $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Address-Defines
; ------------------------------------------------------------------
; input
ADDR_DIP_SWITCH_7_0       EQU        0x60000200
ADDR_BUTTONS              EQU        0x60000210

; output
ADDR_LED_31_0             EQU        0x60000100
ADDR_7_SEG_BIN_DS3_0      EQU        0x60000114
ADDR_LCD_COLOUR           EQU        0x60000340
ADDR_LCD_ASCII            EQU        0x60000300
ADDR_LCD_ASCII_BIT_POS    EQU        0x60000302
ADDR_LCD_ASCII_2ND_LINE   EQU        0x60000314


; ------------------------------------------------------------------
; -- Program-Defines
; ------------------------------------------------------------------
; value for clearing lcd
ASCII_DIGIT_CLEAR        EQU         0x00000000
LCD_LAST_OFFSET          EQU         0x00000028

; offset for showing the digit in the lcd
ASCII_DIGIT_OFFSET        EQU        0x00000030

; lcd background colors to be written
DISPLAY_COLOUR_RED        EQU        0
DISPLAY_COLOUR_GREEN      EQU        2
DISPLAY_COLOUR_BLUE       EQU        4

; checks
BUTTON_PRESSED			  EQU		 0x01
; ------------------------------------------------------------------
; -- myConstants
; ------------------------------------------------------------------
        AREA myConstants, DATA, READONLY
; display defines for hex / dec
DISPLAY_BIT               DCB        "Bit "
DISPLAY_2_BIT             DCB        "2"
DISPLAY_4_BIT             DCB        "4"
DISPLAY_8_BIT             DCB        "8"
        ALIGN

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY
        ENTRY

        ; imports for calls
        import adc_init
        import adc_get_value

main    PROC
        export main
        ; 8 bit resolution, cont. sampling
        BL         adc_init 
        BL         clear_lcd

main_loop
; STUDENTS: To be programmed
		LDR 	R0, =ADDR_BUTTONS
		LDRB 	R1, [R0, #0] 						; Read all buttons into the lower nibble of a byte.
		
		SUBS 	R1, #0xF1
		BEQ 	t0_pressed							; If R1 == 0x00 then go to t0_pressed
		BNE 	t0_not_pressed						; If R1 != 0x00 then go to t0_not_pressed
; END: To be programmed
        B          main_loop

t0_pressed
		BL		adc_get_value						; The function call BL adc_get_value will return the ADC-value in the 32-bit register R0. 
		LSRS	R0, R0, #3							; Use a division by 8 (shift right) to scale the ADC-value from 8-bit down to 5-bit. Then use a loop to calculate the magnitude of the LED-bar. 
		
		ADDS	R0, #0x1
		MOVS 	R1, #0
counter_loop
		MOVS 	R3, #0x1
		LSLS	R1, R1, R3
		ADDS	R1, #0x1
		
		SUBS 	R0, R0, #0x1
		BNE 	counter_loop
		
		LDR 	R4, =ADDR_LED_31_0
		STR		R1, [R4, #0]
		
		B		set_lcd_green
		B		main_loop

t0_not_pressed
		BL		adc_get_value						; The function call BL adc_get_value will return the ADC-value in the 32-bit register R0.
		
		; as we didn't press T0 we need to clear the LED's
		PUSH 	{ R0, R1 }
		MOVS 	R0, #0x00
		LDR 	R1, =ADDR_LED_31_0
		STR		R0, [R1, #0]
		POP		{ R0, R1 }
		
		LDR		R1, =ADDR_DIP_SWITCH_7_0
		LDR		R2, [R1]
		
		; calculate the difference between DIP_SWITCH(R2) - ADC(R0) = (R2)
		SUBS	R2, R2, R0
		
		LDR		R3, =ADDR_7_SEG_BIN_DS3_0
		STR		R2, [R3]							; store the difference inside the SEG_BIN_DS3_0
		
		SUBS	R2, #0x00
		BGE 	set_lcd_blue						; When R2 >= 0x00 then go to set_lcd_blue
		BLT 	set_lcd_red							; When R2 < 0x00 then go to set_lcd_red
		B		main_loop

; Because the LCD needs to get RGB color-coding we set the values like so.
; https://ennis.zhaw.ch/wiki/doku.php?id=ctboard:peripherals:lcd_bg
set_lcd_green
		LDR			R0, =ADDR_LCD_COLOUR
		LDR			R1, =0x0000
		LDR			R2, =0xFFFF
		STRH		R1, [R0, #DISPLAY_COLOUR_RED]
		STRH		R2, [R0, #DISPLAY_COLOUR_GREEN]
		STRH		R1, [R0, #DISPLAY_COLOUR_BLUE]
		B			main_loop
set_lcd_blue
		PUSH		{ R0, R1, R2 }
		
		LDR			R0, =ADDR_LCD_COLOUR
		LDR			R1, =0x0000
		LDR			R2, =0xFFFF
		STRH		R1, [R0, #DISPLAY_COLOUR_RED]
		STRH		R1, [R0, #DISPLAY_COLOUR_GREEN]
		STRH		R2, [R0, #DISPLAY_COLOUR_BLUE]
		
		POP			{ R0, R1, R2 }
		
		PUSH		{ R2 }
		SUBS		R2, #4
		BLO			lower_4							; if R2 < 4 then go to lower_4
		POP			{ R2 }
		SUBS		R2, #16
		BLO			lower_16						; if R2 < 16 then go to lower_16
lower_others
		MOVS		R2, #8
		B			display_bit
lower_4
		MOVS		R2, #2
		B			display_bit
lower_16
		MOVS		R2, #4
		B			display_bit

display_bit
		ADDS 		R2, #0x30						; add offset for ASCII presentation
		
		; display on LCD display
		LDR 		R7, =ADDR_LCD_ASCII
		STR 		R2, [R7]
		BL 			write_bit_ascii
		
		B			main_loop

set_lcd_red
		PUSH		{ R0, R1, R2 }
		
		LDR			R0, =ADDR_LCD_COLOUR
		LDR			R1, =0x0000
		LDR			R2, =0xFFFF
		STRH		R2, [R0, #DISPLAY_COLOUR_RED]
		STRH		R1, [R0, #DISPLAY_COLOUR_GREEN]
		STRH		R1, [R0, #DISPLAY_COLOUR_BLUE]
		
		POP			{ R0, R1, R2 }
		
		PUSH		{ R0, R1, R2 }
		
		MOVS		R6, #0							; zero counter
		MOVS		R7, #8							; general loop counter. e.g. i
start_loop
		LSRS		R2, #1
		BCS			end_loop						; if C-Flag is != 0 then go to "end_loop"
		
		ADDS		R6, #1
end_loop
		SUBS 		R7, #1							; reduce "for loop counter"
		BNE			start_loop						; If Z == 0 then go to label "start_loop"
		
		ADDS 		R6, #0x30						; add offset for ASCII presentation
		
		; display on LCD display 2nd line
		LDR 		R7, =ADDR_LCD_ASCII_2ND_LINE
		STR 		R6, [R7]
		
		POP 		{ R0, R1, R2 }
		B			main_loop
		
clear_lcd
        PUSH       {R0, R1, R2}
        LDR        R2, =0x0
clear_lcd_loop
        LDR        R0, =ADDR_LCD_ASCII
        ADDS       R0, R0, R2                       ; add index to lcd offset
        LDR        R1, =ASCII_DIGIT_CLEAR
        STR        R1, [R0]
        ADDS       R2, R2, #4                       ; increas index by 4 (word step)
        CMP        R2, #LCD_LAST_OFFSET             ; until index reached last lcd point
        BMI        clear_lcd_loop
        POP        {R0, R1, R2}
        BX         LR

write_bit_ascii
        PUSH       {R0, R1}
        LDR        R0, =ADDR_LCD_ASCII_BIT_POS 
        LDR        R1, =DISPLAY_BIT
        LDR        R1, [R1]
        STR        R1, [R0]
        POP        {R0, R1}
        BX         LR

        ENDP
        ALIGN


; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END
