;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 7
;* -- Description : Control structures
;* -- 
;* -- $Id: main.s 3748 2016-10-31 13:26:44Z kesr $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB

ADDR_LED_15_0           EQU     0x60000100
ADDR_LED_31_16          EQU     0x60000102
ADDR_7_SEG_BIN_DS1_0    EQU     0x60000114
ADDR_DIP_SWITCH_15_0    EQU     0x60000200
ADDR_HEX_SWITCH         EQU     0x60000211

NR_CASES        		EQU     0xB
UPPER_BIT_MASK			EQU		0xFF00
LOWER_BIT_MASK			EQU		0x00FF
OPERATION_BIT_MASK      EQU     0x000F

jump_table      ; ordered table containing the labels of all cases
                ; STUDENTS: To be programmed 
						DCD		case_dark
						DCD		case_add
						DCD		case_subtract
						DCD		case_multiply
						DCD		case_and
						DCD		case_or
						DCD		case_xor
						DCD		case_not
						DCD		case_nand
						DCD		case_nor
						DCD		case_xnor
                ; END: To be programmed
    

; -------------------------------------------------------------------
; -- Main
; -------------------------------------------------------------------   
                        
main            PROC
                EXPORT main
                
read_dipsw      ; Read operands into R0 and R1 and display on LEDs
                ; STUDENTS: To be programmed
				LDR		R2, =ADDR_DIP_SWITCH_15_0
				LDR		R0, [R2]
				LDR		R1, [R2]
				
				LDR		R2, =ADDR_LED_15_0
				STR		R0, [R2]
				
				LDR		R3, =UPPER_BIT_MASK
				ANDS	R0, R0, R3
				LSRS	R0, R0, #8						; 8 bit shifting to the right so we can use it for the operation with the other operand R1
				LDR		R3, =LOWER_BIT_MASK
				ANDS	R1, R1, R3
				
                ; END: To be programmed
                    
read_hexsw      ; Read operation into R2 and display on 7seg.
                ; STUDENTS: To be programmed
				LDR		R3, =ADDR_HEX_SWITCH
				LDRB	R3, [R3, #0]
				LDR		R7, =OPERATION_BIT_MASK				; Because register bits [7:4] are read as '1' and therefore need to be masked.
				ANDS	R3, R3, R7							; Apply bitmask to remove unexpected values on upper bits
				
				LDR		R4, =ADDR_7_SEG_BIN_DS1_0
				STRB	R3, [R4]

                ; END: To be programmed
                
case_switch     ; Implement switch statement as shown on lecture slide
                ; STUDENTS: To be programmed
				
				CMP		R3, #NR_CASES					; Compare hex switch value to cases
				BHS		case_default					; When "higher or same" then go inside "case_default". In that case we show all 16 bright.
				
				LSLS	R3, #2							; Multiply (via bitshift) R3 to account for jump table item size to get the correct offset size
				LDR		R7, =jump_table					; Load address of jump table
				LDR		R7, [R7, R3]					; Get value from jump table by using the calculated offset
				BX		R7								; Go to case defined in jump table at the index R7
		
                ; END: To be programmed


; Add the code for the individual cases below
; - operand 1 in R0
; - operand 2 in R1
; - result in R0

case_dark       
                LDR  R0, =0
                B    display_result  

case_add        
                ADDS R0, R0, R1
                B    display_result

; STUDENTS: To be programmed

case_subtract        
                SUBS R0, R0, R1								; Apply subtraction operation to operand 1 & 2
                B    display_result
				
case_multiply        
                MULS R0, R1, R0								; Apply multiplz operation to operand 1 & 2
                B    display_result
				
case_and        
                ANDS R0, R0, R1								; Apply and operation to operand 1 & 2
                B    display_result
				
case_or        
                ORRS R0, R0, R1								; Apply or operation to operand 1 & 2
                B    display_result
				
case_xor        
                EORS R0, R0, R1								; Apply xor operation to operand 1 & 2
                B    display_result
				
case_not        
                MVNS R0, R0									; Apply not operation to operand 1
                B    display_result
				
case_nand        
                ANDS R0, R0, R1								; Apply and operation to operand 1 & 2
                MVNS R0, R0									; Apply not operation to result
                B    display_result
				
case_nor        
                ORRS R0, R0, R1								; Apply or operation to operand 1 & 2
                MVNS R0, R0									; Apply not operation to result
                B    display_result
				
case_xnor        
                EORS R0, R0, R1								; Apply xor operation to operand 1 & 2
                MVNS R0, R0									; Apply not operation to result
                B    display_result

case_default
                LDR  R0, =0xFFFF							; Set result to 0xFFFF to turn on all leds
                B    display_result


; END: To be programmed


display_result  ; Display result on LEDs
                ; STUDENTS: To be programmed

				LDR		R7, =ADDR_LED_31_16					; Load address of led 31-16
				STR 	R0, [R7]							; Store result in address of leds 31-16

                ; END: To be programmed

                B    read_dipsw
                
                ALIGN
                ENDP

; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

