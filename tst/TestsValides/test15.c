#include <stdio.h>
#include <stdlib.h>

void ma_fonction(void)                
{
    printf("Hello world!\n");
}

int main()
{
  void (*pointeurSurFonction)(void);
  pointeurSurFonction = ma_fonction;
  void (*boom)(void) = pointeurSurFonction;

  return EXIT_SUCCESS;
}
