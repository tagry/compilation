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
	FILE *fichier;
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

%type <exp> argument_list primary_expression postfix_expression argument_expression_list unary_expression unary_operator multiplicative_expression additive_expression expression assignment_operator comparison_expression declarator declarator_list declaration type_name parameter_list parameter_declaration statement compound_statement expression_statement selection_statement iteration_statement jump_statement declaration_list statement_list program external_declaration function_definition


%%


primary_expression
: IDENTIFIER {$$.type = VOID; asprintf(&$$.code, "load %s", $1);}
| CONSTANTI  {$$.type = T_INT; asprintf(&$$.code, "%s", $1); /*asprintf($$.code, "%%x%d = add i32 %s, 0",tmp_var_name(), $1);*/}
| CONSTANTF  {$$.type = T_INT; asprintf(&$$.code,"%s",$1);/* asprintf($$.code, "%%x%d = add f32 %s, 0", tmp_var_name(), $1);*/}
| '(' expression ')' {$$.type = VOID; asprintf(&$$.code, "%s", $2.code);}
| MAP '(' postfix_expression ',' postfix_expression ')' {}
| REDUCE '(' postfix_expression ',' postfix_expression ')' {}
| IDENTIFIER '(' ')' {$$.type = VOID;}
| IDENTIFIER '(' argument_expression_list ')' {$$.type = VOID;}
| IDENTIFIER INC_OP {$$.type = VOID;} 
| IDENTIFIER DEC_OP {$$.type = VOID;} 
| IDENTIFIER '[' expression ']' //On ne sait pas comment remonter pour trouver le type tableau
;

postfix_expression
: primary_expression {$$.type = $1.type; 
						asprintf(&$$.name, "%%x%d", tmp_var_name()); 
						if($1.type == T_FLOAT) 
							asprintf(&$$.code, "store f32 %s, f32 %%x%d\n", $1.code, tmp_var_name()); 
						else 
							asprintf(&$$.code, "store i32 %s, i32 %%x%d\n", $1.code, tmp_var_name());}
;

argument_expression_list
: expression {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.type = $1.type; $$.code = $1.code;}
| argument_expression_list ',' expression {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.type = $3.type;}
;

unary_expression
: postfix_expression {$$.type = $1.type; 
						asprintf(&$$.name, "%%x%d", tmp_var_name()); 
						if($1.type == T_FLOAT) 
							asprintf(&$$.code, "store f32 %s, f32 %%x%d\n", $1.code, tmp_var_name()); 
						else 
							asprintf(&$$.code, "store i32 %s, i32 %%x%d\n", $1.code, tmp_var_name());
						}
| INC_OP unary_expression {$$.type = $2.type; 
							asprintf(&$$.name, "%%x%d", tmp_var_name()); 
							if($2.type == T_FLOAT) 
								asprintf(&$$.code, "%%x%d = fadd f32 %s, 1\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $2.code, step, tmp_var_name()); 
							else 
								asprintf(&$$.code, "%%x%d = add i32 %s, 1\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $2.code, step, tmp_var_name());
							}
| DEC_OP unary_expression {$$.type = $2.type; 
							asprintf(&$$.name, "%%x%d", tmp_var_name()); 
							if($2.type == T_FLOAT) 
								asprintf(&$$.code, "%%x%d = fsub f32 %s, 1\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $2.code, step, tmp_var_name()); 
							else 
								asprintf(&$$.code, "%%x%d = sub i32 %s, 1\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $2.code, step, tmp_var_name());
							}
| unary_operator unary_expression {$$.type = $2.type; 
									asprintf(&$$.name, "%%x%d", tmp_var_name()); 
									if($2.type == T_FLOAT) 
										asprintf(&$$.code, "%%x%d = fsub f32 0, %s\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1.code, step, tmp_var_name()); 
									else 
										asprintf(&$$.code, "%%x%d = sub i32 0, %s\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $1.code, step, tmp_var_name());
									}
;


unary_operator
: '-'
;

multiplicative_expression
: unary_expression {$$.type = $1.type; 
						asprintf(&$$.name, "%%x%d", tmp_var_name()); 
						if($1.type == T_FLOAT) 
							asprintf(&$$.code, "store f32 %s, f32 %%x%d\n", $1.code, tmp_var_name()); 
						else 
							asprintf(&$$.code, "store i32 %s, i32 %%x%d\n", $1.code, tmp_var_name());
						} 
| multiplicative_expression '*' unary_expression    {if($3.type == T_FLOAT || $1.type == T_FLOAT) 
														$$.type = T_FLOAT; 
													else 
														$$.type = T_INT; 
													asprintf(&$$.name, "%%x%d", tmp_var_name()); 
													if($3.type == T_FLOAT) 
														asprintf(&$$.code, "%%x%d = fmul f32 %s, %s\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1.code, $3.code, step, tmp_var_name()); 
													else 
														asprintf(&$$.code, "%%x%d = mul i32 %s, %s\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $1.code, $3.code, step, tmp_var_name());
													}
| multiplicative_expression '/' unary_expression {$$.type = T_FLOAT; 
													asprintf(&$$.name, "%%x%d", tmp_var_name()); 
													asprintf(&$$.code, "%%x%d = fdiv f32 %s, %s\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1.code, $3.code, step, tmp_var_name());
													}
;


additive_expression
: multiplicative_expression {$$.type = $1.type; 
								asprintf(&$$.name, "%%x%d", tmp_var_name()); 
								if($1.type == T_FLOAT) 
									asprintf(&$$.code, "store f32 %s, f32 %%x%d\n", $1.code, tmp_var_name()); 
								else 
									asprintf(&$$.code, "store i32 %s, i32 %%x%d\n", $1.code, tmp_var_name());
								}
| additive_expression '+' multiplicative_expression {if($3.type == T_FLOAT || $1.type == T_FLOAT) 
														$$.type = T_FLOAT; 
													else if ($3.type == T_INT || $1.type == T_INT)
														$$.type = T_INT; 
													else 
														$$.type = VOID;
													asprintf(&$$.name, "%%x%d", tmp_var_name()); 
													if($3.type == T_FLOAT) 
														asprintf(&$$.code, "%%x%d = fadd f32 %s, %s\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1.code, $3.code, step, tmp_var_name()); 
													else 
														asprintf(&$$.code, "%%x%d = add i32 %s, %s\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $1.code, $3.code, step, tmp_var_name());
													}
| additive_expression '-' multiplicative_expression {if($3.type == T_FLOAT || $1.type == T_FLOAT) 
														$$.type = T_FLOAT; 
													else if ($3.type == T_INT || $1.type == T_INT)
														$$.type = T_INT; 
													else 
														$$.type = VOID;
													asprintf(&$$.name, "%%x%d", tmp_var_name()); 
													if($3.type == T_FLOAT) 
														asprintf(&$$.code, "%%x%d = fsub f32 %s, %s\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1.code, $3.code, step, tmp_var_name()); 
													else 
														asprintf(&$$.code, "%%x%d = sub i32 %s, %s\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $1.code, $3.code, step, tmp_var_name());
													}
;


comparison_expression
: additive_expression {$$.type = T_INT; 
						asprintf(&$$.name, "%%x%d", tmp_var_name()); 
						asprintf(&$$.code, "store i32 %s, i32 %%x%d\n",$1.code, tmp_var_name());
						}
| '!' additive_expression {$$.type = T_INT; 
							asprintf(&$$.name, "%%x%d", tmp_var_name()); 
							if($2.code) 
								asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name()); 
							else 
								asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name());
							}
| additive_expression '<' additive_expression {$$.type = T_INT; 
												asprintf(&$$.name, "%%x%d", tmp_var_name()); 
												if($1.code < $3.code) 
													asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
												else 
													asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());
												}
| additive_expression '>' additive_expression {$$.type = T_INT; 
												asprintf(&$$.name, "%%x%d", tmp_var_name()); 
												if($1.code > $3.code) 
													asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
												else 
													asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());
												}
| additive_expression ET_OP additive_expression {$$.type = T_INT; 
													asprintf(&$$.name, "%%x%d", tmp_var_name()); 
													if($1.code && $3.code) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());
													}
| additive_expression OU_OP additive_expression {$$.type = T_INT; 
													asprintf(&$$.name, "%%x%d", tmp_var_name()); 
													if($1.code || $3.code) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());
													}
| additive_expression LE_OP additive_expression {$$.type = T_INT; 
													asprintf(&$$.name, "%%x%d", tmp_var_name()); 
													if($1.code <= $3.code) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());
													}
| additive_expression GE_OP additive_expression {$$.type = T_INT; 
													asprintf(&$$.name, "%%x%d", tmp_var_name()); 
													if($1.code >= $3.code) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());
													}
| additive_expression EQ_OP additive_expression {$$.type = T_INT; 
													asprintf(&$$.name, "%%x%d", tmp_var_name()); 
													if($1.code == $3.code) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());
													}
| additive_expression NE_OP additive_expression {$$.type = T_INT; 
													asprintf(&$$.name, "%%x%d", tmp_var_name()); 
													if($1.code != $3.code) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());
													}
;

expression
: unary_expression assignment_operator comparison_expression {
	if($2.code[0] == '=')
	{
		if($1.type == T_INT)
		{
			$$.type = T_INT;
			tmp_var_name();
			asprintf(&$$.code,"%%x%d = load i32* %s\nstore i32 %%x%d, %s\n",step, $3.var,step, $1.var);
		} else if($1.type == T_FLOAT)
		{
			$$.type = T_FLOAT;
			tmp_var_name();
			asprintf(&$$.code,"%%x%d = load f32* %s\nstore f32 %%x%d, %s\n",step, $3.var,step, $1.var);
		}
				 
	}
	else if(strcmp($2.code, "*="))
	{
		if($1.type == T_FLOAT || $3.type == T_FLOAT)
		{
			$$.type = T_FLOAT;
			tmp_var_name();
			asprintf(&$$.code,"%%x%d = load f32* %s\n%%x%d = fmul f32 %s, %%x%d\nstore f32 %%x%d, %s\n", step, $3.var, step, $1.var, step, step, $1.var);
		} else 
		{
			$$.type = T_INT;
			tmp_var_name();
			asprintf(&$$.code,"%%x%d = load i32* %s\n%%x%d = mul f32 %s, %%x%d\nstore i32 %%x%d, %s\n", step, $3.var, step, $1.var, step, step, $1.var);
		}
	}
	else if(strcmp($2.code, "+="))
	{
		if($1.type == T_FLOAT || $3.type == T_FLOAT)
		{
			$$.type = T_FLOAT;
			tmp_var_name();
			asprintf(&$$.code,"%%x%d = load f32* %s\n%%x%d = fadd f32 %s, %%x%d\nstore f32 %%x%d, %s\n", step, $3.var, step, $1.var, step, step, $1.var);
		} else 
		{
			$$.type = T_INT;
			tmp_var_name();
			asprintf(&$$.code,"%%x%d = load i32* %s\n%%x%d = add f32 %s, %%x%d\nstore i32 %%x%d, %s\n", step, $3.var, step, $1.var, step, step, $1.var);
		}
	}
	else if(strcmp($2.code, "-="))
	{
		if($1.type == T_FLOAT || $3.type == T_FLOAT)
		{
			$$.type = T_FLOAT;
			tmp_var_name();
			asprintf(&$$.code,"%%x%d = load f32* %s\n%%x%d = fsub f32 %s, %%x%d\nstore f32 %%x%d, %s\n", step, $3.var, step, $1.var, step, step, $1.var);
		} else 
		{
			$$.type = T_INT;
			tmp_var_name();
			asprintf(&$$.code,"%%x%d = load i32* %s\n%%x%d = sub f32 %s, %%x%d\nstore i32 %%x%d, %s\n", step, $3.var, step, $1.var, step, step, $1.var);
		}
	}
 }
| comparison_expression {$$.type = $1.type; 
							asprintf(&$$.name, "%%x%d", tmp_var_name()); 
							asprintf(&$$.code, "store i32 %s, i32 %%x%d\n",$1.code, tmp_var_name());}
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
	while($2.code[i] != '\0')
	{
		if($2.code[i] == ',')
		{
			$2.code[i] = '\0';
			met_type($2.code, $1.code);
			$2.code += i+1;// Décale le tableau apres la virgule
			i = -1;
		}
		i++;
		
	}
	met_type($2.code, $1.code);
	$$.type = $1.type;
	asprintf(&$$.name, "%%x%d", tmp_var_name());
	if($1.type == T_INT)
		asprintf(&$$.code, "store i32 %s, i32 %%x%d\n",$2.code, tmp_var_name());
	else if($1.type == T_FLOAT)
		asprintf(&$$.code, "store f32 %s, f32 %%x%d\n",$2.code, tmp_var_name());
 }


| EXTERN type_name declarator_list ';' {}
;

declarator_list
: declarator {$$.type = $1.type;}
| declarator_list ',' declarator {asprintf(&$$.code, "%s,%s", $1.code, $3.code);}
;

type_name
: VOID 			{$$.type = VOID; asprintf(&$$.code,"%s", "VOID");}
| INT  			{$$.type = T_INT; asprintf(&$$.code,"%s","INT");}
| FLOAT 		{$$.type = T_FLOAT; asprintf(&$$.code,"FLOAT");}
| VOID '*' 		{$$.type = VOID; asprintf(&$$.code,"VOID*");}
| INT  '*' 		{$$.type = T_INT_TAB; asprintf(&$$.code,"INT*");}
| FLOAT '*' 	{$$.type = T_FLOAT_TAB; asprintf(&$$.code,"FLOAT*");}
;

declarator
: IDENTIFIER {
	$$.type = VOID;
	if(!rechercheTout($1))
		addtab($1);
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);
	}

| IDENTIFIER '=' primary_expression {
	$$.type = $3.type;
	if(!rechercheTout($1))
		addtab($1);
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);
	}

| '(' declarator ')'
| '(' '*'  IDENTIFIER ')' '(' argument_list ')'
| IDENTIFIER '[' CONSTANTI ']' {
	if(!rechercheTout($1))
		addtab($1);
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);}

| IDENTIFIER '[' CONSTANTI ']''=' '{' argument_expression_list '}' {
	$$.type = VOID;
	}
| IDENTIFIER '[' ']' {
	if(!rechercheTout($1))
		addtab($1);
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);}

| IDENTIFIER '(' {entreeFonction();} parameter_list ')' {
	if(!rechercheTout($1))
	{
		addtab($1);
		asprintf(&$$.code, "%s (%s)", $1, $4.code);
	}
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);
	hachtab[hachage($1)];
  }

| IDENTIFIER '(' ')' {
	if(!rechercheTout($1))
	{
		addtab($1);
		asprintf(&$$.code, "%s ()", $1);
	}
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);
  }
;

argument_list
: type_name {$$.type = $1.type;}
| type_name ',' argument_list
;

parameter_list
: parameter_declaration {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.code = $1.code;}
| parameter_list ',' parameter_declaration
;

parameter_declaration
: type_name declarator {$$.type = $1.type;}
;

statement
: compound_statement {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.code = $1.code;}
| expression_statement {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.code = $1.code;}
| selection_statement {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.code = $1.code;}
| iteration_statement {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.code = $1.code;}
| jump_statement {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.code = $1.code;}
;


compound_statement
: '{' '}' {asprintf(&$$.code, " ");}
| '{' statement_list '}' {asprintf(&$$.code, "%s", $2.code);}
| '{' declaration_list statement_list '}' {asprintf(&$$.code, "%s %s", $2.code, $3.code);}
;

declaration_list
: declaration {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.code = $1.code;}
| declaration_list declaration
;

statement_list
: statement {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.code = $1.code;}
| statement_list statement
;

expression_statement
: ';'
| expression ';' {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.code = $1.code;}
;

selection_statement
: IF '(' expression ')' statement 
| IF '(' expression ')' statement ELSE statement {asprintf(&$$.name, "%%x%d", tmp_var_name()); asprintf(&$$.code, "br i1 %s, label %s, label %s", $3.var, $5.code, $7.code);}
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
: external_declaration {asprintf(&$$.name, "%%x%d", tmp_var_name()); asprintf(&$$.code, "%s\n", $1.code); fputs($$.code, fichier);}
| program external_declaration {asprintf(&$$.name, "%%x%d", tmp_var_name()); asprintf(&$$.code, "%s\n%s\n", $1.code, $2.code); fputs($$.code, fichier);}
;

external_declaration
: function_definition {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.code = $1.code;}
| declaration {asprintf(&$$.name, "%%x%d", tmp_var_name()); $$.code = $1.code;}
;

function_definition
: type_name declarator compound_statement {
	sortieFonction();
	if(!strcmp($1.code, "INT"))
		asprintf(&$$.code, "define i32 %s { %s }", $2.code, $3.code);
	else if(!strcmp($1.code, "FLOAT"))
		asprintf(&$$.code, "define float %s { %s }", $2.code, $3.code);
 } 
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

	fichier = NULL;
	fprintf(stderr, "\ncoucou %s\n", argv[2]);
	fichier = fopen(argv[2], "w+");
	if(fichier == NULL)
		fprintf(stderr, "Le fichier ne s'ouvre pas");
	
	init();
    if (argc==3) {
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
	fclose(fichier);
    return 0;
}
