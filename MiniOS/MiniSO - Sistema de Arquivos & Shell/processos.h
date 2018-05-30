#ifndef PROCESSOS_H
#define PROCESSOS_H

#include "tipos.h"

void Inicia_tabela_processos(void);
   /* Inicializa os valores na tabela de processos */

int Cria_processo(usint scod, usint dcod, usint tam);
   /* Cria um processo associado ao c�digo indicado */
   /* sendo:                                        */
   /* scod => segmento onde est� c�digo             */
   /* dcod => deslocamento onde est� o c�digo       */
   /* tam => tamanho do c�digo do processo          */
   /* retorno: 0 => sucesso  -1 => falha            */

#endif
