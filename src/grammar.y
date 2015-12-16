%{
    #include "header.h"
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
	
    extern int yylineno;

    int step=0;
    int yylex ();
    int yyerror ();


	struct symbol_t EMPTY={"",0,"",""}; // un symbole vide
	struct symbol_t hachtab[SIZE];

	int hachage(char *s) {
	unsigned int hash = 0; 
	while (*s!='\0') hash = hash*31 + *s++;
	return hash%SIZE;
 }
	struct symbol_t findtab(char *s) {
	if (strcmp(hachtab[hachage(s)].name,s)) return hachtab[hachage(s)];
	return EMPTY;
 }
	void addtab(char *s,enum type_expression type) {
	struct symbol_t *h=&hachtab[hachage(s)];
	h->name=s; h->type=type; h->code=NULL; h->var=NULL;
 }
	void init() {
	int i;
	for (i=0; i<SIZE; i++) hachtab[i]=EMPTY;
	}

	
    int tmp_var_name()
    {
      step++;
      return step;
    }

%}

%token <string> IDENTIFIER CONSTANTF CONSTANTI
%token MAP REDUCE EXTERN
%token INC_OP DEC_OP LE_OP GE_OP EQ_OP NE_OP OU_OP ET_OP
%token SUB_ASSIGN MUL_ASSIGN ADD_ASSIGN
%token TYPE_NAME
%token INT FLOAT VOID
%token IF ELSE WHILE RETURN FOR
%start program

%union {
  struct symbol_t exp;
  char *string;
  int n;
  float f;
 }

%type <exp> argument_list primary_expression postfix_expression argument_expression_list unary_expression unary_operator multiplicative_expression additive_expression


%%


primary_expression
: IDENTIFIER {asprintf($$.code, "load %s", $1);}
| CONSTANTI  {asprintf($$.code, "%s", $1); /*asprintf($$.code, "%%x%d = add i32 %s, 0",tmp_var_name(), $1);*/}
| CONSTANTF  {asprintf($$.code,"%s",$1);/* asprintf($$.code, "%%x%d = add f32 %s, 0", tmp_var_name(), $1);*/}
| '(' expression ')' {asprintf($$.code, "%s", $1);}
| MAP '(' postfix_expression ',' postfix_expression ')' 
| REDUCE '(' postfix_expression ',' postfix_expression ')'
| IDENTIFIER '(' ')'
| IDENTIFIER '(' argument_expression_list ')'
| IDENTIFIER INC_OP
| IDENTIFIER DEC_OP
| IDENTIFIER '[' expression ']'
;

postfix_expression
: primary_expression 
;

argument_expression_list
: expression
| argument_expression_list ',' expression
;

unary_expression
: postfix_expression
| INC_OP unary_expression
| DEC_OP unary_expression
| unary_operator unary_expression
;

unary_operator
: '-'
;

multiplicative_expression
: unary_expression
| multiplicative_expression '*' unary_expression
| multiplicative_expression '/' unary_expression
;

additive_expression
: multiplicative_expression
| additive_expression '+' multiplicative_expression 
| additive_expression '-' multiplicative_expression
;

comparison_expression
: additive_expression
| '!' additive_expression
| additive_expression '<' additive_expression
| additive_expression '>' additive_expression
| additive_expression ET_OP additive_expression
| additive_expression OU_OP additive_expression
| additive_expression LE_OP additive_expression
| additive_expression GE_OP additive_expression
| additive_expression EQ_OP additive_expression
| additive_expression NE_OP additive_expression
;

expression
: unary_expression assignment_operator comparison_expression {
	if($2 == '=')
	{
		if(unary_expression.type == 'T_INT')
		{
			$$.type = 'T_INT';
			tmp_var_name();
			asprintf($$.code,"%%x%d = load i32* %s\nstore i32 %%x%d, %s",step, $3.var,step, $1.var);
		}
				 
	}
	else if($2 == MUL_ASSIGN)
	{

	}
	else if($2 == ADD_ASSIGN)
	{

	}
	else if($2 == SUB_ASSIGN)
	{

	}
 }
| comparison_expression
;

assignment_operator
: '='
| MUL_ASSIGN
| ADD_ASSIGN
| SUB_ASSIGN
;

declaration
: type_name declarator_list ';'
| EXTERN type_name declarator_list ';'
;

declarator_list
: declarator
| declarator_list ',' declarator
;

type_name
: VOID  
| INT   
| FLOAT
| VOID '*' 
| INT  '*' 
| FLOAT '*'
;

declarator
: IDENTIFIER
| IDENTIFIER '=' primary_expression
| '(' declarator ')'
| '(' '*'  IDENTIFIER ')' '(' argument_list ')'
| declarator '[' CONSTANTI ']'
| declarator '[' CONSTANTI ']''=' '{' argument_expression_list '}'
| declarator '[' ']'
| declarator '(' parameter_list ')'
| declarator '(' ')'
;

argument_list
: type_name
| type_name ',' argument_list
;

parameter_list
: parameter_declaration
| parameter_list ',' parameter_declaration
;

parameter_declaration
: type_name declarator 
;

statement
: compound_statement
| expression_statement 
| selection_statement
| iteration_statement
| jump_statement
;

compound_statement
: '{' '}'
| '{' statement_list '}'
| '{' declaration_list statement_list '}'
;

declaration_list
: declaration
| declaration_list declaration
;

statement_list
: statement
| statement_list statement
;

expression_statement
: ';'
| expression ';'
;

selection_statement
: IF '(' expression ')' statement
| IF '(' expression ')' statement ELSE statement
| FOR '(' expression_statement expression_statement expression ')' statement
;

iteration_statement
: WHILE '(' expression ')' statement
;

jump_statement
: RETURN ';'
| RETURN expression ';'
;

program
: external_declaration
| program external_declaration
;

external_declaration
: function_definition
| declaration
;

function_definition
: type_name declarator compound_statement
;

%%
#include <stdio.h>
#include <string.h>

extern char yytext[];
extern int column;
extern int yylineno;
extern FILE *yyin;

char *file_name = NULL;

int yyerror (char *s) {
    fflush (stdout);
    fprintf (stderr, "%s:%d:%d: %s\n", file_name, yylineno, column, s);
    return 0;
}


int main (int argc, char *argv[]) {
    FILE *input = NULL;
    if (argc==2) {
	input = fopen (argv[1], "r");
	file_name = strdup (argv[1]);
	if (input) {
	    yyin = input;
	}
	else {
	  fprintf (stderr, "%s: Could not open %s\n", *argv, argv[1]);
	    return 1;
	}
    }
    else {
	fprintf (stderr, "%s: error: no input file\n", *argv);
	return 1;
    }
    yyparse ();
    free (file_name);
    return 0;
}
