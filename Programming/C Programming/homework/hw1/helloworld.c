#include <stdio.h>
#include <stdlib.h>

char* hello(void);

int main(){
	printf("%s\n",hello());
	return EXIT_SUCCESS;
}

char* hello(){

	return "hello, world!";
}
