;;; Contém as rotinas de processo escritas em assembly 

global _copia_codigo
global _Inicializa_pilha


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;cabeçalho da função
;; void copia_codigo(usint sorig, usint dorig, usint sdest, usint ddest, usint tam);
;; sendo:
;; sorig, dorig  => segmento e deslocamento do código a ser copiado
;; sdest, ddest  => segmento e deslocamento da posição memória onde o código vai ser copiado
;; tam => quantidade de bytes a serem copiados: tamanho do código
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_copia_codigo:
        push bp             ; preserva bp
        mov bp,sp           ; obtém topo da pilha para buscar parâmetros

        ;; preserva registradores que serão usados na função
        push ds
        push es
        push si
        push di
        push cx

        ;; obtém os parâmetros
        mov ds, [bp+4]      ; obtém sorig
        mov si, [bp+6]      ; obtém dorig
        mov es, [bp+8]      ; obtém sdest
        mov di, [bp+10]     ; obtém ddest
        mov cx, [bp+12]     ; obtém tam

        ;; realiza cópia sentido crescente
        cld              ;; estabelece sentido crescente
        rep movsb

        ;; recupera registradores usados na função 
        pop cx
        pop di
        pop si
        pop es
        pop ds

        ;; encerra função
        pop bp              ; recupera bp
        ret                 ; retorna da função

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;cabeçalho da função
;; usint Inicializa_pilha(usint segproc);
;; sendo:
;; segproc => segmento do processo cuja pilha está sendo inicializada
;; retorno => deslocamento do topo da pilha
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_Inicializa_pilha:
        push bp             ; preserva bp
        mov bp,sp           ; obtém topo da pilha para buscar parâmetros

        ;; preserva registradores que serão usados na função
        push es
        push di
        push cx
        ;; cria a pilha
        mov es, [bp+4]          ; obtém segmento do processo
        mov di, 0x7FFD      ; último endereço do segmento
        mov ax, 0x200       ; valor para FLAGS
        std                 ; seta para direção decrescente
        stosw               ; armazena
        mov ax, [bp+4]      ; obtém segproc
        stosw               ; armazena o segmento para CS
        xor ax,ax           ; zera AX
        mov cx, 8           ; para IP, AX, BX, CX, DX, BP, SI, DI guarda 00h
        rep stosw
        mov ax, [bp+4]      ; obtém segproc
        stosw               ; armazena o segmento para DS
        stosw               ; armazena o segmento para ES
        inc di
        inc di              ; obtém o endereço correto do topo da pilha
        mov ax, di          ; retorna o endereço do topo da pilha
        ;; recupera registradores usados na função 
        pop cx
        pop di
        pop es
        ;; encerra função
        pop bp              ; recupera bp
        ret                 ; retorna da função

