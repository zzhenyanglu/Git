#include "mnist.c"
#include <CUnit/Basic.h>
#include <stdlib.h>
#include <limits.h>
#include <assert.h>
#include <stdbool.h>
#include <malloc.h>
#include <time.h>
#include <ctype.h>


// NNOTICE: I AM SORRY THAT I WAS SO BUSY THIS 
//          WEEK BOTH AT WORK AND AT STUDY
//          COMPUTER SYSTEM COURSE IS AT ITS 
//          HARDEST PART, ALSO DATABASES JUST 
//          HAD A MID TERM EXAM ON THURSDAY 
//          i WAS NOT HAVING SO MUCH TIME DOING
//          THIS HOMEWORK,THOUGH TIME SPENT ON 
//          C HAS BEEN ALWAYS MUCH MORE THAN THE OTHER 
//          TWO COURSES. I AM SO SORRY FOR DELIEVERING
//          SUCH A SHITTY HOMEWORK, THOUGH I ONLY SLEPT
//          5 HOURS DURING THE LAST 48 HOURS. I TRIED 
//          MY BEST BUT STILL FEEL THERE ARE JUST MUCH 
//          MORE NEW STUFF EVERY C COURSE. TIME TO STUDY 
//          THEM IS ALWAYS TIGHT. 


//#include <gmp.h>

/* The suite initialization function.
 * Opens the temporary file used by the tests.
 * Returns zero on success, non-zero otherwise.
 */
static int init_suite(void)
{
   return 0;
}


/* The suite cleanup function.
 * Closes the temporary file used by the tests.
 * Returns zero on success, non-zero otherwise.
 */
static int clean_suite(void)
{
   return 0;
}


void test_open(void)
{   
   mnist_dataset_handle h;
 
   h = mnist_open("train");
   CU_ASSERT(h!=MNIST_DATASET_INVALID);
   mnist_free(h);
   h = mnist_open("t10k"); 
   CU_ASSERT(h!=MNIST_DATASET_INVALID);
   mnist_free(h);
   //h = mnist_open("haha");
   //CU_ASSERT(h == MNIST_DATASET_INVALID);
   
}

void test_create(void)
{
   mnist_dataset_handle b = mnist_create(10,10);
   CU_ASSERT(b!=MNIST_DATASET_INVALID); 
   CU_ASSERT(printf("%d", b->total_rows)==10); 
   CU_ASSERT(printf("%d", b->total_images)==1); 
   mnist_free(b);
}


void test_image_count(void)
{
   mnist_dataset_handle b = mnist_create(10,10);
   mnist_dataset_handle h = mnist_open("train");

   CU_ASSERT(printf("%d", mnist_image_count(b))==1); 
   CU_ASSERT(printf("%d", mnist_image_count(h))==60000); 
   mnist_free(h);
   mnist_free(b);
}

void test_image_size(void)
{

   unsigned int x,y;
   mnist_dataset_handle a =MNIST_DATASET_INVALID;
   mnist_image_size(a,&x,&y);
   
   CU_ASSERT(printf("%d",x)==0); 
   CU_ASSERT(printf("%d",y)==0); 

   mnist_dataset_handle h = mnist_open("train");
   mnist_image_size(h,&x,&y);

   CU_ASSERT(printf("%d",x)==28); 
   CU_ASSERT(printf("%d",y)==28); 

   mnist_free(h);
}


void test_image_begin(void)
{

   mnist_dataset_handle h = mnist_open("train");
   mnist_image_handle image = mnist_image_begin(h);
   CU_ASSERT(printf("%d", image->row_size)==28);
   CU_ASSERT(printf("%d", image->col_size)==28);
   CU_ASSERT(printf("%d", *(image->labeldata))==5);

   mnist_free(h);
} 



void test_image_next(void)
{
   mnist_dataset_handle h = mnist_open("train");
   mnist_image_handle image =mnist_image_begin(h); 
   mnist_image_handle image_next =mnist_image_next(image);

   CU_ASSERT(printf("%d", mnist_image_label(image_next))==0);
   mnist_free(h);
}



void test_add_after(void)
{
   mnist_image_handle i = MNIST_IMAGE_INVALID;
   mnist_dataset_handle h = mnist_open("train");
   mnist_image_handle image =mnist_image_begin(h); 
   mnist_image_handle image_next =mnist_image_next(image);
   const unsigned char * image_next_data = mnist_image_data(image_next);
   unsigned int x=30;
   unsigned int y=30;
   unsigned int label=7;
   CU_ASSERT(mnist_image_add_after(h, i, image_next_data,x, y, label)==MNIST_IMAGE_INVALID);

   x=28; 
   y=28;

   mnist_image_handle added_image = mnist_image_add_after(h, i, image_next_data,x, y, label); 

   CU_ASSERT(printf("%d", *(added_image->labeldata))==7);
   
   mnist_image_handle added_image_2 = mnist_image_add_after(h, image, image_next_data,x, y, label);

   CU_ASSERT(printf("%d", *(added_image_2->labeldata))==7);

   mnist_free(h);
}

void test_mnist_save(void)
{
   
   mnist_dataset_handle h = mnist_open("train");
   mnist_save(h, "haha");

   mnist_free(h);

   h = mnist_open("haha");
   CU_ASSERT(h!=MNIST_DATASET_INVALID);

   CU_ASSERT(printf("%d", mnist_image_count(h))==60000); 

}


int main()
{
   CU_pSuite pSuite = NULL;

   /* initialize the CUnit test registry */
   if (CUE_SUCCESS != CU_initialize_registry())
      return CU_get_error();

   /* add a suite to the registry */
   pSuite = CU_add_suite("Suite_1", init_suite, clean_suite);
   if (NULL == pSuite) {
      CU_cleanup_registry();
      return CU_get_error();
   }

   /* add the tests to the suite */
   /* NOTE - ORDER IS IMPORTANT - MUST TEST fread() AFTER fprintf() */
   if ((NULL == CU_add_test(pSuite, "test of test_open()", test_open)) ||
       (NULL == CU_add_test(pSuite, "test of test_create()", test_create))||
       (NULL == CU_add_test(pSuite, "test of test_image_count()", test_image_count))||
       (NULL == CU_add_test(pSuite, "test of test_image_size()", test_image_size))||
       (NULL == CU_add_test(pSuite, "test of test_image_begin()", test_image_begin))||
       (NULL == CU_add_test(pSuite, "test of test_image_next()", test_image_next))||
       (NULL == CU_add_test(pSuite, "test of test_add_after()", test_add_after))||
       (NULL == CU_add_test(pSuite, "test of test_mnist_save()", test_mnist_save))
      )
   {
      CU_cleanup_registry();
      return CU_get_error();
   }

   /* Run all tests using the CUnit Basic interface */
   CU_basic_set_mode(CU_BRM_VERBOSE);
   CU_basic_run_tests();
   CU_cleanup_registry();
   return CU_get_error();
}
