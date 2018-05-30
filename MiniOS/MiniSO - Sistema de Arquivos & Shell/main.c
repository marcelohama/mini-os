#include "kernel.h"
#include "conversoes.h"
#include "processos.h"
#include "interrupcao.h"
#include "shell.h"

extern usint impA;  /* cont� o endere� inicial do processo A */
extern usint tamA;  /* cont� o tamanho do processo A */
extern usint impB;  /* cont� o endere� inicial do processo B */
extern usint tamB;  /* cont� o tamanho do processo B */

void kernel(void){
	limpa_tela();
	imprime("\n\n\r\t\tTRABALHO FINAL DE SISTEMAS OPERACIONAIS - MiniSo");
	imprime("\n\n\r\t\tComandos Implementados:");
	imprime("\n\r\t\t cd ------- muda de diretorio");
	imprime("\n\r\t\t ps ------- listagem dos processos em execucao");
	imprime("\n\r\t\t ls ------- listagem do conteudo do diretorio atual");
	imprime("\n\r\t\t cat ------ exibicao do conteudo de arquivo");
	imprime("\n\r\t\t exec ----- executar arquivo");
	imprime("\n\r\t\t mkdir ---- cria diretorios");
	imprime("\n\r\t\t rmdir ---- remove diretorios");
	imprime("\n\r\t\t rm ------- remove arquivos");
	imprime("\n\r\t\t cp ------- copia arquivos");
	imprime("\n\r\t\t clear ---- limpa tela");
	system_getch();

	limpa_tela();
   Inicia_tabela_processos();
   Troca_vetor();
}


void principal(void){
	kernel();
	system_fatLoader();
	imprime("root:/");
	system_prompt();
} 
