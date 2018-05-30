;;; Contém as rotinas de interrupcao

global _Troca_vetor
extern _tabproc      ; vetor de processos
extern _processo     ; processo em execução
extern _Busca_prox_pronto ; Função para buscar próximo processo pronto


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;cabeçalho da função
;; void Troca_vetor(void);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_Troca_vetor:
        push bp             ; preserva bp
        mov bp,sp           ; obtém topo da pilha para buscar parâmetros

        ;; preserva registradores que serão usados na função
        push ds
        push es

        cli                 ; bloqueia as interrupções
        ;; copia o vetor original de interrupção
        mov ax, 0x800
        mov ds,ax           ; garante valor certo para DS
        xor ax,ax
        mov es,ax           ; garante valor certo para ES

        mov ax, [es:20h]    ; valor do deslocamento
        mov [VetOrig], ax
        mov ax, [es:22h]    ; valor do segmento
        mov [VetOrig+2], ax

        ;; escreve o novo vetor de interrupção

        mov ax, Manipulador ; obtém deslocamento do no manipulador
        mov [es:20h],ax     ; escreve deslocamento
        mov [es:22h], ds    ; mesmo segmento do kernel


        sti                 ; libera as interrupções
        ;; recupera registradores usados na função 

        pop es
        pop ds

        ;; encerra função
        pop bp              ; recupera bp
        ret                 ; retorna da função

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Manipulador da interrupção

Manipulador:
        cli                 ; bloqueia as interrupções
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
        ;; acerta segmento de dados DS (interrupção pode vir de qualquer processo)
        mov ax, 0x800
        mov ds,ax
        ;; salva topo da pilha na tabela de processos
        mov bx,[_processo]       ; obtém o processo atual
        mov cl, 3
        shl bx, cl               ; multiplica por 8
        mov [bx+_tabproc+2], ss  ; guarda topo da pilha na tabela de processos
        mov [bx+_tabproc+4], sp  ; guarda topo da pilha na tabela de processos
        mov ax, 0                ; estado pronto
        mov [bx+_tabproc], ax    ; muda estado

        ;; obtém a pilha do SO
        mov ss, [_tabproc+2]
        mov sp, [_tabproc+4]

        ;; prepara pilha para executar interrupção antiga e voltar na
        ;; instrução seguinte
        pushf               ; salva flags
        mov ax,0x800        ; segmento do kernel
        push ax
        mov ax, .retorno    ; deslocamento do retorno da interrupção antiga
        push ax
        jmp far [VetOrig]   ; executa interrupção antiga

.retorno:
        ;; obtém o novo processo a ser escalonado
        call _Busca_prox_pronto
        mov [_processo], ax     ; indica como novo processo

        ;; salva a pilha do SO 
        mov [_tabproc+2], ss   ;armazena ss na tabela de processos
        mov [_tabproc+4], sp   ;armazena sp na tabela de processos

        ;; obtém a pilha do novo processo
        mov bx,[_processo]       ; obtém o processo atual
        mov cl, 3
        shl bx, cl               ; multiplica por 8
        mov ss, [bx+_tabproc+2]  ; obtém topo da pilha na tabela de processos
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
        ;; encerra interrupção
        sti                 ; libera as interrupções
        iret                ; retorna da interrupção

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Armazena o vetor original da interrupção

VetOrig dw 0,0