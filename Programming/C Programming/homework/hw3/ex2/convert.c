#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

unsigned int copyAndConvert (const char * source, char * dest, unsigned int destsize)
{
   int i = 0;
 
   // read each char and convert it to UPPERCASE 
   // until reach the end of string or destsize
   for(; i < destsize-1 && *(source+i)!='\0';i++)
   { 
      *(dest+i) = toupper(*(source+i)); 
   }
   *(dest+i)= '\0';
   return i;   
}
