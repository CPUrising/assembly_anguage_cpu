.model small
.stack 100h
.data
    MSG_TITLE DB 0DH, 0AH, 'The 9mul9 table:', 0DH, 0AH, '$'
    MSG_NEXT  DB 0DH, 0AH, '$' ; 换行符
.code
START:
    MOV AX, @DATA
    MOV DS, AX          ; 初始化段寄存器（段地址在此处设置即可）

    ; 输出标题
    LEA DX, MSG_TITLE
    MOV AH, 09H
    INT 21H

    ; 外层循环：控制行数，从 9 递减到 1
    MOV CX, 9           ; CX = 9 (外层乘数 i)

OUTER_LOOP:
    MOV BX, 1           ; BX = 1 (内层乘数 j，每次内层循环重置)

INNER_LOOP:
    ; 准备调用子程序：使用 CX 和 BX 传递参数
    ; 注意：这里不需要刻意用 SI 保存 CX，因为子程序会帮我们保护好的
    CALL PRINT_ITEM     ; 调用过程：输出 "i*j=result" 和制表符

    INC BX              ; j++
    CMP BX, CX          ; 比较 j 和 i (注意：这里的 CX 是外层乘数)
    JLE INNER_LOOP      ; 如果 j <= i，继续内层循环

    ; 内层循环结束，输出换行，开始下一行
    LEA DX, MSG_NEXT
    MOV AH, 09H
    INT 21H

    DEC CX              ; 外层循环 i--
    JNZ OUTER_LOOP      ; 如果 CX != 0，继续外层循环

    ; 程序结束
    MOV AH, 4CH
    INT 21H

; ========================================================
; 子程序：PRINT_ITEM
; 功能：输出乘法表达式及结果，格式如 "9*1=9    "
; 输入：CX = 乘数 i (外层), BX = 乘数 j (内层)
; ========================================================
PRINT_ITEM PROC
    ; 1. 保护现场（入栈）—— 掌握寄存器在过程调用前后的保存和恢复
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    ; === 因为后面要用乘法指令，所以先把 i 和 j 存到安全的地方 ===
    ; 此时栈里已经保存了原始的 CX 和 BX，我们可以放心修改它们
    MOV AL, CL          ; AL = i (CX 的低 8 位)
    MOV AH, BL          ; AH = j (BX 的低 8 位)

    ; 2. 输出 i
    MOV DL, AL
    ADD DL, '0'         ; 转换为 ASCII 字符
    MOV AH, 02H
    INT 21H

    ; 3. 输出 '*'
    MOV DL, '*'
    MOV AH, 02H
    INT 21H

    ; 4. 输出 j
    ; 注意：刚才用 AH 存了 j，但是 INT 21H 会破坏 AH，所以再从堆栈里拿或者从 BL 拿
    ; 幸好 BX 也没有被破坏，直接使用 BL
    MOV DL, BL
    ADD DL, '0'
    MOV AH, 02H
    INT 21H

    ; 5. 输出 '='
    MOV DL, '='
    MOV AH, 02H
    INT 21H

    ; 6. 计算 i * j
    ; 此时我们需要恢复乘数：i 在 CL 中，j 在 BL 中
    ; MUL 指令要求操作数放在 AL 中
    MOV AL, CL          ; AL = i
    MUL BL              ; AX = AL * BL (即 i * j)。结果在 AX 中

    ; 7. 输出结果 (AX 中的数值转十进制输出)
    ; 因为最大是 81 (9*9)，所以 AX 中必定是一个 8 位以内的数 (AH=0)
    MOV CL, 10          ; 准备除以 10
    DIV CL              ; 执行除法：AL = 商(十位), AH = 余数(个位)
    
    MOV CH, AH          ; 暂存个位
    
    ; 判断十位是否为 0，如果为 0 则不输出十位
    CMP AL, 0
    JE  PRINT_ONES
    
    ; 输出十位
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02H
    INT 21H

PRINT_ONES:
    ; 输出个位
    MOV DL, CH
    ADD DL, '0'
    MOV AH, 02H
    INT 21H

    ; 8. 输出制表符 (Tab)，用于对齐
    MOV DL, 09H
    MOV AH, 02H
    INT 21H

    ; 9. 恢复现场（出栈），注意顺序与入栈完全相反
    POP DX
    POP CX
    POP BX
    POP AX

    RET
PRINT_ITEM ENDP

END START