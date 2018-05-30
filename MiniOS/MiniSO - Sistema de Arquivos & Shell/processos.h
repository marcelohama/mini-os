#ifndef PROCESSOS_H
#define PROCESSOS_H

#include "tipos.h"

void Inicia_tabela_processos(void);
   /* Inicializa os valores na tabela de processos */

int Cria_processo(usint scod, usint dcod, usint tam);
   /* Cria um processo associado ao código indicado */
   /* sendo:                                        */
   /* scod => segmento onde está código             */
   /* dcod => deslocamento onde está o código       */
   /* tam => tamanho do código do processo          */
   /* retorno: 0 => sucesso  -1 => falha            */

#endif
