; ============================================================
; 作业题目 6：输出日历
; 输入年份（1900~2099）与月份（1~12），输出该月的月历
;
; 程序结构（两个代码段，段间用 CALL FAR / RET 调用）：
;   CODESEG1：主程序，负责输入、校验、组织调用
;   CODESEG2：功能过程，负责输入数字、输出数字、星期计算、
;             月天数计算、打印月历
;
; 三种参数传递方式对照：
;   1) 寄存器：READ_NUM 通过 AX 返回结果；PRINT_NUM2 通过 AX 传入
;   2) 数据段：CALC_MONTH_DAYS、PRINT_CALENDAR 直接读全局 YEAR/MONTH
;   3) 堆栈  ：CALC_FIRST_DAY 由调用者 PUSH 年、月，过程内 RET 4 清理
;
; 跳转说明：
;   条件跳转（Jcc）的位移只有 1 个字节（-128~+127），当目标太远时，
;   可以让 Jcc 跳到附近的一个标签，再用 JMP（位移 16 位）接力跳远。
;   PRINT_CALENDAR 末尾的 PC_END 处就是这种写法。
; ============================================================

STACKSG SEGMENT PARA STACK 'STACK'
        DW  256 DUP(0)          ; 512 字节栈，远过程调用与中断足够使用
STACKSG ENDS

DATASG  SEGMENT PARA PUBLIC 'DATA'
    MSG_YEAR  DB 0DH,0AH,'Please input year (1900-2099): $'
    MSG_MONTH DB 0DH,0AH,'Please input month (1-12): $'
    MSG_ERR   DB 0DH,0AH,'Invalid input!$'
    CRLF      DB 0DH,0AH,'$'
    WEEK_HEAD DB 'Su Mo Tu We Th Fr Sa$'

    ; 月份名指针表 + 12 个月份名（'$' 结尾，变长字符串）
    MON_PTR   DW M1,M2,M3,M4,M5,M6,M7,M8,M9,M10,M11,M12
    M1        DB 'January$'
    M2        DB 'February$'
    M3        DB 'March$'
    M4        DB 'April$'
    M5        DB 'May$'
    M6        DB 'June$'
    M7        DB 'July$'
    M8        DB 'August$'
    M9        DB 'September$'
    M10       DB 'October$'
    M11       DB 'November$'
    M12       DB 'December$'

    ; 平年各月天数
    DAY_TAB   DB 31,28,31,30,31,30,31,31,30,31,30,31
    ; 平年时某月之前累计的天数（用于求 1 号是星期几）
    ; 最大值 334 超过 255，因此用字（DW）存放
    ACC_TAB   DW 0,31,59,90,120,151,181,212,243,273,304,334

    ; 全局参数区：数据段传参
    YEAR      DW 0
    MONTH     DB 0
    DAYS      DB 0              ; 当月天数
    FIRST_DAY DB 0              ; 当月 1 号是星期几，0=周日
DATASG  ENDS

; ============================================================
; 功能过程段（与主程序段用段间调用联系）
; 先把过程段放在前面，主程序段中的 CALL 就是对已定义的 FAR 过程
; 的向后引用，汇编器能直接确定生成 5 字节的段间调用指令
; ============================================================
CODESEG2 SEGMENT PARA PUBLIC 'CODE'
        ASSUME CS:CODESEG2, DS:DATASG, SS:STACKSG

; ------------------------------------------------------------
; READ_NUM：从键盘读入十进制数，回车结束
; 传参方式：寄存器（结果 AX）；最多取前 4 位数字，非数字被忽略
; ------------------------------------------------------------
READ_NUM PROC FAR
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        XOR BX, BX              ; BX = 累加结果
        XOR SI, SI              ; SI = 已读入的数字位数
RN_NEXT:
        MOV AH, 01H
        INT 21H                 ; 读一个字符并回显
        CMP AL, 0DH
        JE  RN_DONE             ; 回车结束
        CMP AL, '0'
        JB  RN_NEXT
        CMP AL, '9'
        JA  RN_NEXT
        CMP SI, 4               ; 年份最多 4 位，多余位忽略
        JAE RN_NEXT
        INC SI
        SUB AL, '0'
        MOV CL, AL
        XOR CH, CH
        MOV AX, BX
        MOV DX, 10
        MUL DX                  ; AX = 结果 * 10
        MOV BX, AX
        ADD BX, CX              ; BX = 结果 * 10 + 当前位
        JMP RN_NEXT
RN_DONE:
        MOV AX, BX
        POP SI
        POP DX
        POP CX
        POP BX
        RET
READ_NUM ENDP

; ------------------------------------------------------------
; PRINT_STR：输出 DX 指向的 '$' 结尾字符串
; 传参方式：寄存器（DX = 串偏移地址）
; ------------------------------------------------------------
PRINT_STR PROC FAR
        MOV AH, 09H
        INT 21H
        RET
PRINT_STR ENDP

; ------------------------------------------------------------
; PRINT_CHAR：输出 DL 中的一个字符
; 传参方式：寄存器（DL = 字符）
; ------------------------------------------------------------
PRINT_CHAR PROC FAR
        MOV AH, 02H
        INT 21H
        RET
PRINT_CHAR ENDP

; ------------------------------------------------------------
; PRINT_YEAR：输出 AX 中的年份，固定 4 位数字
; 传参方式：寄存器（AX = 年份）
; ------------------------------------------------------------
PRINT_YEAR PROC FAR
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        MOV BX, AX              ; BX = 待输出的年
        MOV CX, 1000            ; CX = 当前位的权值
PY_LOOP:
        MOV AX, BX
        XOR DX, DX
        DIV CX                  ; AX = 当前位数字，DX = 余数
        MOV BX, DX              ; 余数留到下一位
        MOV DL, AL
        ADD DL, '0'
        MOV AH, 02H
        INT 21H
        MOV AX, CX              ; 权值除以 10
        XOR DX, DX
        MOV CX, 10
        DIV CX
        MOV CX, AX
        CMP CX, 0
        JNE PY_LOOP
        POP DX
        POP CX
        POP BX
        POP AX
        RET
PRINT_YEAR ENDP

; ------------------------------------------------------------
; PRINT_NUM2：输出 AX 中的 0~99，宽度固定 2 列（右对齐）
; 传参方式：寄存器（AX = 数值）
; ------------------------------------------------------------
PRINT_NUM2 PROC FAR
        PUSH AX
        PUSH BX
        PUSH DX
        MOV AH, 0
        MOV BL, 10
        DIV BL                  ; AL = 十位，AH = 个位
        MOV BL, AH              ; BL = 个位
        MOV DL, AL
        CMP DL, 0
        JE  PN2_BLANK           ; 十位为 0 时输出空格占位
        ADD DL, '0'
        JMP PN2_OUT_TENS
PN2_BLANK:
        MOV DL, ' '
PN2_OUT_TENS:
        MOV AH, 02H
        INT 21H
        MOV DL, BL
        ADD DL, '0'
        MOV AH, 02H
        INT 21H
        POP DX
        POP BX
        POP AX
        RET
PRINT_NUM2 ENDP

; ------------------------------------------------------------
; CALC_MONTH_DAYS：计算当月天数
; 传参方式：数据段（全局 YEAR、MONTH）；结果在 AL
; 说明：1900~2099 内，能被 4 整除且不是 1900 的年份为闰年
;       （2000 能被 400 整除，同样是闰年）
; ------------------------------------------------------------
CALC_MONTH_DAYS PROC FAR
        PUSH BX
        PUSH SI
        MOV BL, MONTH
        XOR BH, BH
        DEC BX
        MOV SI, BX
        MOV AL, DAY_TAB[SI]     ; 先按平年取天数
        CMP MONTH, 2
        JNE CMD_DONE            ; 不是 2 月，直接返回
        MOV AX, YEAR
        CMP AX, 1900
        JE  CMD_DONE            ; 1900 不是闰年，仍为 28 天
        TEST AX, 3
        JNZ CMD_DONE            ; 低两位非 0 就不能被 4 整除
        MOV AL, 29              ; 闰年 2 月 29 天
CMD_DONE:
        POP SI
        POP BX
        RET
CALC_MONTH_DAYS ENDP

; ------------------------------------------------------------
; CALC_FIRST_DAY：计算当月 1 号是星期几
; 传参方式：堆栈（调用者先压年、后压月）
; 注意：段间调用压入 4 字节返回地址，所以实参从 [BP+6] 开始
;       [BP+8]=年，[BP+6]=月；过程内 RET 4 清理两个实参
; 返回：AL = 0~6（0=周日）
; 算法：以 1900-01-01 是星期一为基准，累计天数后对 7 取余
; ------------------------------------------------------------
CALC_FIRST_DAY PROC FAR
        PUSH BP
        MOV  BP, SP
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI

        MOV CX, [BP+8]          ; CX = 年
        MOV BX, [BP+6]          ; BX = 月

        ; ---- 整年累计天数：365*(年-1900) ----
        ; 只关心对 7 的余数，边算边取模，避免 1900~2099 的天数
        ; （最大 73018）超过 16 位寄存器的表示范围
        MOV AX, CX
        SUB AX, 1900
        MOV DX, 365
        MUL DX                  ; DX:AX = 365*(年-1900)
        MOV DI, 7
        DIV DI                  ; DX = 余数
        MOV SI, DX              ; SI = 天数 mod 7

        ; ---- 加上中间的闰年数：(年-1)/4 - 475 ----
        MOV AX, CX
        DEC AX
        SHR AX, 1
        SHR AX, 1               ; 右移两次即除以 4
        SUB AX, 475
        ADD SI, AX
        MOV AX, SI
        XOR DX, DX
        DIV DI
        MOV SI, DX              ; SI = 累计天数 mod 7

        ; ---- 加上当年本月之前的天数 ----
        DEC BX
        SHL BX, 1               ; 字表，下标乘 2
        MOV AX, ACC_TAB[BX]
        ADD SI, AX
        MOV AX, SI
        XOR DX, DX
        DIV DI
        MOV SI, DX

        ; ---- 3 月以后且闰年，补上 2 月 29 日 ----
        MOV BX, [BP+6]          ; 重新取回月份
        CMP BX, 2
        JBE CFD_WEEKDAY
        MOV AX, CX
        CMP AX, 1900
        JE  CFD_WEEKDAY
        TEST AX, 3
        JNZ CFD_WEEKDAY
        INC SI
        CMP SI, 7
        JB  CFD_WEEKDAY
        SUB SI, 7

CFD_WEEKDAY:
        MOV AX, SI
        INC AX                  ; 1900-01-01 是周一，Sun=0 时序号为 1
        CMP AX, 7
        JB  CFD_DONE
        SUB AX, 7
CFD_DONE:

        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP BP
        RET 4                   ; 段间返回，并弹出 4 字节实参
CALC_FIRST_DAY ENDP

; ------------------------------------------------------------
; PRINT_CALENDAR：输出年、月标题和 6 行日期表格
; 传参方式：数据段（YEAR、MONTH、DAYS、FIRST_DAY）
; ------------------------------------------------------------
PRINT_CALENDAR PROC FAR
        PUSH AX
        PUSH BX
        PUSH DX
        PUSH SI

        ; ---- 标题：年份 + 两个空格 + 月份名 ----
        MOV AX, YEAR
        CALL PRINT_YEAR
        MOV DL, ' '
        CALL PRINT_CHAR
        MOV DL, ' '
        CALL PRINT_CHAR

        MOV BL, MONTH
        XOR BH, BH
        DEC BX
        SHL BX, 1               ; 字指针表，下标乘 2
        MOV DX, MON_PTR[BX]
        CALL PRINT_STR
        LEA DX, CRLF
        CALL PRINT_STR

        ; ---- 星期表头 ----
        LEA DX, WEEK_HEAD
        CALL PRINT_STR
        LEA DX, CRLF
        CALL PRINT_STR

        ; ---- 1 号之前的前导空格，每个空位占 3 列 ----
        MOV BX, 0
        MOV BL, FIRST_DAY
PC_LEAD:
        CMP BX, 0
        JE  PC_DAYS
        MOV DL, ' '
        CALL PRINT_CHAR
        CALL PRINT_CHAR
        CALL PRINT_CHAR
        DEC BX
        JMP PC_LEAD

        ; ---- 逐日输出：每格占 3 列（"%2d " 的效果） ----
PC_DAYS:
        MOV SI, 0               ; SI = 当前列，0=周日 ... 6=周六
        MOV BX, 1               ; BX = 日
PC_LOOP:
        CMP BL, DAYS
        JA  PC_END
        MOV AX, BX
        CALL PRINT_NUM2
        MOV DL, ' '
        CALL PRINT_CHAR
        INC SI
        CMP SI, 7
        JB  PC_NEXT
        XOR SI, SI              ; 周六之后换行，列号归零
        LEA DX, CRLF
        CALL PRINT_STR
PC_NEXT:
        INC BX
        JMP PC_LOOP

PC_END:
        ; 条件跳转位移只有 1 字节；这里用 Jcc + JMP 接力，演示
        ; 目标较远时的处理方式
        CMP SI, 0
        JNE PC_NEWLINE
        JMP PC_RET              ; 恰好排满一行，不再换行
PC_NEWLINE:
        LEA DX, CRLF
        CALL PRINT_STR
PC_RET:
        POP SI
        POP DX
        POP BX
        POP AX
        RET
PRINT_CALENDAR ENDP

CODESEG2 ENDS

; ============================================================
; 主程序段
; ============================================================
CODESEG1 SEGMENT PARA PUBLIC 'CODE'
        ASSUME CS:CODESEG1, DS:DATASG, SS:STACKSG
START   PROC FAR
        MOV AX, DATASG
        MOV DS, AX

        ; ---- 读入年份并校验 ----
        LEA DX, MSG_YEAR
        CALL PRINT_STR
        CALL READ_NUM           ; 寄存器返回：AX = 输入值
        CMP AX, 1900
        JB  MAIN_ERR
        CMP AX, 2099
        JA  MAIN_ERR
        MOV YEAR, AX

        ; ---- 读入月份并校验 ----
        LEA DX, MSG_MONTH
        CALL PRINT_STR
        CALL READ_NUM
        CMP AX, 1
        JB  MAIN_ERR
        CMP AX, 12
        JA  MAIN_ERR
        MOV MONTH, AL

        ; ---- 当月天数：数据段传参（YEAR、MONTH），AL 返回 ----
        CALL CALC_MONTH_DAYS
        MOV DAYS, AL

        ; ---- 1 号星期：堆栈传参（先年、后月） ----
        PUSH YEAR               ; [BP+8]
        MOV AL, MONTH
        XOR AH, AH
        PUSH AX                 ; [BP+6]
        CALL CALC_FIRST_DAY     ; 过程内 RET 4 自动清理实参
        MOV FIRST_DAY, AL

        ; ---- 输出空行后打印月历 ----
        LEA DX, CRLF
        CALL PRINT_STR
        CALL PRINT_CALENDAR

        MOV AX, 4C00H
        INT 21H

MAIN_ERR:
        LEA DX, MSG_ERR
        CALL PRINT_STR
        MOV AX, 4C00H
        INT 21H
START   ENDP
CODESEG1 ENDS

        END START
