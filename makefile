simples : lexico.l sintatico.y tabela.c pilha.c estruturas.h;
	flex -o lexico.c lexico.l; \
	bison -v -d sintatico.y -o sintatico.c; \
	gcc pilha.c tabela.c lexico.c sintatico.c -o simples ;

limpa : ;
	rm lexico.c sintatico.c sintatico.h sintatico.output simples;