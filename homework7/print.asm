; ============================================================
; 作业题目 7：多模块实现输出日历 —— 打印模块 print.asm
;
; 本模块导出：PRINT_YEAR、PRINT_NUM2、PRINT_CALENDAR（均为 FAR 过程）
; 用到全局数据 YEAR / MONTH / DAYS / FIRST_DAY / CRLF / WEEK_HEAD /
; MON_PTR（定义在 main.asm），以及宏库 macro.inc
; ============================================================
        INCLUDE macro.inc

        ; PRINT_YEAR / PRINT_NUM2 只在本模块内被调用，声明为 NEAR 过程，
        ; 这样模块内的 CALL 就是"段内近调用"（机器码 E8），可与跨模块的
        ; 远调用（机器码 9A）形成对照
        PUBLIC  PRINT_CALENDAR
        EXTRN   PRINT_STR:FAR       ; 调用 input.asm 中的输出串过程

DATASG  SEGMENT PARA PUBLIC 'DATA'
        EXTRN   YEAR:WORD, MONTH:BYTE, DAYS:BYTE, FIRST_DAY:BYTE
        EXTRN   CRLF:BYTE, WEEK_HEAD:BYTE, MON_PTR:WORD
DATASG  ENDS

CSEG_PRINT SEGMENT PARA PUBLIC 'CODE'
        ASSUME  CS:CSEG_PRINT, DS:DATASG

; ------------------------------------------------------------
; PRINT_YEAR：输出 AX 中的年份，固定 4 位数字（本模块内部使用）
; 传参方式：寄存器（AX = 年份）
; ------------------------------------------------------------
PRINT_YEAR PROC NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        MOV     BX, AX              ; BX = 待输出的年
        MOV     CX, 1000            ; CX = 当前位的权值
PY_LOOP:
        MOV     AX, BX
        XOR     DX, DX
        DIV     CX                  ; AX = 当前位数字，DX = 余数
        MOV     BX, DX              ; 余数留到下一位
        MOV     DL, AL
        ADD     DL, '0'
        OUT_CHAR                    ; 宏：MOV AH,02H / INT 21H
        MOV     AX, CX              ; 权值除以 10
        XOR     DX, DX
        MOV     CX, 10
        DIV     CX
        MOV     CX, AX
        CMP     CX, 0
        JNE     PY_LOOP
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
PRINT_YEAR ENDP

; ------------------------------------------------------------
; PRINT_NUM2：输出 AX 中的 0~99，宽度固定 2 列（右对齐，本模块内部使用）
; 传参方式：寄存器（AX = 数值）
; ------------------------------------------------------------
PRINT_NUM2 PROC NEAR
        PUSH    AX
        PUSH    BX
        PUSH    DX
        MOV     AH, 0
        MOV     BL, 10
        DIV     BL                  ; AL = 十位，AH = 个位
        MOV     BL, AH              ; BL = 个位
        MOV     DL, AL
        CMP     DL, 0
        JE      PN2_BLANK           ; 十位为 0 时输出空格占位
        ADD     DL, '0'
        JMP     PN2_OUT_TENS
PN2_BLANK:
        MOV     DL, ' '
PN2_OUT_TENS:
        OUT_CHAR
        MOV     DL, BL
        ADD     DL, '0'
        OUT_CHAR
        POP     DX
        POP     BX
        POP     AX
        RET
PRINT_NUM2 ENDP

; ------------------------------------------------------------
; PRINT_CALENDAR：输出年、月标题和 6 行日期表格
; 传参方式：数据段（YEAR、MONTH、DAYS、FIRST_DAY）
; ------------------------------------------------------------
PRINT_CALENDAR PROC FAR
        PUSH    AX
        PUSH    BX
        PUSH    DX
        PUSH    SI

        ; ---- 标题：年份 + 两个空格 + 月份名 ----
        MOV     AX, YEAR
        CALL    PRINT_YEAR
        MOV     DL, ' '
        OUT_CHAR
        MOV     DL, ' '
        OUT_CHAR

        MOV     BL, MONTH
        XOR     BH, BH
        DEC     BX
        SHL     BX, 1               ; 字指针表，下标乘 2
        MOV     DX, MON_PTR[BX]
        CALL    PRINT_STR
        NEWLINE

        ; ---- 星期表头 ----
        OUT_STR WEEK_HEAD
        NEWLINE

        ; ---- 1 号之前的前导空格，每个空位占 3 列 ----
        MOV     BX, 0
        MOV     BL, FIRST_DAY
PC_LEAD:
        CMP     BX, 0
        JE      PC_DAYS
        MOV     DL, ' '
        OUT_CHAR
        OUT_CHAR
        OUT_CHAR
        DEC     BX
        JMP     PC_LEAD

        ; ---- 逐日输出：每格占 3 列（"%2d " 的效果） ----
PC_DAYS:
        MOV     SI, 0               ; SI = 当前列，0=周日 ... 6=周六
        MOV     BX, 1               ; BX = 日
PC_LOOP:
        CMP     BL, DAYS
        JA      PC_END
        MOV     AX, BX
        CALL    PRINT_NUM2
        MOV     DL, ' '
        OUT_CHAR
        INC     SI
        CMP     SI, 7
        JB      PC_NEXT
        XOR     SI, SI              ; 周六之后换行，列号归零
        NEWLINE
PC_NEXT:
        INC     BX
        JMP     PC_LOOP

PC_END:
        ; 条件跳转位移只有 1 字节；这里用 Jcc + JMP 接力，演示
        ; 目标较远时的处理方式
        CMP     SI, 0
        JNE     PC_NEWLINE
        JMP     PC_RET              ; 恰好排满一行，不再换行
PC_NEWLINE:
        NEWLINE
PC_RET:
        POP     SI
        POP     DX
        POP     BX
        POP     AX
        RET
PRINT_CALENDAR ENDP

CSEG_PRINT ENDS
        END
