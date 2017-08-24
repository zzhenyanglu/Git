#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include <stdint.h>

void * printHello (void * threadid)
{
   long tid = (long) threadid;
   printf("Hello from thread %ld!\n", tid);

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

   return EXIT_SUCCESS;
}

