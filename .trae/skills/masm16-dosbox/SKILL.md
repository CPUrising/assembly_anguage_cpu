---
name: masm16-dosbox
description: Build and verify 16-bit MASM 5.0 programs in DOSBox and audit 8086 pitfalls. Use when editing this project's homework asm files, debugging MASM or LINK errors, jump range, segment calls, or stack parameter offsets.
---

# MASM 16 位程序编译验证

本 skill 只提供验证要点、调试方法和 8086 陷阱清单，不自动执行 DOSBox。

## 环境

- DOSBox：`C:\Users\Lenovo\Desktop\DOSBox-0.74\DOSBox.exe`
- MASM 5.0：`D:\Masm50`（`MASM.EXE`、`LINK.EXE`、`DEBUG.EXE`）
- 源码目录：`homeworkN`（第 1 次为 `homework1_helloworld`），启动脚本 `run.bat`

## 手动验证流程

1. `run.bat 6` 挂载源码目录，进入 `C:` 提示符
2. 依次执行 `masm calendar.asm;`、`link calendar.obj;`、`calendar`
3. 运行结束后先关闭 DOSBox 窗口，再从宿主机读取生成的文件
4. 多组年月逐组运行；非法输入单独跑一次

## 验证要点

1. 非交互式调用必须加分号：`masm x.asm;`、`link x.obj;`。否则会停在 `Object filename:` 提示处，看起来执行过但没有 `.OBJ`
2. 需要看机器码或跳转位移时生成列表文件：`masm x.asm,x.obj,x.lst;`（`.lst` 已被 `.gitignore` 忽略）
3. 去掉 `-c "exit"` 可直接进入 DOSBox 手工调试
4. 输入重定向时 DOSBox 不回显键入的字符，输出会与交互式略有差异，比对时只看日期表格
5. DOSBox 关闭前，重定向生成的输出文件可能是空的；不要用"未关闭 DOSBox 时读到的空文件"判断程序失败
6. 通过命令行启动 DOSBox 时收不到窗口内的控制台回显，结论一律以宿主机的日志/输出文件为准

## 调试方法

- 打印中间变量：临时在关键位置插入输出（例如打印过程返回的 `FIRST_DAY`），确认传参和返回值，定位后删除
- 单步跟踪：`debug x.exe`，用 `u` 反汇编、`t` 单步、`g` 运行、`d` 查看内存，观察 IP/CS/SS:SP
- 分离验证：先写最小调用单独验证子过程（传参、返回、栈平衡），再接入主流程
- 对比验证：C 版与汇编版同一输入对比输出（本项目的 `calendar.c` 对 `calendar.asm`）
- 二分定位：先确认输入和输出边界是否正常，再逐段注释/恢复，缩小出错过程
- 单项复验：批量运行时某组没有产物，单独跑一次，区分环境问题与程序问题

## 常见陷阱

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| `A2050 Value out of range` | `DB` 值超过 255（如累计天数 334） | 改用 `DW`，下标乘 2 |
| 年份越大结果越错（如 2099-12 星期错） | 累计天数 73018 超出 16 位 | 只求余数时每步 `DIV 7` 取模，或改用 32 位运算 |
| `A2071 Forward needs override or FAR` | 跨段 `CALL` 引用了后面才定义的 FAR 过程 | 过程段排在主程序段之前，或调用处写 `CALL FAR PTR` |
| `A2073 Symbol is already external` | 同模块内既有 `EXTRN` 又有定义 | 删除 `EXTRN`，靠段顺序解决 |
| 段间调用后栈参数全错 | 远调用返回地址是 4 字节 | 参数从 `[BP+6]` 开始（年 `[BP+8]`、月 `[BP+6]`），`RET 4` 清参 |
| `A4031 Operand types must match` | `MOV BX, 字节变量` | 改为 `MOV BL, 变量` + `XOR BH, BH` |
| 条件跳转报越界或跳错 | `Jcc` 位移只有 1 字节（±127） | `Jcc` 跳到近处标签，再用 `JMP`（近跳转，位移 16 位）接力 |
| 日期与表头不对齐 | 每格 3 列，空位只补了 1 个空格 | 空位补 3 个空格，日期用 `%2d ` 的效果 |

## 完成检查

- [ ] 汇编 0 Warning / 0 Severe Error，链接成功
- [ ] 边界用例通过：最小年份、最大年份、闰年 2 月、非法输入
- [ ] C 对照版与汇编版输出一致（如存在）
- [ ] 临时文件已清理（`IN*/OUT*`、`*.LOG`、`*.LST`、`*.OBJ`、`*.EXE`）
