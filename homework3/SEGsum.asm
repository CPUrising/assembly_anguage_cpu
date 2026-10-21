.model small
.stack 100h
.data
    SUM_VAL DW 0        ; 16 位变量，存和
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

    MOV SUM_VAL, AX     ; 结果存到数据段

    MOV AX, SUM_VAL     ; 从数据段取回
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