#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>

// Function PICKWORD() picks a random word and returns it in buffer if it contains only alpha
// Returns true if success, false on error.

bool pickword(char* buffer, size_t maxlength)
{
   // the outer for loop in the following code
   // keep searching for a qualified word which contains only a-z 
   for(int keep_going = 1; keep_going==1;)
   {  
      keep_going = 0;

      FILE* word_book;
      word_book = fopen("/usr/share/dict/words","r");
      if(!word_book)
      {
         perror("Opening file failed!"); 
         return -1;
      }
      // 99171 is how many word in 
      // /usr/share/dict/words(word_book)
      srand(time(NULL));
      int random_number = rand()%99171;

      //keep reading word_book random_number times

      for(int i=0; i<random_number;i++)
      {
         fgets(buffer,100,word_book);      
      }
      fclose(word_book);

      // for every word read from word_book
      // if non alpha found within it, continue to search for 
      // another one otherwise make it lower
      for(int j =0;*(buffer+j) != '\n' ;j++)
      {
         if(!isalpha(*(buffer+j))){ keep_going=1; break;}
         else *(buffer+j) = tolower(*(buffer+j));
      }
   }
   // get rid of \n at end of each word

   *(buffer+strlen(buffer)-1) = '\0';

   return true;
}

// function showdiagram() draws a hang picture gradually like this: 
//   _____
//   _O_ |
//    |\ |
// I dont think it's worth reading, just play the game you will see it
void showdiagram (unsigned int incorrect)
{
   switch(incorrect)
   {
      case 8:
         printf("\nYou are miserably HANGED!\n\n");
         printf("_____\n");
         printf("_O_ |\n");
         printf(" |\\ |\n");
         showdiagram(3);
         break;
      case 7:
         printf("_____\n");
         printf("_O_ |\n");
         showdiagram(3);
         break;
      case 6:
         printf("_____\n");
         printf(" O  |\n");
         showdiagram(3);
         break;
      case 5:
         printf("_____\n");
      case 4:
         printf("    |\n");
      case 3:
         printf("    |\n");
      case 2:
         printf("   /\\ \n\n");
         break;
      case 1:
         printf("   / \n\n");
         break;
      case 0:
         printf("Lucky you, your feet still on the ground!\n\n");
   }
}

// function readnext() is just read a char from keyboard 
// if more than two is typed, prompt user again and type just one
// return only lower case
char readnext()
{
   char letter[50];

   printf("Please guess a letter: ");
   fgets(letter, 50,stdin);

   while(strlen(letter) > 2 || !isalpha(letter[0])) 
   {
      printf("You can not guess more than one letter or nonalpha letter each time!\n");
      printf("Please guess a letter: ");
      fgets(letter, 50,stdin);
   }
   return tolower(letter[0]);
}

// function showguess gives out a char string based on what chars you have 
// guessed and the guessed word 
// e.g. if the guessed is elephant, and you have guessed out "eph"
// the function returns s tring like "e__ph___" 
void showguesses(char* showword, const char* word, char* guessed)
{
   strcpy(showword, word);
   for(int i = 0; i < strlen(showword) ;i++)
   {
      if (strchr(guessed, *(showword+i)) == NULL )  *(showword+i) = '_'; 
   }
}

// now lets play it 
int main()
{
   // word is the random generated guessed word from linux words
   char word[500];
   // guessed contains the char(s) you have guessed, not duplicate
   char guessed[8]="";
   // total number of times you can guess
   int total_guess =8;
   // signal if the word has been guessed out
   bool success = false;
   printf("\n");
   printf("                WELCOME TO HANGMAN PUZZLE WORD GAME\n");  
   printf("--------------------------------------------------------------------------\n");
   printf("AUTHOR: ZHENYANG LU\n");
   printf("MPCS 51040 - HOMEWORK3\\HANGMAN \n");
   printf("RULES: you will have %d chances to guess the whole word letter by letter.\n",total_guess);
   printf("\n");  

   if(pickword(word,1000))printf("A random word has been chosen! Please take a guess\n");

   // nth_guess is how many times you have tried.
   for(int nth_guess = 0 ;  nth_guess < total_guess && success==false ; )
   { 
     char letter_read ;
     char letter_read_str[2];
     int read_again = 1;
     int is_contained =0;

     // current_showword is like" _a__a" or "e__ph___" 
     char current_showword[strlen(word)];

     // read a guessing char from user if it's in guessed[] then prompt user again 
     while(read_again)
        {
           letter_read = readnext();

           for(int i = 0; i <= strlen(guessed);i++)
           {   
              if(*(guessed+i) == tolower(letter_read))
              {  
                 printf("You have guessed it before!\n");
                 printf("Letter(s) you have tried before: \"%s\"\n", guessed);
                 read_again = 1;
                 break;
              } 
              else read_again =0; 
           }
        }

     // convert the read in char into string
     // so that it can be appended to guessed string 
     letter_read_str[0] = letter_read;
     letter_read_str[1] ='\0';
     strcat(guessed,letter_read_str);

     for(int i =0; i<=strlen(word); i++) if(letter_read == *(word+i)) is_contained = 1;
     if(!is_contained) nth_guess++;

     // show current guessing statistics
     // e.g if the guessed word is panda and you got a right
     // you will get curren_showword as _a__a ;
     showguesses(current_showword, word, guessed);
 
     if(strchr(current_showword, 95)==NULL) 
     { 
        printf("The guessed word is: %s\n", current_showword);
        printf("Congrats! You are free to leave!\n");
        success = true;
        break;
     }
     else 
     { 
        printf("The guessed word is: %s\n",current_showword);
        printf("You still have %d chances\n\n",total_guess - nth_guess);
        showdiagram(nth_guess);    
     }
   }

   printf("The guessed word is: %s\n", word);
   printf("GAME OVER!\n\n");
   
}
