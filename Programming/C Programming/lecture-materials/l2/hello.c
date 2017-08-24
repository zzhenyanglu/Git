#include "hello.h"

#include <stdlib.h>
#include <stdio.h>

int main (int argc, char ** args)
{
   do_print();
   return EXIT_SUCCESS;
}

// DEFINITION of the do_print function
void do_print()
{
   puts("Hello World!");
}
