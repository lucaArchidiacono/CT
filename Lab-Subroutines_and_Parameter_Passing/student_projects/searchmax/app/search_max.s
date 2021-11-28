;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 10
;* -- Description : Search Max
;* -- 
;* -- $Id: search_max.s 879 2014-10-24 09:00:00Z muln $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
                AREA myCode, CODE, READONLY
                THUMB
                    
; STUDENTS: To be programmed

TABLE_SIZE_IN_BYTE		EQU		4
	
; END: To be programmed
; -------------------------------------------------------------------                    
; Searchmax
; - tableaddress in R0
; - table length in R1
; - result returned in R0
; -------------------------------------------------------------------   
search_max      PROC
                EXPORT search_max

                ; STUDENTS: To be programmed
				PUSH 	{ R2, R3, R4, R5, LR }
				
				; Counter fuer die Tabellenlaenge
				LDR		R2, =-1
				; Wert falls Tabellenlaenge = 0 ist
				LDR		R3, =0x80000000
				
				B		loop_cond

loop_start
				; Lade den Eintrag aus der Tabelle
				LDR 	R4, =TABLE_SIZE_IN_BYTE
				MULS 	R4, R2, R4
				LDR 	R4, [R0, R4]
				
				CMP		R4, R3
				BLT 	loop_cond
				MOVS	R3, R4

loop_cond
				ADDS	R2, #1
				CMP		R2, R1
				BNE		loop_start
				
				MOVS 	R0, R3
				POP 	{ R2, R3, R4, R5, PC }
                ; END: To be programmed
                ALIGN
                ENDP
; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

