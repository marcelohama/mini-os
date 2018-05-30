global _divisao
global _resto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;cabeçalho da função
;; usint divisao(usint dividendo, usint divisor);
;; sendo:
;; dividendo  => valor a ser dividido
;; divisor    => valor do divisor
;; retorno => quociente da divisão
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_divisao:
	push bp
        mov bp,sp

        ; preseva registradores
        push dx
        push bx


        ; busca parâmetros
        mov ax,[bp+4]     ; obtém o dividendo
        xor dx,dx
        mov bx,[bp+6]     ; obtém o divisor

        ; faz a divisão DX:AX por BX
        div bx

        ; recupera registradores
        pop bx
        pop dx
 
        ; recupera bp e sai
        pop bp
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;cabeçalho da função
;; usint resto(usint dividendo, usint divisor);
;; sendo:
;; dividendo  => valor a ser dividido
;; divisor    => valor do divisor
;; retorno => resto da divisão
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_resto:
	push bp
        mov bp,sp

        ; preseva registradores
        push dx
        push bx


        ; busca parâmetros
        mov ax,[bp+4]     ; obtém o dividendo
        xor dx,dx
        mov bx,[bp+6]     ; obtém o divisor

        ; faz a divisão DX:AX por BX
        div bx
        mov ax, dx        ; move resto para registrador de retorno
        ; recupera registradores
        pop bx
        pop dx
 
        ; recupera bp e sai
        pop bp
        ret