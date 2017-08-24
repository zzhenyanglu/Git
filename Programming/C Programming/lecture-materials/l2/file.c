// first line of the program
// Example program showing how to open a file and access it
// character-by-character or line-by-line
//

// contains fopen etc.
#include <stdio.h>
#include <stdlib.h>

int main (int argc, char ** args)
{
   // Open file file.c for reading
   FILE * f = fopen("file.c", "r");

   // Make sure to check if we were able to open the file
   if (!f)
   {
      // see the manpage for perror
      perror("There was a problem opening the file: ");
      return EXIT_FAILURE;
   }

   // Read a characer
   int c = fgetc(f);
   if (c == EOF)
   {
      // we couldn't read, it was the end of the file or there was an error
   }
   else
   {
      printf("The first character of the file is: %c\n", c);
   }

   // Now try to read a full line
   char buffer[128];
   if (!fgets(buffer, sizeof(buffer), f))
   {
      // error!
      perror("Couldn't read line: ");
      // close file
      fclose(f);
      return EXIT_FAILURE;
   }
   printf("The REMAINDER of the first line is: %s\n", buffer);

   // make sure to close the file!
   fclose(f);
   return EXIT_SUCCESS;
}
