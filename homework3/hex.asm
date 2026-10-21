.model small
.stack 100h
.data
    MSG_IN  DB 0DH, 0AH, 'Please input a Hex number:$'
    MSG_OUT DB 0DH, 0AH, 'The Dec number:$'
    HEX_VAL DB 0
.code
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, MSG_IN
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H
    CALL CHAR_TO_HEX
    MOV BL, AL

    MOV AH, 01H
    INT 21H
    CMP AL, 0DH
    JE  ONE_DIGIT

    CALL CHAR_TO_HEX
    MOV CL, AL
    MOV AL, BL
    MOV AH, 0
    MOV DL, 16
    MUL DL
    ADD AL, CL
    JMP CALC_DONE

ONE_DIGIT:
    MOV AL, BL

CALC_DONE:
    MOV HEX_VAL, AL

    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H

    ; --- 十进制输出（适配 0-255，自动去前导零） ---
    MOV AL, HEX_VAL
    MOV AH, 0
    MOV BL, 100
    DIV BL
    MOV CX, AX          ; CL=百位, CH=余数

    ; 打印百位（只有百位不为0时才打印）
    CMP CL, 0
    JE  SKIP_HUNDRED
    MOV DL, CL
    ADD DL, 30H
    MOV AH, 02H
    INT 21H
SKIP_HUNDRED:

    ; 处理十位和个位
    MOV AL, CH
    MOV AH, 0
    MOV BL, 10
    DIV BL
    MOV CX, AX          ; CL=十位, CH=个位

    ; 如果原数 >= 10，十位就打印；否则跳过十位
    CMP HEX_VAL, 10
    JB  SKIP_TEN
    MOV DL, CL
    ADD DL, 30H
    MOV AH, 02H
    INT 21H
SKIP_TEN:

    ; 个位无条件打印
    MOV DL, CH
    ADD DL, 30H
    MOV AH, 02H
    INT 21H

    MOV AH, 4CH
    INT 21H

; ========================================================
CHAR_TO_HEX PROC
    CMP AL, '9'
    JBE IS_DIGIT
    AND AL, 0DFH        ; 小写转大写
    SUB AL, 'A' - 10
    JMP DONE_CONV
IS_DIGIT:
    SUB AL, '0'
DONE_CONV:
    RET
CHAR_TO_HEX ENDP

END START