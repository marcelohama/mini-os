#include "tipos.h"

char tabhex[17]="0123456789ABCDEF"; /* tabela de dig�os para facilitar convers� */

void char_hex (unsigned char aux, char *hex){
	hex[2]=0;
	hex[1]=tabhex[aux%16];
	hex[0]=tabhex[aux/16];
}

void short_hex (usint aux, char *hex){
	hex[4]=0;
	hex[3]=tabhex[aux%16];
	aux=aux/16;
	hex[2]=tabhex[aux%16];
	aux=aux/16;
	hex[1]=tabhex[aux%16];
	hex[0]=tabhex[aux/16];
}

void printInt(char *v) {
	char str[3];
	char_hex(v,str);
	imprime(str);
}