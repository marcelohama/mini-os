#ifndef TIPOS_H
#define TIPOS_H

#define pronto 0
#define nusado 1
#define bloqueado 2 
#define rodando 3

typedef unsigned short int usint; /* apelido para inteiro de 16 bits sem sinal */
typedef short int sint;           /* apelido para inteiro de 16 bits com sinal */

typedef struct {
   usint estado;  /* estado do processo */
   usint ss,sp;   /* armazena o topo da pilha */
   usint tempo;   /* tempo total de execução, em interrupções */
} stprocesso;

#endif 
