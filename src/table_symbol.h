#include <stdio.h>
#include <string.h>
#define SIZE 1013 

enum context_expression
{
	VARIABLE_GLOBALE, VARIABLE_LOCALE, ARGUMENT, C_VOID, FONCT
};

enum type_expression
{
	T_INT_TAB, T_FLOAT_TAB, T_INT, T_FLOAT, T_FLOAT_P, T_INT_P, T_VOID
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

/*
Hache le nom pour le retrouver dans la table
 */
int hachage(char *s);

/*
Recherche dans la table des symboles le nom s, renvoi l'élement si il le trouve, renvoi l'élement EMPTY sinon.
 */
struct symbol_t findtab(char *s);


/*
Recherche dans la table des symboles GLOBAL le nom s, renvoi 1 si trouvé et 0 sinon
 */
int rechercheGlobal(char *s);


/*
Recherche dans la table des symboles LOCAL le nom s, renvoi 1 si trouvé et 0 sinon
 */
int rechercheLocal(char *s);


/*
Recherche dans la table des symboles LOCAL puis GLOBAL le nom s, renvoi 1 si trouvé et 0 sinon
 */
int rechercheTout(char *s);

/*
Ajoute à la table un nouvel identificateur
 */
void addtab(char *s,enum type_expression type);

/*
Initialise la table à EMPTY
 */
void init();

/*
Passe la variable état en local
 */
void entreeFonction(void);


/*
Passe la variable état en local et initialise la table des symboles local à EMPTY
 */
void sortieFonction(void);


/*
Détecte les déclaration multiple et arrete la compilation
 */
void detection_declaration_multiple(char *s, char *type);
