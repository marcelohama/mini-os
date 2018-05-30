extern _curDirectory
global _system_getch
global _system_dataRead
global _system_dataWrite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tarefa 3 - implementacao do comando getche do prompt do shell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_system_getch:
	;; recebendo a tecla e devolvendo seu codigo ASCII
	push bp
	mov bp,sp

	xor ax,ax
	mov ah,0h
	int 16h
	
	pop bp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tarefa 6 - Implementacao da funcao de leitura de disco
;; void sistema_dataRead(usint number, usint cylinder, usint sector, usint head, usint destinySeg, usint destinyOff)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_system_dataRead:
	;; salvando os registradores a serem usados
	push bp
	mov bp,sp
	push es
	push bx
	push cx
	push dx
	;; definindo a memoria de destino
	mov ax,[bp+12]						;; definindo o destino (memoria) dos dados lidos
	mov es,ax							;; segmento da memoria
	mov bx,[bp+14]						;; obtendo o offset destino
	;; definicoes da funcao
	mov ah,02							;; funcao de leitura de setores
	mov al,[bp+4]						;; numero de setores a ser lido
	mov ch,[bp+6]						;; cilindro
	mov cl,[bp+8]						;; setor
	mov dh,[bp+10]						;; cabeca
	mov dl,0								;; drive A
	int 13h								;; faz a leitura
	;; recuperacao dos registradores
	pop dx
	pop cx
	pop bx
	pop es
	pop bp
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Tarefa 7 - Implementacao da funcao de gravacao de disco
;; void sistema_dataWrite(usint number, usint cylinder, usint sector, usint head, usint sourceSeg, usint sourceOff)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_system_dataWrite:
	;; salvando os registradores a serem usados
	push bp
	mov bp,sp
	push es
	push bx
	push cx
	push dx
	;; definindo a memoria de origem
	mov ax,[bp+12]						;; obtendo a origem (memoria) dos dados lidos
	mov es,ax							;; segmento da memoria
	mov bx,[bp+14]						;; obtendo o offset origem
	;; definicoes da funcao
	mov ah,03							;; funcao de leitura de setores
	mov al,[bp+4]						;; numero de setores a ser lido
	mov ch,[bp+6]						;; cilindro
	mov cl,[bp+8]						;; setor
	mov dh,[bp+10]						;; cabeca
	mov dl,0								;; drive A
	int 13h								;; faz a leitura
	;; recuperacao dos registradores
	pop dx
	pop cx
	pop bx
	pop es
	pop bp
	ret
