.model small
.stack 100h
.data
    MSG_IN  DB 0DH, 0AH, 'Please input a Dec number (0-255): $'
    MSG_OUT DB 0DH, 0AH, 'The Hex number: $'
    DEC_VAL DB 0
.code
START:
    MOV AX, @DATA
    MOV DS, AX

    LEA DX, MSG_IN
    MOV AH, 09H
    INT 21H

    ; 读入十进制数，累加到 BL
    MOV BL, 0           ; BL = 累加值

READ_LOOP:
    MOV AH, 01H
    INT 21H
    CMP AL, 0DH
    JE  READ_DONE       ; 回车结束

    SUB AL, '0'         ; 转成数字
    MOV CL, AL          ; CL = 当前位数字

    ; BL = BL * 10 + CL
    MOV AL, BL
    MOV AH, 0
    MOV DL, 10
    MUL DL              ; AX = BL * 10
    ADD AL, CL          ; 加当前位
    MOV BL, AL
    JMP READ_LOOP

READ_DONE:
    MOV DEC_VAL, BL

    ; 输出提示
    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H

    ; 取数值
    MOV AL, DEC_VAL
    MOV AH, 0

    ; 除以 16，得到高位和低位
    MOV BL, 16
    DIV BL              ; AL = 高位(商), AH = 低位(余数)
    MOV CL, AL          ; CL = 高位
    MOV CH, AH          ; CH = 低位

    ; 输出高位
    MOV AL, CL
    CALL HEX_TO_CHAR
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    ; 输出低位
    MOV AL, CH
    CALL HEX_TO_CHAR
    MOV DL, AL
    MOV AH, 02H
    INT 21H

    MOV AH, 4CH
    INT 21H

; ========================================================
; 子程序：数值(0-15) -> ASCII 字符
; 输入：AL = 数值
; 输出：AL = ASCII
; ========================================================
HEX_TO_CHAR PROC
    CMP AL, 9
    JBE IS_NUM
    ADD AL, 'A' - 10    ; 10~15 → 'A'~'F'
    RET
IS_NUM:
    ADD AL, '0'         ; 0~9 → '0'~'9'
    RET
HEX_TO_CHAR ENDP

END START