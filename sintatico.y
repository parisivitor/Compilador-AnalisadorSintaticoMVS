%{
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
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "estruturas.h"
#include "tabela.h"
#include "pilha.h"

#define DEBUG(x) x

int yylex();
void msg (char *s);
int yyerror (char *);

extern FILE * yyin;
extern FILE * yyout;
extern char atomo[80];
int conta=0;
int rotulo=0;
int tipo;
int mecanismo = -1;
char cat;
char escopoVar = 'G';
int npar = 0;
int nvarl =0;
int nvarg =0;
int tamtab=0;
int ehRouV = 0;


%}


/*-----------------------------
 * Sigma
 *-----------------------------*/
%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_REPITA
%token T_ATE
%token T_FIMREPITA
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_NAO
%token T_V
%token T_F
%token T_NUMERO
%token T_ABRE
%token T_FECHA
%token T_INTEIRO
%token T_LOGICO
%token T_LITERAL //opcao a mais
%token T_FUNC
%token T_FIMFUNC
%token T_REF

%start programa

// Precedencia para tratar ambiguidade
%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

/*-------
 * Regras
 *-------*/
%%
programa:  cabecalho                           { fprintf (yyout,"\tINPP\n");}
            variaveis 
            rotinas
            T_INICIO                            
            lista_comandos                      {escopoVar = 'L';}
            T_FIM                               {mostra_tabela();
                                                 if(nvarg > 0)
                                                  fprintf (yyout,"\tDMEM\t%d\n", nvarg);
                                                 fprintf (yyout,"\tFIMP\n");} ;

cabecalho: T_PROGRAMA T_IDENTIF;



rotinas: |                                      {fprintf (yyout,"\tDSVS\tL%d\n", rotulo);
                                                 empilha(rotulo, 'r');}                             //gerar DSVS L0
          lista_funcoes                         { //mostrapilha("TESTE");
                                                  int r = desempilha();
                                                  fprintf (yyout,"L%d\tNADA\n", r); }/*gerar L0 NADA */;


lista_funcoes: funcao lista_funcoes
             | funcao;


funcao: T_FUNC tipo T_IDENTIF               {rotulo++;
                                             npar=0;
                                             cat='F';    
                                             strcpy(elem_tab.id, atomo);
                                             elem_tab.desloca = conta;
                                             elem_tab.tipo = tipo;
                                             elem_tab.escopo = escopoVar;
                                             elem_tab.cat = cat;
                                             elem_tab.rotulo = rotulo;
                                             elem_tab.mec = mecanismo;
                                             insere_simbolo(elem_tab);  //inserir nome da funcao na tabela
                                             conta++;
                                             tamtab++;
                                             escopoVar = 'L';           //mudar o escopo para local              
                                             fprintf (yyout,"L%d\tENSP\n",rotulo);} //gerar ENSP
                                            
        T_ABRE
        lista_parametros T_FECHA            {TabSimb[tamtab-1-npar].desloca = -3-npar;
                                             TabSimb[tamtab-1-npar].npar = npar;
                                             lista l;
                                             l = inicia();
                                             int aux = npar;
                                             for(;aux>0;aux--){
                                                TabSimb[tamtab-aux].desloca = -2 -aux;                              //ajustar deslocamentos
                                                l=insere_lista(l,TabSimb[tamtab-aux].tipo,TabSimb[tamtab-aux].mec); //incluir lista de param
                                             }
                                             TabSimb[tamtab-1-npar].listapar = l;
                                             conta=0;
                                             mostra_tabela();
                                             mecanismo= -1;
                                             } 
                                             
        variaveis                           
        T_INICIO lista_comandos T_FIMFUNC   {tamtab=remove_tabela(nvarl,npar); //remover variaveis locais
                                            
                                            escopoVar = 'G';                   /*mudar o escopo para global*/
                                            if (nvarl>0)
                                              fprintf (yyout,"\tDMEM\t%d\n",nvarl);
                                            fprintf (yyout,"\tRTSP\t%d\n",npar); };// gerar RTSP                
                                                                              


lista_parametros: | lista_parametros parametros;


parametros: mecanismo tipo T_IDENTIF        {strcpy(elem_tab.id, atomo);
                                             cat = 'P';
                                             elem_tab.desloca = conta;
                                             elem_tab.tipo = tipo;
                                             elem_tab.escopo = escopoVar;
                                             elem_tab.mec = mecanismo;
                                             elem_tab.cat = cat;
                                             elem_tab.rotulo = -1;
                                             elem_tab.npar = -1;
                                             elem_tab.listapar = NULL;
                                             npar++; 
                                             insere_simbolo(elem_tab);  //inserir nome da funcao na tabela
                                             conta++;
                                             tamtab++;};


mecanismo:                                {mecanismo = VAL;}
         |T_REF                           {mecanismo = REF;} ;


variaveis:  | declaracao_variaveis             {mostra_tabela();
                                                if(escopoVar=='L')
                                                  fprintf (yyout,"\tAMEM\t%d\n",nvarl);
                                                else
                                                  fprintf (yyout,"\tAMEM\t%d\n",nvarg);}; ///AMEM GLOBAL E LOCAL

declaracao_variaveis : tipo lista_variaveis 
                      declaracao_variaveis      
                      | tipo  lista_variaveis;

tipo: T_LOGICO {tipo = LOG;}
     | T_INTEIRO {tipo = INT;} ;

lista_variaveis: lista_variaveis T_IDENTIF      { strcpy(elem_tab.id, atomo);
                                                   cat='V';
                                                   elem_tab.desloca = conta;
                                                   elem_tab.tipo = tipo;
                                                   elem_tab.escopo = escopoVar;
                                                   elem_tab.cat = cat;
                                                   elem_tab.mec = mecanismo;
                                                   elem_tab.rotulo = -1;
                                                   elem_tab.npar = -1;
                                                   elem_tab.listapar = NULL;
                                                   insere_simbolo(elem_tab);
                                                   if(escopoVar=='L')
                                                    nvarl++;
                                                   conta++;
                                                   tamtab++;
                                                   if(escopoVar=='G'&& cat =='V') 
                                                    nvarg++;
                                                   }

                  | T_IDENTIF                    { strcpy(elem_tab.id, atomo);
                                                   cat='V';
                                                   elem_tab.desloca = conta;
                                                   elem_tab.tipo = tipo;
                                                   elem_tab.escopo = escopoVar;
                                                   elem_tab.cat = cat;
                                                   elem_tab.mec = mecanismo;
                                                   elem_tab.rotulo = -1;
                                                   elem_tab.npar = -1;
                                                   elem_tab.listapar = NULL;
                                                   insere_simbolo(elem_tab);
                                                   if(escopoVar=='L')
                                                    nvarl++;
                                                   conta++;
                                                   if(escopoVar=='G'&& cat =='V') 
                                                    nvarg++;
                                                   tamtab++;   } ;

lista_comandos:  | comando lista_comandos;

comando: entrada_saida 
        | repeticao 
        | selecao 
        | atribuicao 
        | repita;

entrada_saida: leitura 
              | escrita;


leitura: T_LEIA                         
          T_IDENTIF                       { fprintf (yyout,"\tLEIA\n");
                                            int pos = busca_simboloID(atomo);
                                            if(pos == -1)
                                              msg("Variavel nao declara!");
                                            //gerar ARMI se a lleitura eh para um parametro por referencia
                                            if(TabSimb[pos].cat == 'P' && TabSimb[pos].mec == REF)
                                              fprintf (yyout,"\tARMI\t%d\n", TabSimb[pos].desloca);  
                                            //ARZL para parametro por valor ou variavel local
                                            else if(TabSimb[pos].cat == 'P' && TabSimb[pos].mec == VAL)
                                              fprintf (yyout,"\tARZL\t%d\n", TabSimb[pos].desloca);  
                                            // ou ARZG para variavel global
                                            else/*(TabSimb[pos].escopo == 'G')*/
                                              fprintf (yyout,"\tARZG\t%d\n", TabSimb[pos].desloca);  }; 

escrita: T_ESCREVA expressao             { fprintf (yyout,"\tESCR\n");
                                            desempilha();} ;


repeticao: T_ENQTO                       { rotulo++; 
                                            fprintf (yyout,"L%d\tNADA\n", rotulo);  
                                            empilha(rotulo,'r'); }

            expressao T_FACA              { DEBUG(mostrapilha("repeticao");)
                                            int t1 = desempilha();
                                            if(t1 != LOG)
                                              msg("Incompatibilidade de tipos");
                                            rotulo++; 
                                            fprintf (yyout,"\tDSVF\tL%d\n", rotulo); 
                                            empilha(rotulo,'r'); }  

            lista_comandos T_FIMENQTO     { int r1 = desempilha();
                                            int r2 = desempilha();
                                            fprintf (yyout,"\tDSVS\tL%d\n", r2);
                                            fprintf (yyout,"L%d\tNADA\n", r1); } ;

repita: T_REPITA lista_comandos T_ATE expressao T_FIMREPITA;

selecao: T_SE expressao T_ENTAO          { DEBUG(mostrapilha("selecao:T_ENTAO");)
                                            int t1 = desempilha();
                                            if(t1 != LOG)
                                              msg("Incompatibilidade de tipos");
                                            rotulo++;
                                            fprintf (yyout,"\tDSVF\tL%d\n", rotulo);
                                            empilha(rotulo,'r');}

          lista_comandos T_SENAO          { int r = desempilha();
                                            rotulo++;
                                            fprintf (yyout,"\tDSVS\tL%d\n", rotulo);
                                            fprintf (yyout,"L%d\tNADA\n", r); 
                                            empilha(rotulo,'r'); }

          lista_comandos T_FIMSE          { int r=desempilha();
                                            fprintf (yyout,"L%d\tNADA\n", r);} ;

atribuicao: T_IDENTIF                    { int pos = busca_simboloID(atomo);
                                            if(pos == -1)
                                              msg("Variavel nao declarada!");
                                            empilha(TabSimb[pos].desloca,'e'); 
                                            empilha(TabSimb[pos].tipo,'t');
                                            empilha(TabSimb[pos].rotulo,'r');
                                            printf("atribuicao:T_IDENTIF %s", TabSimb[pos].id);
                                            mostrapilha("atribuicao:T_IDENTIF") ; }


            T_ATRIB expressao             { DEBUG(mostrapilha("atribuicao:T_ATRIB expressao");)
                                            int texp = desempilha();

                                            int rt = desempilha();
                                            int tvar = desempilha();
                                            int end = desempilha();

                                            if(texp != tvar)
                                              msg("Incompatibilidade de tipos atrib: T_ATRIB");
                                            int pos = busca_simboloDesRt(end,rt);
                                            printf("teste buscaDes(%d %d) %s\n",end, rt, TabSimb[pos].id ); 
                                            if(TabSimb[pos].mec == REF)
                                              fprintf (yyout,"\tARMI\t%d\n", end);        //gerar ARMI se a atribuicao eh para um parametro por referencia
                                            else if(TabSimb[pos].mec == VAL || TabSimb[pos].escopo == 'L' || TabSimb[pos].cat =='F')
                                              fprintf (yyout,"\tARZL\t%d\n", end);        //ARZL para parametro por valor ou variavel local ou nome de funcao
                                            else/*(TabSimb[pos].escopo == 'G')*/
                                              fprintf (yyout,"\tARZG\t%d\n", end);  };    // ou ARZG para variavel global

expressao: expressao T_VEZES expressao   { int t1 = desempilha();
                                            int t2 = desempilha();
                                            if( t1 != INT || t2 != INT)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tMULT\n");
                                            empilha(INT,'t'); }   

          |  expressao T_DIV expressao    { int t1 = desempilha();
                                            int t2 = desempilha();
                                            if( t1 != INT || t2 != INT)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tDIVI\n");
                                            empilha(INT,'t'); }    

          |  expressao T_MAIS expressao   { int t1 = desempilha();
                                            int t2 = desempilha();
                                            if( t1 != INT || t2 != INT)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tSOMA\n");
                                            empilha(INT,'t'); }    

          |  expressao T_MENOS expressao  { int t1 = desempilha();
                                            int t2 = desempilha();
                                            if( t1 != INT || t2 != INT)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tSUBT\n");
                                            empilha(INT,'t'); }     

          |  expressao T_MAIOR expressao  { int t1 = desempilha();
                                            int t2 = desempilha();
                                            if( t1 != INT || t2 != INT)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tCMMA\n");
                                            empilha(LOG,'t');}   

          |  expressao T_MENOR expressao  { int t1 = desempilha();
                                            int t2 = desempilha();
                                            if( t1 != INT || t2 != INT)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tCMME\n");
                                            empilha(LOG,'t');}

          |  expressao T_IGUAL expressao  { int t1 = desempilha();
                                            int t2 = desempilha();
                                            if( t1 != INT || t2 != INT)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tCMIG\n");
                                            empilha(LOG,'t');}             
          |  expressao T_E expressao      { int t1 = desempilha();
                                            int t2 = desempilha();
                                            if( t1 != LOG || t2 != LOG)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tCONJ\n");
                                            empilha(LOG,'t');}             

          |  expressao T_OU expressao     { int t1 = desempilha();
                                            int t2 = desempilha();
                                            if( t1 != LOG || t2 != LOG)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tDISJ\n");
                                            empilha(LOG,'t');}             
          |  termo;




argumentos: |                             { //ehRouV = ehREF;
                                            }//contar argumentos
            lista_argumentos             {
                                            //ehRouV = ehValor;
                                            };//comparar numero de argumentos com o numero de parametros


lista_argumentos: lista_argumentos argumento 
                | argumento;

argumento: expressao;                       //comparar tipo do argumento com o paramentro

termo: T_IDENTIF                         { int pos = busca_simbolo(atomo, escopoVar);
                                            if(pos == -1)
                                              msg("Variavel nao declara!");
                                            //printf("\nPRINT ATOMO %s  ESCOPOVAR %c \n",atomo,  escopoVar);
                                            //printf("POS TabSimb[%d].id %s \n", pos, TabSimb[pos].id );
                                            //gerar CREG escopo == G, mec ==REF          - se a variavel eh global e o parametro correspondente for por referencia
                                            //gerar CREL escopo == L, mec == REF, cat==V - se a variavel eh local e o parametro eh por referencia
                                            //gerar CRVL escopo==L, mec==VAL             - se a variavel eh local e o paramentro eh por valor ou
                                            //gerar CRVL mec==REF, cat==P, ehREF         - se eh um parametro por referencia e o parametro eh por referencia
                                            //gerar CRVI mec==REF, ehValor               - se eh um parametro por referencia e passada por valor
                                            //gerar CRVG escopo==G                       - se a variavel é global
                                            if(TabSimb[pos].escopo == 'G' && TabSimb[pos].mec == REF /*&& ehRouV == ehREF*/){//precisa comparar se ehRef para entrar nesse if e setar CREG, como fazer ?
                                              fprintf (yyout,"\tCREG\t%d \n", TabSimb[pos].desloca);
                                              empilha(TabSimb[pos].tipo,'t');
                                              printf("termo:T_IDENTIF %s", TabSimb[pos].id); 
                                              mostrapilha("termo:T_IDENTIF");}  

                                            else if(TabSimb[pos].escopo == 'L' && TabSimb[pos].mec == REF && TabSimb[pos].cat == 'V'){
                                              fprintf (yyout,"\tCREL\t%d \n", TabSimb[pos].desloca);
                                              empilha(TabSimb[pos].tipo,'t');
                                              printf("termo:T_IDENTIF %s", TabSimb[pos].id); 
                                              mostrapilha("termo:T_IDENTIF");} 

                                            
                                            else if(TabSimb[pos].escopo == 'L' && TabSimb[pos].mec == VAL ){
                                              fprintf (yyout,"\tCRVL\t%d \n", TabSimb[pos].desloca);
                                              empilha(TabSimb[pos].tipo,'t');
                                              printf("termo:T_IDENTIF %s", TabSimb[pos].id); 
                                              mostrapilha("termo:T_IDENTIF");}   
                                              
                                            //enum { ehValor = 1 , ehREF} para usar nessos 2 proximos if
                                            //onde setar ehRouV para comparar no if?
                                              //else if(TabSimb[pos].escopo == 'L' && TabSimb[pos].mec == REF /*&& ehRouV == ehREF*/){
                                              // fprintf (yyout,"\tCRVL\t%d \n", TabSimb[pos].desloca);
                                              //empilha(TabSimb[pos].tipo,'t');
                                              //printf("termo:T_IDENTIF %s", TabSimb[pos].id); 
                                              //mostrapilha("termo:T_IDENTIF");} 

                                            else if(TabSimb[pos].mec == REF /*&& ehRouV == ehValor*/){
                                              fprintf (yyout,"\tCRVI\t%d \n", TabSimb[pos].desloca);
                                              empilha(TabSimb[pos].tipo,'t');
                                              printf("termo:T_IDENTIF %s", TabSimb[pos].id); 
                                              mostrapilha("termo:T_IDENTIF");}

                                            else{
                                              fprintf (yyout,"\tCRVG\t%d \n", TabSimb[pos].desloca);
                                              empilha(TabSimb[pos].tipo,'t');
                                              printf("termo:T_IDENTIF %s", TabSimb[pos].id); 
                                              mostrapilha("termo:T_IDENTIF");}
                                            }


      |  T_NUMERO                         { fprintf (yyout,"\tCRCT\t%s\n", atomo);
                                            empilha(INT,'t'); } 

      |  T_V                              { int t1 = desempilha();
                                            if(t1 != LOG)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tCRCT\t1\n");
                                            empilha(LOG,'t'); } 

      |  T_F                              { int t1 = desempilha();
                                            if(t1 != LOG)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tCRCT\t0\n");
                                            empilha(LOG,'t'); }

      |  T_NAO termo                      { int t1 = desempilha();
                                            if(t1 != LOG)
                                              msg("Incompatibilidade de tipos!");
                                            fprintf (yyout,"\tNEGA\n");
                                            empilha(LOG,'t'); } ;    

      | T_ABRE expressao T_FECHA
      | T_IDENTIF T_ABRE                  { int pos = busca_simboloID(atomo);
                                            if(pos == -1)
                                              msg("Variavel nao declara! adicionado agora");
                                            empilha(TabSimb[pos].rotulo, 'r');
                                            fprintf (yyout,"\tAMEM\t%d\n",1);//gerar AMEM 1 ?? gerar o amem da funcao e
                                            }
        argumentos
        T_FECHA                           {fprintf (yyout,"\tSVCP\n");             //gerar SVCP 
                                           int t = desempilha();
                                           fprintf (yyout,"\tDSVS\tL%d\n",t);  };  //gerar DSVS        
%% 

/*+----------------------------------------------+
  |    Corpo principal do programa COMPILADOR    |
  +----------------------------------------------+*/
int yyerror (char *s) {
    msg("ERRO SINTATICO");
}

int main (int argc, char * argv[]) {
    char *p, nameIn[100], nameOut[100];

    argc--;
    argv++;
    if(argc < 1){
      puts("Compilador Simples");
      puts("\t USO: ./simples <nomefonte[.simples]\n\n>");
      exit(10);
    }
    p = strstr(argv[0], ".simples");
    if(p) *p = 0;
    strcpy (nameIn, argv[0]);
    strcat (nameIn, ".simples");
    strcpy (nameOut, argv[0]);
    strcat (nameOut, ".mvs");

    //puts(nameIn);
    //puts(nameOut);

    yyin = fopen (nameIn, "rt");
    if(!yyin){
      puts("Programa fonte nao encontrado!");
      exit(20);
    }

    yyout = fopen(nameOut, "wt");
    if(!yyparse())
      puts("\n Programa OK!\n\n");
}

