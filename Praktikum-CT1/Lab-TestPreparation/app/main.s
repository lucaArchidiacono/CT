        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
MY_CONST                EQU     0x12
ADDR_DIP_SWITCH_31_0    EQU     0x60000200
ADDR_LED_31_0           EQU     0x60000100

; ------------------------------------------------------------------
; -- Variables
; ------------------------------------------------------------------
                AREA   progData, DATA, READWRITE
Long1           DCD       0; low  word
                DCD       0; high word
Long2           DCD       0; low  word
                DCD       0; high word
Long3           DCD       0; low  word
                DCD       0; high word
				ALIGN

; ------------------------------------------------------------------
; -- Constants
; ------------------------------------------------------------------
				AREA MyAsmConst, DATA, READONLY
				ALIGN

; ------------------------------------------------------------------
; -- MyCode
; ------------------------------------------------------------------
        AREA MyCode, CODE, READONLY

main    PROC
        EXPORT main
        LDR R0,=Long1
		LDM R0!,{R1-R4}
		ADDS R1,R1,R3
		ADCS R2,R2,R4
		LDR R0,=Long3
		STM R0!,{R1,R2}
		

        B       main
        
        ALIGN

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
