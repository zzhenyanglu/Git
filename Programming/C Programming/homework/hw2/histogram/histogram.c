/*************************************
// 51040 - C Programming
// HW2 - Histogram.c
// Description: 
//    This file takes a input file which
//    is from linux arg and output the 
//    frequency histogram of each letter
//    A-Z, case insensitive and digits 
//    0-9
// Author: Zhenyang Lu
*************************************/


#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

int main(int argc, char **argv)
{
   // PART 1: READ IN THE INPUT FILE AND COUNT FREQUENCY
 
   FILE *fread = fopen(argv[1],"r");
   
   if(!fread)
   {
      perror("Opening file failed!"); 
      return -1;
   }

   //count is an array that whose cell
   //is for storing the occurrance of 
   //26 letters and 9 numbers
   //count[0..9] is for 0 - 9
   //count[10..35] is for A-Z and a-z
   //e.g. if letter a and A together 
   //shows up 100 times in histogram-in.txt
   //then count[10] = 100

   int count[36] ={0};
   
   for(int c=fgetc(fread) ; c != EOF; )
   {
      //If c is A-Z
      //count one in the corresponding  cell of count[10..35]
      if (c>=65&&c<=90) {count[c-55]=count[c-55]+1;}

      //if c is a-z
      else if (c>=97&&c<=122){count[c-87]=count[c-87]+1; }

      //if c is 0-9
      else if (c>=48&&c<=57) {count[c-48]=count[c-48]+1; }

      c=fgetc(fread);
   }
   fclose(fread);

   // END OF PART 1: READ IN THE INPUT FILE AND COUNT FREQUENCY
   

   
   // PART 2: PRINT HISTOGRAM 
  
   // output the historam
   for(int i = 0;i < sizeof(count)/sizeof(count[0]); i++)
   {  
      int current_char; // store the ascii int version of 0-9 a-z

      //if output histogram for 0-9
      if (i>=0&&i<=9) {current_char =i+48;}
      //if output for a-z
      else {current_char =i+87;}
      
      //if count !=0 output histogram for A-Z and a-z
      if(count[i]!=0) 
      {
         char pound = '#';
         printf("%c: ",current_char);  
         for(int j=1; j<=count[i];j++) printf("%c",pound);//write variable number of #
         printf(" (%d)\n",count[i]);
      }
      else continue;
      
   }

   // END OF PART 2: OUTPUT HISTOGRAM TO *-out.txt  
}
