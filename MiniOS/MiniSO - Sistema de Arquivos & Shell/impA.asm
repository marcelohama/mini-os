org 0h

inicio:	mov al,'A'
	mov ah,0Eh
	mov bh,0
	mov bl,15
	mov cx,1
	int 10h
	jmp inicio