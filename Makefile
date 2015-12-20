SRC=src
BUILD=build
LEX=lex
YACC=bison
CFLAGS=-Wall 
CC=gcc -O0 -g 

EXPRESSION= 

all:parse

parse:grammar.c scanner.c
	$(CC) $(CFLAGS) -o $(BUILD)/$@ $(BUILD)/grammar.c $(BUILD)/scanner.c -lpthread 

grammar.c:$(SRC)/grammar.y
	$(YACC) -d -o $(BUILD)/$@ --defines=$(BUILD)/grammar.tab.h $^

scanner.c: $(SRC)/scanner.l
	$(LEX) -o $(BUILD)/$@ $^

testV:parse
	clear
	echo ###############TEST1################			
	./build/parse Tests/TestsValides/test1.c $(BUILD)/log/log1.txt
	echo ###############TEST2################		
	./build/parse Tests/TestsValides/test2.c $(BUILD)/log/log2.txt
	echo ###############TEST3################		
	./build/parse Tests/TestsValides/test3.c $(BUILD)/log/log3.txt
	echo ###############TEST4################		
	./build/parse Tests/TestsValides/test4.c $(BUILD)/log/log4.txt
	echo ###############TEST5################		
	./build/parse Tests/TestsValides/test5.c $(BUILD)/log/log5.txt
	echo ###############TEST6################		
	./build/parse Tests/TestsValides/test6.c $(BUILD)/log/log6.txt
	echo ###############TEST7################		
	./build/parse Tests/TestsValides/test7.c $(BUILD)/log/log7.txt
	echo ###############TEST8################		
	./build/parse Tests/TestsValides/test8.c $(BUILD)/log/log8.txt
	echo ###############TEST9################		
	./build/parse Tests/TestsValides/test9.c $(BUILD)/log/log9.txt
	echo ###############TEST10###############		
	./build/parse Tests/TestsValides/test10.c $(BUILD)/log/log10.txt
	echo ###############TEST11###############		
	./build/parse Tests/TestsValides/test11.c $(BUILD)/log/log11.txt
	echo ###############TEST12###############		
	./build/parse Tests/TestsValides/test12.c $(BUILD)/log/log12.txt
	echo ###############TEST13###############	
	./build/parse Tests/TestsValides/test13.c $(BUILD)/log/log13.txt
	echo ###############TEST14###############		
	./build/parse Tests/TestsValides/test14.c $(BUILD)/log/log14.txt
	echo ###############TEST15###############	
	./build/parse Tests/TestsValides/test15.c $(BUILD)/log/log15.txt

testNV:parse
	clear
	echo ###############TEST1################ line 9			
	./build/parse Tests/TestsNonValide/test1.c $(BUILD)/log/log1.txt
	echo ###############TEST2################ line 14
	./build/parse Tests/TestsNonValide/test2.c $(BUILD)/log/log2.txt
	echo ###############TEST3################ 
	./build/parse Tests/TestsNonValide/test3.c $(BUILD)/log/log3.txt
	echo ###############TEST4################		
	./build/parse Tests/TestsNonValide/test4.c $(BUILD)/log/log4.txt
	echo ###############TEST5################		
	./build/parse Tests/TestsNonValide/test5.c $(BUILD)/log/log5.txt
	echo ###############TEST6################		
	./build/parse Tests/TestsNonValide/test6.c $(BUILD)/log/log6.txt
	echo ###############TEST7################		
	./build/parse Tests/TestsNonValide/test7.c $(BUILD)/log/log7.txt
	echo ###############TEST8################		
	./build/parse Tests/TestsNonValide/test8.c $(BUILD)/log/log8.txt
	echo ###############TEST9################		
	./build/parse Tests/TestsNonValide/test9.c $(BUILD)/log/log9.txt
	echo ###############TEST10###############		
	./build/parse Tests/TestsNonValide/test10.c $(BUILD)/log/log10.txt
	echo ###############TEST11###############		
	./build/parse Tests/TestsNonValide/test11.c $(BUILD)/log/log11.txt
	echo ###############TEST12###############		
	./build/parse Tests/TestsNonValide/test12.c $(BUILD)/log/log12.txt
	echo ###############TEST13###############	
	./build/parse Tests/TestsNonValide/test13.c $(BUILD)/log/log13.txt
	echo ###############TEST14################			
	./build/parse Tests/TestsNonValide/test14.c $(BUILD)/log/log14.txt
	echo ###############TEST15################		
	./build/parse Tests/TestsNonValide/test15.c $(BUILD)/log/log15.txt
	echo ###############TEST16################		
	./build/parse Tests/TestsNonValide/test16.c $(BUILD)/log/log16.txt
	echo ###############TEST17################		
	./build/parse Tests/TestsNonValide/test17.c $(BUILD)/log/log17.txt
	echo ###############TEST18################		
	./build/parse Tests/TestsNonValide/test18.c $(BUILD)/log/log18.txt
	echo ###############TEST19################		
	./build/parse Tests/TestsNonValide/test19.c $(BUILD)/log/log19.txt
	echo ###############TEST20################		
	./build/parse Tests/TestsNonValide/test20.c $(BUILD)/log/log20.txt
	echo ###############TEST21################		
	./build/parse Tests/TestsNonValide/test21.c $(BUILD)/log/log21.txt
	echo ###############TEST22################		
	./build/parse Tests/TestsNonValide/test22.c $(BUILD)/log/log22.txt
	echo ###############TEST23###############		
	./build/parse Tests/TestsNonValide/test23.c $(BUILD)/log/log23.txt
	echo ###############TEST24###############		
	./build/parse Tests/TestsNonValide/test24.c $(BUILD)/log/log24.txt
	echo ###############TEST25###############		
	./build/parse Tests/TestsNonValide/test25.c $(BUILD)/log/log25.txt
	echo ###############TEST26###############	
	./build/parse Tests/TestsNonValide/test26.c $(BUILD)/log/log26.txt

clean:
	rm -rf build/*
	mkdir build/log
	cp $(SRC)/table_symbol.h $(BUILD)
	cp $(SRC)/table_symbol.c $(BUILD)
