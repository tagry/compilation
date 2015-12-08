#include <stdio.h>
#include <stdlib.h>

int g(int x)
{
	return x+2;
}

int main()
{
	float x = 2.1;
	g(x); // int attendu donner x
	return 0;
}
