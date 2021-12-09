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
;* -- Description : Common procedures
;* -- 
;* -- $Id: utils.s 1244 2015-02-03 10:12:17Z ruan $
;* ----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; -- Constants
; -----------------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB
    

; -----------------------------------------------------------------------------
; Set bit of a register (SFR, word -> 32 bit)
; - Address of register in R6
; - Bits to be set in R7
; -----------------------------------------------------------------------------
set_sfr         PROC
                EXPORT set_sfr
                       
                PUSH {R0, LR}
                
                LDR  R0, [R6]               ; Load register value to R0
                ORRS R0, R0, R7             ; Set bits
                STR  R0, [R6]               ; Store new register value

                POP  {R0, PC}               ; Restore registers and return
                
                ENDP
                    
                    
; -----------------------------------------------------------------------------
; Clear all bits of a register (SFR, word -> 32 bit)
; - Address of register in R6
; - Bits to be cleared in R7
; -----------------------------------------------------------------------------
clear_sfr       PROC
                EXPORT clear_sfr
                    
                PUSH {R0-R1, LR}
                
                LDR  R0, [R6]               ; Load register value to R0
                BICS R0, R0, R7             ; Clear bits
                STR  R0, [R6]               ; Store new register value

                POP  {R0-R1, PC}           ; Restore registers and return

                ENDP


; -----------------------------------------------------------------------------
; -- End of file
; -----------------------------------------------------------------------------
                END

