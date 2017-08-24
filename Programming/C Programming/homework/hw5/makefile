all: test_mnist mnist2pgm

test: test_mnist
   valgrind --leak-check=full ./test_mnist 

test_mnist: test_mnist.o
   gcc -std=c11 -pedantic -Wall -Werror -ggdb -o test_mnist -lgmp -lcunit test_mnist.o

test_mnist.o: test_mnist.c mnist.c mnist.h
   gcc -std=c11 -pedantic -Wall -Werror -ggdb -c -o test_mnist.o -lgmp -lcunit test_mnist.c

mnist2pgm: mnist2pgm.o
   gcc -std=c11 -Wall -Werror -pedantic -o mnist2pgm mnist2pgm.o    

mnist2pgm.o: mnist.h mnist.c mnist2pgm.c
   gcc -std=c11 -Wall -Werror -pedantic -c -o mnist2pgm.o mnist2pgm.c

.PHONY: clean
clean:
   rm test_mnist test_mnist.o mnist2pgm mnist2pgm.o
        
