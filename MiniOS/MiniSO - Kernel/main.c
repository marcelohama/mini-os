/*================================================*/
/*   PROJETO MINISO - SISTEMAS OPERACIONAIS II    */
/*   [Implementaao]                               */
/*================================================*/

#include "kernel.h"
extern impa;
extern tama;
extern impb;
extern tamb;

void principal(void) {
    ProcessTableInit();
    InterruptExchange();
    makeProcess(tama, 0x0800, impa);
    makeProcess(tamb, 0x0800, impb);
    limpa_tela();
    imprimexy(1,1,"TESTANDO MINISO");
}
