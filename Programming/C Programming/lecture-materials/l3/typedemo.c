#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

int main (int argc, char ** args)
{
   
   // Domain is only 2 values: 0 and 1
   _Bool q;

   q = 3;
   printf ("Value of q = %i\n", q);
   printf ("Size of _Bool = %i bytes\n", (int) sizeof(q));


   // After including stdbool.h, bool becomes an alias for _Bool
   // and true and false are defined
   bool d = q;
   printf ("Value of d = %i\n", d);

   // true and false are #define'd to 1 and 0 respectively
   // (*only* when stdbool.h is included)
   int tval = true;
   int qval = false;
   printf ("true = %i, false=%i\n", tval, qval);


   // It is possible to have fixed-width integer types: look at stdint.h
   // (man stdint.h)


   // How to know what the range of a certain type is?
   // --> see limits.c
   // For floating point types: see floatlimits.c

   // constant/literal:
   int i = 3;     // integer numbers are integer constants (i.e. SIGNED!)
   unsigned int j = 10u; // u suffix indicates unsigned int constant

   {
   // Flaoting point types: (always signed)
   // Float, double, long double
   float f = 0.23;
   double d = 0.49;
   long double dd = 12121212.23423;

#define SHOWME(var,type) printf("Variable " #var " of type " #type ": value=%f size=%i\n", \
      (double) var, (int) sizeof(var))

   SHOWME(f, float);
   SHOWME(d, double);
   SHOWME(dd, long double);

#undef SHOWME
   }



   // Types can be /qualified/: const, volatile (ignore for now), long, short, signed, unsigned
   
   // const -> prevents modifying the type
   {
      const int z;   // doesn't make any sense: uninitialized and can't modify!

      // z = 10;  // error

      puts("Compiler won't allow us to modify const types");
   }

   // long
   long long unsigned int big = 16;
   printf("size of long long unsigned int=%lu bytes\n", sizeof(big));

   return EXIT_SUCCESS;
}
