#include "board.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>
#include <stdint.h>
#include <stdbool.h>

/**
 * In this file, implement all of the functions for board.h
 *
 * Once done, make sure you pass all the tests in board_test.c
 * (make test_board)
 *
 */

struct board_t
{
   unsigned int height;
   unsigned int width;
   unsigned int run;
   unsigned char* board;

};

bool board_create(board_t ** b, unsigned int height,unsigned int width, unsigned int run,const player_t * i)
{

   *b = (board_t*) malloc(sizeof(board_t));
   (*b)->board = (unsigned char*) malloc(sizeof(unsigned char)*height*width+sizeof(unsigned char));
   (*b)->height = height;  
   (*b)->width = width;
   (*b)->run =run;


   if(i == NULL) 
   {
      for(unsigned int j=0; j<height*width;j++)
      {
         (*b)->board[j]= PLAYER_EMPTY;
      }  
   }

   else
   {
      for(unsigned int j=0; j<height*width;j++)
      {
         (*b)->board[j]= *(i+j);
      }  
   }

   return true;
}


bool board_destroy (board_t * b)
{
   if (b==NULL) { return false;}

   free(b->board);
   free(b);

   return true;
}


unsigned int board_get_height (const board_t * b)
{
   return b->height;
}

/// Return the width of the board
unsigned int board_get_width (const board_t * b)
{
   return b->width;
}


unsigned int board_get_run (const board_t * b)
{
   return b->run;
}


bool board_can_play (const board_t * b, player_t p)
{
   for(unsigned int j=0; j< (b->height * b->width);j++)
   {
      if(b->board[j] == PLAYER_EMPTY) return true;
   }
   return false;
}

// width starts from 0
// column starts from 0
bool board_play (board_t * b, unsigned int column, player_t player)
{
      
   for(unsigned int j=column; j <  b->width * b->height; j=j+(b->width))
   {
      if(b->board[j] == PLAYER_EMPTY) 
      {
         b->board[j] = player;
         return true;
      }
   }
   return false;
   
}


bool board_can_play_move (const board_t * b, player_t p, unsigned int column)
{
   
   for(unsigned int j=column; j< (b->height * b->width); j=j+(b->width))
   {
      if(b->board[j] == PLAYER_EMPTY) return true;
   }

   return false;

}


bool board_unplay (board_t * b, unsigned int column)
{
  
   // reverse loop the board and undo if 
   for(unsigned int j=((b->height-1) * b->width+column);(int)j>=(int)0 ; j=j-(b->width))
   {

      if(b->board[j] == PLAYER_EMPTY) continue; 
      else 
      { 
         b->board[j] = PLAYER_EMPTY;
         return true;
      }
   }
   return false;
}


bool board_duplicate (board_t ** newboard, const board_t * old)
{
   if (old==NULL) return false;
   
   *newboard = (board_t *) malloc(sizeof(board_t));

   (*newboard)->height = old->height;
   (*newboard)->width = old->width;
   (*newboard)->run = old->run;

   (*newboard)->board = (unsigned char*) malloc(sizeof(char)*(old->height)*(old->width)+sizeof(char));

   for(unsigned int j=0; j< (old->height * old->width); j++)
   {
      (*newboard)->board[j] = old->board[j];
   }

   return true;
}


// notice: row and column starts from 0
bool board_get (const board_t * b, unsigned int row, unsigned int column,player_t * piece)
{
   if(b->height <= row || b->width <= column) return false;

   *piece = b->board[row * b->width + column];
   return true;
}


bool board_clear (board_t * b)
{   
   if (b==NULL) return false;

   for(unsigned int j=0; j < b->height * b->width ; j++)
   {
      b->board[j] = PLAYER_EMPTY;
   } 

   return true;
}



bool board_print (const board_t * b, FILE * f)
{
   if (!f) return false;
   
    for(unsigned int j=b->height-1;(int)j>=(int)0 ; j--) 
    { 
       for(unsigned int i=0; i < b->width ; i++) 
       { 
          if(b->board[j* b->width+i] == PLAYER_YELLOW) 
          fputc('X',f); 
          else if(b->board[j* b->width+i] == PLAYER_BLUE) 
          fputc('O',f); 
          else  
          fputc(' ',f); 
          fputc('|',f); 
       } 
       fputc('\n',f); 
    } 
  
   return true; 
}


int board_has_winner (const board_t * b, player_t * player)
{

    // row-wise
   if (b->width >=  b->run) 
   {

     // loop height-wise   
     for(unsigned int j=0;j<b->height ; j++)
     {   
        // loop width-wise 
        for(unsigned int i=0; i < b->width - b->run+1; i++)
        {
           // if current cell is empty then pass
           if (b->board[j*b->width + i] == PLAYER_EMPTY) continue;
                  
           unsigned char current = b->board[j*b->width+i];
           unsigned int t=1;

           for(unsigned int k =1;k+i<b->width;k++)
           {
              if (b->board[j*b->width+i+k] == current) t++;
              else if (b->board[j*b->width+i+k] != current) break;
           }  

           if (t >= b->run) 
           {*player=current;
            return 1;}
        }
     }
   }

   // check columns
   if (b->height >=  b->run) 
   {
     // loop height-wise   
     for(unsigned int j=b->width-1 ;(int)j>=(int)0; j--)
     {   
        // loop width-wise 
        for(unsigned int i=0; i < b->height-1; i++)
        {
           // if current cell is empty then pass
           if (b->board[i*b->width + j] == PLAYER_EMPTY) continue;
                  
           unsigned char current = b->board[i*b->width+j];
         
           unsigned int t=1;

           for(unsigned int k = 1;k+i < b->height;k++)
           {
              if (b->board[b->width*(k+i)+j] ==current)t++;
              else if (b->board[b->width*(i+k)+j] != current) break;
           }

           if (t >= b->run) 
           {*player=current;
            return 1;}
        }
     }
   }


   // diagonal

   for(unsigned int j =0;j < b->height ; j++)
   {   
        // loop width-wise 
      for(unsigned int i=0; i < b->width; i++)
      {
         unsigned int t =1; 
         unsigned char current = b->board[j*b->width+i];

         if(current==PLAYER_EMPTY)continue;

         for(unsigned int k=1; k+j < b->height && k+i < b->width; k++)
         {
            if (b->board[(j+k)*b->width+(i+k)]==current) t++;
            else if (b->board[(j+k)*b->width+(i+k)]!=current) break;
         }
                    
         if(t >= b->run)
         { 
             *player = current;
             return 1;
         }
       }
    }
  
 // diagonal from bottom left

   for(unsigned int j= b->height-1;(int)j>=0; j--)
   {   
        // loop width-wise 
      for(unsigned int i=0;i < b->width;i++)
      {
         unsigned int t = 1;
         unsigned char current = b->board[j*b->width+i];
         if(current==PLAYER_EMPTY)continue;

         for(unsigned int k=1; i+k <  b->width && (int)(j-k) >= (int)0; k++)
         {
            if (b->board[(j-k)*b->width+(i+k)]==current) t++;
            else if (b->board[(j-k)*b->width+(i+k)]!=current) break;
         }
                    
         if((int)t >= (int)b->run)
         { 
             *player = current;
             return 1; 
         }
       }
   }
   if (board_can_play(b, PLAYER_YELLOW) ==true) return 0;
   else return -1;

}

