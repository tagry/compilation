#ifndef TABLE_SYMBOL_H
#define TABLE_SYMBOL_H

#define SIZE 1013

#define C_VARIABLE_GLOBALE 1
#define C_VARIABLE_LOCALE 2
#define C_ARGUMENT 3

#define T_ENTIER 1
#define T_TABLEAU_ENTIER 2
#define T_FONCTION 3

typedef struct {
	char *identif;
	int classe;
	int type;
	int adresse;
	int complement;
} desc_identif;

typedef struct {
	desc_identif tab[maxDico];
	int base;
	int sommet;
} dico_;

void entreeFonction(void);
void sortieFonction(void);
int ajouteIdentificateur(char *identif,  int classe, int type, int adresse, int complement);
int rechercheExecutable(char *identif);
int rechercheDeclarative(char *identif);
void affiche_dico(void);

dico_ dico;
extern int contexte;
extern int adresseLocaleCourante;
extern int adresseArgumentCourant;


#endif
