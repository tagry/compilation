#include <stdio.h>
#include <stdlib.h>

int main()
{
	int x = 2;

	if(x == 0)//if basique =
		x = 1;

	if(x > 0)// >
		x = 3;

	if(x < 5)//<
		x = 6;

	if(x == 60)//avec accolade
	{
		x = 0;
	}
	else if(x == 6)//avec else if
		x= 1;
	else//avec else et else if
		x= 9;
			
	
	return 0;
}
