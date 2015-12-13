SRC=src
BUILD=build
LEX=lex
YACC=bison
CFLAGS=-Wall
CC=gcc

EXPRESSION= 

all:parse

parse:grammar.c scanner.c
	$(CC) $(CFLAGS) -o $(BUILD)/$@ $(BUILD)/grammar.c $(BUILD)/scanner.c

grammar.c:$(SRC)/grammar.y
	$(YACC) -d -o $(BUILD)/$@ --defines=$(BUILD)/grammar.tab.h $^

scanner.c: $(SRC)/scanner.l
	$(LEX) -o $(BUILD)/$@ $^

test:parse
	clear
	echo ###############TEST1################			
	./build/parse Tests/TestsValides/test1.c
	echo ###############TEST2################		
	./build/parse Tests/TestsValides/test2.c
	echo ###############TEST3################		
	./build/parse Tests/TestsValides/test3.c
	echo ###############TEST4################		
	./build/parse Tests/TestsValides/test4.c
	echo ###############TEST5################		
	./build/parse Tests/TestsValides/test5.c
	echo ###############TEST6################		
	./build/parse Tests/TestsValides/test6.c
	echo ###############TEST7################		
	./build/parse Tests/TestsValides/test7.c
	echo ###############TEST8################		
	./build/parse Tests/TestsValides/test8.c
	echo ###############TEST9################		
	./build/parse Tests/TestsValides/test9.c
	echo ###############TEST10###############		
	./build/parse Tests/TestsValides/test10.c
	echo ###############TEST11###############		
	./build/parse Tests/TestsValides/test11.c
	echo ###############TEST12###############		
	./build/parse Tests/TestsValides/test12.c
	echo ###############TEST13###############	
	./build/parse Tests/TestsValides/test13.c

clean:
	rm -f build/*
	cp $(SRC)/header.h $(BUILD)
