global _divisao
global _resto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;cabe�alho da fun��o
;; usint divisao(usint dividendo, usint divisor);
;; sendo:
;; dividendo  => valor a ser dividido
;; divisor    => valor do divisor
;; retorno => quociente da divis�o
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_divisao:
	push bp
        mov bp,sp

        ; preseva registradores
        push dx
        push bx


        ; busca par�metros
        mov ax,[bp+4]     ; obt�m o dividendo
        xor dx,dx
        mov bx,[bp+6]     ; obt�m o divisor

        ; faz a divis�o DX:AX por BX
        div bx

        ; recupera registradores
        pop bx
        pop dx
 
        ; recupera bp e sai
        pop bp
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;cabe�alho da fun��o
;; usint resto(usint dividendo, usint divisor);
;; sendo:
;; dividendo  => valor a ser dividido
;; divisor    => valor do divisor
;; retorno => resto da divis�o
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_resto:
	push bp
        mov bp,sp

        ; preseva registradores
        push dx
        push bx


        ; busca par�metros
        mov ax,[bp+4]     ; obt�m o dividendo
        xor dx,dx
        mov bx,[bp+6]     ; obt�m o divisor

        ; faz a divis�o DX:AX por BX
        div bx
        mov ax, dx        ; move resto para registrador de retorno
        ; recupera registradores
        pop bx
        pop dx
 
        ; recupera bp e sai
        pop bp
        ret