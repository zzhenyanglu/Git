histogram: histogram.o 
	gcc -std=c11 -Wall -Werror -pedantic -o histogram histogram.o

histogram.o: histogram.c
	gcc -std=c11 -Wall -Werror -pedantic -c -o histogram.o histogram.c

.PHONY: clean
clean:
	rm histogram histogram.o
