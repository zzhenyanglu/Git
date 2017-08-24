#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>



// function palindrome() takes a string arugment
// and test if it's a palindrome

int palindrome(char* string)
{
   int result;
   int string_len = strlen(string) ;
 
   // first case: the string is only one char. 
   // it's a palindrome
   if (string_len == 1) result= 1 ;

   // second case: the string length is two AND the two are identical. 
   // it's a palindrome
   else if (string_len == 2 && string[0] == string[1]) result= 1;

   // third case: the string length is two AND the two are NOT identical. 
   // it's NOT a palindrome
   else if (string_len == 2 && string[0] != string[1]) result= 0; 

   // fourth case: the string length is larger than two, I will remove the first and last char 
   // from the string and run palindrome(string) again. 
   
   else if(string_len > 2 && string[0] == string[string_len-1]) 
   {
      for(int i =0; *(string+i) !='\0';i++)*(string+i) = *(string+i+1);
      string[string_len-1] ='\0';
      palindrome(string);
   }
   // otherwise: NOT PALINDROME
   else result=0;
   return result;
}


int main()
{
   // max_len is the max length of input sentence
   const int max_len = 1024;

   // sentence is the char string to store input sentence
   char sentence[max_len];

   // prompt user to enter source string
   printf("Please enter setence(max length %d): ",max_len);
   fgets(sentence,max_len,stdin);

   if(sentence[0]=='\n')return EXIT_SUCCESS;

   // The following for loop is trying to eliminate non-alnum
   // element in sentence anything like "!@#%$#%^" or blank, tab
   // and convert the element to UPPERCASE

   for(int i =0; *(sentence+i) !='\0';) 
   {
      if(!isalnum(*(sentence+i)))
      {
         for(int j=0; *(sentence+i+j)!='\0'; j++){ *(sentence+i+j) = *(sentence+i+j+1);}
      }
      else
      { 
         *(sentence+i)=toupper(*(sentence+i));
         i++;
      }
   }

   // the following part is to check palindrome of the trimmed string 
   if(palindrome(sentence)) printf("PALINDROME\n");
   else printf("NOT PALINDROME\n");

   return EXIT_SUCCESS;
}
