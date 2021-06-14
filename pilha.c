/*+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
| UNIFAL − Universidade Federal de Alfenas.
| BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho . . : Compilador Simples − Funcao
| Diciplina: Teoria de Linguagens e Compiladores
| Professor . : Luiz Eduardo da Silva
| Aluno  . . . . . : Vitor Risso Parisi
| Data . . . . . . : 30/03/2021
| RA . . . . . . . : 2016.1.08.037
+−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−*/
#include "estruturas.h"
#include <stdio.h>

int topo = -1;
void msg (char *s);

void empilha (int valor, char tipo){
    if(topo == TAM_PIL)
        msg("Pilha cheia");
    Pilha[++topo].valor = valor;
    Pilha[topo].tipo = tipo;
}

int desempilha(){
    if(topo == -1)
        msg("Pilha vazia");
    return Pilha[topo--].valor;
}

void mostrapilha(char *s){
    int i;
    printf("\nPilha (%s) = [ ", s);
    for(i=topo;i>=0;i--)
        printf("(%d ,%c)", Pilha[i].valor, Pilha[i].tipo);
    printf("]\n");
}