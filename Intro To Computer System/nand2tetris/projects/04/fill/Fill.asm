// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input. 
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

////////////////DESCRIPTION//////////////////////        
// My general idea: Use R0 to store the address of
// the current pixel of screen. When the program 
// starts, put the SCREEN (predefined var) address
// to R0. When the keyboard is pressed, value at RO 
// is retrieved and 
// used as the current address of screen and output 
// a black pixel ( assign -1 to M). increment the 
// value of R0 and stores it to R0. If the keyboard 
// is idle, then get the value of R0, which is the 
// address of current pixel and whites it (assign
// 0 to M), and decrement the value of RO.      

// NOTIE: Address value stored at R0 should be 
// [16384, 16384+8912], which is screen's 8K RAM
// 8912 = 256 rows * 512 pixel per row / 16 (size of byte)
// this number corresponse to Figure 5.7 in textbook.
// So each ticktack, I will check R0's value, if 
// it exceeds the boundary, then do nothing. 

 
// put the first pixel's address in R0 
// and use it as the starting point. 
   @SCREEN  
   D = A
   @R0
   M = D 

(LOOP)
   @KBD           // check keyboard 
   D = M
   @KBDPRESSED    // if it's pressed GOTO @KBDPRESSED
   D;JGT
   @KBDIDLE       // otherwise GOTO @KBDIDLE
   0;JMP

(KBDPRESSED)   
   @R0         // check if R0's value, which is
   D = M       // the current pixel is out of
   @KBD        // screen boundary, if it is
   D = D - A   // GOTO @DONOTHING
   @DONOTHING  // otherwise blacks a pixel and increment
   D;JGE       // R0 by 1 and put it back to R0

   @R0
   A = M     // otherwise blacken the pixel
   M = -1    // and increment R0 by 1 and 
   @R0       // put it back to R0
   M = M + 1
   @LOOP
   0;JMP     // continue checking KBD

(KBDIDLE)
   @R0        // check if R0's value, which is
   D = M      // the current pixel is not screen
   @SCREEN    // if it is GOTO @DONOTHING
   D = D - A  
   @DONOTHING  
   D;JLE

   @R0        // otherwise blacks a pixel and decrement
   A = M      // R0 by 1 and put it back to R0 
   M = 0
   @R0 
   M = M -1 
   @LOOP
   0;JMP      // continue checking KBD

(DONOTHING)  
   @LOOP
   0;JMP