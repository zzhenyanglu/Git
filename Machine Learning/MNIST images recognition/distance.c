#include "distance.h"
#include <stdlib.h>
#include <stdbool.h>
#include "mnist.h"
#include <stdio.h>
#include <string.h>
#include <time.h>  
#include <math.h>

   // FUNCTION TYPE:
   // 1: euclid
   // 2: reduced
   // 3: downsample
   // 4: crop
   // 5: threshold

distance_t create_distance_function(const char *schemename)
{
   distance_t new = malloc(sizeof(distance_t));

   if(strcmp(schemename, "euclid")==0)
   {
      new-> function_type =1;
      new-> function = euclid;
   }
   else if(strcmp(schemename, "reduced")==0)
   {
      new-> function_type =2;
      new-> function = reduced;
   }
   else if(strcmp(schemename, "downsample")==0)
   {
      new-> function_type =3;
      new-> function = downsample;
   }
   else if(strcmp(schemename, "crop")==0)
   {
      new-> function_type =4;
      new-> function = crop;
   }
   else if(strcmp(schemename, "threshold")==0)
   {
      new-> function_type =5;
      new-> function = threshold;
   }
   else
   {
      printf("The following distance schemes are support: \neuclid\nreduced\ndownsample\ncrop\nthreshold\n");
      free(new);
      return NULL;
   }

   return new;
}


unsigned long euclid(mnist_image_handle a , mnist_image_handle b)
{
   unsigned int size_x_a, size_y_a, size_x_b, size_y_b;
   size_x_a = a->row_size; 
   size_y_a = b->col_size;
   size_x_b = b->row_size; 
   size_y_b = b->col_size;


   if ((size_x_a !=  size_x_b) || (size_y_a !=size_y_b))
   {
      perror("image size do not match!\n");
      return -1;
   }
   
   unsigned long sum=0;
   unsigned long diff =0;
       
   for(unsigned int i =0; i < size_x_a*size_y_a ; i++)
   {
      // compute the diff between two corresponding pixels
      if((unsigned long)a->imagedata[i]>=(unsigned long)b->imagedata[i])
          diff = ((unsigned long)a->imagedata[i]-(unsigned long)b->imagedata[i]);
      else
          diff = ((unsigned long)b->imagedata[i]-(unsigned long)a->imagedata[i]);

      sum = sum + diff*diff;
   }
   sum = sqrt(sum);
   return sum;
}




unsigned long reduced(mnist_image_handle a , mnist_image_handle b)
{
   unsigned int size_x_a, size_y_a, size_x_b, size_y_b;
   size_x_a = a->row_size; 
   size_y_a = b->col_size;
   size_x_b = b->row_size; 
   size_y_b = b->col_size;

   if ((size_x_a !=  size_x_b) || (size_y_a !=size_y_b))
   {
      perror("image size do not match!\n");
      return -1;
   }
   
   unsigned long sum_a=0;
   unsigned long sum_b=0;
       
   for(unsigned int i =0; i < size_x_a*size_y_a ; i++)
   {
      sum_a = sum_a + (unsigned long)a->imagedata[i]; 
      sum_b = sum_b + (unsigned long)b->imagedata[i];
   }
   if (sum_a >= sum_b)
      return sum_a - sum_b;
   else return sum_b - sum_a;
}



unsigned long downsample(mnist_image_handle a , mnist_image_handle b)
{

   // NOTICE: this is the downsizing parameter of the function
   //         like, currently the function computes the distance
   //         for every other corresponding pixels.
   unsigned int jump =2;
  
   unsigned int size_x_a, size_y_a, size_x_b, size_y_b;
   size_x_a = a->row_size; 
   size_y_a = b->col_size;
   size_x_b = b->row_size; 
   size_y_b = b->col_size;

   if ((size_x_a !=  size_x_b) || (size_y_a !=size_y_b))
   {
      perror("image size do not match!\n");
      return -1;
   }

   unsigned long sum=0;
   unsigned long diff=0;
       
   // loop every other pixel, jumping by jump pixels
   for(unsigned int i =0; i < size_x_a*size_y_a ; i=i+jump)
   {
      // get the difference between two corresponding pixels 
      if((unsigned long)a->imagedata[i]>=(unsigned long)b->imagedata[i])
          diff = ((unsigned long)a->imagedata[i]-(unsigned long)b->imagedata[i]);
      else
          diff = ((unsigned long)b->imagedata[i]-(unsigned long)a->imagedata[i]);
      sum = sum + diff*diff;
   }

   sum = sqrt(sum);
   return sum;
}


// layer is the number of pixels of empty edges/board
unsigned long crop(mnist_image_handle a , mnist_image_handle b)
{
   // NOTICE: this is the cropping  parameter of the function
   //         like, currently the function does not computes 
   //         the distance for corresponding pixels on the 
   //         first 2 layers of image boarder. 
   unsigned int layer =1;

   unsigned int size_x_a, size_y_a, size_x_b, size_y_b;
   size_x_a = a->row_size; 
   size_y_a = b->col_size;
   size_x_b = b->row_size; 
   size_y_b = b->col_size;

   if ((size_x_a !=  size_x_b) || (size_y_a !=size_y_b))
   {
      perror("image size do not match!\n");
      return -1;
   }
   
   unsigned long sum=0;
   unsigned long diff=0;
       
   for(unsigned int i =layer; i < size_x_a-layer ; i++)
   {
      for(unsigned int j =layer; j < size_y_a-layer ; j++)
      {
         //printf("i=%d, j=%d\n",i, j);
         //printf("index = %d\n",j*size_x_a+i);
         if((unsigned long)a->imagedata[j*size_x_a+i]>=(unsigned long)b->imagedata[j*size_x_a+i])
             diff = ((unsigned long)a->imagedata[j*size_x_a+i]-(unsigned long)b->imagedata[j*size_x_a+i]);
         else
             diff = ((unsigned long)b->imagedata[j*size_x_a+i]-(unsigned long)a->imagedata[j*size_x_a+i]);
         sum = sum + diff*diff;
      }
   }

   sum = sqrt(sum);
   return sum;
}


unsigned long threshold(mnist_image_handle a , mnist_image_handle b)
{
   // NOTICE: this is the threshold parameter of the function
   //         like, currently the function does not counts 
   //         the number of pixels that have a value less than 
   //         127
   unsigned int threshold = 127;

   unsigned int size_x_a, size_y_a, size_x_b, size_y_b;
   size_x_a = a->row_size; 
   size_y_a = b->col_size;
   size_x_b = b->row_size; 
   size_y_b = b->col_size;

   if ((size_x_a !=  size_x_b) || (size_y_a !=size_y_b))
   {
      perror("image size do not match!\n");
      return -1;
   }
   
   unsigned long count_a=0; 
   unsigned long count_b=0;
       
   // loop every other pixel, jumping by jump pixels
   for(unsigned int i =0; i < size_x_a*size_y_a ; i++)
   {
       //printf("threshold= %u ,a=%lu\n", threshold, (unsigned long)a->imagedata[i]);
       
      // get the difference between two corresponding pixels 
       if ((unsigned int)a->imagedata[i] >= threshold ) 
          ++count_a;
       if ((unsigned int)b->imagedata[i] >= threshold ) 
          ++count_b;
   }

   if (count_a >= count_b)
      return count_a - count_b;
   else return count_b - count_a;
}



