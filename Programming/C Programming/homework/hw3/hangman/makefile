hangman: hangman.o 
	gcc -std=c11 -Wall -Werror -pedantic -o hangman hangman.o

hangman.o: hangman.c
	gcc -std=c11 -Wall -Werror -pedantic -c -o hangman.o hangman.c
        	

.PHONY: clean
clean:
	rm hangman hangman.o
