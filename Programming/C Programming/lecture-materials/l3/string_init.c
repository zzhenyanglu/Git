// Example showing string initialization

#include <string.h>
#include <stdlib.h>
#include <stdio.h>




int main (int argc, char ** args)
{
   // Size of this array will be 6 bytes: 5 characters + terminating 0-byte
   // ( "12345" is really the same as the array of chars containing  '1','2','3','4','5',0 )
   char mystring[] = "12345";


   puts(mystring);

   printf ("Size of the mystring array = %i bytes\n", (int) sizeof(mystring));
   printf ("Length of the string stored in the  mystring array = %i characters\n", (int)
         strlen(mystring));

   char c = mystring[0];
   printf("The first character is at position 0 in the array: %c\n", c);

   printf("The numeric value of character '1' is: %i\n", (int) c);
   printf("The numeric value of character '2' is: %i\n", (int) '2');


   return EXIT_SUCCESS;
}
