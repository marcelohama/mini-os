BITS 16
section .text
global _impa
global _tama
global _impb
global _tamb

;----------------------------------------------------------;
; CHAMADA DA FUNcaO EM C                                   ;
;----------------------------------------------------------;
   global _main
   extern _principal
_main:
   mov ax, 800h
   mov ds, ax
   mov es, ax
   call _principal
fim: jmp fim

;----------------------------------------------------------;
; IMPRESSaO A PARTIR DA POSIcaO DADA                       ;
;----------------------------------------------------------;
   global _imprimexy				;; exportando a funcao
_imprimexy:
   push bp					;; preserva BP
   mov bp,sp					;; obtem o topo da pilha
   mov si, [bp+8]				;; obtem o ponteiro da string
   xor cx,cx					;; zera CX
.laco: lodsb					;; carrega em AL e incrementa SI
   and al,al					;; testa o valor
   jz .fimstr					;; achou fim da string
   inc cx					;; incrementa contador
   jmp .laco					;; repete ate encontrar fim
.fimstr:
   mov dx,[bp+4]				;; obtem a coluna
   mov ax,[bp+6]				;; obtem a linha
   mov dh, al					;;
   mov ax,[bp+8]				;; obtem o ponteiro para a string
   mov bp,ax					;;
   mov bh, 0					;; pagina
   mov bl, 15					;; atributo
   mov al, 1					;; modo de escrita (caracteres apenas, move cursor)
   mov ah, 13h					;; funcao escrever string na tela
   int 10h					;; interrupcao de video
   pop bp
   ret

;----------------------------------------------------------;
; IMPRESSaO A PARTIR DA POSIcaO DO CURSOR                  ;
;----------------------------------------------------------;
   global _imprime
_imprime:
   push bp					;; preserva BP
   mov ah, 03h					;; funcao
   mov bh, 0					;; pagina
   int 10h					;; interrupcao de video
   mov bp,sp					;; obtem o topo da pilha
   mov si, [bp+4]				;; obtem o ponteiro da string
   xor cx,cx					;; zera CX
.laco: lodsb					;; carrega em AL e incrementa SI
   and al,al					;; testa o valor
   jz .fimstr					;; achou fim da string
   inc cx					;; incrementa contador
   jmp .laco					;; repete ate encontrar fim
.fimstr:
   mov ax,[bp+4]				;; obtem o ponteiro para a string
   mov bp,ax					;; 
   mov bh, 0					;; pagina
   mov bl, 15					;; atributo
   mov al, 1					;; modo de escrita (caracteres apenas, move cursor)
   mov ah, 13h					;; funcao escrever string na tela
   int 10h					;; interrupcao de video
   pop bp
   ret

;----------------------------------------------------------;
; LIMPADOR DE TELA                                         ;
;----------------------------------------------------------;
   global _limpa_tela				;; exportando a funcao
_limpa_tela:
   mov ah, 02					;; funcao 02 muda cursor
   mov bh, 0					;; pagina zero
   mov dh, 0					;; linha zero
   mov dl, 0					;; coluna zero
   int 10h					;; interrupcao de video
   mov ah, 09h					;; funcao imprimir caracter
   mov al, ' '					;; espaco em branco para imprimir
   mov bh, 0					;; pagina
   mov bl, 15					;; atributo
   mov cx, 25*80				;; total de caracteres
   int 10h					;; interrupcao de video
   ret

;----------;
; Tarefa 8 ;
;--------------------------------------------------------------------------------------------------------------------------------;
; void CodeCopy(unsigned short SegS, unsigned short OffsetS, unsigned short SegD, unsigned short OffsetD, unsigned short NBytes) ;
;--------------------------------------------------------------------------------------------------------------------------------;
   global _CodeCopy
_CodeCopy:
   push bp					;; guardando bp
   mov bp,sp					;; movendo o topo da pilha para bp

   mov ds,[bp+4]				;; obtendo o segmento fonte
   mov si,[bp+6]				;; obtendo o offset fonte
   mov es,[bp+8]				;; obtendo o segmento destino
   mov di,[bp+10]				;; obtendo o offset destino
   mov cx,[bp+12]				;; obtendo o numero de bytes a copiar
   rep movsb					;; copia cx vezes

   pop bp					;; recuperando bp
   mov ax,800h					;; ax recebe o segmento do kernel
   mov es,ax					;; reatualizando es
   ret						;; retornando

;----------;
; Tarefa 9 ;
;-----------------------------------;
; extern void StackInit(char Index) ;
;-----------------------------------;
   global _StackInit
   extern _SegmentProcessTake
   extern _TableRefresh
_StackInit:
   push bp					;; guarda bp na pilha
   mov bp,sp					;; bp recebe o topo da pilha

   mov bx,[bp+4]				;; recebe o indice do processo
   push bx					;; empilha o indice para a funcao externa achar o segmento
   call _SegmentProcessTake			;; achando o segmento do processo pedido
   mov sp,bp					;; sp recebe o seu valor anterior

   mov es,ax					;; move segmento do processo para es
   mov di,0x7FFE				;; di recebe o offset final do segmento
   std						;; seta o flag da direcao

   mov ax,0x0200				;; ax recebe 0x0200
   stosw					;; salvando-se o topo da pilha
   mov ax,es					;; prepara ax para salvar es
   stosw					;; salva es na pilha

   xor ax,ax					;; zerando ax
   mov cx,5					;; contador de registradores a salvar
   rep stosw					;; salvando os registradores ip, ax, bx, cx, dx
   mov ax,es					;; preparando para salvar os segmentos ds, es
   stosw					;; salvando-se ds
   stosw					;; salvando-se es
   xor ax,ax					;; zerando ax
   stosw					;; salvando-se bp
   stosw					;; salvando-se di
   mov[es:di],ax				;; [es:di] recebe ax, salvando-se si

   push bx					;; empilha bx para obtencao do indice em C
   push di					;; empilha di para atualizar sp em C
   push es					;; empilha es para atualizar ss em C
   call _TableRefresh				;; chama funcao para atribuir ss sp  na tabela de processo
   mov sp,bp					;; reatualiza sp

   pop bp					;; recupera bp
   mov ax,800h					;; ax recebe o segmento do kernel
   mov es,ax					;; reatualizando es
   ret						;; retornando

;-----------;
; Tarefa 12 ;
;----------------------------------;
; extern void NewInterrupt08(void) ;
;----------------------------------;
   global _NewInterrupt08
   extern _ChangeToReady
   extern _TableProcess
   extern _TableRefresh2
   extern _LoadProcess
   extern _NextProcess
_NewInterrupt08:
                            			;;[item a]
   push ax					;; salvando ax na pilha
   push bx					;; salvando bx na pilha
   push cx					;; salvando cx na pilha
   push dx					;; salvando dx na pilha
   push ds					;; salvando ds na pilha
   push es					;; salvando es na pilha
   push bp					;; salvando bp na pilha
   push di					;; salvando di na pilha
   push si					;; salvando si na pilha
                            			;;[item b]
   call _ChangeToReady				;; colocando o processo atual em estado ready
                            			;;[item c]
   mov dx,sp					;; usa dx como seguranca
   push dx					;; passa ss como parametro
   mov dx,ss					;; usa dx como seguranca
   push dx					;; passa sp como parametro
   call _TableRefresh2				;; chama funcao para atribuir ss sp  na tabela de processo
   add sp,4					;; corrige o topo da pilha
                            			;;[item d]
   xor bx,bx					;; carrega em bx o indice 0, que e o do SO
   push bx					;; manda bx como parametro
   call _LoadProcess				;; chama o carregamento de funcao, retornando em ax seu endereco
   add sp,2					;; corrige o topo da pilha
   mov bx,ax					;; coloca em bx o endereco do processo do SO
   mov ss,[bx]					;; coloca em SS o SS do SO
   mov sp,[bx+2]				;; coloca em SP o SP do SO
                           			;;[item e]
   pushf		 			;; salvando flags na pilha
   mov ax,800h					;; ax recebe o segmento do SO
   push ax					;; empilha ax
   mov ax,.salvaInt				;; ax recebe endereco do label .salvaInt para chama-lo em _InterruptExchange
   push ax					;; empilha ax
   jmp far [ClockBackUp]			;; desvio para a troca de interrupcao
.salvaInt:					;; label de retorno
						;;[item f]
   call _NextProcess				;; procura o proximo processo nao usado
						;;[item g]
   mov dx,sp					;; usa dx como seguranca
   push dx					;; passa sp como parametro
   mov dx,ss					;; usa dx como seguranca
   push dx					;; passa ss como parametro
   call _TableRefresh2				;; armazena o ss e o sp do SO
   add sp,4					;; corrige o topo da pilha
						;;[item h]
   push ax					;; passa ax como parametro, que contem o indice do processo nao usado
   mov dx,sp					;; usa dx como seguranca
   push dx					;; passa sp como parametro, que contem o indice do processo nao usado
   mov dx,ss					;; usa dx como seguranca
   push dx					;; passa ss como parametro, que contem o indice do processo nao usado
   call _TableRefresh				;; chama o carregamento de funcao, retornando em ax seu endereco
   add sp,6					;; corrige o topo da pilha
						;;[item i]
   pop si					;; recupera si
   pop di					;; recupera di
   pop bp					;; recupera bp
   pop es					;; recupera es
   pop ds					;; recupera ds
   pop dx					;; recupera dx
   pop cx					;; recupera cx
   pop bx					;; recupera bx
   pop ax					;; recupera ax
   iret						;; retorna

ClockBackUp dw 0,0

;-----------;
; Tarefa 13 ;
;-------------------------------------;
; extern void InterruptExchange(void) ;
;-------------------------------------;
   global _InterruptExchange
_InterruptExchange:

   cli				;; desabilitando as interrupcoes
   xor ax,ax			;; zerando ax para passa-lo para es
   mov es,ax			;; zera es, que passara a conter o endereco dos vetores (segmento 0x0000)

   mov bx,[es:20h]		;; obtendo o endereco da interrupcao 08h no vetor
   mov [ClockBackUp],bx		;; coloca o endereco da interrupcao do relogio em [ClockBackUp]
   mov bx,[es:22h]		;; obtendo o segundo word do endereco
   mov [ClockBackUp+2],bx	;; colocando o segundo word na tabela

   mov ax,800h			;; ax recebe o segmento do kernel
   mov [es:22h],ax		;; tabela passa a conter o segmento do kernel (segmento 0x0800)
   mov ax,_NewInterrupt08	;; ax recebe o offset da interrupcao
   mov [es:20h],ax		;; tabela passa a conter o offset do kernel
   mov ax,0x800			;; ax recebe o segmento do kernel
   mov es,ax			;; reatualiza es

   sti				;; libera para ocorrencia de interrupcao
   ret

;------------------;
; Processos testes ;
;-------------------------------------;
; extern void InterruptExchange(void) ;
;-------------------------------------;
impa: incbin "impa.bin"
_tama dw ($-impa)
_impa dw impa

impb: incbin "impb.bin"
_tamb dw ($-impb)
_impb dw impb