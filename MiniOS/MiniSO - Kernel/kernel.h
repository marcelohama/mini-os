/*=================================================*/
/*   PROJETO MINISO - SISTEMAS OPERACIONAIS II     */
/*  [Header]                                       */
/*=================================================*/

#ifndef KERNEL_H
#define KERNEL_H

/*=================================================*/
/* Funcoes ja implementadas                        */
/*=================================================*/
void imprimexy(short lin, short col, char *mens);
void imprime(char *mens);
void limpa_tela(void);

/*=================================================*/
/* 3) Estrutura contendo informacoes de processos  */
/*=================================================*/
#define ready 0
#define unused 1
#define blocked 2
#define running 3
typedef struct Process {
	unsigned short SS;
    unsigned short SP;
	char status;
    int timeExec;
} tProcess;

/*=================================================*/
/* 4) Definicao das variaveis dos processos        */
/*=================================================*/
tProcess TableProcess[20];
char CurrentProcessIndex;

/*=================================================*/
/* 1) Funcoes de conversao de inteiros para string */
/*=================================================*/
char hexVector[16] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
void Hex_CharToString(char Integer, char *String) {
	int position;
    for(position=0;position<2;position++) {
		String[1-position] = hexVector[Integer%16];
        Integer /= 16;
	}
    String[2] = '\0';
}
void Hex_ShortToString(short Integer, char *String) {
    int position;
    for(position=0;position<4;position++) {
    	String[3-position] = hexVector[Integer%16];
        Integer /= 16;
    }
    String[4] = '\0';
}

/*=================================================*/
/* 2) Funcoes de manipulacao de strings            */
/*=================================================*/
void CopyString(char *Origin, char *Destiny) {
	int position = 0;
    while(Origin[position] != '\0') {
    	Destiny[position] = Origin[position];
        position++;
    }
    Destiny[position] = '\0';
}
void FuseString(char *Primary, char *Secondary) {
    int positionP = 0, positionS = 0;
	while(Primary[positionP] != '\0')
    	positionP++;
    while(Secondary[positionS] != '\0') {
        Primary[positionP++] = Secondary[positionS++];
    }
    Primary[positionP] = '\0';
}
int StringLength(char *String) {
	int n = 0;
    while(String[n++] != '\0');
    return n-1;
}

/*=================================================*/
/* 5) Rotina de inicializacao da tabela            */
/*=================================================*/
void ProcessTableInit(void) {
    char index;
    for(index=19;index>0;index--)
        TableProcess[index].status = unused;
    TableProcess[index].status = running;
    CurrentProcessIndex = 0;
}

/*=================================================*/
/* 6) Busca de processo nao usado na tabela        */
/*=================================================*/
char NoUsedProcessSearch(void) {
    char index;
    for(index=0;index<20;index++)
        if(TableProcess[index].status == unused)
        	return index;
    return (-1);
}

/*=================================================*/
/* 7) Retorno de segmento de processo              */
/*=================================================*/
short SegmentProcessTake(char Index) {
    return (0x0800*Index);
}

/*=================================================*/
/* 8) Copia codigo de Fonte para Destino           */
/*=================================================*/
void CodeCopy(unsigned short SegS, unsigned short OffsetS, unsigned short SegD, unsigned short OffsetD, unsigned short NBytes);

/*=================================================*/
/* 9) Inicializa pilha de processos                */
/*=================================================*/
void StackInit(char Index);
void TableRefresh(unsigned short ss, unsigned short sp, char Index) {
   TableProcess[Index].SS = ss;
   TableProcess[Index].SP = sp;
}

/*=================================================*/
/* 10) Dado um endereco de codigo, monta processo  */
/*=================================================*/
void makeProcess(unsigned short Size, unsigned short SegCode, unsigned short OffsetCode) {
     char newIndex;
     short newSegment;
     newIndex = NoUsedProcessSearch();
     newSegment = SegmentProcessTake(newIndex);
     CodeCopy(SegCode, OffsetCode, newSegment, 0, Size);
     StackInit(CurrentProcessIndex);
     TableProcess[newIndex].status = ready;
}

/*=================================================*/
/* 11) Busca o proximo processo no estado pronto   */
/*=================================================*/
char NextProcess(void) {
     char CurrentIndex = CurrentProcessIndex+1;
     while(CurrentIndex < 20 && TableProcess[CurrentIndex].status != ready) CurrentIndex++;
    if(CurrentIndex == 20)
    	return 0;
    else return CurrentIndex;
}

/*=================================================*/
/* 12) Novo manipulador da interrupcao 08h         */
/*=================================================*/
void NewInterrupt08(void);
void ChangeToReady(void) {
	TableProcess[CurrentProcessIndex].status = ready;
}
void TableRefresh2(unsigned int ss, unsigned int sp) {
	TableProcess[CurrentProcessIndex].SS = ss;
	TableProcess[CurrentProcessIndex].SP = sp;
}
tProcess *LoadProcess(char index) {
   return &TableProcess[index];
}

/*=================================================*/
/* 13) Troca de interrupcao da tabela              */
/*=================================================*/
void InterruptExchange(void);

#endif
