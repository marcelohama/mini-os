#ifndef SHELL_H
#define SHELL_H

#include "tipos.h"

void command_ps(void);
void command_cd(char *way);
void command_ls(char *way);
void command_cat(char *fileName);
void command_exec(char *fileName);
void command_mkdir(char *wayName);
void command_rmdir(char *wayName);
void command_rm(char *wayName);
void command_cp(char *parameters);

int system_fileInitialSector(char *way, usint *type);
void system_absolutWay(char *absWay, char *way);
usint system_fileInfoLoader(char *way, char *buffer, usint maxSize);
usint system_fileInfoWriter(char *way, char *buffer, usint maxSize);
usint system_getch();
void system_fatLoader(void);
void system_prompt(void);
usint system_drawSubFile(char *sourceString, char *subFile, usint init);
void system_sectorWrite(char *way, char *buffer, usint fileName);
void system_dataRead(usint number, usint cylinder, usint sector, usint head, usint sourceSeg, usint sourceOff);
void system_dataWrite(usint number, usint cylinder, usint sector, usint head, usint destinySeg, usint destinyOff);

#endif