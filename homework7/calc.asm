; ============================================================
; 作业题目 7：多模块实现输出日历 —— 计算模块 calc.asm
;
; 本模块导出：CALC_MONTH_DAYS、CALC_FIRST_DAY（均为 FAR 过程）
; 用到的全局数据 YEAR / MONTH / DAY_TAB / ACC_TAB 定义在 main.asm，
; 这里按 MASM 5 的约定"把 EXTRN 放在同名段内"，告诉汇编器这些外部
; 符号属于 DATASG 段
; ============================================================
        PUBLIC  CALC_MONTH_DAYS, CALC_FIRST_DAY

DATASG  SEGMENT PARA PUBLIC 'DATA'
        EXTRN   YEAR:WORD, MONTH:BYTE, DAY_TAB:BYTE, ACC_TAB:WORD
DATASG  ENDS

CSEG_CALC SEGMENT PARA PUBLIC 'CODE'
        ASSUME  CS:CSEG_CALC, DS:DATASG

; ------------------------------------------------------------
; CALC_MONTH_DAYS：计算当月天数
; 传参方式：数据段（全局 YEAR、MONTH）；结果在 AL
; 说明：1900~2099 内，能被 4 整除且不是 1900 的年份为闰年
;       （2000 能被 400 整除，同样是闰年）
; ------------------------------------------------------------
CALC_MONTH_DAYS PROC FAR
        PUSH    BX
        PUSH    SI
        MOV     BL, MONTH
        XOR     BH, BH
        DEC     BX
        MOV     SI, BX
        MOV     AL, DAY_TAB[SI]     ; 先按平年取天数
        CMP     MONTH, 2
        JNE     CMD_DONE            ; 不是 2 月，直接返回
        MOV     AX, YEAR
        CMP     AX, 1900
        JE      CMD_DONE            ; 1900 不是闰年，仍为 28 天
        TEST    AX, 3
        JNZ     CMD_DONE            ; 低两位非 0 就不能被 4 整除
        MOV     AL, 29              ; 闰年 2 月 29 天
CMD_DONE:
        POP     SI
        POP     BX
        RET
CALC_MONTH_DAYS ENDP

; ------------------------------------------------------------
; CALC_FIRST_DAY：计算当月 1 号是星期几
; 传参方式：堆栈（调用者先压年、后压月）
; 注意：跨段调用压入 4 字节返回地址，所以实参从 [BP+6] 开始
;       [BP+8]=年，[BP+6]=月；过程内 RET 4 清理两个实参
; 返回：AL = 0~6（0=周日）
; 算法：以 1900-01-01 是星期一为基准，累计天数后对 7 取余
; ------------------------------------------------------------
CALC_FIRST_DAY PROC FAR
        PUSH    BP
        MOV     BP, SP
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI

        MOV     CX, [BP+8]          ; CX = 年
        MOV     BX, [BP+6]          ; BX = 月

        ; ---- 整年累计天数：365*(年-1900) ----
        ; 只关心对 7 的余数，边算边取模，避免 1900~2099 的天数
        ; （最大 73018）超过 16 位寄存器的表示范围
        MOV     AX, CX
        SUB     AX, 1900
        MOV     DX, 365
        MUL     DX                  ; DX:AX = 365*(年-1900)
        MOV     DI, 7
        DIV     DI                  ; DX = 余数
        MOV     SI, DX              ; SI = 天数 mod 7

        ; ---- 加上中间的闰年数：(年-1)/4 - 475 ----
        MOV     AX, CX
        DEC     AX
        SHR     AX, 1
        SHR     AX, 1               ; 右移两次即除以 4
        SUB     AX, 475             ; 475 = floor(1899/4) + 1，那 1 年是 1900
                                    ;   本身（4 的倍数但不是闰年）
        CMP     CX, 1900
        JNE     CFD_LEAPCNT
        INC     AX                  ; 年为 1900 时区间为空，补回多减的 1
CFD_LEAPCNT:
        ADD     SI, AX
        MOV     AX, SI
        XOR     DX, DX
        DIV     DI
        MOV     SI, DX              ; SI = 累计天数 mod 7

        ; ---- 加上当年本月之前的天数 ----
        DEC     BX
        SHL     BX, 1               ; 字表，下标乘 2
        MOV     AX, ACC_TAB[BX]
        ADD     SI, AX
        MOV     AX, SI
        XOR     DX, DX
        DIV     DI
        MOV     SI, DX

        ; ---- 3 月以后且闰年，补上 2 月 29 日 ----
        MOV     BX, [BP+6]          ; 重新取回月份
        CMP     BX, 2
        JBE     CFD_WEEKDAY
        MOV     AX, CX
        CMP     AX, 1900
        JE      CFD_WEEKDAY
        TEST    AX, 3
        JNZ     CFD_WEEKDAY
        INC     SI
        CMP     SI, 7
        JB      CFD_WEEKDAY
        SUB     SI, 7

CFD_WEEKDAY:
        MOV     AX, SI
        INC     AX                  ; 1900-01-01 是周一，Sun=0 时序号为 1
        CMP     AX, 7
        JB      CFD_DONE
        SUB     AX, 7
CFD_DONE:

        POP     DI
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        POP     BP
        RET     4                   ; 跨段返回，并弹出 4 字节实参
CALC_FIRST_DAY ENDP

CSEG_CALC ENDS
        END
