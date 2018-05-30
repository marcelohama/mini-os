ORG 7C00h

         ;; define o destino do so carregado
inicio:	 mov ax,seg_cod_des ; segmento de destino
	 mov es,ax
	 mov bx,off_cod_des ; offset de destino
         ;; faz a leitura do so
         mov ah,02   ; fun��o de leitura de setores
	 mov al,63   ; n�mero de setores a ser lido
	 mov ch, 0   ; cilindro
	 mov cl, 2   ; setor
	 mov dh, 0   ; cabe�a
	 mov dl, 0   ; driver A
	 int 13h    ; faz a leitura
   jmp seg_cod_des:off_cod_des  ; executa o c�digo

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AREA DE DADOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

seg_cod_des   equ  800h        ; segmento do endere�o de destino
off_cod_des   equ  0h     ; deslocamento do destino


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Finalizador do setor de boot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

times 510-($-$$) db 0   ; completa setor de boot
          db 55h, 0AAh  ; identificador do setor de boot

;;restante do disquete

kernel:
;;;;; 64 setores do kernel
 incbin "kernel.bin"  ;; inclui o kernel pr�-compilada

times 32768-($-kernel) db 0     ;; completa espa�o dos arquivos

arquivos:

times 1440256-($-arquivos) db 0     ;; completa espa�o dos arquivos