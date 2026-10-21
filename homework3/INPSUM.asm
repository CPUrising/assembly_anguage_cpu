.model small
.stack 100h
.data
    MSG_IN  DB 0DH, 0AH, 'Please input N (1-100): $'
    MSG_OUT DB 0DH, 0AH, 'The sum is: $'
.code
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, MSG_IN
    MOV AH, 09H
    INT 21H

    ; ---- 读入十进制数 N，累加到 BX ----
    MOV BX, 0           ; BX = N
READ_LOOP:
    MOV AH, 01H
    INT 21H
    CMP AL, 0DH
    JE  READ_DONE

    SUB AL, '0'
    MOV CL, AL
    MOV AX, BX
    MOV DX, 10
    MUL DX              ; AX = BX * 10
    MOV BX, AX
    MOV AL, CL
    MOV AH, 0
    ADD BX, AX          ; BX = BX*10 + 当前位
    JMP READ_LOOP

READ_DONE:
    ; ---- 求和 1+2+...+BX ----
    MOV AX, 0           ; AX = 和
    MOV CX, BX          ; 循环次数 = N
    MOV BX, 1           ; 当前加数
SUM_LOOP:
    ADD AX, BX
    INC BX
    LOOP SUM_LOOP

    ; ---- 输出提示 ----
    MOV BX, AX          ; 暂存和到 BX
    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H

    MOV AX, BX          ; 恢复和
    CALL PRINT_DEC

    MOV AH, 4CH
    INT 21H

; ========================================================
; 子程序：把 AX 中的无符号数按十进制输出
; ========================================================
PRINT_DEC PROC
    MOV CX, 0
    MOV BX, 10
DIV_LOOP:
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DIV_LOOP
PRINT_LOOP:
    POP DX
    ADD DL, 30H
    MOV AH, 02H
    INT 21H
    LOOP PRINT_LOOP
    RET
PRINT_DEC ENDP

END START