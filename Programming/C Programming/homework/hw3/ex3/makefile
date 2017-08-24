palindrome: palindrome.o 
	gcc -std=c11 -Wall -Werror -pedantic -o palindrome palindrome.o

palindrome.o: palindrome.c
	gcc -std=c11 -Wall -Werror -pedantic -c -o palindrome.o palindrome.c


        	

.PHONY: clean
clean:
	rm palindrome palindrome.o
