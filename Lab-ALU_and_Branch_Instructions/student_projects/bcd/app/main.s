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
; -- CT1 P06 "ALU und Sprungbefehle" mit MUL
; --
; -- $Id: main.s 4857 2019-09-10 17:30:17Z akdi $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Address Defines
; ------------------------------------------------------------------

ADDR_LED_15_0           EQU     0x60000100
ADDR_LED_31_16          EQU     0x60000102
ADDR_DIP_SWITCH_7_0     EQU     0x60000200
ADDR_DIP_SWITCH_15_8    EQU     0x60000201
ADDR_7_SEG_BIN_DS3_0    EQU     0x60000114
ADDR_BUTTONS            EQU     0x60000210

ADDR_LCD_RED            EQU     0x60000340
ADDR_LCD_GREEN          EQU     0x60000342
ADDR_LCD_BLUE           EQU     0x60000344
LCD_BACKLIGHT_FULL      EQU     0xffff
LCD_BACKLIGHT_OFF      	EQU     0x0000

BUTTON_MASK				EQU		0x01
BCD_MASK				EQU		0x0F
HEX_TEN					EQU		0xA

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

        ENTRY

main    PROC
        export main
            
; STUDENTS: To be programmed
		
		LDR		R6, =BUTTON_MASK
		LDR		R7, =BCD_MASK
		
		; Load values from the dip switches, mask them with 0x00001111, then shift the SWITCH_15_8 and finally add them together.
		LDR		R0, =ADDR_DIP_SWITCH_7_0	
		LDRB	R0, [R0]					; BCD Ones
		ANDS	R0, R0, R7
		
		LDR		R1, =ADDR_DIP_SWITCH_15_8	
		LDRB	R1, [R1]					; BCD Tens
		ANDS	R1, R1, R7
		
		LSLS	R2, R1, #4					; Left shift tens-value to make space for ones-value
		ADDS	R2, R2, R0					; Store result of (tens + ones) values in R2. R2 will be later used to show in LED_7_0 and DS_1_0
		
		; Check for the pressed button T0
		LDR		R7, =ADDR_BUTTONS
		LDRB	R7, [R7]
		TST		R7, R6						; Test if P0 was pressed or not
		
		; If Button T0 was pressed set background and go to shift_add branch.
		LDR		R6, =ADDR_LCD_BLUE
		LDR		R7, =ADDR_LCD_RED
		BNE		shift_add					; Branch if Z-Flag is == 0

multiply
		LDR		R3, =HEX_TEN
		MULS	R1, R3, R1					; Multiply 0xA (10) with R1 (to get binary values) and store in R1
		ADDS	R5, R1, R0					; Store result of R1 + R0 in R5. R5 will be later used to show in LED_15_8 and DS_3_2
	
		; Set LCD Background color to blue
		LDR		R3, =LCD_BACKLIGHT_FULL
		STRH	R3, [R6]					; Pass to LCD_Blue register the address of LCD_BACKLIGHT_FULL -> enable BLUE
		LDR		R4, =LCD_BACKLIGHT_OFF		; Pass to LCD_Red register the address of LCD_BACKLIGHT_OFF -> disable RED
		STRH	R4, [R7]
		
		B		end_branch
		
shift_add
		; Shift and add to make BCD 10s and add BCD values for binary value
		LSLS	R5, R1, #1					; R1 * 2^1 = R1 * 2
		LSLS	R4, R1, #3					; R1 * 2^3 = R1 * 8
		ADDS	R5, R5, R4					; (R1*2) + (R1*8) = R1*10
		
		ADDS	R5, R5, R0					; Store result of R5 + R0 in R5. R5 will be later used to show in LED_15_8 and DS_3_2
		
		; Set LCD Background color to red
		LDR		R3, =LCD_BACKLIGHT_OFF		; Pass to LCD_Blue register the address of LCD_BACKLIGHT_OFF -> enable BLUE
		STRH	R3, [R6]
		LDR		R4, =LCD_BACKLIGHT_FULL		; Pass to LCD_Red register the address of LCD_BACKLIGHT_FULL -> enable RED
		STRH	R4, [R7]
		
end_branch
		; Show BCD
		LDR 	R1, =ADDR_7_SEG_BIN_DS3_0
		STRB    R2, [R1]                    ; Display value of R2 on 7-seg display R1 (DS1, DS0)
        STRB 	R5, [R1, #1]				; Display value of R5 on 7-seg display R1 with offset (DS3, DS2)
		
		LDR 	R1, =ADDR_LED_15_0
        STRB 	R2, [R1]					; Display value of R2 in LED_7_0
        STRB 	R5, [R1, #1]				; Display value of R5 in LED_15_8
		
		
		; initialise width of rotation bar before do-while loop
		MOVS	R0, #0						; 0000 0000 -> will be used to count the 1's in R5. After every shift to the right and carry = 1 this R0 will get +1 on the far right side.
		MOVS 	R1, #7						; 0000 0111 == 7 -> is the counter which will be counted down --1
		
start_width_loop
		LSRS	R5, R5, #1					; Shift from left to right and additionaly check if there will be a carry flag set to 1 or not
		BCC 	end_width_loop				; If C-Flag is == 0 then go to label "inside_loop"
		
		; Execution continues here if C-Flag != 0
		LSLS	R0, #1						; Shfit all the 1 on the far right side one step left, to make place for the upcoming 1
		ADDS	R0, R0, #1					; Adds 1 on the far right. This indicates another 1 was found in R5 (BCD)

end_width_loop
		SUBS	R1, #1
		BNE		start_width_loop			; If Z == 0 then go to label "start_loop"
		
		; Execution continues here if Z-Flag != 0
		LSLS	R6, R0, #16					; Shifts the width-block to the left with Offset 16 (in this case this will be not seen in the beginning on the LED. because it's outside the range 0-15). 
											; E.g. R0 = 1111. Then we shift this value with offset 16 -> 1111 0000 0000 0000 0000
		ORRS	R6, R6, R0					; Combines the far left width-block with the far right widt-block -> 1111 0000 0000 0000 0000 OR 1111 == 1111 0000 0000 0000 1111
		MOVS	R0, R6						; Copies this new value to R0
		
rotate_full
		LDR		R4, =ADDR_LED_31_16
		STRH	R0, [R4]
		
		MOVS	R4, #1
		RORS	R0, R0, R4					; Rotate the value right by 1. E.g. starting with = 1111 0000 0000 0000 1111 then rotate right 1 -> 1111 1000 0000 0000 0111.
		BL	pause
		CMP		R0, R6						; Compare the both values R0 and R6. If R0 is less or equal to R6 then jump to label "rotate_full"
		BNE rotate_full
		

; END: To be programmed

        B       main
        ENDP
            
;----------------------------------------------------
; Subroutines
;----------------------------------------------------

;----------------------------------------------------
; pause for disco_lights
pause           PROC
        PUSH    {R0, R1}
        LDR     R1, =1
        LDR     R0, =0x000FFFFF
        
loop        
        SUBS    R0, R0, R1
        BCS     loop
    
        POP     {R0, R1}
        BX      LR
        ALIGN
        ENDP

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END
