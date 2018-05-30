ORG 7C00h

         ;; define o destino do so carregado
inicio:	 mov ax,seg_cod_des ; segmento de destino
	 mov es,ax
	 mov bx,off_cod_des ; offset de destino
         ;; faz a leitura do so
         mov ah,02   ; fun�o de leitura de setores
	 mov al,63   ; nmero de setores a ser lido
	 mov ch, 0   ; cilindro
	 mov cl, 2   ; setor
	 mov dh, 0   ; cabe�
	 mov dl, 0   ; driver A
	 int 13h    ; faz a leitura
   jmp seg_cod_des:off_cod_des  ; executa o c�igo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AREA DE DADOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

seg_cod_des   equ  800h        ; segmento do endere� de destino
off_cod_des   equ  0h     ; deslocamento do destino


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Finalizador do setor de boot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

times 510-($-$$) db 0   ; completa setor de boot
          db 55h, 0AAh  ; identificador do setor de boot

;;restante do disquete

kernel:
;;;;; 64 setores do kernel
 incbin "kernel.bin"  ;; inclui o kernel pr�compilada

times 32768-($-kernel) db 0     ;; completa espa� dos arquivos

;; Tabela de arquivos raiz
tabraiz:
;entrada 1 - arquivo
    db "teste"      ; nome do primeiro arquivo
    db "txt"        ; extens�
    dw 78           ; setor inicial
    dw 1            ; tipo do arquivo
    dw 0,0          ; reservado
;; entrada 2 - diret�io
    db "diret"      ; nome do diret�io
    db 0,0,0        ; extens�
    dw 79           ; setor inicial
    dw 2            ; tipo do arquivo
    dw 0,0          ; reservado
;; entrada 3 - executavel impA
    db "impA",0      ; nome do diret�io
    db 0,0,0        ; extens�
    dw 86           ; setor inicial
    dw 1            ; tipo do arquivo
    dw 0,0          ; reservado
;; entrada 4 - executavel impB
    db "impB",0      ; nome do diret�io
    db 0,0,0        ; extens�
    dw 87           ; setor inicial
    dw 1            ; tipo do arquivo
    dw 0,0          ; reservado
times 512-($-tabraiz) db 0     ;; completa espa� da tabela de arquivos da raiz


;; define constantes para a tabela de Aloca�o
setorSO equ -3
setorFinal equ -1
setorLivre equ -2

;; Tabela de Aloca�o de arquivos
tabaloc:
    times 78 dw setorSO                ;; setores do sistema operacional
    dw setorFinal ;;78                 ;; setor final do arquivo teste.txt
    dw setorFinal ;;79                 ;; setor da tabela diret
    dw 85         ;;80                 ;; setor 1 do arquivo diret/teste
    dw setorLivre ;;81                 ;; setor n� usado
    dw setorFinal ;;82                 ;; setores final de diret/teste
    dw setorLivre ;;83                 ;; setor n� usado
    dw setorLivre ;;84                 ;; setor n� usado
    dw 82         ;;85                 ;; setor 2 do arquivo diret/teste
    dw setorFinal ;;86
    dw setorFinal ;;87
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
    dw setorLivre
times 12*512-($-tabaloc) db setorLivre ;; completa espa� da tabela de aloca�o de arquivos


arquivos:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; setor 78 - arquivo teste.txt
arq_teste_txt:
	db "Conteudo do arquivo teste.txt",10,13
        db "Este e um arquivo simples",10,13
        db "Para teste do miniso", 10,13
   times 512-($-arq_teste_txt) db 0        ;; completa espa� do setor do arquivo teste.txt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;setor 79 - tabela do subdiret�io diret
tabdiret:
;entrada 1 - arquivo
    db "teste"      ; nome do primeiro arquivo
    db 0,0,0        ; extens�
    dw 80           ; setor inicial
    dw 1            ; tipo do arquivo
    dw 0,0          ; reservado
times 512-($-tabdiret) db 0     ;; completa espa� da tabela de arquivos da raiz

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;setor 80 - setor 1 do arquivo diret/teste
times 256 db 'S1'    ; cheio com as letras S1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;setor 81 - setor n� usado
times 512 db 0       ; n� usado

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;setor 82 - setor 2 do arquivo diret/teste
times 256 db 'S2'    ; cheio com as letras S2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;setor 83 - setor n� usado
times 512 db 0       ; n� usado

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;setor 84 - setor n� usado
times 512 db 0       ; n� usado

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;setor 85 - setor 3 (final) do arquivo diret/teste
times 256 db 'S3'    ; cheio com as letras S2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; setor 86 - execut�el impA
arq_impA:
    incbin 'impA.bin'
    times 512-($-arq_impA) db 0        ;; completa espa� do setor do arquivo teste.txt

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; setor 87 - execut�el impB
arq_impB:
    incbin 'impB.bin'
    times 512-($-arq_impB) db 0        ;; completa espa� do setor do arquivo teste.txt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; demais setores
times 2802*512-($-arquivos) db 0     ;; completa espa� dos demais setores