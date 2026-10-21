.model small
.stack 100h
.code
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV AX, 0
    MOV CX, 100
    MOV BX, 1
SUM_LOOP:
    ADD AX, BX
    INC BX
    LOOP SUM_LOOP

    PUSH AX             ; 结果压栈
    POP AX              ; 再取回（演示用）
    CALL PRINT_DEC

    MOV AH, 4CH
    INT 21H

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