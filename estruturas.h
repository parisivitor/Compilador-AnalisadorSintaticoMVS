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
#include <stdlib.h>
#define TAM_TAB 100
#define TAM_PIL 100
enum { INT = 1 , LOG, VAL = 10 , REF } ;
enum { ehValor = 1 , ehREF};

typedef struct no * lista ;
struct no {
    int tipo ; // INt ou LOG
    int mec ; //valor ou ref
    lista prox ;
} ;

struct {
    int valor;
    char tipo; 
}Pilha[TAM_PIL];


struct elem_tab_simbolos{
    char id[30]; // posicao na tabela
    int desloca; // endereco
    int tipo;    // INT ou log
    int mec;     //valor ou ref
    int rotulo;  //
    char escopo; // G ou L
    char cat;    // Parametro Variavel ou Funcao    
    int npar;    // quantidade de parametros
    lista listapar;   // lista dos parametros
}TabSimb[TAM_TAB], elem_tab;