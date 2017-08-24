scramble: scramble.o 
	gcc -std=c11 -Wall -Werror -pedantic -o scramble scramble.o

scramble.o: scramble.c
	gcc -std=c11 -Wall -Werror -pedantic -c -o scramble.o scramble.c

.PHONY: clean
clean:
	rm scramble scramble.o
