#define HEADER_H
#ifndef HEADER_H

enum type_expression
  {
    T_INT, T_FLOAT
  };

struct expression
{
  char * code;
  enum type_expression type;  
  int name;
};


#endif
