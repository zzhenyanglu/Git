#include "mnist.h"
#include "distance.h"
#include "knn.h"
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>

//program arugments:
// 0. train_dataset_name
// 1. train_size
// 2. test_dataset_name
// 3. k
// 4. distance_scheme

double ocr( unsigned long train_size, unsigned int k, char* train_dataset_name, char* test_dataset_name, char* distance_scheme)
{
   // HANDLE DISTANCE FUNCTION 
   // initiate distance_t
   distance_t distance = create_distance_function(distance_scheme);
   if (distance ==NULL)
      return EXIT_FAILURE;
   
   // HANDLE TRAIN DATASET
   // handle train-size
   mnist_dataset_handle train_dataset=mnist_open(train_dataset_name);
   unsigned long train_dataset_image_count = (unsigned long) mnist_image_count(train_dataset);
  
   // if train_size ==0 or equal to train dataset
   if (train_size==0 || train_size==train_dataset_image_count);
    
   // if less than training dataset size
   // use mnist_open_sample
   else if (train_size > 0 &&  train_size < train_dataset_image_count)
   {
      mnist_free(train_dataset);
      train_dataset = mnist_open_sample(train_dataset_name, train_size);
   }

   // if less than 0 or bigger than train_size
   else  
   {
      printf("Invalid image size for training dataset! %s dataset has %lu images\n",train_dataset_name, train_size );
      return EXIT_FAILURE;
   }

   // HANDLE TEST DATASET
   mnist_dataset_handle test_dataset = mnist_open(test_dataset_name);

   // check return value; 
   if(test_dataset == MNIST_DATASET_INVALID || train_dataset == MNIST_DATASET_INVALID)
   {
      printf("empty train or test dataset\n");
      return EXIT_FAILURE;
   }

   // count how many images in both datasets
   unsigned long test_dataset_image_count = mnist_image_count(test_dataset);
   train_dataset_image_count = mnist_image_count(train_dataset);

   mnist_image_handle first_image = mnist_image_begin(test_dataset);
   mnist_image_handle second_image;

   unsigned long guess = knn(train_dataset, first_image,5,distance);
   unsigned int processed_image =1;
   unsigned int right_guess =0;
   unsigned int wrong_guess =0;
   
   // handle the first image
   guess = knn(train_dataset, first_image,5,distance);
   if(guess == mnist_image_label(first_image))
      right_guess++;
   else wrong_guess++;
     
   printf("K = %u\n",k);
   printf("[%s] %u/%lu (%5.2f%%), %u/%u (%5.2f%%)\n",distance_scheme,processed_image, \
      test_dataset_image_count, ((double)processed_image/test_dataset_image_count*10)\
      ,right_guess, processed_image, ((double)right_guess/processed_image*100) );

   long t= time(0);
   for(unsigned int processed_image=1;processed_image<test_dataset_image_count-1;processed_image++)
   {

      second_image = mnist_image_next(first_image);
      guess = knn(train_dataset, second_image,5,distance);

      // count right/wrong guess
      if(guess == mnist_image_label(second_image))
         right_guess++;
      else wrong_guess++;  
 
      //printf("label =%u\n",mnist_image_label(second_image));
      //printf("guess =%lu\n",guess);
      
      if( time(0) >t) 
      {   
         printf("[%s] %u/%lu (%5.2f%%), %u/%u (%5.2f%%)\n",distance_scheme, processed_image,\
         test_dataset_image_count, ((double)processed_image/test_dataset_image_count*100),\
         right_guess, processed_image, ((double)right_guess/processed_image*100) );

         t = time(0); 
      }

      // clean up the memory takes up by the image.
      free(first_image->imagedata);
      free(first_image->labeldata);
      free(first_image->next);

      first_image = second_image;
   }

   printf("All images are processed with %s distance function, accuracy rate is %5.2f%%\n",distance_scheme,((double)right_guess/test_dataset_image_count*100) );
   
   return (double)right_guess/test_dataset_image_count*100;
}



int main(int argc, char** argv)
{
   
   if (argc!=6)
   {
      printf("Exactly 5 arguments needed:\n[train-name]\n[train-size]\n[test-name]\n[k]\n[distance-scheme]\n");
      return EXIT_FAILURE;
   }
   
   // 1. handle test and train dataset names
   char* train_dataset_name = argv[1];
   char* test_dataset_name = argv[3];

   unsigned long train_size[4] = {0,0,0,0};
   unsigned int k[5] = {0,0,0,0,0};
   char* distance_scheme[5] = {" "};

   // 2. handle train_size
   if(strcmp(argv[2],"all") !=0)
   {
      train_size[0] = (unsigned long)atol(argv[2]);
   }

   else 
   {
      mnist_dataset_handle train_dataset = mnist_open(train_dataset_name);
      int train_dataset_image_count = mnist_image_count(train_dataset);
  
      train_size[0] = (unsigned long)train_dataset_image_count*.25;
      train_size[1] = (unsigned long)train_dataset_image_count*.5;
      train_size[2] = (unsigned long)train_dataset_image_count*.75;
      train_size[3] = (unsigned long)train_dataset_image_count;
      mnist_free(train_dataset);
   }

   // test print
   //for(int i=0; i < sizeof(train_size)/sizeof(train_size[0]);i++)
   //   printf("train_size is %lu\n",train_size[i]);

   // 3. handle K
   if(strcmp(argv[4],"all") !=0)
   {
      k[0] = (unsigned int)atoi(argv[4]);
   }
   else 
   {
      k[0] = 1;
      k[1] = 5;
      k[2] = 10;
      k[3] = 15;
      k[4] = 20;
   }

   // 4. handle distance schemes 
   if(strcmp(argv[5],"all") !=0)
   {
       distance_scheme[0] = argv[5];
   }
   else
   {
       distance_scheme[0] = "euclid";
       distance_scheme[1] = "reduced";
       distance_scheme[2] = "downsample";
       distance_scheme[3] = "crop";
       distance_scheme[4] = "threshold";
   }

   double stats[100];
   
//  stats[100]=  {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100};

   unsigned int stats_index=0;

   // running the ocr 
   for(unsigned long i=0; (distance_scheme[i] != NULL) && (i < sizeof(distance_scheme)/sizeof(distance_scheme[0]));i++)
      for(unsigned long j=0; (k[j]!=0) && (j < sizeof(k)/sizeof(k[0]));j++)
         for(unsigned long h=0; (train_size[h] != 0) && (h < sizeof(train_size)/sizeof(train_size[0]));h++)
         {
            stats[stats_index] = ocr(train_size[h], k[j], train_dataset_name , test_dataset_name, distance_scheme[i]);
            stats_index++;
         }

 
   // if there is at least one 'all' sepcified as argument then
   // PRINT ADDITIONAL REPORT
   if ( (strcmp(argv[5],"all") ==0) || (strcmp(argv[4],"all") ==0)|| (strcmp(argv[2],"all") ==0))
   {
      // PRINTING RESULTS
      // printing header 
      printf("# distance k ");

      for(unsigned long h=0; (train_size[h] != 0) && (h < sizeof(train_size)/sizeof(train_size[0]));h++)
         printf("%lu ", train_size[h]);

      printf("\n");
      
      // printing body
      stats_index=0;

      for(unsigned long i=0; (distance_scheme[i] != NULL) && (i < sizeof(distance_scheme)/sizeof(distance_scheme[0]));i++)
         for(unsigned long j=0; (k[j]!=0) && (j < sizeof(k)/sizeof(k[0]));j++)
         {
            printf("%s %u ",distance_scheme[i],k[j]);
            for(unsigned long h=0; (train_size[h] != 0) && (h < sizeof(train_size)/sizeof(train_size[0]));h++)
            {
               printf("%5.2f ",stats[stats_index]);
               stats_index++;
            }
            printf("\n");
         }
   }

   return EXIT_SUCCESS;
}

