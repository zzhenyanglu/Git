arb_test: arb_test.o 
	gcc -std=c11 -Wall -Werror -pedantic -o arb_test arb_test.o

arb_test.o: arb_test.c arb_int.c arb_int.h
	gcc -std=c11 -Wall -Werror -pedantic -c -o arb_test.o arb_test.c
        	

.PHONY: clean
clean:
	rm arb_test arb_test.o 
