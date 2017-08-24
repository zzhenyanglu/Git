main: main.o 
	gcc -std=c11 -Wall -Werror -pedantic -o main main.o

main.o: main.c convert.c convert.h
	gcc -std=c11 -Wall -Werror -pedantic -c -o main.o main.c


        	

.PHONY: clean
clean:
	rm main main.o 
