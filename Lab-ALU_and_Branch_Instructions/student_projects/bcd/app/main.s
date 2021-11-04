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
		BNE		shift_add

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
		STRB    R2, [R1]                    ; Display value of R2 on 7-seg display R0 (DS1, DS0)
        STRB 	R5, [R1, #1]				; Display value of R5 on 7-seg display R0 with offset (DS3, DS2)
		
		LDR 	R1, =ADDR_LED_15_0
        STRB 	R2, [R1]					; Display value of R2 in LED_7_0
        STRB 	R5, [R1, #1]				; Display value of R5 in LED_15_8

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
