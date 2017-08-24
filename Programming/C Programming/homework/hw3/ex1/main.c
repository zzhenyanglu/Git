// I'm not sure what exactly I have to put into 
// swap.h so I just declare swap() in swap.h
// and leave the definition part in here
#include <stdio.h>
#include <stdlib.h>
#include "swap.h"
#include "swap.c"

int main()
{   
   int a=1;
   int b=0;
   printf("before: a=%d , b=%d\n",a,b); 
   swap(&a,&b);
   printf("after: a=%d , b=%d\n",a,b); 

}
