.model small
.stack 100h

.data
    MSG_TITLE  DB 0DH, 0AH, 'x y     error', 0DH, 0AH, '$'
    MSG_OK     DB 0DH, 0AH, 'accomplish!', 0DH, 0AH, '$'
    MSG_SPACE  DB '        ', '$'          ; 用于对齐的空格

    ; 9*9 乘法表数据（按行存放，每行 9 个字节）
    ; 其中故意设错：第1行第2个、第2行第3个、第4行第5个、第6行第6个、第8行第7个
    TABLE DB  7,2,3,4,5,6,7,8,9
          DB  2,4,7,8,10,12,14,16,18
          DB  3,6,9,12,15,18,21,24,27
          DB  4,8,12,16,7,24,28,32,36
          DB  5,10,15,20,25,30,35,40,45
          DB  6,12,18,24,30,7,42,48,54
          DB  7,14,21,28,35,42,49,56,63
          DB  8,16,24,32,40,48,56,7,72
          DB  9,18,27,36,45,54,63,72,81

.code
START:
    MOV AX, @DATA
    MOV DS, AX          ; 初始化数据段

    ; 输出标题
    LEA DX, MSG_TITLE
    MOV AH, 09H
    INT 21H

    ; 双循环：i 从 1 到 9，j 从 1 到 9
    MOV CX, 1           ; CX = i（行号，也对应乘法表第一个乘数）

OUTER_LOOP:
    MOV BX, 1           ; BX = j（列号，也对应第二个乘数）

INNER_LOOP:
    ; 调用检查过程：传递 i 在 CX，j 在 BX
    CALL CHECK_ITEM

    INC BX              ; j++
    CMP BX, 9           ; 内层到 9 为止
    JLE INNER_LOOP

    INC CX              ; i++
    CMP CX, 9           ; 外层到 9 为止
    JLE OUTER_LOOP

    ; 全部检查完成，输出 accomplish!
    LEA DX, MSG_OK
    MOV AH, 09H
    INT 21H

    ; 程序结束
    MOV AH, 4CH
    INT 21H

; ========================================================
; 子程序：CHECK_ITEM
; 功能：检查 TABLE 中第 i 行第 j 列的数据是否正确
;       正确：TABLE[(i-1)*9 + (j-1)] == i*j
;       错误：输出 "i j     error"
; 输入：CX = i (1~9)，BX = j (1~9)
; ========================================================
CHECK_ITEM PROC
    ; 1. 保护现场
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    ; 2. 计算表项地址：SI = (i-1)*9 + (j-1)
    ;    注意：CX 和 BX 从 1 开始，先减 1
    MOV AX, CX
    DEC AX              ; AX = i - 1
    MOV DX, 9
    MUL DX              ; AX = (i-1)*9
    MOV SI, AX

    MOV AX, BX
    DEC AX              ; AX = j - 1
    ADD SI, AX          ; SI = (i-1)*9 + (j-1)

    ; 3. 取出表中的值到 AL
    MOV AL, TABLE[SI]   ; AL = 表项数据

    ; 4. 计算正确值：i * j
    MOV DL, CL          ; DL = i
    MOV DH, BL          ; DH = j
    MOV AL, DL
    MUL DH              ; AX = i * j（结果最大 81，AH=0）

    ; 5. 比较：表项值在 TABLE[SI]，正确值在 AL
    ;    注意：MUL 后 AL 被覆盖，需要重新取表项值比较
    MOV DL, TABLE[SI]   ; DL = 表项数据
    CMP DL, AL          ; 比较表项与正确结果
    JE  CHECK_DONE      ; 相等则正确，直接返回

    ; 6. 不相等：输出 "i j     error"
    ; 输出 i
    MOV DL, CL
    ADD DL, '0'
    MOV AH, 02H
    INT 21H

    ; 输出空格
    MOV DL, ' '
    MOV AH, 02H
    INT 21H

    ; 输出 j
    MOV DL, BL
    ADD DL, '0'
    MOV AH, 02H
    INT 21H

    ; 输出若干空格对齐（与标题 "x y     error" 对齐）
    LEA DX, MSG_SPACE
    MOV AH, 09H
    INT 21H

    ; 输出 "error"
    MOV DL, 'e'
    MOV AH, 02H
    INT 21H
    MOV DL, 'r'
    MOV AH, 02H
    INT 21H
    MOV DL, 'r'
    MOV AH, 02H
    INT 21H
    MOV DL, 'o'
    MOV AH, 02H
    INT 21H
    MOV DL, 'r'
    MOV AH, 02H
    INT 21H

    ; 换行
    LEA DX, MSG_NEXT
    MOV AH, 09H
    INT 21H

CHECK_DONE:
    ; 7. 恢复现场
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
CHECK_ITEM ENDP

; 换行字符串（放在代码段末尾或数据段均可，这里放在数据段更规范）
.data
    MSG_NEXT DB 0DH, 0AH, '$'

END START