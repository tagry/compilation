#include "table_symbol.h"
#define SIZE 1013 
#define GLOBAL 0
#define LOCAL 1

int etat = GLOBAL; //defini si on est en global ou en local
int appel_arg = 0; // variable qui compte les argument donner à une fonctionx
char *fonction;

struct symbol_t EMPTY={"","",0,C_VOID,T_VOID}; // un symbole vide
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

void addtab(char *s) {
	struct symbol_t *h=&hachtab[hachage(s)][etat];
	h->name=s;
	h->var=NULL;
}
void init() {
	int i;
	for (i=0; i<SIZE; i++) hachtab[i][LOCAL]=EMPTY;
	for (i=0; i<SIZE; i++) hachtab[i][GLOBAL]=EMPTY;
}

void entreeFonction(void){
	int i = 0;
	etat = LOCAL;
	for (i=0; i<SIZE; i++) hachtab[i][LOCAL]=EMPTY;
}

void sortieFonction(void){
	int i = 0;
	etat = GLOBAL;
	for (i=0; i<SIZE; i++) hachtab[i][LOCAL]=EMPTY;
}


void met_type(char *s, char *type)
{
	if(!strcmp(type,"VOID"))
	{
		fprintf (stderr, "%s: Pas de type \n", s);
	}
	else if(!strcmp(type,"INT"))
	{
		if(hachtab[hachage(s)][etat].complement > 0)
			hachtab[hachage(s)][etat].type = T_INT_TAB;
		else
			hachtab[hachage(s)][etat].type = T_INT;
	}
	else if(!strcmp(type,"FLOAT"))
	{
		if(hachtab[hachage(s)][etat].complement > 0)
			hachtab[hachage(s)][etat].type = T_FLOAT_TAB;
		else
			hachtab[hachage(s)][etat].type = T_FLOAT;
	}
	
	else if(!strcmp(type,"INT*"))
	{
		hachtab[hachage(s)][etat].type = T_INT_P;
	}
	else if(!strcmp(type,"FLOAT*"))
	{
		hachtab[hachage(s)][etat].type = T_FLOAT_P;
	}
}

void met_classe_variable(char *s)
{
	if(etat == GLOBAL)
		hachtab[hachage(s)][etat].classe = VARIABLE_GLOBALE;
	else
		hachtab[hachage(s)][etat].classe = VARIABLE_LOCALE;
}

void met_classe_arg(char *s)
{
	hachtab[hachage(s)][etat].classe = ARGUMENT;
}


void *routine(void *ptr) { 
	int x=*(int *)ptr;
	printf("Un thread en plus pour le processus pid %d) ! x=%d\n",getpid(),++x); 
	return NULL; // Equivalent � pthread_exit(NULL)
}

enum context_expression retourn_type(char *s)
{
	if(!strcmp(s,"VOID"))
	{
		return T_VOID;
	}
	else if(!strcmp(s,"INT"))
	{
		return T_INT;
	}
	else if(!strcmp(s,"FLOAT"))
	{
		return T_FLOAT;
	}
	else if(!strcmp(s,"INT*"))
	{
		return T_INT_P;
	}
	else if(!strcmp(s,"FLOAT*"))
	{
		return T_FLOAT_P;
	}
	else
		return T_FLOAT_P;
}
