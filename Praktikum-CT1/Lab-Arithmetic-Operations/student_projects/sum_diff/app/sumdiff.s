; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- sumdiff.s
; --
; -- CT1 P05 Summe und Differenz
; --
; -- $Id: sumdiff.s 705 2014-09-16 11:44:22Z muln $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_7_0     EQU     0x60000200
ADDR_DIP_SWITCH_15_8    EQU     0x60000201
ADDR_LED_7_0            EQU     0x60000100
ADDR_LED_15_8           EQU     0x60000101
ADDR_LED_23_16          EQU     0x60000102
ADDR_LED_31_24          EQU     0x60000103

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA MyCode, CODE, READONLY

main    PROC
        EXPORT main

user_prog
        ; STUDENTS: To be programmed
		
		LDR		R0, =ADDR_DIP_SWITCH_15_8
		LDRB	R1, [R0]					; Operand A
		LDR		R2, =ADDR_DIP_SWITCH_7_0
		LDRB	R3, [R2]					; Operand B
		
		LSLS	R1, R1, #24					; Expand from 8 bits to 32 bits
		LSLS	R3, R3, #24					; Expand from 8 bits to 32 bits
		
		; ADD
		ADDS	R1, R1, R3					; A = A+B. Result will be stored in the address of R1
		MRS		R6, APSR					; copies the content of the application program status register to register R6
		
		LSRS	R6, R6, #24					; Shift position of flags to the lower 4 bits
		LDR		R5, =ADDR_LED_15_8
		STRB 	R6, [R5]					; Store addition value in LED 15_8
		
		LSRS	R1, R1, #24 				; Move result back 24 bits again
		LDR		R4, =ADDR_LED_7_0
		STRB 	R1, [R4]					; Store addition value in LED 7_0
		
		; SUB
		LDRB    R1, [R0]							; Operand A
		LDRB    R3, [R2]							; Operand B
		
		LSLS	R1, R1, #24 						; Expand from 8 bits to 32 bits
		LSLS	R3, R3, #24 						; Expand from 8 bits to 32 bits
		
		SUBS 	R1, R1, R3							; A = A-B. Result will be stored in the address of R1
		MRS 	R6, APSR							; copies the content of the application program status register to register R6
		
		LSRS	R6, R6, #24							; Shift position of flags to the lower 4 bits
		LDR		R5, =ADDR_LED_31_24
		STRB 	R6, [R5]							; Store addition value in LED 31_24
		
		LSRS	R1, R1, #24 						; Move result back 24 bits again
		LDR		R4, =ADDR_LED_23_16
		STRB 	R1, [R4]							; Store addition value in LED 23_16

        ; END: To be programmed
        B       user_prog
        ALIGN
; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
