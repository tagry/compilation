int g(int x,int y) {
   return x+y;
}

int main()
{
	int B[];
	int x;
	x = reduce(g,B); // pas de tableaux vide pour reduce
	return 0;
}
