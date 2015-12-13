//#include <stdio.h>
//#include <stdlib.h>

int g(int x,int y) {
   return x+y;
}

int main()
{
	int B[3];
	B[0] = 1;
	B[1] = 2;
	B[2] = 3;

	int x;
	x = reduce(g,B); // x = 1+2+3 = 6

	return 0;
}
