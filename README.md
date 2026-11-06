# 汇编语言作业项目

本项目是汇编语言课程的作业合集，使用 8086 汇编（MASM，16 位 DOS 程序）完成课堂练习与课后作业，并配有对应的 C 语言实现和反汇编对照。

## 目录结构

| 目录 | 内容 |
| --- | --- |
| `homework1_helloworld/` | 第一个程序：输出 `Hello world!`，分别用 `LEA` 和 `MOV ... OFFSET` 两种方式取偏移地址；附带 DEBUG 手工输入机器码运行的程序与命令脚本 |
| `homework2/` | 循环与跳转：用 `LOOP` 和 `DEC/CMP/JNZ` 两种方式实现双循环、输出字符矩阵；附 C 语言实现与反汇编结果 |
| `homework3/` | 求和与进制转换：1+2+...+100，结果分别放在寄存器/数据段/栈中，支持用户输入 1~100；十六进制与十进制互转；附 C 语言实现与反汇编注释 |
| `homework4/` | 乘法指令与过程调用：用 `CALL/RET` 实现过程调用，输出九九乘法表；附 C 语言实现 |
| `homework5/` | 递归调用：求斐波那契数列第 n 项（目前仅有题目说明，代码待补充） |

其他文件：

- `使用方法.md`：DOSBox 下挂载目录、编译、链接、运行及反汇编的操作步骤
- `Syllabus of Assembly Programming_2021.pdf`：课程大纲
- `教你如何在64位WIN7系统下配置汇编软件并运行汇编程序.pdf`：环境配置教程

## 环境与工具

- **汇编器/链接器**：MASM 5.0（`masm`、`link`）
- **运行环境**：DOSBox（16 位 DOS 程序）
- **反汇编工具**：NASM 自带的 `ndisasm`（如 `ndisasm -b 32 jump.exe > disasm.txt`）
- **C 语言对照**：任意 C 编译器，用于生成反汇编代码并加注释

## 编译与运行

### 一键启动（推荐）

项目根目录提供了 [`run.bat`](./run.bat) 脚本，**自动打开 DOSBox 并执行挂载命令**，无需在 DOSBox 内手动输入。

**两种用法：**

- **双击 `run.bat`**：按提示输入作业编号（1-5），回车
- **命令行运行**：`run.bat 2`（把 `2` 换成你的作业编号）

脚本会自动执行以下命令，然后停在 C 盘提示符下：

```dos
mount c D:\documents\assembly_anguage_cpu\homework2
mount d D:\Masm50
path d:\;d:\bin
c:
dir
```

进入 C 盘后，用 `masm`、`link` 编译运行：

```dos
masm 文件名.asm
link 文件名.obj
文件名.exe
```

**如需修改路径**（你的 DOSBox 或项目位置不同），编辑 `run.bat` 中的以下两行：

```bat
set FULL=D:\documents\assembly_anguage_cpu\%DIR%
"C:\Users\Lenovo\Desktop\DOSBox-0.74\DOSBox.exe" -c "mount c %FULL%" -c "mount d D:\Masm50" -c "path d:\;d:\bin" -c "c:" -c "dir"
```

- 第 1 行：项目根目录路径
- 第 2 行：DOSBox.exe 路径 + MASM 工具目录（`D:\Masm50`）

### 完整示例（以 homework2 的 loop.asm 为例）

```dos
mount c D:\documents\assembly_anguage_cpu\homework2
mount d D:\Masm50
path d:\;d:\bin
c:
masm loop.asm
link loop.obj
loop.exe
```

详细步骤见 [使用方法.md](./使用方法.md)。

## 说明

- 各次作业的题目要求、输出示例与思路记录在对应目录的 `README.md`（如 `homework4/README.md`、`homework5/README.md`）或说明文件中。
- 编译产物（`*.exe`、`*.obj`）已在 `.gitignore` 中忽略，仓库只保留源码与说明文档。
