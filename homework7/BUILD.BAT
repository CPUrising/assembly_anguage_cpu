@echo off
masm main.asm,main.obj,main.lst,nul > MAIN.LOG
masm input.asm,input.obj,input.lst,nul > IN.LOG
masm calc.asm,calc.obj,calc.lst,nul > CALC.LOG
masm print.asm,print.obj,print.lst,nul > PRINT.LOG
link main+input+calc+print,calendar,calendar.map; > LINK.LOG
