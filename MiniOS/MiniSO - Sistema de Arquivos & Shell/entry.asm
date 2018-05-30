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
    ;; chama a fun��o
    call _principal      ;; chama fun��o do C
fim: jmp fim

;; fun��o que imprime em posi��o xy da tela
_imprimexy:
       push bp     ; preserva BP
       ;; prepara para imprimir
       mov bp,sp   ; obt�m o topo da pilha
       mov si, [bp+8] ;obt�m o ponteiro da string
       ; calcula o tamanho da string
       xor cx,cx   ; zera CX
       cld         ; muda dire��o para crescente
.laco: lodsb       ; carrega em AL e incrementa SI
       and al,al   ; testa o valor
       jz .fimstr   ; achou fim da string
       inc cx      ; incrementa contador
       jmp .laco   ; repete at� encontrar fim
.fimstr: ;; encontrou o tamanho da string
       mov dx,[bp+4] ; obt�m a coluna
       mov ax,[bp+6] ; obt�m a linha
       mov dh, al
       mov ax,[bp+8] ; obt�m o ponteiro para a string
       mov bp,ax
       mov bh, 0    ; p�gina
       mov bl, 15   ; atributo
       mov al, 1    ; modo de escrita (caracteres apenas, move cursor)
       mov ah, 13h  ; fun��o escrever string na tela
       int 10h      ; interrup��o de v�deo
       pop bp
       ret

;; fun��o que imprime a partir da �ltima posi��o
_imprime:
       push bp     ; preserva BP
       ;; encontra a posi��o atual do cursor
       mov ah, 03h  ; fun��o
       mov bh, 0    ; p�gina
       int 10h      ; interrup��o de v�deo
       ;; prepara para imprimir
       mov bp,sp   ; obt�m o topo da pilha
       mov si, [bp+4] ;obt�m o ponteiro da string
       ; calcula o tamanho da string
       xor cx,cx   ; zera CX
       cld         ; muda dire��o para crescente
.laco: lodsb       ; carrega em AL e incrementa SI
       and al,al   ; testa o valor
       jz .fimstr   ; achou fim da string
       inc cx      ; incrementa contador
       jmp .laco   ; repete at� encontrar fim
.fimstr: ;; encontrou o tamanho da string
       mov ax,[bp+4] ; obt�m o ponteiro para a string
       mov bp,ax
       mov bh, 0    ; p�gina
       mov bl, 15   ; atributo
       mov al, 1    ; modo de escrita (caracteres apenas, move cursor)
       mov ah, 13h  ; fun��o escrever string na tela
       int 10h      ; interrup��o de v�deo
       pop bp
       ret

;; fun��o que limpa a tela
_limpa_tela:  ;; limpa a tela
      mov ah, 02    ; fun��o 02 muda cursor
      mov bh, 0     ; p�gina zero
      mov dh, 0     ; linha zero
      mov dl, 0     ; coluna zero
      int 10h       ; interrup��o de v�deo
      mov ah, 09h   ; fun��o imprimir caracter
      mov al, ' '   ; espa�o em branco para imprimir
      mov bh, 0     ; p�gina
      mov bl, 15    ; atributo
      mov cx, 25*80 ; total de caracteres
      int 10h       ; interrup��o de v�deo
      ret


impA:	incbin 'impA.bin'
_tamA dw ($-impA)	
_impA dw impA

impB:	incbin 'impB.bin'
_tamB dw ($-impB)	
_impB dw impB
