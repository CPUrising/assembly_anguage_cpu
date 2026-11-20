; ============================================================
; macro.inc —— 宏库（被 main.asm / print.asm 等模块 INCLUDE）
;
; 这里只放"宏定义"，不含数据、不含可执行代码，所以可以被多个模块
; 同时包含，不会产生重复定义的链接错误。
;
; 宏与过程的区别：
;   宏在汇编阶段就地展开，展开出的指令与手写的完全一样，省掉了
;   CALL / RET 的时间与栈开销；但每一处引用都会复制一份代码，程序
;   体积会变大。过程只有一份代码，但要付出调用开销。
;   本作业用宏封装"取偏移 + 调用输出过程"这类重复动作。
; ============================================================

; 输出以 '$' 结尾的字符串：参数 addr 是字符串的偏移（标号）
; 展开为：LEA DX,addr / CALL PRINT_STR
OUT_STR MACRO addr
        LEA     DX, addr
        CALL    PRINT_STR
        ENDM

; 输出回车换行（CRLF 与 PRINT_STR 都是跨模块的公共符号）
NEWLINE MACRO
        LEA     DX, CRLF
        CALL    PRINT_STR
        ENDM

; 输出 DL 中的一个字符（DOS 功能号 02H）
OUT_CHAR MACRO
        MOV     AH, 02H
        INT     21H
        ENDM

; 范围校验：若 AX 不在 [lo, hi] 区间内，跳到 err 标号
; 展开为两条比较 + 两次条件跳转
CHECK_RANGE MACRO lo, hi, err
        CMP     AX, lo
        JB      err
        CMP     AX, hi
        JA      err
        ENDM
