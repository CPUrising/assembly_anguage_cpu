; ============================================================
; 作业题目 7：多模块实现输出日历 —— 主模块 main.asm
;
; 模块划分（每个模块拥有自己的代码段，跨模块调用都是远调用）：
;   main.asm  ：CSEG_MAIN ，主程序 START，并集中定义全局数据段 DATASG
;               与堆栈段 STACKSG
;   input.asm ：CSEG_IN   ，READ_NUM、PRINT_STR
;   calc.asm  ：CSEG_CALC ，CALC_MONTH_DAYS、CALC_FIRST_DAY
;   print.asm ：CSEG_PRINT，PRINT_YEAR、PRINT_NUM2、PRINT_CALENDAR
;   macro.inc ：宏库，被各模块 INCLUDE
;
; 与作业 6 的对比：
;   作业 6 是"一个文件、两个代码段"，段间调用用 CALL FAR；
;   本作业是"多个文件、各自独立的代码段"，跨文件调用的机器码同样是
;   远调用（9A），但 CALL 的目标要到链接阶段才能确定，所以引用方必须
;   用 EXTRN ...:FAR 声明目标类型，定义方必须用 PUBLIC 导出。
; ============================================================
        INCLUDE macro.inc

; ---- 引用其它模块用 PUBLIC 导出的过程 ----
        EXTRN   READ_NUM:FAR
        EXTRN   PRINT_STR:FAR
        EXTRN   CALC_MONTH_DAYS:FAR
        EXTRN   CALC_FIRST_DAY:FAR
        EXTRN   PRINT_CALENDAR:FAR

; ---- 导出本模块定义的全局数据，供 calc.asm / print.asm 使用 ----
        PUBLIC  YEAR, MONTH, DAYS, FIRST_DAY
        PUBLIC  MSG_YEAR, MSG_MONTH, MSG_ERR, CRLF, WEEK_HEAD
        PUBLIC  MON_PTR, DAY_TAB, ACC_TAB

STACKSG SEGMENT PARA STACK 'STACK'
        DW      256 DUP(0)          ; 512 字节栈，远过程调用与中断足够使用
STACKSG ENDS

DATASG  SEGMENT PARA PUBLIC 'DATA'
        MSG_YEAR  DB 0DH,0AH,'Please input year (1900-2099): $'
        MSG_MONTH DB 0DH,0AH,'Please input month (1-12): $'
        MSG_ERR   DB 0DH,0AH,'Invalid input!$'
        CRLF      DB 0DH,0AH,'$'
        WEEK_HEAD DB 'Su Mo Tu We Th Fr Sa$'

        ; 月份名指针表 + 12 个月份名（'$' 结尾的变长字符串）
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
        ; 平年时某月之前累计的天数（最大 334 超过 255，故用字）
        ACC_TAB   DW 0,31,59,90,120,151,181,212,243,273,304,334

        ; 全局参数区：数据段传参
        YEAR      DW 0
        MONTH     DB 0
        DAYS      DB 0              ; 当月天数
        FIRST_DAY DB 0              ; 当月 1 号是星期几，0=周日
DATASG  ENDS

CSEG_MAIN SEGMENT PARA PUBLIC 'CODE'
        ASSUME  CS:CSEG_MAIN, DS:DATASG, SS:STACKSG

START   PROC FAR
        MOV     AX, DATASG
        MOV     DS, AX

        ; ---- 读入年份并校验 ----
        OUT_STR MSG_YEAR
        CALL    READ_NUM            ; 寄存器返回：AX = 输入值
        CHECK_RANGE 1900, 2099, MAIN_ERR
        MOV     YEAR, AX

        ; ---- 读入月份并校验 ----
        OUT_STR MSG_MONTH
        CALL    READ_NUM
        CHECK_RANGE 1, 12, MAIN_ERR
        MOV     MONTH, AL

        ; ---- 当月天数：数据段传参（YEAR、MONTH），AL 返回 ----
        CALL    CALC_MONTH_DAYS
        MOV     DAYS, AL

        ; ---- 1 号星期：堆栈传参（先年、后月） ----
        PUSH    YEAR                ; [BP+8]
        MOV     AL, MONTH
        XOR     AH, AH
        PUSH    AX                  ; [BP+6]
        CALL    CALC_FIRST_DAY      ; 过程内 RET 4 自动清理实参
        MOV     FIRST_DAY, AL

        ; ---- 输出空行后打印月历 ----
        NEWLINE
        CALL    PRINT_CALENDAR

        MOV     AX, 4C00H
        INT     21H

MAIN_ERR:
        OUT_STR MSG_ERR
        MOV     AX, 4C00H
        INT     21H
START   ENDP

CSEG_MAIN ENDS
        END     START
