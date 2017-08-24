/******************************
// 51040 - C Programming
// HW 2 - Scramble.c
// Description: 
//    the following takes a input
//    file from linux arg and 
//    output a scrambled version
//    of each word
// Author: Zhenyang Lu
******************************/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int main(int argc, char **argv)
{ 

   FILE *fread = fopen(argv[1],"r");
   
   if(!fread)
   {
      perror("Opening file failed!"); 
      return -1;
   }

   // initiate a variable to store a string e.g Jonathan 
   // if it islanum() of it not 0 then stores it 
   // if it is isblank() or newline than put it to 
   // random shuffler and print out     
   char word[128];

   for(int c=fgetc(fread),counter = 0 ; c != EOF; )
   {  
      // if c is not newline or blank 
      // and it is alpha or num string 
      // store it to word
      // if it is special character e.g. !@$!
      // then ignore it and continue
      if(c != 10 && c!= 32)
      {  
         if (isalnum(c))
         {
            word[counter] =c;
            counter++;
         }  
         c=fgetc(fread);
      }


      // if c is newline or blank
      // then shuffle it and print out
      else 
      {
        if(counter!=0)
        {
           // put a null terminator to signal the end of string
           word[counter] = '\0';         

           // word_len is the length of the current word
           // word_cp is a copy of word which we use to shuffle

           int word_len = strlen(word);  
           char word_cp[word_len];
           strcpy(word_cp,word);
           
           // NOTICE: I was thinking trial-and-error 
           // a random array that contains index without repetition
           // thru which I could access the word_cp as a way 
           // to shuffle it, but it costs a lot of time
           // so I did some research on stackoverflow
           // and someone suggests a way to shuffle it 
           // which is like random generate two numbers between 0 and 
           // strlen(word) and use them as index to swap two char in 
           // the word_cp string. But the code is implemented by myself
           // A.K.A I borrowed someone's idea and coded the following 
           // steps to shuffle a char string. 
           
           // I assume shuffle it for strlen(word)*multiple is good enough to
           // efficiently shuffle it. 
 
           int multiple =10;

           for(int i =0; i <=word_len*multiple;i++)
           {
              int shuffle_a_index = rand()%word_len;
              int shuffle_another_index = rand()%word_len;
              char temp = word_cp[shuffle_a_index];
              word_cp[shuffle_a_index] = word_cp[shuffle_another_index]; 
              word_cp[shuffle_another_index] = temp;    
           }
           printf("%s\n",word_cp);
        }

        // reset counter and keep going 
        counter =0;         
        c=fgetc(fread);
      }
   }
   fclose(fread);
   return EXIT_SUCCESS;

}



