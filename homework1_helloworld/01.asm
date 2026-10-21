.model small
.data
Hello DB 'Hello world!',0dh,0ah,'$'
.code
START:
    MOV AX,@DATA
    MOV DS,AX
    LEA DX,Hello      ; 使用 LEA 获取偏移地址
    MOV AH,9
    INT 21H 
    MOV AX,4C00H
    INT 21h
END START 