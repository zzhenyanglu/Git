DOWNLOAD connect-4.data dataset: https://archive.ics.uci.edu/ml/datasets/Connect-4

0. HOW COMPUTER AGENT IMPLEMENTED

   there is function called minmax which takes in board_t*, player_t color as   the current player that's playing, unsigned int start, which the starting    position of the algorithm and finally, unsigned int max, which is the last   available position of the board. Everytime when it's computer agent's turn   , minmax function gets called, if there is a winning board available from    current board, then minmax function return a 100 score, draw 0, and lose 
   returns -100 with the computer agent as a the playing player. Depending on   the score, if the computer agent is not winning, then loop the board again   to see if we could play a draw move that can delay the current game if the   computer agent is losing anway, pick a random move.

1. STEP 5 Optional Credit
   
   NOT IMPLEMENTED 
