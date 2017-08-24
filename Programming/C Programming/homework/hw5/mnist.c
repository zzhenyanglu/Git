#include <stdlib.h>
#include <netinet/in.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include "mnist.h"
#include <stdint.h>
#include <stdbool.h>

struct  mnist_image_t
{
   struct mnist_image_t* next;
   int row_size;
   int col_size;
   unsigned char * imagedata;
   unsigned char * labeldata;
   // the nth image of ORIGINAL datasets
   unsigned int nth_image;
   mnist_dataset_handle original_dataset; 

};



struct  mnist_dataset_t
{
   struct mnist_dataset_t* next;
   int total_images;
   int total_rows;
   int total_cols;
   int label_magic_number;
   int image_magic_number;
   unsigned char * imagedata;
   unsigned char * labeldata;
};



mnist_dataset_handle mnist_open(const char * name)
{
   //create file names to be read from
   char label_file_name[50]="";
   char image_file_name[50]="";

   strcat(label_file_name, name);
   strcat(image_file_name, name);

   strcat(label_file_name, "-labels-idx1-ubyte");
   strcat(image_file_name, "-images-idx3-ubyte");
   
   FILE * label_file = fopen(label_file_name, "rb");
   FILE * image_file = fopen(image_file_name, "rb");

   // Make sure to check if we were able to open the file
   if (!label_file || !image_file)
   {
      // see the manpage for perror
      perror("There was a problem opening the file: ");
      fclose(image_file);
      fclose(label_file);
      return MNIST_DATASET_INVALID;
   }

   // get a handy stuff to read unsigned int 32 
   // must include netinet/in.h 
   uint32_t label_magic[1], image_magic[1];
   
   fread(label_magic, sizeof(uint32_t),1,label_file);  
   fread(image_magic, sizeof(uint32_t),1,image_file); 
    
   int label_magics=ntohl(label_magic[0]); 
   int image_magics=ntohl(image_magic[0]); 

   // check magic numbers 
   // I don't know what to check with the magic numbers
   // so I just say if label magic is not 2049 or image 
   // magic is not 2051 then it's MNIST_DATASET_INVALID
   if (label_magics != 2049 || image_magics != 2051) 
      return MNIST_DATASET_INVALID;

   // continue reading image file to get other parameters
   uint32_t totalimage[1]; 
   fread(&totalimage, sizeof(uint32_t),1,image_file);  
   int total_image=ntohl(totalimage[0]);
 
   uint32_t totalcol[1], totalrow[1];
   fread(&totalrow, sizeof(uint32_t),1,image_file);  
   fread(&totalcol, sizeof(uint32_t),1,image_file);  
   int total_col=ntohl(totalcol[0]);
   int total_row=ntohl(totalrow[0]);

   // continue reading label file to jump to label data
   fread(&totalcol, sizeof(uint32_t),1,label_file);  

   // malloc a pointer to mnist_dataset_t 
   mnist_dataset_handle new_dataset = (mnist_dataset_handle)malloc(sizeof(struct mnist_dataset_t));

   new_dataset->labeldata = malloc(total_image*sizeof(unsigned char)+10);
   new_dataset->imagedata = malloc(total_image*sizeof(unsigned char)*total_row*total_col+10);
   
   new_dataset->total_images = total_image;
   new_dataset->total_rows = total_row;
   new_dataset->total_cols = total_col;
   new_dataset->image_magic_number = image_magics;
   new_dataset->label_magic_number = label_magics;
   new_dataset->next = NULL;

   fread(new_dataset->imagedata, sizeof(unsigned char),total_image*total_col*total_row,image_file);
   fread(new_dataset->labeldata, sizeof(unsigned char),total_image,label_file);

   fclose(image_file);
   fclose(label_file);

   return new_dataset;
}



bool mnist_save(const mnist_dataset_handle h, const char * filename)
{

   //create file names to be read from
   char label_file_name[50]="";
   char image_file_name[50]="";

   strcat(label_file_name, filename);
   strcat(image_file_name, filename);

   strcat(label_file_name, "-labels-idx1-ubyte");
   strcat(image_file_name, "-images-idx3-ubyte");
   
   FILE * label_file = fopen(label_file_name, "wb");
   FILE * image_file = fopen(image_file_name, "wb");

   // Make sure to check if we were able to open the file
   if (!label_file || !image_file)
   {
      // see the manpage for perror
      perror("There was a problem opening the file: ");
      fclose(label_file);
      fclose(image_file);
      return false;
   }

   // get a handy stuff to read unsigned int 32 
   // must include netinet/in.h 
   // MAGIC NUMBERS
   uint32_t label_magic_int32[1], image_magic_int32[1];
  
   label_magic_int32[0]=ntohl(h->label_magic_number); 
   image_magic_int32[0]=ntohl(h->image_magic_number); 
   
   fwrite(label_magic_int32, sizeof(uint32_t),1,label_file);  
   fwrite(image_magic_int32, sizeof(uint32_t),1,image_file); 
    
   // total items
   uint32_t totalimage_int32[1]; 
   totalimage_int32[0]=ntohl(h->total_images); 
   fwrite(totalimage_int32, sizeof(uint32_t),1,image_file);  
   fwrite(totalimage_int32, sizeof(uint32_t),1,label_file);  

 
   uint32_t totalcol_int32[1], totalrow_int32[1];
   totalcol_int32[0]=ntohl(h->total_cols);
   totalrow_int32[0]=ntohl(h->total_rows);

   fwrite(totalrow_int32, sizeof(uint32_t),1,image_file);  
   fwrite(totalcol_int32, sizeof(uint32_t),1,image_file);  

   fwrite(h->imagedata, sizeof(unsigned char),h->total_images*h->total_cols*h->total_rows, image_file);
   fwrite(h->labeldata, sizeof(unsigned char),h->total_images,label_file);

   fclose(image_file);
   fclose(label_file);

   return true;
}




mnist_dataset_handle mnist_create(unsigned int x, unsigned int y)
{
   // NOTICE: I DONT KNOW HOW MANY IMAGES THIS DATASET IS TAKING IN
   //         SO I ASSUME ONLY 1 IMAGE IS INSIDE THE NEW DATASET

   int total_image =1;
   mnist_dataset_handle new_dataset = (mnist_dataset_handle)malloc(sizeof(struct mnist_dataset_t));
   
   new_dataset->labeldata = malloc(total_image*sizeof(unsigned char)+10);
   new_dataset->imagedata = malloc(total_image*sizeof(unsigned char)*x*y+10);
   new_dataset->total_images = total_image;
   new_dataset->total_rows = x;
   new_dataset->total_cols = y;
   new_dataset->image_magic_number = 0;
   new_dataset->label_magic_number = 0;
   new_dataset->next = NULL;

   if (!new_dataset) return MNIST_DATASET_INVALID;

   return new_dataset;
}


void mnist_free (mnist_dataset_handle handle)
{
   free(handle->labeldata);
   free(handle->imagedata);
   free(handle);
}


int mnist_image_count (const mnist_dataset_handle handle)
{
   if (handle == MNIST_DATASET_INVALID) return -1;
   return handle->total_images;
}


void mnist_image_size (const mnist_dataset_handle handle,unsigned int * x, unsigned int * y)
{
   if (handle == MNIST_DATASET_INVALID) { *x = 0; *y=0;}
   
   else 
   {
      *x=handle->total_rows;
      *y=handle->total_cols;
   }
}


mnist_image_handle mnist_image_begin (const mnist_dataset_handle handle)
{
   mnist_image_handle new_image = (mnist_image_handle)malloc(sizeof(struct mnist_image_t));
   new_image->labeldata = malloc(sizeof(unsigned char)+10);
   new_image->imagedata = malloc(sizeof(unsigned char)*handle->total_rows*handle->total_cols+10);

   new_image->row_size = handle->total_rows;
   new_image->col_size = handle->total_cols;
   new_image->nth_image = 0;
   new_image->original_dataset = handle;
   new_image->next = NULL;
 
   memcpy(new_image->imagedata, handle->imagedata,sizeof(unsigned char)*handle->total_rows*handle->total_cols);
   memcpy(new_image->labeldata, handle->labeldata,sizeof(unsigned char));
   
   if (!new_image) return MNIST_IMAGE_INVALID;
   return new_image;
}

const unsigned char * mnist_image_data (const mnist_image_handle h)
{
   unsigned char * image_pointer; 
   if (h->nth_image == 0)
      image_pointer = &(h->original_dataset->imagedata[0]);

   else image_pointer = &(h->original_dataset->imagedata[h->nth_image*h->row_size*h->col_size]);
   return image_pointer;
}



int mnist_image_label (const mnist_image_handle h)
{  
   if (h == MNIST_IMAGE_INVALID) return -1;
   return (int)*(h->labeldata);
}


mnist_image_handle mnist_image_next (const mnist_image_handle h)
{

   if (h->nth_image == h->original_dataset->total_images) return MNIST_IMAGE_INVALID;

   mnist_image_handle new_image = (mnist_image_handle)malloc(sizeof(struct mnist_image_t));
   new_image->labeldata = malloc(sizeof(unsigned char)+10);
   new_image->imagedata = malloc(sizeof(unsigned char)*h->row_size*h->col_size+10);
   
   new_image->row_size = h->row_size;
   new_image->col_size = h->col_size;
   new_image->nth_image = (h->nth_image +1);
   new_image->original_dataset = h->original_dataset;
   new_image->next = NULL;
   h->next = new_image;
  
   // get the second image and label from the dataset and memcpy
   // it into new_image->imagedata

   const unsigned char* image_pointer = mnist_image_data(new_image);

   unsigned char* label_pointer; 

   label_pointer = &(new_image->original_dataset->labeldata[new_image->nth_image]);

   memcpy(new_image->imagedata, image_pointer, sizeof(unsigned char)*new_image->row_size*new_image->col_size);
   memcpy(new_image->labeldata, label_pointer, sizeof(unsigned char));
   
   if (!new_image) return MNIST_IMAGE_INVALID;
   return new_image;

}



// NOTICE: IF WE CALL THIS FUNCTION AND INSERT A IMAGE IN BETWEEN TWO
//         IMAGE, THEN IF YOU CALL mnist_image_data() AGAIN, YOU WILL 
//         PROBABLY GET A WRONG ANSWER, BECAUSE YOU DON'T KNOW THE IMAGE 
//         CREATED BY mnist_image_add_after() FUNCTION IS WHICH IMAGE IN
//         IN ORIGINAL DATASETS (WELL YOU CAN KNOW, BUT IT'S TAKING A BIG
//         AMOUNT OF TIME TO COMPARE THE INSERTED IMAGE WITH EVERY IMAGE IN 
//         DATASETS. SO GIVEN THE UNIQUE REQUIREMENT OF mnist_image_data()
//         I WILL NOT CALL mnist_image_data() ON A IMAGE INSERTED IN BETWEEN 
//         TWO IMAGES BY CALLING mnist_image_add_after() FUNCTION. 

mnist_image_handle mnist_image_add_after(mnist_dataset_handle h,mnist_image_handle i,const unsigned char * imagedata, unsigned int x, unsigned int y, unsigned int label)
{
   if(h->total_rows !=y || h->total_cols !=x) return MNIST_IMAGE_INVALID;
   
   else if (i == MNIST_IMAGE_INVALID)
   {
      mnist_image_handle new_image = mnist_image_begin(h);
      return new_image; 
   }

   // IF ADD A IMAGE AFTER THE END OF A IMAGE LIST 
   // AKA I.NEXT == NULL
   // CREATE A NEW IMAGE BY CALLING MNIST_IMAGE_NEXT
   // AND THEN REPALCE THE IMAGE WITH GIVEN ONE

   mnist_image_handle new_image;

   if(i->next ==NULL)
   {
      new_image = mnist_image_next(i);
      memcpy(new_image->imagedata, imagedata, sizeof(unsigned char)*new_image->row_size*new_image->col_size);
      *(new_image->labeldata) = label; 
   }

   // if add_after a image in between a image list
   else 
   {
      new_image = (mnist_image_handle)malloc(sizeof(struct mnist_image_t));
      new_image->labeldata = malloc(sizeof(unsigned char)+10);
      new_image->imagedata = malloc(sizeof(unsigned char)*i->row_size*i->col_size+10);

      new_image->row_size = x;
      new_image->col_size = y;
 
      new_image->nth_image = (i->nth_image +1);
      new_image->original_dataset = h;
      new_image->next = i->next;
      i->next = new_image;

      memcpy(new_image->imagedata, imagedata, sizeof(unsigned char)*new_image->row_size*new_image->col_size);
      *(new_image->labeldata)= label;
   }
   
   if (!new_image) return MNIST_IMAGE_INVALID;
   return new_image;
}


