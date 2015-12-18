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
: IDENTIFIER {$$.type = hachtab[hachage($1)][etat].type; asprintf(&$$.code, "load %s", $1);}
| CONSTANTI  {$$.type = T_INT; asprintf(&$$.code, "%s", $1); /*asprintf($$.code, "%%x%d = add i32 %s, 0",tmp_var_name(), $1);*/}
| CONSTANTF  {$$.type = T_FLOAT; asprintf(&$$.code,"%s",$1);/* asprintf($$.code, "%%x%d = add f32 %s, 0", tmp_var_name(), $1);*/}
| '(' expression ')' {asprintf(&$$.code, "%s", $2.code);}
| MAP '(' postfix_expression ',' postfix_expression ')' 
| REDUCE '(' postfix_expression ',' postfix_expression ')'
| IDENTIFIER '(' ')' {
	appel_arg = hachtab[hachage($1)][GLOBAL].complement;
	asprintf(&fonction, "%s", $1);
  }
| IDENTIFIER '(' {
	appel_arg = hachtab[hachage($1)][GLOBAL].complement;
	asprintf(&fonction, "%s", $1);
  } argument_expression_list ')' {
	  if(appel_arg > 0)
		  fprintf(stderr, "Dans fonction : %s pas bon nombre d'argument\n", fonction);
	}
| IDENTIFIER INC_OP
| IDENTIFIER DEC_OP
| IDENTIFIER '[' expression ']'
;

postfix_expression
: primary_expression {$$.type = $1.type; 
						$$.name = tmp_var_name(); 
						if($2.type == FLOAT) 
							asprintf(&$$.code, "store f32 %s, f32 %%x%d\n", $1, tmp_var_name()); 
						else 
							asprintf(&$$.code, "store i32 %s, i32 %%x%d\n", $1, tmp_var_name());}
;

argument_expression_list
: expression {
	if(appel_arg < 0)
	{
		fprintf(stderr, "Dans fonction : %s pas bon nombre d'argument\n", fonction);
	}
    else if($1.type != hachtab[hachage(fonction)][GLOBAL].arg[appel_arg])
	{
		fprintf(stderr, "Dans fonction : %s pas bon type pour l'argument %d\n", fonction, appel_arg+1);
		return 1;
	}
	else
		appel_arg--;
 }
| argument_expression_list ',' expression {
	if(appel_arg < 0)
	{
		fprintf(stderr, "Dans fonction : %s pas bon nombre d'argument\n", fonction);
		return 1;
	}
	else if($3.type != hachtab[hachage(fonction)][GLOBAL].arg[appel_arg])
	{
		fprintf(stderr, "Dans fonction : %s pas bon type pour l'argument %d\n", fonction, appel_arg+1);
		return 1;
	}
	
	else
		appel_arg--;
  }
;

unary_expression
: postfix_expression {$$.type = $1.type; 
						$$.name = tmp_var_name(); 
						if($2.type == FLOAT) 
							asprintf(&$$.code, "store f32 %s, f32 %%x%d\n", $1, tmp_var_name()); 
						else 
							asprintf(&$$.code, "store i32 %s, i32 %%x%d\n", $1, tmp_var_name());}
| INC_OP unary_expression {$$.type = $1.type; 
							$$.name = tmp_var_name(); 
							if($2.type == T_FLOAT) 
								asprintf(&$$.code, "%%x%d = fadd f32 %s, 1\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1, step, tmp_var_name()); 
							else 
								asprintf(&$$.code, "%%x%d = add i32 %s, 1\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $1, step, tmp_var_name());}
| DEC_OP unary_expression {$$.type = $1.type; 
							$$.name = tmp_var_name(); 
							if($2.type == T_FLOAT) 
								asprintf(&$$.code, "%%x%d = fsub f32 %s, 1\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1, step, tmp_var_name()); 
							else 
								asprintf(&$$.code, "%%x%d = sub i32 %s, 1\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $1, step, tmp_var_name());}
| unary_operator unary_expression {$$.type = $2.type; 
									$$.name = tmp_var_name(); 
									if($2.type == FLOAT) 
										asprintf(&$$.code, "%%x%d = fsub f32 0, %s\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1, step, tmp_var_name()); 
									else 
										asprintf(&$$.code, "%%x%d = sub i32 0, %s\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $1, step, tmp_var_name());}
;


unary_operator
: '-'
;

multiplicative_expression
: unary_expression {$$.type = $1.type; 
						$$.name = tmp_var_name(); 
						if($2.type == T_FLOAT) 
							asprintf(&$$.code, "store f32 %s, f32 %%x%d\n", $1, tmp_var_name()); 
						else 
							asprintf(&$$.code, "store i32 %s, i32 %%x%d\n", $1, tmp_var_name());} 
| multiplicative_expression '*' unary_expression    {if($2.type == T_FLOAT || $1.type == T_FLOAT) 
														$$.type = T_FLOAT; 
													else 
														$$.type = T_INT; 
													$$.name = tmp_var_name(); 
													if($2.type == T_FLOAT) 
														asprintf(&$$.code, "%%x%d = fmul f32 %s, %s\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1, $2, step, tmp_var_name()); 
													else 
														asprintf(&$$.code, "%%x%d = mul i32 %s, %s\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $1, $2, step, tmp_var_name());}
| multiplicative_expression '/' unary_expression {$$.type = T_FLOAT; 
													$$.name = tmp_var_name(); 
													asprintf(&$$.code, "%%x%d = fdiv f32 %s, %s\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1, $2, step, tmp_var_name());}
;


additive_expression
: multiplicative_expression {$$.type = $1.type; 
								$$.name = tmp_var_name(); 
								if($2.type == T_FLOAT) 
									asprintf(&$$.code, "store f32 %s, f32 %%x%d\n", $1, tmp_var_name()); 
								else 
									asprintf(&$$.code, "store i32 %s, i32 %%x%d\n", $1, tmp_var_name());}
| additive_expression '+' multiplicative_expression {if($2.type == T_FLOAT || $1.type == T_FLOAT) 
														$$.type = T_FLOAT; 
													else 
														$$.type = T_INT; 
													$$.name = tmp_var_name(); 
													if($2.type == T_FLOAT) 
														asprintf(&$$.code, "%%x%d = fadd f32 %s, %s\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1, $2, step, tmp_var_name()); 
													else 
														asprintf(&$$.code, "%%x%d = add i32 %s, %s\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $1, $2, step, tmp_var_name());}
| additive_expression '-' multiplicative_expression {if($2.type == T_FLOAT || $1.type == T_FLOAT) 
														$$.type = T_FLOAT; 
													else 
														$$.type = T_INT; 
													$$.name = tmp_var_name(); 
													if($2.type == T_FLOAT) 
														asprintf(&$$.code, "%%x%d = fsub f32 %s, %s\n store f32 %%x%d, f32 %%x%d", tmp_var_name(), $1, $2, step, tmp_var_name()); 
													else 
														asprintf(&$$.code, "%%x%d = sub i32 %s, %s\n store i32 %%x%d, i32 %%x%d\n", tmp_var_name(), $1, $2, step, tmp_var_name());}
;


comparison_expression
: additive_expression {$$.type = INT; 
						$$.name = tmp_var_name(); 
						asprintf(&$$.code, "store i32 %s, i32 %%x%d\n",$1, tmp_var_name());}
| '!' additive_expression {$$.type = INT; 
							$$.name = tmp_var_name(); 
							if($1) 
								asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name()); 
							else 
								asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name());}
| additive_expression '<' additive_expression {$$.type = INT; 
												$$.name = tmp_var_name(); 
												if($1 < $2) 
													asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
												else 
													asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());}
| additive_expression '>' additive_expression {$$.type = INT; 
												$$.name = tmp_var_name(); 
												if($1 > $2) 
													asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
												else 
													asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());}
| additive_expression ET_OP additive_expression {$$.type = INT; 
													$$.name = tmp_var_name(); 
													if($1 && $2) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());}
| additive_expression OU_OP additive_expression {$$.type = INT; 
													$$.name = tmp_var_name(); 
													if($1 || $2) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());}
| additive_expression LE_OP additive_expression {$$.type = INT; 
													$$.name = tmp_var_name(); 
													if($1 <= $2) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());}
| additive_expression GE_OP additive_expression {$$.type = INT; 
													$$.name = tmp_var_name(); 
													if($1 >= $2) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());}
| additive_expression EQ_OP additive_expression {$$.type = INT; 
													$$.name = tmp_var_name(); 
													if($1 == $2) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());}
| additive_expression NE_OP additive_expression {$$.type = INT; 
													$$.name = tmp_var_name(); 
													if($1 != $2) 
														asprintf(&$$.code, "store i32 1, i32 %%x%d\n",tmp_var_name()); 
													else 
														asprintf(&$$.code, "store i32 0, i32 %%x%d\n",tmp_var_name());}
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
| comparison_expression {$$.type = INT; 
							$$.name = tmp_var_name(); 
							asprintf(&$$.code, "store i32 %s, i32 %%x%d\n",$1, tmp_var_name());}
;


argument_expression_list
: expression
| argument_expression_list ',' expression
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
			met_classe_variable($2.code);
			$2.code += i+1;// Décale le tableau apres la virgule
			i = -1;
		}
		i++;
		
	}
	met_type($2.code, $1.code);
	met_classe_variable($2.code);
 }


| EXTERN type_name declarator_list ';'
;

declarator_list
: declarator
| declarator_list ',' declarator {asprintf(&$$.code, "%s,%s", $1.code, $3.code);}
;

type_name
: VOID 			{asprintf(&$$.code,"%s", "VOID");}
| INT  			{asprintf(&$$.code,"%s","INT");}
| FLOAT 		{asprintf(&$$.code,"FLOAT");}
| VOID '*' 		{asprintf(&$$.code,"VOID*");}
| INT  '*' 		{asprintf(&$$.code,"INT*");}
| FLOAT '*' 	{asprintf(&$$.code,"FLOAT*");}
;

declarator
: IDENTIFIER {
	if(!rechercheTout($1))
		addtab($1);
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);}

| IDENTIFIER '=' primary_expression {
	if(!rechercheTout($1))
		addtab($1);
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);}

| '(' declarator ')'
| '(' '*'  IDENTIFIER ')' '(' argument_list ')'
| IDENTIFIER '[' CONSTANTI ']' {
	if(!rechercheTout($1))
		addtab($1);
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);}

| IDENTIFIER '[' CONSTANTI ']''=' '{' argument_expression_list '}'
| IDENTIFIER '[' ']' {
	if(!rechercheTout($1))
		addtab($1);
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);}

| IDENTIFIER '(' {asprintf(&fonction, "%s", $1); entreeFonction(); appel_arg = 0;} parameter_list ')' {
	if(!rechercheTout($1))
	{
		addtab($1);
		hachtab[hachage($1)][GLOBAL].classe = FONCT;
	}
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);
	hachtab[hachage($1)];
  }

| IDENTIFIER '(' ')' {
	if(!rechercheTout($1))
	{
		addtab($1);
		hachtab[hachage($1)][GLOBAL].classe = FONCT;
	}
	else
		fprintf(stderr, "%s : Déclaration multiple ! ERREUR\n", $1);
  }
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
: type_name declarator {
	int i = 0;
	while($2.code[i] != '\0')
	{
		if($2.code[i] == ',')
		{
			$2.code[i] = '\0';
			met_type($2.code, $1.code);
			met_classe_arg($2.code);
			$2.code += i+1;// Décale le tableau apres la virgule
			i = -1;
		}
		i++;
		
	}
	met_type($2.code, $1.code);
	met_classe_arg($2.code);
 }
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
: type_name declarator {
	int i = 0;
	int fonct = 0;
	for(i = 0; hachtab[i][GLOBAL].classe != FONCT; i++);
	fonct = i;
	
	hachtab[fonct][GLOBAL].complement = 0;
	for(i = 0;i < SIZE; i++)
	{
		if(hachtab[i][LOCAL].classe == ARGUMENT)
		{
			hachtab[fonct][GLOBAL].arg[hachtab[fonct][GLOBAL].complement] = hachtab[i][LOCAL].type;
			hachtab[fonct][GLOBAL].complement++;
		}
	}
 }
compound_statement {
	
	sortieFonction();} 
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
