#include "convert.h"
#include "convert.c"
#include <stdio.h>
#include <stdlib.h>
int main()
{

   // NOTICE: 
   //        dest_size is the length of destination string
   //        max_source_string_size is the max length of source string
   //        since the homework doesn't specify max length of source
   //        string, I will make my own assumptions

   const int dest_string_size = 100;
   const int max_source_string_size = 1000; 
   char dest_string[dest_string_size]; 
   
   //char source_string[source_string_size];
   //NOTICE: for now I assume the max source 
   //        string is 2000 byte
   char source_string[max_source_string_size];
   
   // prompt user to enter source string
   printf("Please enter source string(max length %d): \n", max_source_string_size);
   fgets(source_string,max_source_string_size,stdin);

   // output source and dstination string

   printf("Character converted to destination: %d\n", copyAndConvert(source_string,dest_string, dest_string_size));
   printf("Destination string: %s\n", dest_string);
   
   return EXIT_SUCCESS;  
}
