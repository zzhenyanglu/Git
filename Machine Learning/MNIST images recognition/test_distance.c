#include <CUnit/Basic.h>
#include <stdlib.h>
#include <limits.h>
#include <assert.h>
#include <stdbool.h>
#include <malloc.h>
#include <time.h>
#include <ctype.h>
#include "mnist.h"
#include "distance.h"
#include <gmp.h>
#include <unistd.h>

static int init_suite(void)
{
   return 0;
}


static int clean_suite(void)
{
   return 0;
}

   // FUNCTION TYPE:
   // 1: euclid
   // 2: reduced
   // 3: downsample
   // 4: crop
   // 5: threshold

// this part does not test results returned by any distance function
// just test bunch of general stuff like call function or distance 
// function errors handling..and so on 
void general_test(void)
{
   
   // launch a dataset
   mnist_dataset_handle dataset = mnist_open_sample("t10k",100);
   mnist_image_handle image_a = mnist_image_begin(dataset);
   mnist_image_handle image_b = mnist_image_next(image_a);
   
   CU_ASSERT(dataset!=MNIST_DATASET_INVALID);
   CU_ASSERT(image_a!=MNIST_IMAGE_INVALID);
   CU_ASSERT(image_b!=MNIST_IMAGE_INVALID);

   // test function call
   distance_t f = create_distance_function("euclid");
   unsigned long result = f->function(image_a, image_b);
   CU_ASSERT(result !=-1 && result!= 0);   
   CU_ASSERT(f->function_type ==1);
   free(f);   


   // test function call
   f = create_distance_function("reduced");
   result = f->function(image_a, image_b);
   CU_ASSERT(result !=-1 && result!= 0);   
   CU_ASSERT(f->function_type ==2);
   free(f);   
   

   // test function call
   f = create_distance_function("downsample");
   result = f->function(image_a, image_b);
   CU_ASSERT(result !=-1 && result!= 0);   
   CU_ASSERT(f->function_type ==3);
   free(f);   


   // test function call
   f = create_distance_function("crop");
   result = f->function(image_a, image_b);
   CU_ASSERT(result !=-1 && result!= 0);   
   CU_ASSERT(f->function_type ==4);
   free(f);   

   // test function call
   f = create_distance_function("threshold");
   result = f->function(image_a, image_b);
   CU_ASSERT(result !=-1 && result!= 0);   
   CU_ASSERT(f->function_type ==5);
   free(f);   

 
   // test error handling, should return -1
   image_b->row_size = 29;
   f = create_distance_function("threshold");
   result = f->function(image_a, image_b);
   CU_ASSERT(result ==-1 );   
   CU_ASSERT(f->function_type ==5);
   free(f);   

   mnist_free(dataset);
}

// the following tests are testing distance values
// returned by each distance function
void test_euclid(void)
{  
 
   mnist_dataset_handle a = mnist_open("t10k");
   mnist_image_handle image_a = mnist_image_begin(a);
   mnist_image_handle image_b = mnist_image_next(image_a);
   mnist_image_handle image_c = mnist_image_next(image_b);
   mnist_image_handle image_d = mnist_image_next(image_c);
   
   distance_t f = create_distance_function("euclid");

   CU_ASSERT(f->function(image_a, image_b)==2873);   
   CU_ASSERT(f->function(image_a, image_c)==2176);   
   CU_ASSERT(f->function(image_a, image_d)==2655);   
   
   mnist_free(a);
   
}


//every other pixels get computed standard variance
void test_downsample(void)
{
   mnist_dataset_handle a = mnist_open("t10k");
   mnist_image_handle image_a = mnist_image_begin(a);
   mnist_image_handle image_b = mnist_image_next(image_a);
   mnist_image_handle image_c = mnist_image_next(image_b);
   mnist_image_handle image_d = mnist_image_next(image_c);
   
   distance_t f = create_distance_function("reduced");
 
   CU_ASSERT(f->function(image_a, image_b)==10396);   
   CU_ASSERT(f->function(image_a, image_c)==8583);   
   CU_ASSERT(f->function(image_a, image_d)==18560);   
   
   mnist_free(a);
}



void test_reduced(void)
{
   mnist_dataset_handle a = mnist_open("t10k");
   mnist_image_handle image_a = mnist_image_begin(a);
   mnist_image_handle image_b = mnist_image_next(image_a);
   mnist_image_handle image_c = mnist_image_next(image_b);
   mnist_image_handle image_d = mnist_image_next(image_c);
   
   distance_t f = create_distance_function("downsample");
 
   CU_ASSERT(f->function(image_a, image_b)==2033);   
   CU_ASSERT(f->function(image_a, image_c)==1492);   
   CU_ASSERT(f->function(image_a, image_d)==1831);   
   
   mnist_free(a);
}

// layer: 1
// if layer == 2 then there should be diff between
// crop and euclid for image 1
// otherwise they have same results
void test_crop(void)
{
   mnist_dataset_handle a = mnist_open("t10k");
   mnist_image_handle image_a = mnist_image_begin(a);
   mnist_image_handle image_b = mnist_image_next(image_a);
   mnist_image_handle image_c = mnist_image_next(image_b);
   mnist_image_handle image_d = mnist_image_next(image_c);
   
   distance_t f = create_distance_function("crop");
 
   CU_ASSERT(f->function(image_a, image_b)==2873);   
   CU_ASSERT(f->function(image_a, image_c)==2176);   
   CU_ASSERT(f->function(image_a, image_d)==2655);   
   
   mnist_free(a);

}

// threshold value : 127
void test_threshold(void)
{
   mnist_dataset_handle a = mnist_open("t10k");
   mnist_image_handle image_a = mnist_image_begin(a);
   mnist_image_handle image_b = mnist_image_next(image_a);
   mnist_image_handle image_c = mnist_image_next(image_b);
   mnist_image_handle image_d = mnist_image_next(image_c);
   
   distance_t f = create_distance_function("threshold");
 
   CU_ASSERT(f->function(image_a, image_b)==44);   
   CU_ASSERT(f->function(image_a, image_c)==32);   
   CU_ASSERT(f->function(image_a, image_d)==75);   
   
   mnist_free(a);

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
   if ((NULL == CU_add_test(pSuite, "test of general_test()", general_test)) ||
       (NULL == CU_add_test(pSuite, "test of euclid_function()", test_euclid))||
       (NULL == CU_add_test(pSuite, "test of reduced_function()", test_reduced))||
       (NULL == CU_add_test(pSuite, "test of downsample_function()", test_downsample))||
       (NULL == CU_add_test(pSuite, "test of crop_function()", test_crop))||
       (NULL == CU_add_test(pSuite, "test oif threshold_function()", test_threshold))
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
