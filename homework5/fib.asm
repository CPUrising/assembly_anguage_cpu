; ============================================================
; 作业题目 5：递归调用
; 求斐波那契数列第 n 项：F(0)=0, F(1)=1, F(n)=F(n-1)+F(n-2)
; 1) 从键盘输入 n（1 <= n <= 100）
; 2) 递归实现，过程中使用寄存器
; 3) 结果按十进制输出（使用大数存储，可正确输出 F(100)）
; 4) 通过记忆化避免朴素递归的指数级重复计算
; ============================================================
.model small
; 栈空间：递归深度最大 100 层，每层约 16 字节（返回地址、参数、
; 保护的 6 个寄存器），合计约 1.6KB；再预留 DOS 与中断使用的空间，
; 取 4KB（1000H）足以避免 Stack Overflow。
.stack 1000h

.data
    MSG_IN   DB 0DH, 0AH, 'Please input n (1-100): $'
    MSG_OUT  DB 0DH, 0AH, 'The Fibonacci number is: $'
    MSG_ERR  DB 0DH, 0AH, 'Invalid input!$'
    CRLF     DB 0DH, 0AH, '$'

    ; FIB_LEN[n] = 第 n 项十进制位数，0 表示尚未计算（记忆化标记）
    FIB_LEN  DB 101 DUP(0)
    ; FIB_BUF 中每项占 24 字节：十进制数字，低位在前，每字节存 0~9
    ; 第 n 项从 FIB_BUF + n*24 开始；F(100) 共 21 位，24 字节足够
    FIB_BUF  DB 2424 DUP(0)

.code
START:
    MOV AX, @DATA
    MOV DS, AX

    ; ---- 输出提示 ----
    LEA DX, MSG_IN
    MOV AH, 09H
    INT 21H

    ; ---- 从键盘读入十进制数 n，结果放在 BX ----
    MOV BX, 0
READ_LOOP:
    MOV AH, 01H
    INT 21H
    CMP AL, 0DH             ; 回车结束输入
    JE  READ_DONE
    CMP AL, '0'
    JB  BAD_INPUT
    CMP AL, '9'
    JA  BAD_INPUT

    SUB AL, '0'
    MOV CL, AL
    MOV AX, BX
    MOV DX, 10
    MUL DX                  ; AX = BX * 10
    MOV BX, AX
    MOV AL, CL
    MOV AH, 0
    ADD BX, AX              ; BX = BX * 10 + 当前位
    JMP READ_LOOP

READ_DONE:
    CMP BX, 1
    JB  BAD_INPUT
    CMP BX, 100
    JA  BAD_INPUT

    ; ---- 输出提示 ----
    LEA DX, MSG_OUT
    MOV AH, 09H
    INT 21H

    ; ---- 调用递归过程求 F(n) ----
    PUSH BX                 ; 参数入栈
    CALL FIB
    ADD SP, 2               ; 调用者清理参数

    ; ---- 输出 FIB_BUF[n] 中的十进制结果（高位在前） ----
    MOV AX, BX
    MOV CX, 24
    MUL CX                  ; AX = n * 24
    MOV SI, AX
    MOV CL, FIB_LEN[BX]     ; CL = 位数
    MOV CH, 0
    ADD SI, CX
    DEC SI                  ; SI 指向最高位数字
PRINT_LOOP:
    MOV DL, FIB_BUF[SI]
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    DEC SI
    LOOP PRINT_LOOP

    LEA DX, CRLF
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H

BAD_INPUT:
    LEA DX, MSG_ERR
    MOV AH, 09H
    INT 21H
    MOV AH, 4CH
    INT 21H

; ============================================================
; 递归过程 FIB
; 入口参数：[BP+4] = n
; 结果写入 FIB_BUF 的第 n 项，位数写入 FIB_LEN[n]
; 说明：FIB_LEN[n] 非 0 时直接返回，避免重复递归（记忆化）
; ============================================================
FIB PROC
    PUSH BP
    MOV  BP, SP
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

    MOV BX, [BP+4]          ; BX = n
    CMP FIB_LEN[BX], 0
    JE  FIB_CALC
    JMP FIB_DONE            ; 已计算过，直接返回
FIB_CALC:

    CMP BX, 1
    JA  FIB_RECURSE

    ; ---- 递归出口：n = 0 时结果为 0，n = 1 时结果为 1 ----
    MOV AX, BX
    MOV DX, 24
    MUL DX
    MOV SI, AX
    MOV FIB_BUF[SI], BL
    MOV FIB_LEN[BX], 1
    JMP FIB_DONE

FIB_RECURSE:
    ; ---- 递归求 F(n-1) ----
    MOV AX, BX
    DEC AX
    PUSH AX
    CALL FIB
    ADD SP, 2

    ; ---- 递归求 F(n-2) ----
    MOV AX, BX
    SUB AX, 2
    PUSH AX
    CALL FIB
    ADD SP, 2

    ; ---- 计算偏移：SI 指向第 n 项，DI 指向第 n-1 项 ----
    MOV AX, BX
    MOV DX, 24
    MUL DX                  ; AX = n * 24
    MOV SI, AX
    MOV DI, AX
    SUB DI, 24              ; 第 n-2 项为 DI-24

    ; ---- 取两个加数的位数 ----
    MOV AL, FIB_LEN[BX-1]
    MOV CL, AL              ; CL = F(n-1) 的位数
    MOV AL, FIB_LEN[BX-2]
    MOV DL, AL              ; DL = F(n-2) 的位数

    MOV CH, CL
    CMP CH, DL
    JAE FIB_LEN_OK
    MOV CH, DL              ; CH = 两个位数中的较大者
FIB_LEN_OK:

    ; ---- 按十进制逐位相加，低位在前，DH 保存进位 ----
    MOV BX, 0               ; BX = 当前位下标
    XOR DH, DH              ; 进位清零
FIB_ADD_LOOP:
    CMP BL, CH
    JAE FIB_ADD_DONE

    MOV AL, 0
    CMP BL, CL
    JAE FIB_SKIP_D1
    MOV AL, FIB_BUF[DI+BX]  ; 第 n-1 项的第 i 位
FIB_SKIP_D1:

    MOV AH, 0
    CMP BL, DL
    JAE FIB_SKIP_D2
    MOV AH, FIB_BUF[DI+BX-24] ; 第 n-2 项的第 i 位
FIB_SKIP_D2:

    ADD AL, AH
    ADD AL, DH
    CMP AL, 10
    JB  FIB_NO_CARRY
    SUB AL, 10
    MOV DH, 1
    JMP FIB_STORE_DIGIT
FIB_NO_CARRY:
    XOR DH, DH
FIB_STORE_DIGIT:
    MOV FIB_BUF[SI+BX], AL
    INC BX
    JMP FIB_ADD_LOOP

FIB_ADD_DONE:
    MOV AL, CH              ; 结果位数先取较大位数
    CMP DH, 0
    JE  FIB_SAVE_LEN
    MOV FIB_BUF[SI+BX], 1   ; 最高位还有进位（此时 BX = CH）
    INC AL
FIB_SAVE_LEN:
    MOV BX, [BP+4]          ; 恢复 n
    MOV FIB_LEN[BX], AL

FIB_DONE:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP BP
    RET
FIB ENDP

END START
