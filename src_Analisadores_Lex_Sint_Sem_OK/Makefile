
all: bison flex gcc
	@echo "Done."

bison: parser.y
	bison parser.y

flex: scanner.l
	flex scanner.l

gcc: scanner.c parser.c tables.c
	gcc -Wall -o checker scanner.c parser.c tables.c

clean:
	@rm -f *.o *.output *.dot *.pdf scanner.c parser.h parser.c checker
