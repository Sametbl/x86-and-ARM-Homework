; LUONG THANH VY (2151280)
org 100h


; Prompt and input x, y, z
LEA  DX, [prompt]
CALL Print_string   ; Print prompt message
CALL Enter_input    ; Read input from keyboard to CX
   

LEA  DX, [result_msg]
CALL Print_string
CALL Output

HLT                 ; HALT  
     
;---------------------------------------------------------------------------     
; Subroutine for display interrupt
Print_string:
    MOV AH, 09h     ; Function that display string
    INT 21h         ; Interrupt
    RET
;---------------------------------------------------------------------------         
;---------------------------------------------------------------------------          
; Subroutine for entering multiple digit input
Enter_input:
    MOV CX, 0            ; CX as input accumulator
    MOV BX, 0            ; BX as temp register
    MOV SI, 0            ; SI as sign flag (0 = positive, 1 = negative)

    ; Read the first character to check for sign
    MOV AH, 01h          ; Function to read character
    INT 21h              ; Interrupt    
    CMP AL, '-'          ; Check if the input is a negative sign
    JE SetNegative       ; If negative sign, set the sign flag
    CMP AL, '+'          ; Check if the input is a positive sign
    JE Read_digit        ; If positive sign, just continue reading digits
    JMP CheckDigit       ; If neither, assume it's a digit

SetNegative:
    MOV SI, 1            ; Set SI = 1 to indicate negative number
    JMP Read_digit       ; Jump to start reading digits
CheckDigit:
    CMP AL, '0'          ; Valid: '0' <= ASCII <= '9;
    JL Invalid_input     
    CMP AL, '9'         
    JG Invalid_input     
    SUB AL, 48           ; Convert ASCII to numeric value
    MOV BL, AL           

    MOV AX, CX           ; AX = CX
    MOV DX, 10           ; DX = 10 (for multiplying by 10)
    MUL DX               ; AX = AX * 10
    ADD AX, BX           ; AX = 10 * AX + BL (input digit)
    MOV CX, AX           ; CX = AX (update accumulated number)
    JMP Read_digit       ; Continue reading the next digit

Read_digit:
    MOV AH, 01h          ; Function to read next character
    INT 21h              ; Interrupt    
    CMP AL, 0Dh          ; Check for Enter (CR: ASCII 13)
    JE  CheckSign         ; If Enter is pressed, go to CheckSign
    JMP CheckDigit       ; Otherwise, check the next digit

CheckSign:
    CMP SI, 1            ; Check if SI (sign flag) is set to 1 (negative)
    JNE Exit_input       ; If not negative, exit normally
    NEG CX               ; If negative, negate the value in CX

Exit_input:
    RET                  ; Return from subroutine
 
    
    
    

    
Invalid_input:
    MOV AH, 09h          ; Function that print string
    LEA DX, invalid_msg  ; Print error message
    INT 21h               
    JMP Enter_input         
    
;---------------------------------------------------------------------------    
    
;---------------------------------------------------------------------------
; Subroutine that print out value in CX
Output: 
    PUSH CX               ; Save the original CX 
    CALL Start_Output     ; Finally, restore original CX when returned  
    POP  CX
    RET 
                      
Start_Output:
    CMP CX, 0             ; Check: 0h - CX
    JGE Print_Num         ; If CX >= 0, print the number
    MOV DL, '-'           ; Minus sign
    MOV AH, 02h           ; Function that print a character
    INT 21h               ; Interrupt
    NEG CX                ; CX = Abs(CX) = -CX
Print_Num:
    MOV  BX, 10           ; BX = 10
    MOV  AX, CX           ; because DIV instr uses AX
    MOV  DX, 0            ; clear DX to store remainder
    DIV  BX               ; AX = CX / 10 = Quotient
                          ; DX = CX % 10 = Remainder

    MOV  CX, AX
    CMP  CX, 0            ; Check: 0 - Quotient
    JE   Print_digit      ; If CX == 0 then start print the current digit
    PUSH DX               ; Else Save remainder of current digit  
    
    CALL Print_Num        ; Recursively print the quotient
    POP  DX               ; Restore the remainder (current digit)
Print_digit:
    ADD DL, 48            ; Convert remainder to ASCII
    MOV AH, 02h           ; Function that print a character
    INT 21h               ; Print the digit
    RET                   ; (Stack) Return to "POP DX" then back to CALL Start_Output 

 ;---------------------------------------------------------------------------
    

; 0Dh: Carriage return (moves the cursor to the beginning of the current line).
; 0Ah: Line feed (moves the cursor to the next line).
; Combine: 0Dh + 0Ah = newline
prompt      DB 'Enter a number: $'  
result_msg  DB 0Dh, 0Ah, 'Diplay the number on consoles: $' 
invalid_msg DB 0Dh, 0Ah
            DB 'Invalid input, only digits and signs allowed.'
            DB 0Dh, 0Ah
            DB 'Re-enter input: $'


              
END


