#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include <stdint.h>

unsigned int total = 0;

void * printHello (void * threadid)
{
   ++total;
   // or pthread_exit(NULL);
   return NULL;
}

int main (int argc, char ** args)
{
   if (argc != 2)
   {
      fputs("Need argument: number of thread to create!\n", stderr);
      return EXIT_FAILURE;
   }

   int count = atoi(args[1]);

   pthread_t threads[count];

   for (int i=0; i<count; ++i)
   {
      pthread_create(&threads[i],
            NULL, printHello, (void *)(intptr_t) i);
   }

   // Join all threads
   for (int i=0; i<count; ++i)
   {
      // -- BLOCKING -- operation
      void * returncode;
      pthread_join(threads[i], &returncode);
   }

   printf("Total count = %u\n", total);

   return EXIT_SUCCESS;
}

