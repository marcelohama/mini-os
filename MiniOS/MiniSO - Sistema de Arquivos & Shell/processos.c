 
#include "processos.h"
#include "rotproc.h"

usint processo;   /* índice contendo o processo que está rodando agora */
stprocesso tabproc[19];  /* tabela de processos */

void Inicia_tabela_processos(void){
     int i;
     processo=0;  /* processo kernel inicialmente rodando */
     tabproc[0].estado=rodando;
     tabproc[0].tempo=0;
     /* seta valores dos demais processos */
     for (i=1;i<19; i++) {
        tabproc[i].estado=nusado;
        tabproc[i].tempo=0;
     }
}

int Busca_processo_nusado(void){
    /* busca primeiro processo não usado */
    int i=1;
    while ((i<19) && (tabproc[i].estado!=nusado)) i++;
    if (i<19) return i; else return -1;
}

/* usa tabela para definir segmentos */
/* é mais rápido e permite usar segmentos diferentes do padrão */
usint tabseg[19]={0x0800,0x1000,0x1800,0x2000,0x2800,0x3000,0x3800,0x4000,0x4800,0x5000,
                0x5800,0x6000,0x6800,0x7000,0x7800,0x8000,0x8800,0x9000,0x9800};

usint Segmento_processo(usint i) {
    /* retorna o segmento do processo indicado */
    return tabseg[i];
}

int Cria_processo(usint scod, usint dcod, usint tam){
   /* Cria um processo associado ao código indicado */
   /* sendo:                                        */
   /* scod => segmento onde está código             */
   /* dcod => deslocamento onde está o código       */
   /* tam => tamanho do código do processo          */
   /* retorno: 0 => sucesso  -1 => falha            */
   int proc; 
   usint seg;
   /* busca processo não usado, se houver */
   proc=Busca_processo_nusado();
   if (proc==-1) { /* ERRO ao procurar processo */
     return -1;
   }
   /* encontra o segmento associado ao processo */
   seg=Segmento_processo(proc);
   /* copia o código da origem para o segmento do processo */
   copia_codigo(scod, dcod, seg, 0x0000, tam);
   /*Inicializa a pilha e armazena topo na tabela de processos */
   tabproc[proc].sp=Inicializa_pilha(seg);
   tabproc[proc].ss=seg;
   /* Coloca o processo no estado pronto */
   tabproc[proc].estado=pronto;
   return 0;  /* sucesso */
}

usint Busca_prox_pronto(void){
   /* busca o próximo processo pronto a partir do atual */
   /* se não encontrar, retorna o kernel */
   int i=processo+1;
   while ((i<19) && (tabproc[i].estado!=pronto)) i++;
   if (i<19) return i; else return 0;
}

