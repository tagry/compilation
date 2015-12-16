#include <stdio.h>
#include <string.h>
#define SIZE 1013 

enum context_expression
{
	VARIABLE_GLOBALE, VARIABLE_LOCALE, ARGUMENT
};

enum type_expression
{
	T_INT_TAB, T_FLOAT_TAB, T_INT, T_FLOAT, T_FONCT
};

//Que pour les expression (pas besoin de table de symbole)
struct expression
{
	char *code;
	char *var;//(pointeur)
	enum type_expression type;  
};

//Que pour les symboles ! :
struct  symbol_t{
	char *name;//nom de la variable si c'est une variable
	char *var;// variable temporaire pour assembleur (pointeur)
	enum context_expression classe;
	enum type_expression type;
	int complement;//nb de case pour un tableau, nb arg pour fonct
};




