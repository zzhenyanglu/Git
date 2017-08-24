#include "mylib.h"

// for tolower
#include <ctype.h>

// for assert
#include <assert.h>

int copy_and_lower(char * dest, const char * source, size_t destsize)
{
   unsigned int curpos;
   for (curpos=0; curpos<destsize-1; ++curpos)
   {
      char c = source[curpos];
      if (!c)
         break;
      dest[curpos] = tolower(c);
   }
   // make sure to zero-terminate string!
   dest[curpos]=0;

   // Sanity check we didn't write outside of our dest buffer!
   assert(curpos < destsize);
   return curpos;
}

