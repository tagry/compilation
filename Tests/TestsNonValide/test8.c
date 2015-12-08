#include <stdio.h>
#include <stdlib.h>

int g(int x)
{
	return x+2;
}


int main()
{
	int x= 0;
	float y = 2.1;
	y = g(0);//Type attendu int est donné un float
	return 0;
}
