;;; Cont�m as rotinas de interrupcao

global _Troca_vetor
extern _tabproc      ; vetor de processos
extern _processo     ; processo em execu��o
extern _Busca_prox_pronto ; Fun��o para buscar pr�ximo processo pronto


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;cabe�alho da fun��o
;; void Troca_vetor(void);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_Troca_vetor:
        push bp             ; preserva bp
        mov bp,sp           ; obt�m topo da pilha para buscar par�metros

        ;; preserva registradores que ser�o usados na fun��o
        push ds
        push es

        cli                 ; bloqueia as interrup��es
        ;; copia o vetor original de interrup��o
        mov ax, 0x800
        mov ds,ax           ; garante valor certo para DS
        xor ax,ax
        mov es,ax           ; garante valor certo para ES

        mov ax, [es:20h]    ; valor do deslocamento
        mov [VetOrig], ax
        mov ax, [es:22h]    ; valor do segmento
        mov [VetOrig+2], ax

        ;; escreve o novo vetor de interrup��o

        mov ax, Manipulador ; obt�m deslocamento do no manipulador
        mov [es:20h],ax     ; escreve deslocamento
        mov [es:22h], ds    ; mesmo segmento do kernel


        sti                 ; libera as interrup��es
        ;; recupera registradores usados na fun��o 

        pop es
        pop ds

        ;; encerra fun��o
        pop bp              ; recupera bp
        ret                 ; retorna da fun��o

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Manipulador da interrup��o

Manipulador:
        cli                 ; bloqueia as interrup��es
        ;; salva contexto do processo
        push ax
        push bx
        push cx
        push dx
        push bp
        push si
        push di
        push ds
        push es
        ;; acerta segmento de dados DS (interrup��o pode vir de qualquer processo)
        mov ax, 0x800
        mov ds,ax
        ;; salva topo da pilha na tabela de processos
        mov bx,[_processo]       ; obt�m o processo atual
        mov cl, 3
        shl bx, cl               ; multiplica por 8
        mov [bx+_tabproc+2], ss  ; guarda topo da pilha na tabela de processos
        mov [bx+_tabproc+4], sp  ; guarda topo da pilha na tabela de processos
        mov ax, 0                ; estado pronto
        mov [bx+_tabproc], ax    ; muda estado

        ;; obt�m a pilha do SO
        mov ss, [_tabproc+2]
        mov sp, [_tabproc+4]

        ;; prepara pilha para executar interrup��o antiga e voltar na
        ;; instru��o seguinte
        pushf               ; salva flags
        mov ax,0x800        ; segmento do kernel
        push ax
        mov ax, .retorno    ; deslocamento do retorno da interrup��o antiga
        push ax
        jmp far [VetOrig]   ; executa interrup��o antiga

.retorno:
        ;; obt�m o novo processo a ser escalonado
        call _Busca_prox_pronto
        mov [_processo], ax     ; indica como novo processo

        ;; salva a pilha do SO 
        mov [_tabproc+2], ss   ;armazena ss na tabela de processos
        mov [_tabproc+4], sp   ;armazena sp na tabela de processos

        ;; obt�m a pilha do novo processo
        mov bx,[_processo]       ; obt�m o processo atual
        mov cl, 3
        shl bx, cl               ; multiplica por 8
        mov ss, [bx+_tabproc+2]  ; obt�m topo da pilha na tabela de processos
        mov sp, [bx+_tabproc+4] 
        mov ax, 3                ; estado rodando
        mov [bx+_tabproc], ax    ; muda estado

        ;; recupera contexto salvo
        pop es
        pop ds
        pop di
        pop si
        pop bp
        pop dx
        pop cx
        pop bx
        pop ax
        ;; encerra interrup��o
        sti                 ; libera as interrup��es
        iret                ; retorna da interrup��o

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Armazena o vetor original da interrup��o

VetOrig dw 0,0