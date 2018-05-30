BITS 16
section .text
global _main
global _imprimexy
global _imprime
global _limpa_tela
extern _principal

global _impA
global _tamA
global _impB
global _tamB


_main
    ;; acerta segmentos de dados
    mov ax, 800h
    mov ds, ax
    mov es, ax
    mov ss, ax     ;mesmo segmento para a pilha
    mov sp, 0x8000 ;no fim do segmento de 32K 
    ;; chama a função
    call _principal      ;; chama função do C
fim: jmp fim

;; função que imprime em posição xy da tela
_imprimexy:
       push bp     ; preserva BP
       ;; prepara para imprimir
       mov bp,sp   ; obtém o topo da pilha
       mov si, [bp+8] ;obtém o ponteiro da string
       ; calcula o tamanho da string
       xor cx,cx   ; zera CX
       cld         ; muda direção para crescente
.laco: lodsb       ; carrega em AL e incrementa SI
       and al,al   ; testa o valor
       jz .fimstr   ; achou fim da string
       inc cx      ; incrementa contador
       jmp .laco   ; repete até encontrar fim
.fimstr: ;; encontrou o tamanho da string
       mov dx,[bp+4] ; obtém a coluna
       mov ax,[bp+6] ; obtém a linha
       mov dh, al
       mov ax,[bp+8] ; obtém o ponteiro para a string
       mov bp,ax
       mov bh, 0    ; página
       mov bl, 15   ; atributo
       mov al, 1    ; modo de escrita (caracteres apenas, move cursor)
       mov ah, 13h  ; função escrever string na tela
       int 10h      ; interrupção de vídeo
       pop bp
       ret

;; função que imprime a partir da última posição
_imprime:
       push bp     ; preserva BP
       ;; encontra a posição atual do cursor
       mov ah, 03h  ; função
       mov bh, 0    ; página
       int 10h      ; interrupção de vídeo
       ;; prepara para imprimir
       mov bp,sp   ; obtém o topo da pilha
       mov si, [bp+4] ;obtém o ponteiro da string
       ; calcula o tamanho da string
       xor cx,cx   ; zera CX
       cld         ; muda direção para crescente
.laco: lodsb       ; carrega em AL e incrementa SI
       and al,al   ; testa o valor
       jz .fimstr   ; achou fim da string
       inc cx      ; incrementa contador
       jmp .laco   ; repete até encontrar fim
.fimstr: ;; encontrou o tamanho da string
       mov ax,[bp+4] ; obtém o ponteiro para a string
       mov bp,ax
       mov bh, 0    ; página
       mov bl, 15   ; atributo
       mov al, 1    ; modo de escrita (caracteres apenas, move cursor)
       mov ah, 13h  ; função escrever string na tela
       int 10h      ; interrupção de vídeo
       pop bp
       ret

;; função que limpa a tela
_limpa_tela:  ;; limpa a tela
      mov ah, 02    ; função 02 muda cursor
      mov bh, 0     ; página zero
      mov dh, 0     ; linha zero
      mov dl, 0     ; coluna zero
      int 10h       ; interrupção de vídeo
      mov ah, 09h   ; função imprimir caracter
      mov al, ' '   ; espaço em branco para imprimir
      mov bh, 0     ; página
      mov bl, 15    ; atributo
      mov cx, 25*80 ; total de caracteres
      int 10h       ; interrupção de vídeo
      ret


impA:	incbin 'impA.bin'
_tamA dw ($-impA)	
_impA dw impA

impB:	incbin 'impB.bin'
_tamB dw ($-impB)	
_impB dw impB
