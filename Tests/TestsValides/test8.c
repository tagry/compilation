//#include <stdio.h>
//#include <stdlib.h>

int f(int x)
{
  return x+5;
}

int g(float x)
{
  return x/2;
}

int main()
{
  int bonjour = 0;

  int A[100];
  int B[];
  int C[];
  B = map(f,A);

  //test de map
  int i;
  for(i=0;i<100;i=i+1)
    {
      if(B[i]!=(A[i]+5))
	{
	  printf("Ne compile pas !\n");
	}
	  
    }
  C = map(g,A);
  for(i=0;i<100;i=i+1)
    {
      if(C[i]!=(A[i]/2))
	{
	  printf("Ne compile pas !\n");
	}
    }


  return bonjour;
}
