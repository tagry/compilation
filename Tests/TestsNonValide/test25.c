#include <stdio.h>
#include <stdlib.h>

int main()
{
  int bonjour = 2;
  int i = 0;
  for(i=0, i<20 ; i=i+1) 
    {
     bonjour = 1;
     i = i + 1;
    }
  return bonjour;
}
