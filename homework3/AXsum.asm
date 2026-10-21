.model small
.stack 100h
.code
START:
    MOV AX, @DATA
    MOV DS, AX

    ; ---- 求和：1+2+...+100 ----
    MOV AX, 0           ; AX = 累加和
    MOV CX, 100         ; 循环 100 次
    MOV BX, 1           ; BX = 当前加数
SUM_LOOP:
    ADD AX, BX
    INC BX
    LOOP SUM_LOOP       ; 循环结束后 AX = 5050

    ; ---- 输出 AX 中的十进制数 ----
    CALL PRINT_DEC

    MOV AH, 4CH
    INT 21H

; ========================================================
; 子程序：把 AX 中的无符号数按十进制输出
; ========================================================
PRINT_DEC PROC
    MOV CX, 0           ; CX 记录压栈的位数
    MOV BX, 10
DIV_LOOP:
    MOV DX, 0
    DIV BX              ; AX=商, DX=余数
    PUSH DX             ; 余数入栈
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