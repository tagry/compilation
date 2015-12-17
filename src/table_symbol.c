#include "table_symbol.h"
#define SIZE 1013 
#define GLOBAL 0
#define LOCAL 1

int etat = 0; //defini si on est en global ou en local

struct symbol_t EMPTY={"","",C_VOID,T_VOID,0}; // un symbole vide
struct symbol_t hachtab[SIZE][2];

int hachage(char *s) {
	unsigned int hash = 0; 
	while (*s!='\0') hash = hash*31 + *s++;
	hash = hash % SIZE;
	return hash;
}
struct symbol_t findtab(char *s) {

	if (!strcmp(hachtab[hachage(s)][LOCAL].name,s))
		return hachtab[hachage(s)][LOCAL];

	else if (!strcmp(hachtab[hachage(s)][GLOBAL].name,s))
		return hachtab[hachage(s)][GLOBAL];

	else
		return EMPTY;
}

int rechercheGlobal(char *s)
{
	if (!strcmp(hachtab[hachage(s)][GLOBAL].name,s))
		return 1;
	else
		return 0;
}

int rechercheLocal(char *s)
{
	if (!strcmp(hachtab[hachage(s)][LOCAL].name,s))
		return 1;
	else
		return 0;
}

int rechercheTout(char *s)
{
	if(rechercheLocal(s) || rechercheGlobal(s))
		return 1;
	else
		return 0;

}

void addtab(char *s,enum type_expression type) {
	struct symbol_t *h=&hachtab[hachage(s)][etat];
	h->name=s;
	h->type=type;
	h->var=NULL;
}
void init() {
	int i;
	for (i=0; i<SIZE; i++) hachtab[i][LOCAL]=EMPTY;
	for (i=0; i<SIZE; i++) hachtab[i][GLOBAL]=EMPTY;
}

void entreeFonction(void){
	etat = LOCAL;
}

void sortieFonction(void){
	int i = 0;
	etat = GLOBAL;
	for (i=0; i<SIZE; i++) hachtab[i][LOCAL]=EMPTY;
}


void detection_declaration_multiple(char *s, char *type)
{
	if(rechercheTout(s))
	{
		fprintf (stderr, "%s: Declaration Multiple : ERREUR\n", s);
		return 1;
	}
	else
	{
		if(!strcmp(type,"VOID"))
		{
			fprintf (stderr, "%s: Pas de type \n", s);
		}
		else if(!strcmp(type,"INT"))
		{
			addtab(s, T_INT);
		}
		else if(!strcmp(type,"FLOAT"))
		{
			addtab(s, T_FLOAT);
		}
		else if(!strcmp(type,"INT*"))
		{
			addtab(s, T_INT_P);
		}
		else if(!strcmp(type,"FLOAT*"))
		{
			addtab(s, T_FLOAT_P);
		}
	}
}
