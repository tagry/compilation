#include <stdio.h>
#include <string.h>
#define SIZE 1013 

enum type_expression
  {
    T_INT, T_FLOAT
  };

struct expression
{
	char *code;
	enum type_expression type;  
	int name;
};

struct  symbol_t{
  char *name;
  enum type_expression type;
  char *code;
  char *var;
};




