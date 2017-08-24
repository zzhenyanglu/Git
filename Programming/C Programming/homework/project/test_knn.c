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
#include "knn.h"
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

   // DISTANCE FUNCTION TYPE:
   // 1: euclid
   // 2: reduced
   // 3: downsample
   // 4: crop
   // 5: threshold

// this part does not test function errors handling
void error_handling_test(void)
{
   distance_t f = create_distance_function("euclid");
   
   printf("\n");
   // test empty dataset
   mnist_dataset_handle dataset_test=NULL;
   mnist_dataset_handle dataset_train=NULL;
   mnist_image_handle first_image = NULL;
   
   unsigned long result = knn(dataset_train, first_image,5,f);;

   CU_ASSERT(dataset_test == MNIST_DATASET_INVALID);
   CU_ASSERT(dataset_train == MNIST_DATASET_INVALID);
   CU_ASSERT(first_image == MNIST_IMAGE_INVALID);
   CU_ASSERT(result == EXIT_FAILURE);
  
   // launch a dataset and test empty image
   dataset_test = mnist_open("t10k");
   dataset_train = mnist_open("train");
 
   result = knn(dataset_train, first_image,5,f);;
   CU_ASSERT(dataset_test != MNIST_DATASET_INVALID);
   CU_ASSERT(dataset_train != MNIST_DATASET_INVALID);
   CU_ASSERT(result == EXIT_FAILURE);

   // test k = 0
   first_image = mnist_image_begin(dataset_train);
   result = knn(dataset_train, first_image,0,f);;

   CU_ASSERT(first_image != MNIST_IMAGE_INVALID);
   CU_ASSERT(result == EXIT_FAILURE);

   // test null distance function
   f = NULL;
   result = knn(dataset_train, first_image,5,f);;
   CU_ASSERT(result == EXIT_FAILURE);

   // finally test a valid use case
   f = create_distance_function("euclid");
   result = knn(dataset_train, first_image,5,f);;
   CU_ASSERT(result != EXIT_FAILURE);
  
   mnist_free(dataset_test);   
   mnist_free(dataset_train); 

   free(first_image->imagedata);
   free(first_image->labeldata);
   free(first_image->next);  
   free(first_image);  

}

// the following is testing knn logics with euclid distance function
// My euclid distance function is able to give out very accurate guess
// so I will use it to test the KNN logic
// if using "train" dataset as the training one, and images inside t10k
// as the testing ones, I have verify that the first 100 images can be guesse
// 100% right. So I will repeat this test as to verify KNN logic. 
// I will guess the first 30 images, as it's relatively fast for the first 30

// if you test it with random sample then there will be assertion that fails. 
void test_knn(void)
{  
   mnist_dataset_handle dataset_train =  mnist_open("train");
   mnist_dataset_handle dataset_test =  mnist_open("t10k");
   mnist_image_handle first_image = mnist_image_begin(dataset_test);
   mnist_image_handle second_image ;
   distance_t f = create_distance_function("euclid");
   unsigned char result; 


   CU_ASSERT(dataset_test != MNIST_DATASET_INVALID);
   CU_ASSERT(dataset_train != MNIST_DATASET_INVALID);
   CU_ASSERT(first_image != MNIST_IMAGE_INVALID);
   printf("\n");

   for(unsigned int i=0;i<30;i++)
   {
      second_image = mnist_image_next(first_image);
      CU_ASSERT(first_image != MNIST_IMAGE_INVALID);

      result = knn(dataset_train, second_image,5,f);
      CU_ASSERT(result==mnist_image_label(second_image));
      printf("the %ust image: \n",i);
      printf("guess =%u ",result);
      printf("label =%u\n",mnist_image_label(second_image));
      
      // clean up the memory takes up by the image.
      free(first_image->imagedata);
      free(first_image->labeldata);
      free(first_image->next);

      first_image = second_image;
   }
   
   mnist_free(dataset_train);
   mnist_free(dataset_test);

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
   if ((NULL == CU_add_test(pSuite, "test of error_handling", error_handling_test)) ||
       (NULL == CU_add_test(pSuite, "test of KNN logic", test_knn))
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
