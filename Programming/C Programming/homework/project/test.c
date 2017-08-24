#include <CUnit/Basic.h>
#include <stdlib.h>
#include <limits.h>
#include <assert.h>
#include <stdbool.h>
#include <malloc.h>
#include <time.h>
#include <ctype.h>
#include "mnist.c"


int main()
{
   mnist_dataset_handle b = mnist_open_sample("train",10);
   printf("haha %d\n", b->total_rows);
   printf("haha %d\n", b->total_images);
   printf("image0 %d\n", b->labeldata[0]);
   printf("image1 %d\n", b->labeldata[1]);
   printf("image2 %d\n", b->labeldata[2]);
   mnist_save(b,"haha");
}
