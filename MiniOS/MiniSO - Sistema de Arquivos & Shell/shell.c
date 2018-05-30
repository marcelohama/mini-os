#include "shell.h"
#include "kernel.h"
#include "processos.h"
#include "divide.h"

/**************************\
| TABELA DE ARQUIVOS & FAT | OK!
|************************************************************************************|
| Definicao no segmento do kernel de uma estrutura para montagem da pagina atual da  |
| tabela de arquivos. Toda vez que um setor e lido, ele e armazenado no vetor struct |
| [Files]. Cada setor tem 32 entradas de arquivos de 16 bytes, totalizando 512 bytes |
| por setor. [FAT] e uma tabela do tipo Lista-Ligada onde indica-se o proximo setor  |
| a ler-se. Se FAT[setorX] == -1, entao setorX e o setor final do arquivo lido.      |
|************************************************************************************/
struct tabFile {
   char name[5];
   char sufix[3];
   usint initialSector;
   usint fileType;
   long int reserved;
} Files[32];
int FAT[3072];

/**************************\
| ANEXOS DAS TAREFAS 2 & 4 | OK!
|************************************************************************************|
| Definicao das variaveis globais que guardam:                                       |
| tabproc --------------> tabela de processos do kernel;                             |
| curDirectory ---------> nome completo do diretorio atual                           |
| bufferPrompt ---------> buffer que guarda os caracteres digitados no prompt        |
| curDirectorySector ---> guarda o setor inicial do diretorio atual                  |
|************************************************************************************/
extern stprocesso tabproc[19];
char curDirectory[128];
char bufferPrompt[64];
usint curDirectorySector = 65;

/************************\
| MANIPULACAO DE STRINGS | OK!
|************************************************************************************|
| Definicao das variaveis globais que guardam:                                       |
| CopyString -----------> copia a string de [Origin] para [Destiny]                  |
| FuseString -----------> concatena a string [Secondary] no fim de [Primary]         |
| StringLength ---------> retorna quantos caracteres tem a string [String]           |
| StringCmp ------------> retorna 0 se [Str1] for diferente de [Str2] e 1 se forem   |
| elas forem iguais.                                                                 |
|************************************************************************************/
void CopyString(char *Origin, char *Destiny) {
   usint position = 0;
   while(Origin[position] != '\0') {
      Destiny[position] = Origin[position];
      position++;
   }
   Destiny[position] = '\0';
}
/************************************************************************************/
void FuseString(char *Primary, char *Secondary) {
   usint positionP = 0, positionS = 0;
   while(Primary[positionP] != '\0')
      positionP++;
   while(Secondary[positionS] != '\0') {
      Primary[positionP] = Secondary[positionS];
      positionP++;
      positionS++;
   }
   Primary[positionP] = '\0';
}
/************************************************************************************/
usint StringLength(char *String) {
   usint n = 0;
   while(String[n] != '\0') n++;
   return n;
}
/************************************************************************************/
usint StringCmp(char *str1, char *str2) {
   usint pos1 = 0, pos2 = 0;
   while(str1[pos1] == str2[pos2] && str1[pos1] != '\0') {
      pos1++;
      pos2++;
   }
   if(str1[pos1] == '\0' && str2[pos2] == '\0') return 1;
   else return 0;
}
/************************************************************************************/

/**********\
| TAREFA 1 | OK!
|************************************************************************************|
| Funcao de exibicao da lista de processos. Nela e exibida uma tabela com o Process  |
| ID (PID), Status (running, ready, unused, blocked) e Time (tempo de execucao). O   |
| tempo de execucao nao foi implementado.                                            |
|************************************************************************************/
void command_ps() {
   int i=0;
   char str[3];
   imprime(" \n\r");
   imprime("PID   STATUS     TIME\n\r");
   while(i<19) {
      if(tabproc[i].estado == rodando) {
         char_hex(i,str);
         imprime(str);
         imprime("    running\n\r");
      }
      else if(tabproc[i].estado == pronto) {
         char_hex(i,str);
         imprime(str);
         imprime("    ready\n\r");
      }
      else if(tabproc[i].estado == nusado) {
         char_hex(i,str);
         imprime(str);
         imprime("    unused\n\r");
      }
      else if(tabproc[i].estado == bloqueado) {
         char_hex(i,str);
         imprime(str);
         imprime("    blocked\n\r");
      }
      i++;
   }
   return;
}
/************************************************************************************/

/**********\
| TAREFA 2 | OK!
|************************************************************************************|
| Funcao de ajustamento de caminho absoluto. Recebe duas strings: [absWay] e [way],  |
| que sao os caminhos absolutos e relativos respectivamente. Sempre que o [way]      |
| comecar com o [/], isso indica que e passado um caminho absoluto. Quando nao       |
| houver o [/] no inicio do [way], entao ele e concatenado no fim do [absWay]. Apos  |
| estes ajustes, o [absWay] e fechado com um [/] em seu fim formando uma string da   |
| forma [/nome1/nome2/nome3/.../nomeN/]. A segunda parte elimina duplicacoes do [/]. |
|************************************************************************************/
void system_absolutWay(char *absWay, char *way) {
   usint i = 0, j;
   if(way[0] != '/') FuseString(absWay,way);
   else CopyString(way,absWay);
   while(absWay[i] != '\0') i++;
   if(absWay[i-1] != '/') {
      absWay[i] = '/';
      absWay[i+1]  = '\0';
   }
   i = 0;
   while(absWay[i] != '\0') {
      if(absWay[i] == absWay[i+1] && absWay[i] == '/') {
         j = i;
         while(absWay[j] != '\0') {
            absWay[j] = absWay[j+1];
            j++;
         }
      }
      i++;
   }
}
/************************************************************************************/

/**********\
| TAREFA 8 | OK!
|************************************************************************************|
| Funcao de mapeamento de disco. Recebe o parametro [logicSector] e atraves dele,    |
| encontra o [cylinder], [head] e [sector], definindo assim argumentos para funcoes  |
| de leitura e gravacao de disco.                                                    |
|************************************************************************************/
void system_discMaping(usint logicSector, usint *cylinder, usint *head, usint *sector) {
   *cylinder = divisao(logicSector,36);
   *head = resto(divisao(logicSector,18),2);
   *sector = 1+resto(logicSector,18);
}
/************************************************************************************/

/****************\
| LEITURA DA FAT | OK!
|************************************************************************************|
| Funcao que carrega a [FAT] do disco para o kernel na inicializacao                 |
|************************************************************************************/
void system_fatLoader() {
   usint cylinder,head,sector;
   system_discMaping(66, &cylinder, &head, &sector);
   system_dataRead(12, cylinder, sector, head, 0x0800, FAT);
}
/************************************************************************************/

/**********\
| TAREFA 9 | OK!
|************************************************************************************|
| Esta funcao recebe um caminho absoluto completo [way] e atraves dele, percorre as  |
| tabelas de diretorios procurando nome a nome o ultimo nome dado. A funcao recebe   |
| tambem o argumento [type] que indica o tipo do arquivo retornado.                  |
| Retorna 0 em caso de erro de leitura ou diretorio/arquivo nao encontrado ou o      |
| inicio do setor do arquivo encontrado.                                             |
|************************************************************************************/
int system_fileInitialSector(char *way, usint *type) {
   usint i, cylinder, head, sector = 0, wayPos = 0, tabFileIndex = 0;
   char fileName[6], curDir[6]; curDir[0] = '/'; curDir[1] = '\0';
   /* leitura da tabela raíz */
   system_discMaping(65, &cylinder, &head, &sector);
   system_dataRead(1, cylinder, sector, head, 0x0800, Files);
   /* caso o caminho dado seja o root "/" */
   if(StringLength(way) == 1 && StringCmp(way,"/") == 1) {
      *type = 2;
      return 65;
   }
   /* senão, procura pelo diretório */
   else {
      /* obtendo o nome do diretório */
      system_drawSubFile(way,curDir,&wayPos);
      /* montando uma string com o nome do diretório */
      for(i=0;i<5;i++)
         fileName[i] = Files[tabFileIndex].name[i];
      fileName[i] = '\0';
      /* varre a tabela de arquivos tentando obter o nome até que seja encontrado o fim do caminho */
      while(tabFileIndex != 32 && wayPos <= StringLength(way)) {
         /* achou um nome coincidente */
         if(StringCmp(curDir,fileName) == 1) {
            /* caso seja um arquivo e se é o último nome procurado, retorna seu setor inicial */
            if(Files[tabFileIndex].fileType == 1 && wayPos >= StringLength(way)) {
               *type = 1;
               return Files[tabFileIndex].initialSector;
            }
            /* caso seja um diretório */
            if(Files[tabFileIndex].fileType == 2) {
               /* se for o último nome procurado, retorna seu setor inicial */
               if(wayPos >= StringLength(way)) {
                  *type = 2;
                  return Files[tabFileIndex].initialSector;
               }
               /* se não for o último nome procurado, lê o disco novamente e procura próximo nome */
               else {
                  system_discMaping(Files[tabFileIndex].initialSector, &cylinder, &head, &sector);
                  system_dataRead(1, cylinder, sector, head, 0x0800, Files);
                  tabFileIndex = 0;
                  system_drawSubFile(way,curDir,&wayPos);
                  for(i=0;i<5;i++)
                     fileName[i] = Files[tabFileIndex].name[i];
                  fileName[i] = '\0';
               }
            }
         }
         /* não achou nome coincidente, incrementa o índice */
         else {
            tabFileIndex++;
            /* montando uma string com o nome do diretório */
            for(i=0;i<5;i++)
               fileName[i] = Files[tabFileIndex].name[i];
            fileName[i] = '\0';
         }
      }
   }
   /* retorna 0 caso nao encontre nada */
   return 0;
}

/*******************\
| ANEXO DA TAREFA 9 | OK!
|************************************************************************************|
| Funcao de retorno de substring a partir de uma string da forma [/nome1/nome2/.../] |
| que retorna os campos [nomeN] em funcao de um indice de posicao. Esta funcao nao   |
| serve para ser usada em nenhum outro lugar senao na tarefa 9.                      |
|************************************************************************************/
usint system_drawSubFile(char *sourceString, char *subFile, usint *sourcePos) {
   usint subFilePos = 0;
   if((*sourcePos) == 0) (*sourcePos)++;
   while(sourceString[*sourcePos] != '/') {
      subFile[subFilePos] = sourceString[*sourcePos];
      (*sourcePos)++;
      subFilePos++;
   }
   (*sourcePos)++;
   subFile[subFilePos] = '\0';
}
/************************************************************************************/

/********************\
| EXTRA - COMANDO CD | OK!
|************************************************************************************|
| O comando [CD] recebe uma string que indica um caminho que e analisado pela funcao |
| [absolutWay]. O absWay obtido, se retorna um setor inicial de diretorio, e entao   |
| copiado para o [curDirectory] e o setor vai em curDirectorySector.                 |
|************************************************************************************/
void command_cd(char *way) {
   char tempWay[128];
   int sector, type;
   usint index = 0;
   while(way[index] != '\0') {
      if((way[index] == '/' && way[index+1] == '/') || way[index] == '|' || way[index] == '?' || way[index] == '\\') {
         imprime(" [caminho invalido]");
         return;
      }
      index++;
   }
   CopyString(curDirectory,tempWay);
   system_absolutWay(tempWay,way);
   sector = system_fileInitialSector(tempWay,&type);
   if((sector > 0 && type == 2 && FAT[sector] != -2) || sector == 65) {
      curDirectorySector = sector;
      CopyString(tempWay,curDirectory);
   }
   else imprime(" [arquivo ou diretorio nao encontrado]");
}
/************************************************************************************/

/***********\
| TAREFA 10 | OK!
|************************************************************************************|
| O comando [LS] tem a funcao de listar os diretorios e arquivos contidos no atual   |
| diretorio ou no diretorio passado como parametro. Recebe-se um caminho, que e em   |
| seguida concatenado com o diretorio atual e verificado sua existencia, lista-se os |
| seus itens.                                                                        |
|************************************************************************************/
void command_ls(char *way) {
   char i, j, fileName[6], diretorio[128];
   usint dirSec, type, cylinder, sector, head, tabFileIndex = 0;
    /* obtendo o caminho absoluto do arquivo */
   CopyString(curDirectory,diretorio);
   system_absolutWay(diretorio,way);
   dirSec = system_fileInitialSector(diretorio,&type);
   if(dirSec <= 0 || type != 2) {
      imprime(" [diretorio nao encontrado]");
      return;
   }
   /* achou o diretorio e imprimindo os itens */
   imprime("\n\n\rO Diretorio ["); imprime(diretorio); imprime("] contem os seguintes itens:");
   imprime("\n\rNOME ========== TIPO ========== SETOR === EXTENSAO\n\r");
   while(dirSec != -1 && dirSec != -2 && dirSec != -3) {
      system_discMaping(dirSec, &cylinder, &head, &sector);
      system_dataRead(1, cylinder, sector, head, 0x0800, Files);
      for(tabFileIndex=0;tabFileIndex<32;tabFileIndex++) {
         if(FAT[Files[tabFileIndex].initialSector] >= -1 ) {
            for(i=0;i<6;i++) fileName[i] = '\0';
            for(i=0;i<5;i++) fileName[i] = Files[tabFileIndex].name[i];
            imprime(fileName); imprime(" ");
            for(i=0;i<14-StringLength(fileName);i++) imprime("-");
            if(Files[tabFileIndex].fileType == 2) imprime(" diretorio -----   ");
            else imprime(" arquivo -------   ");
            printInt(Files[tabFileIndex].initialSector);
            imprime("  --- ");
            for(i=0;i<3;i++) fileName[i] = Files[tabFileIndex].name[i+5];
            fileName[3] = '\0';
            imprime(fileName);
            imprime("\n\r");
         }
      }
      dirSec = FAT[dirSec];
   }
}
/************************************************************************************/

/***********\
| TAREFA 11 | OK!
|************************************************************************************|
| Esta funcao recebe [way], [buffer] e [maxSize], e inicia uma copia do arquivo em   |
| setor inicial achado por [way]. O conteudo e guardado em [buffer]. A copia ira     |
| terminar se o arquivo acabar ou o tamanho do buffer ter chegado ao limite.         |
|************************************************************************************/
usint system_fileInfoLoader(char *way, char *buffer, usint maxSize) {
   char fileName[128];
   usint curSector, cylinder, head, sector, type, bufpos = 0, index = 512, nReadSector = 0;
   /* recebendo o setor inicial do arquivo */
   CopyString(curDirectory,fileName);
   system_absolutWay(fileName,way);
   curSector = system_fileInitialSector(fileName,&type);
   /* inicia cópia até o setor final se não for um diretório */
   if(type == 2 && FAT[curSector] != -2) {
      imprime(" [arquivo nao encontrado]");
      return 0;
   }
   do {
      /* é iniciado um novo setor de 512 em 512 bytes */
      if(index == 512) {
         /* se há erro de leitura ou esta no setor final e ja o leu, retorna */
         if(curSector == 0 || (FAT[curSector] == -1 && nReadSector != 0)) return nReadSector;
         if(nReadSector != 0) curSector = FAT[curSector];
         nReadSector++;
         system_discMaping(curSector, &cylinder, &head, &sector);
         system_dataRead(1, cylinder, sector, head, 0x0800, Files);
         index = 0;
      }
      /* lê caracteres, incrementa índices e copia no buffer */
      buffer[bufpos++] = Files[0].name[index++];
   } while(bufpos < maxSize);
}

/************************************************************************************/

/***********\
| TAREFA 12 | OK!
|************************************************************************************|
| Esta funcao recebe [way], [buffer] e [maxSize], e inicia uma copia do arquivo em   |
| setor inicial achado por [way]. O conteudo e guardado em [buffer]. A copia ira     |
| terminar se o arquivo acabar ou o tamanho do buffer ter chegado ao limite.         |
|************************************************************************************/
void command_cat(char *fileName) {
   /* caracter para leitura, variáveis e obtenção do setor inicial */
   char buffer[4096], way[128];
   usint type, curSector, cylinder, head, sector, nReadedSectors, index = 0;
   /* obtendo o caminho absoluto do arquivo */
   CopyString(curDirectory,way);
   system_absolutWay(way,fileName);
   /* obtendo o setor */
   curSector = system_fileInitialSector(way,&type);
   nReadedSectors = system_fileInfoLoader(way, buffer, sizeof(buffer));
   if(curSector <= 0) {
      imprime(" [arquivo nao encontrado]");
      return;
   }
   if(nReadedSectors > 0 && type != 2) {
      imprime("\n\r");
      imprime(buffer);
   }
}
/************************************************************************************/

/***********\
| TAREFA 13 | OK!
|************************************************************************************|
| O comando [EXEC] recebe um caminho de arquivo e executa o seu conteudo.            |
|************************************************************************************/
void command_exec(char *fileName) {
   usint nSector;
   char buffer[512], way[128];
   /* montando o caminho absoluto */
   CopyString(curDirectory,way);
   system_absolutWay(way,fileName);
   /* executa o conteudo, caso tenha lido alguma coisa */
   nSector = system_fileInfoLoader(fileName, buffer, sizeof(buffer));
   if(nSector > 0) Cria_processo(0x0800, buffer, sizeof(buffer));
   else imprime(" [arquivo nao encontrado]");
}
/************************************************************************************/

/***********\
| TAREFA 14 | OK!
|************************************************************************************|
| Esta funcao procura por um nome dado. Se encontrado, carrega seu setor inicial e   |
| copia o buffer em cima dele. Se nao for encontrado este nome, entao e criado um    |
| novo setor a partir de analise da [FAT] e o conteudo do buffer e inserido.         |
|************************************************************************************/
usint system_fileInfoWriter(char *way, char *buffer, usint maxSize) {
   char fileName[128];
   int type;
   usint fatIndex, curSector, cylinder, head, sector, posbuf = 0, index = 0;
   /* recebendo o setor inicial do arquivo */
   CopyString(curDirectory,fileName);
   system_absolutWay(fileName,way);
   curSector = system_fileInitialSector(fileName,&type);
   /* obtem um setor livre caso nao encontre o setor pedido */
   if(curSector < 1) {
      for(fatIndex=0;fatIndex<3072 && FAT[fatIndex] != -2;fatIndex++);
      curSector = fatIndex;
   }
   /* iniciando a copia enquanto o [posbuf] for menor que o tamanho dado */
   do {
      for(index=0;index<512;index++) Files[0].name[index] = buffer[posbuf++];
      system_discMaping(curSector, &cylinder, &head, &sector);
      system_dataWrite(1, cylinder, sector, head, 0x0800, Files);
      /* completou a insercao de 1 setor e nao acabou ainda o buffer */
      if(posbuf < maxSize) {
         for(fatIndex=0;fatIndex<3072 && FAT[fatIndex] != -2;fatIndex++);
         FAT[curSector] = fatIndex;
         FAT[fatIndex] = -1;
         curSector = fatIndex;
      }
   } while(posbuf < maxSize);
}
/************************************************************************************/

/***********\
| TAREFA 15 | OK!
|************************************************************************************|
| Comando [MKDIR] que cria diretorios, dado um nome/caminho. Esta funcao recebe um   |
| caminho, que na verdade tambem e o nome do novo diretorio, sendo que o ultimo nome |
| e o diretorio a ser criado e o restante e o caminho.                               |
|************************************************************************************/
void command_mkdir(char *wayName) {
   char newName[8], fileName[128];
   int type;
   usint i, fatIndex, curSector, cylinder, head, sector, newDirSector, j = 0;
   /* recebendo o setor inicial do arquivo */
   CopyString(curDirectory,fileName);
   system_absolutWay(fileName,wayName);
   curSector = system_fileInitialSector(fileName,&type);
   /* conferindo se o diretorio nao existe */
   if(type > 0 && FAT[curSector] != -2) {
      imprime(" [este nome ja existe]");
      return;
   }
   /* obtendo o caminho e setor do diretorio pai, nome do novo diretorio e conferindo o tamanho*/
   for(i=0;i<128 && fileName[i] != '\0';i++) if(fileName[i+1] != '\0' && fileName[i] == '/') j=i;
   for(i=0;i<5;i++) newName[i] = fileName[j+1+i];
   for(i=0;i<5;i++) if(newName[i] == '/') newName[i] = '\0';
   fileName[j+1] = '\0';
   curSector = system_fileInitialSector(fileName,&type);
   system_discMaping(curSector, &cylinder, &head, &sector);
   system_dataRead(1, cylinder, sector, head, 0x0800, Files);
   if(StringLength(newName) > 5) {
      imprime(" [tamanho maximo de nome e 5 caracteres]");
      return;
   }
   /* procurando por uma entrada nao usada */
   i = 0; j = 0;
   while(Files[i].initialSector != 0) {
      if(FAT[Files[i].initialSector] == -2) break;
      /* [j] e um backup do setor atual */
      j = curSector;
      i++;
      /* se atingiu o fim do setor e nao e setor final, vai para o proximo */
      if(i == 32 && FAT[curSector] != -1) {
         i = 0;
         curSector = FAT[curSector];
         system_discMaping(curSector, &cylinder, &head, &sector);
         system_dataRead(1, cylinder, sector, head, 0x0800, Files);
      }
      /* estava ja no setor final, inicia portanto outro setor */
      else if(i == 32 && FAT[curSector] == -1) {
         for(i=0;i<3072 && FAT[i] != -2;i++);
         FAT[curSector] = i;
         FAT[i] = -1;
         system_discMaping(curSector, &cylinder, &head, &sector);
         system_dataRead(1, cylinder, sector, head, 0x0800, Files);
         i = 0;
      }
   }
   /* indicando o setor inicial do novo diretorio */
   for(newDirSector=0;newDirSector<3072 && FAT[newDirSector] != -2;newDirSector++);
   FAT[newDirSector] = -1;
   /* obtido o indice de entrada livre do diretorio pai, insere-se o novo diretorio */
   for(j=0;j<5;j++) Files[i].name[j] = newName[j];
   for(j=5;j<8;j++) Files[i].name[j] = '\0';
   Files[i].fileType = 2;
   Files[i].initialSector = newDirSector;
   system_discMaping(curSector, &cylinder, &head, &sector);
   system_dataWrite(1, cylinder, sector, head, 0x0800, Files);
}
/************************************************************************************/

/***********\
| TAREFA 16 | OK!
|************************************************************************************|
| Comando [RMDIR] que remove diretorios, dado um nome/caminho. Esta funcao recebe um |
| caminho, que na verdade tambem e o nome do diretorio a apagar, sendo que o ultimo  |
| nome e o diretorio a ser removido e o restante e o caminho.                        |
|************************************************************************************/
void command_rmdir(char *wayName) {
   char dropName[8], fileName[128];
   int type;
   usint i, fatIndex, curSector, cylinder, head, sector, newDirSector, j = 0;
   /* obtendo o caminho absoluto */
   CopyString(curDirectory,fileName);
   system_absolutWay(fileName,wayName);
   curSector = system_fileInitialSector(fileName,&type);
   /* conferindo se o diretorio existe e se esta vazio */
   if(type != 2) {
      imprime(" [este diretorio nao existe]");
      return;
   }
   else while(curSector != -1) {
      system_discMaping(curSector, &cylinder, &head, &sector);
      system_dataRead(1, cylinder, sector, head, 0x0800, Files);
      for(i=0;i<32;i++) {
         if(FAT[Files[i].initialSector] > -2) {
            imprime(" [este diretorio nao esta vazio]");
            return;
         }
      }
      curSector = FAT[curSector];
   }
   /* obtendo o caminho e setor do diretorio pai e nome do diretorio a remover */
   for(i=0;i<128 && fileName[i] != '\0';i++) if(fileName[i+1] != '\0' && fileName[i] == '/') j=i;
   for(i=0;i<5;i++) dropName[i] = fileName[j+1+i];
   for(i=0;i<5;i++) if(dropName[i] == '/') dropName[i] = '\0';
   fileName[j+1] = '\0';
   curSector = system_fileInitialSector(fileName,&type);
   system_discMaping(curSector, &cylinder, &head, &sector);
   system_dataRead(1, cylinder, sector, head, 0x0800, Files);
   /* removendo o diretorio passado */
   i = 0;
   while(1) {
      /* comparando os nomes */
      for(j=0;j<5;j++) if(dropName[j] != Files[i].name[j]) break;
      /* se iguais, remove */
      if(j == 5) {
         FAT[Files[i].initialSector] = -2;
         system_discMaping(66, &cylinder, &head, &sector);
         system_dataWrite(1, cylinder, sector, head, 0x0800, Files);
         return;
      }
      /* se nomes sao diferentes, [i=31] e nao e o setor final, atualiza a tabela */
      else if(i == 31 && curSector != -1) {
         curSector = FAT[curSector];
         system_discMaping(curSector, &cylinder, &head, &sector);
         system_dataRead(1, cylinder, sector, head, 0x0800, Files);
         i = 0;
      }
      /* senao vai para o proximo indice */
      else i++;
   }
}
/************************************************************************************/

/***********\
| TAREFA 17 | OK!
|************************************************************************************|
| Comando [RM] que remove arquivos, dado um nome/caminho. Esta funcao recebe um      |
| caminho, que na verdade tambem e o nome do arquivo a remover, sendo que o ultimo   |
| nome e o arquivo a ser removido e o restante e o caminho.                          |
|************************************************************************************/
void command_rm(char *wayName) {
   char dropName[8], fileName[128];
   int type;
   usint i, fatIndex, curSector, cylinder, head, sector, newDirSector, j = 0;
   /* obtendo o caminho absoluto */
   CopyString(curDirectory,fileName);
   system_absolutWay(fileName,wayName);
   curSector = system_fileInitialSector(fileName,&type);
   /* conferindo se o arquivo existe */
   if(type != 1) {
      imprime(" [este nome nao existe]");
      return;
   }
   /* obtendo o caminho e setor do diretorio pai e nome do arquivo a remover */
   for(i=0;i<128 && fileName[i] != '\0';i++) if(fileName[i+1] != '\0' && fileName[i] == '/') j=i;
   for(i=0;i<8;i++) dropName[i] = fileName[j+1+i];
   for(i=0;i<8;i++) if(dropName[i] == '/') dropName[i] = '\0';
   fileName[j+1] = '\0';
   curSector = system_fileInitialSector(fileName,&type);
   system_discMaping(curSector, &cylinder, &head, &sector);
   system_dataRead(1, cylinder, sector, head, 0x0800, Files);
   /* removendo o arquivo passado */
   i = 0;
   while(1) {
      /* comparando os nomes */
      for(j=0;j<5;j++) if(dropName[j] != Files[i].name[j]) break;
      /* se iguais, remove */
      if(j == 5) {
         FAT[Files[i].initialSector] = -2;
         Files[i].initialSector = 0;
         system_discMaping(curSector, &cylinder, &head, &sector);
         system_dataWrite(1, cylinder, sector, head, 0x0800, Files);
         return;
      }
      /* se nomes sao diferentes, [i=31] e nao e o setor final, atualiza a tabela */
      else if(i == 31 && curSector != -1) {
         curSector = FAT[curSector];
         system_discMaping(curSector, &cylinder, &head, &sector);
         system_dataRead(1, cylinder, sector, head, 0x0800, Files);
         i = 0;
      }
      /* senao vai para o proximo indice */
      else i++;
   }
}
/************************************************************************************/

/***********\
| TAREFA 18 | OK!
|************************************************************************************|
| Comando [CP] que copia arquivos de um lugar para outro. Esta funcao recebe um      |
| caminho, que na verdade sao tambem os parametros da funcao. Eles devem estar no    |
| formato [string1 string2] onde a origem e [string1] e o destino e [string2].       |
|************************************************************************************/
void command_cp(char *parameters) {
   char origin[128], destiny[128], nameAux1[128], nameAux2[128], buffer[512];
   usint originSector, newFileSector, nReadedSectors, cylinder, head, sector, i = 0, j = 0;
   int curSector, type;
   /* separando os parametros */
   CopyString(parameters,origin);
   while(origin[i] != ' ' && origin[i] != '\0') i++;
   if(origin[i] == ' ') origin[i++] = '\0';
   while(origin[i] != '\0') {
      destiny[j] = origin[i];
      i++; j++;
   }
   destiny[j] = '\0';
   /* obtendo os caminhos completos */
   CopyString(curDirectory,nameAux1);
   system_absolutWay(nameAux1,destiny);
   CopyString(curDirectory,nameAux2);
   system_absolutWay(nameAux2,origin);
   /* verificando se a origem existe e se sim, deixa copiado para um buffer o seu conteudo */
   curSector = system_fileInitialSector(nameAux2,&type);
   nReadedSectors = system_fileInfoLoader(nameAux2, buffer, sizeof(buffer));
   originSector = curSector;
   if(curSector < 1 || type != 1) { 
      return;
   }
   /* verificando se o diretorio-pai existe */
   curSector = system_fileInitialSector(nameAux1,&type);
   if(curSector < 1 || type != 2) {
      imprime(" [diretorio destino nao existente]");
      return;
   }
   /* conferindo se o arquivo destino ja existe */
   for(i=0;i<128 && nameAux2[i] != '\0';i++) if(nameAux2[i+1] != '\0' && nameAux2[i] == '/') j=i;
   for(i=0;i<128 && nameAux1[i] != '\0';i++);
   for(j;nameAux2[j] != '\0';j++) nameAux1[i++] = nameAux2[1+j];
   curSector = system_fileInitialSector(nameAux1,&type);
   if(curSector > 0) {
      imprime(" [arquivo destino ja existe]");
      return;
   }
   /* reseparando as strings para a cópia */
   for(i=0;i<128 && nameAux1[i] != '\0';i++) if(nameAux1[i+1] != '\0' && nameAux1[i] == '/') j=i;
   for(i=0;i<5;i++) nameAux2[i] = nameAux1[j+1+i];
   for(i=0;i<5;i++) if(nameAux2[i] == '/') nameAux2[i] = '\0';
   nameAux1[j+1] = '\0';
   curSector = system_fileInitialSector(nameAux1,&type);
   system_discMaping(curSector, &cylinder, &head, &sector);
   system_dataRead(1, cylinder, sector, head, 0x0800, Files);
   /* procurando por uma entrada nao usada */
   i = 0; j = 0;
   while(Files[i].initialSector != 0) {
      /* [j] e um backup do setor atual */
      j = curSector;
      i++;
      /* se atingiu o fim do setor e nao e setor final, vai para o proximo */
      if(i == 32 && FAT[curSector] != -1) {
         i = 0;
         curSector = FAT[curSector];
         system_discMaping(curSector, &cylinder, &head, &sector);
         system_dataRead(1, cylinder, sector, head, 0x0800, Files);
      }
      /* estava ja no setor final, inicia portanto outro setor */
      else if(i == 32 && FAT[curSector] == -1) {
         for(i=0;i<3072 && FAT[i] != -2;i++);
         FAT[curSector] = i;
         FAT[i] = -1;
         system_discMaping(curSector, &cylinder, &head, &sector);
         system_dataRead(1, cylinder, sector, head, 0x0800, Files);
         i = 0;
      }
   }
   /* indicando o setor inicial do arquivo */
   for(newFileSector=0;newFileSector<3072 && FAT[newFileSector] != -2;newFileSector++);
   FAT[newFileSector] = -1;
   /* obtido o indice de entrada livre do diretorio pai, insere-se o novo diretorio */
   for(j=0;j<5;j++) Files[i].name[j] = nameAux2[j];
   for(j=5;j<8;j++) Files[i].name[j] = '\0';
   Files[i].fileType = 1;
   Files[i].initialSector = newFileSector;
   system_discMaping(curSector, &cylinder, &head, &sector);
   system_dataWrite(1, cylinder, sector, head, 0x0800, Files);
   /* copiando o buffer */
   i = 78;
   while(1) {
      system_discMaping(newFileSector, &cylinder, &head, &sector);
      system_dataWrite(1, cylinder, sector, head, 0x0800, buffer);
      if(FAT[originSector] == -1) return;
      originSector = FAT[originSector];
      system_discMaping(originSector, &cylinder, &head, &sector);
      system_dataRead(1, cylinder, sector, head, 0x0800, buffer);
      while(FAT[i] != -2 && i < 3072) {
         i++;
      }
      FAT[newFileSector] = i;
      FAT[i] = -1;
      newFileSector = i;
   }
}

/************************************************************************************/

/**********\
| TAREFA 5 | OK!
|************************************************************************************|
| Esta e a rotina de reconhecimento de comandos do prompt. O parametro [pos] indica  |
| aonde deve ser colocado o caracter [\0] indicador de fim de string. As strings     |
| [bufferPrompt] e [bufferAux] recebem respectivamente, o trecho antes de um espaco  |
| e o trecho depois de um espaco.                                                    |
|************************************************************************************/
void system_execute(int *pos) {
   usint i = 0, j = 0;
   char bufferAux[64];

   bufferPrompt[*pos] = 0;
   bufferAux[j] = '\0';
   /* este trecho pega a substring depois de um espaço */
   while(bufferPrompt[i] != ' ' && bufferPrompt[i] != '\0') i++;
   if(bufferPrompt[i] == ' ') i++;
   while(bufferPrompt[i] != '\0') {
      bufferAux[j] = bufferPrompt[i];
      i++; j++;
   }
   bufferAux[j] = '\0';
   i = 0;
   /* fechando o [bufferPrompt] */
   while(bufferPrompt[i] != ' ' && bufferPrompt[i] != '\0') i++;
   bufferPrompt[i] = '\0';

   /* chamada do comando [cd] */
   if(StringCmp("cd",bufferPrompt) == 1) {
      command_cd(bufferAux);
   }
   /* chamada do comando [mkdir] */
   else if(StringCmp("mkdir",bufferPrompt) == 1) {
      command_mkdir(bufferAux);
   }
   /* chamada do comando [rmdir] */
   else if(StringCmp("rmdir",bufferPrompt) == 1) {
      command_rmdir(bufferAux);
   }
   /* chamada do comando [rm] */
   else if(StringCmp("rm",bufferPrompt) == 1) {
      command_rm(bufferAux);
   }
   /* chamada do comando [cp] */
   else if(StringCmp("cp",bufferPrompt) == 1) {
      command_cp(bufferAux);
   }
   /* chamada do comando [cat] */
   else if(StringCmp("cat",bufferPrompt) == 1) {
      command_cat(bufferAux);
   }
   /* chamada do comando [exec] */
   else if(StringCmp("exec",bufferPrompt) == 1) {
      command_exec(bufferAux);
   }
   /* chamada do comando [ls] */
   else if(StringCmp("ls",bufferPrompt) == 1) {
      command_ls(bufferAux);
   }
   /* chamada do comando [ps] */
   else if(StringCmp("ps",bufferPrompt) == 1) {
      if(bufferAux[0] != '\0') imprime(" [este comando nao recebe parametros]");
      else command_ps();
   }
   /* chamada do comando [clear] */
   else if(StringCmp("clear",bufferPrompt) == 1) {
      if(bufferAux[0] != '\0') imprime(" [este comando nao recebe parametros]");
      else limpa_tela();
   }
   /* chamada para um [enter] */
   else if(*pos != 0) {
      imprime("\n\r[comando nao implementado]");
   }
   imprime("\n\rroot:");
   imprime(curDirectory);
   *pos = 0;
   bufferPrompt[*pos] = 0;
   for(i=0;i<64;i++)
      bufferAux[i] = '\0';
}
/************************************************************************************/

/**********\
| TAREFA 4 | OK!
|************************************************************************************|
| Esta rotina e o laco principal do prompt de comandos do shell. E nela onde teclas  |
| sao capturadas, ecoadas na tela e guardadas no [bufferPrompt].                     |
|************************************************************************************/
void system_prompt(void) {
   usint pos = 0;
   char str[2];
   curDirectory[0] = '/';
   curDirectory[1] = '\0';
   str[0] = '\0';
   str[1] = 0;
   do {
      /* leitura da tecla */
      bufferPrompt[pos] = system_getch();
      /* tratando a tecla backspace */
      if(bufferPrompt[pos] == 8) {
         if(pos != 0) {
            str[0]=bufferPrompt[pos];
            bufferPrompt[pos] = '\0';
            imprime(str);
            imprime(" ");
            imprime(str);
            pos--;
         }
      }
      /* tratando a tecla enter */
      else if(bufferPrompt[pos] == 13) {
         if(pos != 0)
            system_execute(&pos);
         else {
            imprime("\n\rroot:");
            imprime(curDirectory);
         }
      }
      /* tratando as demais teclas */
      else if(bufferPrompt[pos] != 27 && bufferPrompt[pos] != 0) {
         str[0]=bufferPrompt[pos];
         imprime(str);
         pos++;
         bufferPrompt[pos] = '0';
      }
   } while(1);
}
