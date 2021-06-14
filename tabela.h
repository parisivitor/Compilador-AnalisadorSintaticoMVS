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
void insere_simbolo(struct elem_tab_simbolos);
int busca_simbolo(char *, char);
int busca_simboloID(char *);
int busca_simboloDesRt(int, int);
void mostra_tabela();
int remove_tabela(int ,int );
lista inicia();
lista  insere_lista(lista , int , int );
void mostra_lista(lista l);