#include "computer_agent.h"

/*
 * In this file, put your implementation of a 'random agent', i.e. a player
 * who will make a VALID but random move.
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>

struct board_t
{
   unsigned int height;
   unsigned int width;
   unsigned int run;
   unsigned char* board;

};

int minmax(board_t* b, player_t color,unsigned int start,unsigned int max) 
{
   // find empty spot 
   int has_winner; 
   player_t p =NULL;
   
   //int has_winner;

   for(unsigned int i=start; i<max;  ++i)
   {
      unsigned char c = b->board[i];

      if (c!=PLAYER_EMPTY)
         // can't place anything here
         continue;

      b->board[i]=color;
      has_winner = board_has_winner(b,&p);

      if (has_winner ==1 && p == color)
      {  
          return 100;
      }

      else if (has_winner ==1 && p != color)
      {  
          return -100;
      }

      // recurse  
      minmax(b,(color==PLAYER_BLUE?PLAYER_YELLOW:PLAYER_BLUE),i+1, max);
      b->board[i]=PLAYER_EMPTY;
   }

   return 0;
}


static char * mystrdup (const char * s)
{
   char * n = (char *) malloc (strlen(s)+1);
   strcpy (n, s);
   return n;
}

typedef struct
{
   char * name;
} computer_agent_data_t;


static const char * computer_agent_describe (agent_t * gthis)
{
   computer_agent_data_t * data = (computer_agent_data_t *) gthis->data;
   return data->name;
}


static int computer_agent_play (agent_t * gthis, const board_t * b,player_t color, unsigned int *move)
{
   unsigned int board_width = b->width;

   board_t* b_copy;

   bool copy_b = board_duplicate(&b_copy, b);
  
 
   if (copy_b == false) {puts("failed to copy board\n");return -1;}
   int score=0;

   // if I can win then try a move that can win
   for(unsigned int i=0; i<board_width; i++)
   {

      if(board_can_play_move(b_copy,color,i)) 
      {  
         board_play(b_copy, i, color);
         score = minmax(b_copy,color,0,board_width);
         if (score == 100) 
         {
           *move=i;
           board_destroy(b_copy);
           return 0;
         }
      } 
   }
  
   // if I can not win then try a move that can make the game draw
   for(unsigned int i=0; i<board_width; i++)
   {

      if(board_can_play_move(b_copy,color,i)) 
      {  
         board_play(b_copy, i, color);
         score = minmax(b_copy,color,0,board_width);
         if (score == 0) 
         {
           *move=i;
           board_destroy(b_copy);
           return 0;
         }
      } 
   }
 

   // If I will lose, choose a random move
   srand(time(NULL));
   *move = rand()%((int)board_get_width(b)-1);

   while(board_can_play_move(b, color, *move)==false)
   {
      *move = rand()%((int)board_get_width(b));
      continue;
   }

   board_destroy(b_copy);
   return 0;
}



static
bool computer_agent_destroy (agent_t * this)
{
   computer_agent_data_t * data = (computer_agent_data_t *) this->data;
   free (data->name);
   free (this->data);
   return true;

}

agent_t * computer_agent_create ()
{    
    // Allocate vtable structure
    agent_t * n = malloc (sizeof(agent_t));

    n->destroy = computer_agent_destroy;
    n->play = computer_agent_play;
    n->describe = computer_agent_describe;

    computer_agent_data_t * data = malloc (sizeof(computer_agent_data_t));
    n->data = data;

    char ha[] = "Computer_player";
    data->name = mystrdup(ha);
    return n;
}

