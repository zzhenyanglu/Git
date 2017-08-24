
#include <stdio.h>

int max (int a, int b)
{
   return (a > b ? a : b);
}


#define MAX(a,b) (a > b ? a : b)

int main (int argc, char ** args)
{
   int i = 3;

   i++;  // same as i=i+1;

   printf("Value is=%i\n", MAX(i++,3));

   MAX(2+3, 3);

   printf("Value of i is=%i\n", i);

}
