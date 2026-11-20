; ============================================================
; 作业题目 7：多模块实现输出日历 —— 输入输出模块 input.asm
;
; 本模块导出：READ_NUM、PRINT_STR（均为 FAR 过程）
; 本模块不访问全局数据，因此不需要 DATASG 段声明
; ============================================================
        PUBLIC  READ_NUM, PRINT_STR

CSEG_IN SEGMENT PARA PUBLIC 'CODE'
        ASSUME  CS:CSEG_IN

; ------------------------------------------------------------
; READ_NUM：从键盘读入十进制数，回车结束
; 传参方式：寄存器（结果 AX）；最多取前 4 位数字，非数字被忽略
; ------------------------------------------------------------
READ_NUM PROC FAR
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        XOR     BX, BX              ; BX = 累加结果
        XOR     SI, SI              ; SI = 已读入的数字位数
RN_NEXT:
        MOV     AH, 01H
        INT     21H                 ; 读一个字符并回显
        CMP     AL, 0DH
        JE      RN_DONE             ; 回车结束
        CMP     AL, '0'
        JB      RN_NEXT
        CMP     AL, '9'
        JA      RN_NEXT
        CMP     SI, 4               ; 年份最多 4 位，多余位忽略
        JAE     RN_NEXT
        INC     SI
        SUB     AL, '0'
        MOV     CL, AL
        XOR     CH, CH
        MOV     AX, BX
        MOV     DX, 10
        MUL     DX                  ; AX = 结果 * 10
        MOV     BX, AX
        ADD     BX, CX              ; BX = 结果 * 10 + 当前位
        JMP     RN_NEXT
RN_DONE:
        MOV     AX, BX
        POP     SI
        POP     DX
        POP     CX
        POP     BX
        RET
READ_NUM ENDP

; ------------------------------------------------------------
; PRINT_STR：输出 DX 指向的 '$' 结尾字符串
; 传参方式：寄存器（DX = 串偏移地址）
; ------------------------------------------------------------
PRINT_STR PROC FAR
        MOV     AH, 09H
        INT     21H
        RET
PRINT_STR ENDP

CSEG_IN ENDS
        END
