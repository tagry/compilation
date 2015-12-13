int f(int x) {
   return x+5;
}

int main()
{
	int A[];
	int B[];
	B = map(f,A); //probleme la taille de A est nul	
	return 0;
}
