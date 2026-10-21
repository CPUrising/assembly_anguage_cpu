.model small
.stack 100h
.data
    ; 无需预定义字符串，直接计算 ASCII 码输出
.code
START:
    MOV AX, @DATA
    MOV DS, AX

    ; 初始字符 'a' 的 ASCII 码是 61H
    MOV BL, 61H       ; 用 BL 寄存器存放当前要打印的字符

    MOV CX, 2         ; 外层循环：共 2 行

OUTER_LOOP:
    PUSH CX           ; 【关键】保存外层循环的 CX 值到栈中

    MOV CX, 13        ; 内层循环：每行 13 个字符

INNER_LOOP:
    ; 1. 打印当前字符
    MOV DL, BL        ; 把字符放入 DL
    MOV AH, 02H       ; DOS 2号功能：显示单个字符
    INT 21H

    ; 2. 打印一个空格，让字符之间隔开（参照你的示例图）
    MOV DL, ' '
    MOV AH, 02H
    INT 21H

    ; 3. 字符递增，准备打印下一个
    INC BL

    ; 4. 内层循环控制
    LOOP INNER_LOOP   ; CX 减 1，如果不为 0 就跳回 INNER_LOOP

    ; 5. 内层循环结束，打印回车换行，准备开始下一行
    MOV DL, 0DH       ; 回车
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH       ; 换行
    MOV AH, 02H
    INT 21H

    POP CX            ; 【关键】从栈中恢复外层循环的 CX 值
    LOOP OUTER_LOOP   ; 外层循环控制

    ; 程序结束
    MOV AX, 4C00H
    INT 21H
END START