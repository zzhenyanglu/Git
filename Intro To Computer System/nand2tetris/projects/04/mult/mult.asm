// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Put your code here.


// we assume that R0>=0, R1>=0, and R0*R1<32768
// 2**15 = 32768, so the largest number 
// a 16-bit register can represent is 32767 by 
// 2's complement representation.  

// as a reference, I put a C version of the mult in here

// int sum = 0; 
// int plus = R1;
// int i = 1;
// int stop = R0;
// while (i <= stop){sum = sum + plus; i++};
 

// Multiply R0 by R1 and output to R2
    @0         // load 0 into A
    D = A      // Put A into D
    @sum       // load sum into A
    M = D      // RAM[A] = 0 

    @R1        // load R1 into plus
    D = M      // plus is the amount 
    @plus      // we add to the running
    M = D      // sum

    @1         // load 1 into i
    D = A      // i is loop counter
    @i
    M = D

    @R0        // load R0 into stop
    D = M      // stop is max times of loop
    @stop
    M = D 

    @sum       // load the data of RAM[sum] to R2
    D = M      // in case we compute 0*0
    @R2
    M = D

(LOOP)
    @i       // check loop condition
    D=M      // D=i
    @stop
    D=D-M    // D=i-100
    @END     
    D;JGT    // end of check loop condition
    @plus    // RAM[sum] = RAM[sum] + RAM[plus] 
    D = M
    @sum
    M = M + D
    @1       // i++
    D=A
    @i
    M=M+D
    @sum     // load RAM[sum] to R2
    D = M    // AKA output the result
    @R2      
    M = D
    @LOOP
    0;JMP    // goto LOOP

(END)
    @END
    0;JMP
