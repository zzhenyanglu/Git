#pragma once
#include "mnist.h"
#include <stdlib.h>
#include <stdbool.h>

typedef struct distance_t* distance_t;
struct distance_t
{
   // FUNCTION TYPE:
   // 1: euclid
   // 2: reduced
   // 3: downsample
   // 4: crop
   // 5: threshold

   unsigned int function_type;
   unsigned long (*function)(mnist_image_handle a, mnist_image_handle b);
};



distance_t create_distance_function(const char *schemename);
// the 4 functions below takes two mnist_image_handle as arguments
// first check if the images are same size, 
// if not RETURN -1 to signal error
// otherwise calculate square root. 


unsigned long euclid(mnist_image_handle a , mnist_image_handle b);

// notice: change jump variable to signal how much to downsize a sample 
unsigned long downsample(mnist_image_handle a , mnist_image_handle b);

unsigned long reduced(mnist_image_handle a , mnist_image_handle b);

// notice: change layer variable to specify how many pixels we use as a boarder
unsigned long crop(mnist_image_handle a , mnist_image_handle b);

// notice: change threshold variable to specify the threshold value. 
unsigned long threshold(mnist_image_handle a , mnist_image_handle b);
