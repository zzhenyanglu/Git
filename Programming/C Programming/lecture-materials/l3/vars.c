#include <stdio.h>
#include <stdlib.h>

int main ()
{
   // some variable
   int i;

   // type is integer
   // size of integer known at compile time.
   
   // Uninitialized variables have no predetermined value
   // Initialize before using!
   printf ("value of i = %i\n", i);

   // constant for a given platform *and* compiler
   printf ("size of i = %i\n", (int) sizeof(i));

   // operator &  (address-of) returns:
   //   - a /pointer/ to T (where T is the type of the variable, int in this case)
   //   - the *value* of pointer will be the *address* of i
   printf ("address of i = %p\n", (void*) &i);
   
   return EXIT_SUCCESS;
}
