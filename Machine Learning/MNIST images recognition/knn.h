#pragma once
#include "mnist.h"
#include "distance.h"
#include <stdlib.h>
#include <stdbool.h>
#include <CUnit/Basic.h>

signed long partition( unsigned long a[], unsigned char b[], unsigned long l, unsigned long r);

void quicksort( unsigned long a[], unsigned char b[], unsigned long  l, unsigned long r);

unsigned char knn(mnist_dataset_handle dataset , mnist_image_handle image, unsigned int k, distance_t t);

