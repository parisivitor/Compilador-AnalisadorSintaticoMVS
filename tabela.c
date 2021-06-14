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
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "estruturas.h"

void msg (char *s);
int pos_tab =0;

void maiuscula(char *s){
     int i;
     for (i = 0; s[i]; i++)
        s[i] = toupper(s[i]);
}

//retorna a posicao de id na tabela ou -1 se nao encontrar
int busca_simbolo(char *id, char escopo){
    int i = pos_tab -1;
    for(; i>=0 ; i--){
        if( strcmp(TabSimb[i].id, id)==0 && TabSimb[i].escopo == escopo  ) 
            return i;  
    }
    return -1;
}

int busca_simboloID(char *id){
    int i = pos_tab -1;
    //maiuscula(id);
    for(; strcmp(TabSimb[i].id, id) && i>=0 ; i--)
        ;
    return i;
}
int busca_simboloDesRt(int desloca, int rotulo){
    int i = pos_tab -1;
    //maiuscula(id);
    for(; i>=0 ; i--){
        if(TabSimb[i].desloca== desloca && TabSimb[i].rotulo == rotulo)
            return i;
        }
    return -1;
}

void insere_simbolo(struct elem_tab_simbolos elem){
    int i=0;
    //printf("teste funca antes de inserir na tabbela %s\n",elem.id);
    if (pos_tab == TAM_TAB)
        msg("OVERFLOW - tabela de simbolos");
    
    i = busca_simbolo(elem.id,  elem.escopo);
    //printf("TESTE INSERINDO NA TABELA%3s\n",TabSimb[i].id);
    if(i != -1)
        msg("Identificador duplicado");
    //maiuscula(elem.id);
    TabSimb[pos_tab] = elem;
    pos_tab++;
}

void mostra_lista(lista l){
    printf("\n->[");
    while(l){
        printf("( t=%d, m=%d )", l->tipo, l->mec);
        l=l->prox;
        if(l)printf(",");
    }
    printf(" ]\n");
}

void mostra_tabela(){
    int i;
    lista aux;
    for(i=0;i<51;i++)
        printf("- ");
    printf("\n");
    printf("|%40s Tabela de Simbolos %39s|\n","","");
    for(i=0;i<51;i++)
        printf("- ");
    printf("\n| %3s | %15s | %s | %s | %s | %s | %s | %s | %s | %30s |\n", "#","ID", "ESC", "DSL", "ROT", "CAT", "TIP", "MEC", "NPAR", "LPAR");
    for(i=0;i<51;i++)
        printf("- ");
    for (i = 0 ; i < pos_tab ; i++){
        printf("\n| %3d | %15s | %3c | %3d | %3d | %3c | %3d | %3d | %4d | ", i, TabSimb[i].id, TabSimb[i].escopo, TabSimb[i].desloca, TabSimb[i].rotulo, TabSimb[i].cat, TabSimb[i].tipo, TabSimb[i].mec, TabSimb[i].npar);
        if(TabSimb[i].listapar != NULL){
            printf("-> [");
            aux = TabSimb[i].listapar ;
            while(aux){
                printf("(t=%d,m=%d)", aux->tipo, aux->mec);
                aux=aux->prox;
                if(aux)printf(", ");
            }
            printf(" ]");
        }else{
            printf("%30s |", "");
        }
    }
    printf("\n");
    for(i=0;i<51;i++)
        printf("- ");
    printf("\n\n");
}

int remove_tabela(int nvarl,int npar){
    pos_tab = pos_tab - npar - nvarl ;
    return pos_tab;
}

lista inicia(){
    return NULL;
}

lista  insere_lista(lista lno, int tipo, int mec){
    lista aux, ant, p;
    p=(lista)malloc(sizeof(struct no));
    if(!p) printf("\n Lista Cheia");
    else{
        ant=NULL;
        aux=lno;
        while(aux!=NULL){
            ant = aux;
            aux = aux->prox;
        }
        p->tipo = tipo;
        p->mec = mec;
        if(ant==NULL){
            p->prox = lno;
            lno=p;
        }
        else{
            p->prox = ant->prox;
            ant->prox = p;
        }
    }
    return lno;
}
