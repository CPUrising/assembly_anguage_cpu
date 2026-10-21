.model small
.stack 100h
.data
.code
START:
    MOV AX, @DATA
    MOV DS, AX

    MOV BL, 61H       ; 当前字符 'a'

    MOV SI, 2         ; 外层计数器：2 行

OUTER_LOOP:
    MOV DI, 13        ; 内层计数器：13 个字符

INNER_LOOP:
    ; 1. 打印字符
    MOV DL, BL
    MOV AH, 02H
    INT 21H

    ; 2. 打印空格
    MOV DL, ' '
    MOV AH, 02H
    INT 21H

    ; 3. 字符递增
    INC BL

    ; 4. 内层循环控制：DI 减 1，如果不为 0 就跳转
    DEC DI
    CMP DI, 0
    JNZ INNER_LOOP    ; 条件跳转：如果不为 0，跳回内层循环

    ; 5. 换行
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H

    ; 6. 外层循环控制
    DEC SI
    CMP SI, 0
    JNZ OUTER_LOOP    ; 条件跳转：如果不为 0，跳回外层循环

    ; 结束
    MOV AX, 4C00H
    INT 21H
END START