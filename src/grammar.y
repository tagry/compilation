%{
	#define _GNU_SOURCE
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
	#include "table_symbol.c"
	
    extern int yylineno;

    int step=0;
    int yylex ();
    int yyerror ();
	
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
  struct expression exp;
  char *string;
  int n;
  float f;
 }

%type <exp> argument_list primary_expression postfix_expression argument_expression_list unary_expression unary_operator multiplicative_expression additive_expression expression assignment_operator comparison_expression declarator declarator_list declaration type_name


%%


primary_expression
: IDENTIFIER {asprintf(&$$.code, "load %s", $1);}
| CONSTANTI  {asprintf(&$$.code, "%s", $1); /*asprintf($$.code, "%%x%d = add i32 %s, 0",tmp_var_name(), $1);*/}
| CONSTANTF  {asprintf(&$$.code,"%s",$1);/* asprintf($$.code, "%%x%d = add f32 %s, 0", tmp_var_name(), $1);*/}
| '(' expression ')' {asprintf(&$$.code, "%s", $2.code);}
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
	if($2.code[0] == '=')
	{
		if($1.type == T_INT)
		{
			$$.type = T_INT;
			tmp_var_name();
			asprintf(&$$.code,"%%x%d = load i32* %s\nstore i32 %%x%d, %s",step, $3.var,step, $1.var);
		}
				 
	}
	else if(strcmp($2.code, "*="))
	{

	}
	else if(strcmp($2.code, "+="))
	{

	}
	else if(strcmp($2.code, "-="))
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
: type_name declarator_list ';' {
	int i = 0;
	for(i = 0; $2.code[i] != '\0';i++)
	{
		if($2.code[i] == ',')
		{
			$2.code[i] = '\0';
			detection_declaration_multiple($2.code, $1.code);
			$2.code += i+1;// Décale le tableau apres la virgule
			i = 0;
		}
		
	}
	detection_declaration_multiple($2.code, $1.code);
 }


| EXTERN type_name declarator_list ';'
;

declarator_list
: declarator 
| declarator_list ',' declarator
;

type_name
: VOID {asprintf(&$$.code,"%s", "VOID");}
| INT  {asprintf(&$$.code,"%s","INT");}
| FLOAT {asprintf(&$$.code,"FLOAT");}
| VOID '*' {asprintf(&$$.code,"VOID*");}
| INT  '*' {asprintf(&$$.code,"INT*");}
| FLOAT '*' {asprintf(&$$.code,"FLOAT*");}
;

declarator
: IDENTIFIER {$$.code = $1;}
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
	init();
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
