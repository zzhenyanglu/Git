#include "mnist.h"
#include "distance.h"

#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <math.h>


unsigned long partition( unsigned long a[], unsigned char b[], unsigned long l, unsigned long r) {
   unsigned long pivot, i, j, t;
   unsigned char c;
   pivot = a[l];
   i = l; j = r+1;
		
   while( 1)
   {
   	do ++i; while( a[i] <= pivot && i <= r );
   	do --j; while( a[j] > pivot );
   	if( i >= j ) break;
        // swap a[i] and a[j]
   	t = a[i]; a[i] = a[j]; a[j] = t;
   	c = b[i]; b[i] = b[j]; b[j] = c;
   }
   // swap a[i] and a[j]
   t = a[l]; a[l] = a[j]; a[j] = t;
   c = b[l]; b[l] = b[j]; b[j] = c;
   return j;
}



void quicksort( unsigned long a[], unsigned char b[], unsigned long  l, unsigned long r)
{
   unsigned long j;

   if( l < r ) 
   {
       j = partition( a, b, l, r);
       // if pivot is the first element in array
       // AKA j ==0
       if(j==0)
       {
          quicksort( a,b,j+1, r);
       }

       // if j >0, quicksort twice
       else
       {
          quicksort( a,b,l, j-1);
          quicksort( a,b,j+1, r);
       }
     
   }
}


unsigned char knn(mnist_dataset_handle dataset , mnist_image_handle image, unsigned int k, distance_t t)
{

    if(k==0)
    {
       printf("INVALID INPUT FOR K PARAMETER!\n");
       return EXIT_FAILURE;
    }

    else if(dataset==MNIST_DATASET_INVALID)
    {
       printf("EMPTY INPUT TRAINING DATASET!\n");
       return EXIT_FAILURE;
    }
    
    else if(image== MNIST_IMAGE_INVALID)
    {
       printf("INVALID INPUT IMAGE!\n");
       return EXIT_FAILURE;
    }

    else if(t==NULL)
    {
       printf("INVALID DISTANCE FUNCTION!\n");
       return EXIT_FAILURE;
    }
    

    // train_image is the image from train dataset
    mnist_image_handle train_image = mnist_image_begin(dataset);
    unsigned long dataset_image_count=(unsigned long)mnist_image_count(dataset);


    if(dataset_image_count==0)
    {
       printf("TRAINING DATASET IS EMPTY\n");
       return EXIT_FAILURE;
    }

    // labels and distances remember all label from tests and distance
    // between testing image and train datasets
    unsigned char labels[dataset_image_count];
    unsigned long distances[dataset_image_count]; 
    unsigned long distance = t->function(train_image, image);
    unsigned char label = mnist_image_label(train_image);
   
    labels[0] = label;
    distances[0] = distance;

    // record all distance and label to distances and 
    // labels arrays, which will be sorted by quickSort
    // function.
    for(unsigned long i =1; i <dataset_image_count;i++)
    {
       train_image = mnist_image_next(train_image);
       label = mnist_image_label(train_image);
       labels[i] = label;
       distance = t->function(train_image,image); 
       distances[i] = distance; 
    }

    // for(unsigned int i=0;i<50;i++)
    //    printf("i=%u,label[]=%u, distance[]= %lu\n", i,labels[i],distances[i]);

    // this is a sepcial implemented quicksort in the sense that 
    // when distances array being sorted labels array comes along 
    // with it and being divided as well, but it's not being sorted
    // rather just being divided together with the corresponding
    // distance. 
    quicksort(distances, labels, 0,dataset_image_count-1);
    // this array counts the occurance of labels that K nearest 
    // neighbors have. 
    // NOTICE: this array only works with this MNIST datasets, 
    //         as it only counts labels that are 0-9!
    
    // guess_count[0] counts occurance of 0..
    // guess_count[9] counts occurance of 9..
    
    unsigned long guess_count[10]={0};
    unsigned char guess_index[10]={0,1,2,3,4,5,6,7,8,9};
   
    for(int i=0;i<k;i++)
       guess_count[labels[i]]++;
    
    quicksort(guess_count, guess_index, 0, 9);

    // tie counts how many labels occur equal times after the guess_count sorted 
    unsigned int tie =1;
    
    for(unsigned int i=9;i>=0;i--)
    {   
       if (guess_count[i] > guess_count[i-1]) 
          break;
    
       else if (guess_count[i] == guess_count[i-1])
       {
          tie++;
          continue;
       }
    }
    
    if(tie==1) return guess_index[9];

    // if there are more than 1 label being guessed same times  
    for(unsigned int i=0;i<k;i++)
       for(unsigned int j=9;j>9-tie;j--)
       {
          if (labels[i] == guess_index[j])
          { 
             return guess_index[j];
          }
       }
    return guess_index[0];
}


