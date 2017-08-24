all: ocr test_mnist test_distance test_knn
	
test: test_d test_m test_k
	
test_o: ocr
	./ocr
        
test_d: test_distance
	./test_distance

test_m: test_mnist
	./test_mnist

test_k: test_knn
	./test_knn

ocr: ocr.c mnist.c mnist.h distance.h distance.c knn.h knn.c
	gcc -std=c11 -Wall -Werror -pedantic -o ocr ocr.c mnist.c distance.c knn.c -lm

test_mnist: test_mnist.c mnist.h mnist.c
	gcc -std=c11 -Wall -Werror -pedantic -o test_mnist mnist.c test_mnist.c -lcunit

test_distance: test_distance.c distance.h distance.c
	gcc -std=c11 -Wall -Werror -pedantic -o test_distance test_distance.c distance.c mnist.c -lm -lcunit

test_knn: test_knn.c knn.h knn.c distance.h distance.c mnist.c mnist.h
	gcc -std=c11 -Wall -Werror -pedantic -o test_knn knn.c test_knn.c distance.c mnist.c -lm -lcunit

.PHONY: clean
clean:
	rm test_knn test_distance test_mnist ocr 

