; LUONG THANH VY (2151280)
ORG 100h
a             DW 0            
b             DW 0                
result_quo    DW 0   
result_remain DW 0   
     
          
; Solving euation:   ax + b = 0
; Prompt two 1-digit number in range [-9,9]:  a, b
LEA   DX, [intro_msg]                                  
CALL  Print_string   ; Print introduction message

LEA   DX, [prompt_a]                                  
CALL  Print_string   ; Print prompt message
CALL  Enter_input    ; Read input from keyboard to CX
MOV   [a], CX 

LEA   DX, [prompt_b]
CALL  Print_string
CALL  Enter_input   
MOV   [b], CX   


; Calculate -b/a
MOV   AX, [b]       ;  AL =  AX = b
NEG   AX            ; -AL = -AX = -b
MOV   BX, [a]       ;  BL =  BX = a
IDIV  BL            ; -AL/BL = -AX/BL = -b/a
                    ; AL = Quotient   (AL < 10) 
                    ; AH = Remainder  (AH < 10)   
MOV   CH, AL                ; CX = {AL, 0x0000}
SAR   CX, 8                 ; Right Shift Arithmetic, sign-extend AL into CX
MOV   [result_quo],    CX   ; Store the result quotient 

MOV   CH, AH                ; CX = {AH, 0x0000}
SAR   CX, 8                 ; Right Shift Arithmetic, sign-extend AH into CX
MOV   [result_remain], CX   ; Store the result remainder

MOV   CX, [result_quo]
LEA   DX, result_quo_msg    ; Load address of result message
CALL  Print_string
CALL  Output

MOV   CX, [result_remain]
LEA   DX, result_remain_msg ; Load address of result message
CALL  Print_string
CALL  Output
HLT                         ; HALT  
     
;---------------------------------------------------------------------------     
; Subroutine for display interrupt
Print_string:
    MOV AH, 09h     ; Function that display string
    INT 21h         ; Interrupt
    RET

;---------------------------------------------------------------------------          
; Subroutine for entering multiple digit input
Enter_input:  
    MOV CX, 0            ; Initializae CX, AX, SI
    MOV AX, 0          
    MOV SI, 0

    ; Read the first character to check for sign
    MOV AH, 01h          ; Function to read character
    INT 21h              ; Interrupt    
    CMP AL, '-'         
    JE SetNegative       ; If input negative sign, set the sign flag and read another character
    CMP AL, '+'         
    JE Read_digit        ; If input plus sign, read another character
    JMP CheckDigit       ; If neither, check if that character is valid or not

SetNegative:
    MOV SI, 1            ; Set SI = 1 to indicate negative number
Read_digit:
    MOV AH, 01h          ; Function to read next character
    INT 21h              ; Interrupt    

CheckDigit:
    CMP AL, '0'          ; Valid: '0' <= ASCII <= '9;
    JL Invalid_input     
    CMP AL, '9'         
    JG Invalid_input     
    SUB AL, 48           ; Convert ASCII to numeric value
    MOV CL, AL           

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
; Subroutine that print out value in CX
Output: 
    PUSH CX               ; Save the original CX 
    CALL Start_Output     ; Finally, restore original CX when returned  
    POP  CX
    RET 
                      
Start_Output:
    CMP CX, 0             ; Check: 0h - CX
    JGE Print_Num         ; If CX < 0, print the negative sign
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

    ADD DL, 48            ; Convert remainder to ASCII
    MOV AH, 02h           ; Function that print a character
    INT 21h               ; Print the digit
    RET                   ; (Stack) Return to "POP DX" then back to CALL Start_Output 

 ;---------------------------------------------------------------------------
    

; 0Dh: Carriage return (moves the cursor to the beginning of the current line).
; 0Ah: Line feed (moves the cursor to the next line).
; Combine: 0Dh + 0Ah = newline 
intro_msg          DB 'Solve first degreee equation:   ax + b = 0 $'
prompt_a           DB 0Dh, 0Ah, 'Enter value for a in range [-9,9]: $'
prompt_b           DB 0Dh, 0Ah, 'Enter value for b in range [-9,9]: $'     
result_quo_msg     DB 0Dh, 0Ah, 'The Quotient of -b/a is: $' 
result_remain_msg  DB 0Dh, 0Ah, 'The Remainder of -b/a is: $'     

invalid_msg        DB 0Dh, 0Ah
                   DB 'Invalid input, only one digit and numberic character is allowed.'
                   DB 0Dh, 0Ah
                   DB 'Re-enter input: $'


              
END
