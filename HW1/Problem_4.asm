; Luong Thanh Vy (2151280)
ORG 100h  

i DW 0    ; int i
S DW 0    ; int S

MAIN: 
      CALL For_Loop
      HLT            ; Halt


 
; For ( CX = 0; CX < 10; CX++ )   
For_loop:
    PUSH AX          ; Save registers before using them
    PUSH BX         
    PUSH CX 
    MOV  CX, 0       ; Clear CX, For_Loop counter  
    MOV  AX, 0       ; Clear AX      
    
Run_loop:    
    MOV  BX, CX      ; BX = CX
    SUB  BX, 10      ; BX = BX - 10
    JGE  Break       ; BX >= 10 ? EXIT
        
    ADD  AX, CX      ; S = S + i  
    ADD  CX, 1       ; CX++
    MOV  [S], AX     ; S variable always update each iteration   
    MOV  [i], CX     ; i variable always update each iteration    
    JMP  Run_loop    ; Next iteration

Break: 
    POP CX           ; Restore registers for Main program
    POP BX 
    POP AX
    RET

END




