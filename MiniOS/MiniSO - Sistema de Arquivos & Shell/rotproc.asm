;;; Cont�m as rotinas de processo escritas em assembly 

global _copia_codigo
global _Inicializa_pilha


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;cabe�alho da fun��o
;; void copia_codigo(usint sorig, usint dorig, usint sdest, usint ddest, usint tam);
;; sendo:
;; sorig, dorig  => segmento e deslocamento do c�digo a ser copiado
;; sdest, ddest  => segmento e deslocamento da posi��o mem�ria onde o c�digo vai ser copiado
;; tam => quantidade de bytes a serem copiados: tamanho do c�digo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_copia_codigo:
        push bp             ; preserva bp
        mov bp,sp           ; obt�m topo da pilha para buscar par�metros

        ;; preserva registradores que ser�o usados na fun��o
        push ds
        push es
        push si
        push di
        push cx

        ;; obt�m os par�metros
        mov ds, [bp+4]      ; obt�m sorig
        mov si, [bp+6]      ; obt�m dorig
        mov es, [bp+8]      ; obt�m sdest
        mov di, [bp+10]     ; obt�m ddest
        mov cx, [bp+12]     ; obt�m tam

        ;; realiza c�pia sentido crescente
        cld              ;; estabelece sentido crescente
        rep movsb

        ;; recupera registradores usados na fun��o 
        pop cx
        pop di
        pop si
        pop es
        pop ds

        ;; encerra fun��o
        pop bp              ; recupera bp
        ret                 ; retorna da fun��o

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;cabe�alho da fun��o
;; usint Inicializa_pilha(usint segproc);
;; sendo:
;; segproc => segmento do processo cuja pilha est� sendo inicializada
;; retorno => deslocamento do topo da pilha
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_Inicializa_pilha:
        push bp             ; preserva bp
        mov bp,sp           ; obt�m topo da pilha para buscar par�metros

        ;; preserva registradores que ser�o usados na fun��o
        push es
        push di
        push cx
        ;; cria a pilha
        mov es, [bp+4]          ; obt�m segmento do processo
        mov di, 0x7FFD      ; �ltimo endere�o do segmento
        mov ax, 0x200       ; valor para FLAGS
        std                 ; seta para dire��o decrescente
        stosw               ; armazena
        mov ax, [bp+4]      ; obt�m segproc
        stosw               ; armazena o segmento para CS
        xor ax,ax           ; zera AX
        mov cx, 8           ; para IP, AX, BX, CX, DX, BP, SI, DI guarda 00h
        rep stosw
        mov ax, [bp+4]      ; obt�m segproc
        stosw               ; armazena o segmento para DS
        stosw               ; armazena o segmento para ES
        inc di
        inc di              ; obt�m o endere�o correto do topo da pilha
        mov ax, di          ; retorna o endere�o do topo da pilha
        ;; recupera registradores usados na fun��o 
        pop cx
        pop di
        pop es
        ;; encerra fun��o
        pop bp              ; recupera bp
        ret                 ; retorna da fun��o

