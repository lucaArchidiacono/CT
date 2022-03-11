;* ----------------------------------------------------------------------------
;* --  _____       ______  _____                                              -
;* -- |_   _|     |  ____|/ ____|                                             -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems              -
;* --   | | | '_ \|  __|  \___ \   Zurich University of                       -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                           -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland               -
;* ----------------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 12
;* -- Description : Reading the User-Button as Interrupt source
;* -- 				 
;* -- $Id: main.s 5071 2020-05-08 11:54:33Z akdi $
;* -- 		
;* ----------------------------------------------------------------------------


                IMPORT init_measurement
                IMPORT clear_IRQ_EXTI0
                IMPORT clear_IRQ_TIM2

; -----------------------------------------------------------------------------
; -- Constants
; -----------------------------------------------------------------------------

                AREA myCode, CODE, READONLY

                THUMB

REG_GPIOA_IDR       EQU  0x40020010
LED_15_0		    EQU  0x60000100
LED_16_31			EQU  0x60000102
REG_CT_7SEG         EQU  0x60000114
REG_SETENA0         EQU  0xe000e100


; -----------------------------------------------------------------------------
; -- Main
; -----------------------------------------------------------------------------             
main            PROC
                EXPORT main


                BL   init_measurement    

                ; Configure NVIC (enable interrupt channel)
                ; STUDENTS: To be programmed
				LDR		R0, =REG_SETENA0
				; check this number out for TIM2_IRQHandler
				LDR 	R1, =0x10000040
				STR		R1, [R0]
                ; END: To be programmed 

                ; Initialize variables
                ; STUDENTS: To be programmed	


                ; END: To be programmed
				
loop
                ; Output counter on 7-seg
				; STUDENTS: To be programmed
				LDR		R0, =counter
				LDR		R1, [R0]
				LDR		R0, =REG_CT_7SEG
				STR		R1, [R0]
				
                ; END: To be programmed

                B    loop

				
                ENDP

 
; -----------------------------------------------------------------------------
; Handler for EXTI0 interrupt
; -----------------------------------------------------------------------------
                 ; STUDENTS: To be programmed
EXTI0_IRQHandler	PROC
					EXPORT	EXTI0_IRQHandler

					PUSH	{LR}
				
					LDR		R0, =temp
					LDR		R1, [R0]
					ADDS	R1, 0x01
					STR		R1, [R0]
					BL		clear_IRQ_EXTI0
				
					POP		{PC}
					ENDP

                 ; END: To be programmed

 
; -----------------------------------------------------------------------------                   
; Handler for TIM2 interrupt
; -----------------------------------------------------------------------------
				; STUDENTS: To be programmed
TIM2_IRQHandler 	PROC
					EXPORT TIM2_IRQHandler
					
					PUSH	{LR}
				
					LDR		R0, =LED_16_31
					LDR		R1, [R0]
					LDR		R2, =0xFFFF
					; exclusie OR wird gemacht damit man einen 2sek intervall auf der LED simulieren kann
					EORS 	R1, R1, R2
					STR		R1, [R0]
				
					; hier wird die value vom counter auf die temp variable gespeichert, weil alle 2 sek der counter wieder auf 0 gesetzt wird
					LDR		R0, =counter
					LDR		R1, =temp
					LDR		R3, [R0]
					; damit der counter auf 0 gesetzt wird
					LDR		R2, =0x00
					; counter wert wird in die temporaere variable gespeichert
					STR		R3, [R1]
					STR		R2, [R0]
				
					BL		clear_IRQ_TIM2
			
					POP		{PC}
				
					ENDP

                ; END: To be programmed
                ALIGN

; -----------------------------------------------------------------------------
; -- Variables
; -----------------------------------------------------------------------------

                AREA myVars, DATA, READWRITE

                ; STUDENTS: To be programmed
counter			DCD 0x00000000
temp			DCD 0x00000000
                ; END: To be programmed


; -----------------------------------------------------------------------------
; -- End of file
; -----------------------------------------------------------------------------
                END
