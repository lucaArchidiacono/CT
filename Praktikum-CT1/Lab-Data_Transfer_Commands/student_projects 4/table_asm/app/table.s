; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- table.s
; --
; -- CT1 P04 Ein- und Ausgabe von Tabellenwerten
; --
; -- $Id: table.s 800 2014-10-06 13:19:25Z ruan $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB
; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_7_0         EQU     0x60000200
ADDR_DIP_SWITCH_15_8        EQU     0x60000201
ADDR_DIP_SWITCH_31_24       EQU     0x60000203
ADDR_LED_7_0                EQU     0x60000100
ADDR_LED_15_8               EQU     0x60000101
ADDR_LED_23_16              EQU     0x60000102
ADDR_LED_31_24              EQU     0x60000103
ADDR_BUTTONS                EQU     0x60000210

BITMASK_KEY_T0              EQU     0x01
BITMASK_LOWER_NIBBLE        EQU     0x0F

; ------------------------------------------------------------------
; -- Variables
; ------------------------------------------------------------------
        AREA MyAsmVar, DATA, READWRITE
; STUDENTS: To be programmed

store_table	SPACE 16


; END: To be programmed
        ALIGN

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

main    PROC
        EXPORT main

readInput
        BL    waitForKey                    ; wait for key to be pressed and released
; STUDENTS: To be programmed

		;loads address of ADDR_DIP_SWITCH_7_0 into register R1
		LDR		R1, =ADDR_DIP_SWITCH_7_0
		;unsigned Byte (Zero extend to 32 bits on loads.)
		LDRB	R0, [R1]
		;loads address of ADDR_DIP_SWITCH_15_8 into register R5
		LDR		R5, =ADDR_DIP_SWITCH_15_8
		;unsigned Byte (Zero extend to 32 bits on loads.)
		LDRB    R6, [R5]
		
		;AND operiere die gestorten values von den ADDR_DIP_SWITCH_15_8 welche sich im Register R6 befinden
		LDR 	R2, =BITMASK_LOWER_NIBBLE
		ANDS 	R6, R6, R2
		
		;loads address of ADDR_LED_7_0 into register R3
		LDR     R3, =ADDR_LED_7_0
		;stores the unsigned byte from R3 into R0
		STRB 	R0, [R3]
		;loads address of ADDR_LED_15_8 into register R3
        LDR     R7, =ADDR_LED_15_8
		;stores the unsigned byte from R7 into R6
		STRB 	R6, [R7]
		
		
		LDR		R4, =store_table
		STRB	R0, [R4, R6]
		
		
		
		LDR		R1, =ADDR_DIP_SWITCH_31_24
		LDRB    R0, [R1]
		
		LDR 	R2, =BITMASK_LOWER_NIBBLE
		ANDS 	R0, R0, R2
		
        LDR     R3, =ADDR_LED_31_24
		STRB 	R0, [R3]
		
        LDR     R4, =store_table
		STRB    R6, [R4, R0]
		
        LDR     R5, =ADDR_LED_23_16
		STRB 	R6, [R5]
		
; END: To be programmed
        B       readInput
        ALIGN

; ------------------------------------------------------------------
; Subroutines
; ------------------------------------------------------------------

; wait for key to be pressed and released
waitForKey
        PUSH    {R0, R1, R2}
        LDR     R1, =ADDR_BUTTONS           ; laod base address of keys
        LDR     R2, =BITMASK_KEY_T0         ; load key mask T0

waitForPress
        LDRB    R0, [R1]                    ; load key values
        TST     R0, R2                      ; check, if key T0 is pressed
        BEQ     waitForPress

waitForRelease
        LDRB    R0, [R1]                    ; load key values
        TST     R0, R2                      ; check, if key T0 is released
        BNE     waitForRelease
                
        POP     {R0, R1, R2}
        BX      LR
        ALIGN

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
