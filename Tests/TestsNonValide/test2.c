int g(int x)
{
	return x+2;
}
	
int main()
{
	int (*pointeur_sur_g)(int);

	pointeur_sur_g = g;
	pointeur_sur_g = pointeur_sur_g + 1;// Les pointeurs de fonction ne peuvent pas faire d'opération
	
	return 0;
}
