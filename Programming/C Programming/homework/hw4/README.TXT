 use char ** to represent arb_int_t with the following declaration: 
   typedef char ** arb_int_t;


// 2. IMPLEMENTATION of FUNCTIONS 

// void arb_free (arb_int_t* i): 
   
   since arb_int_t is char**, arb_free() function has two steps essentially, 
   first: free(the string pointed by **i),    second: free(the string pointer pointed by *i)

// int arb_duplicate(arb_int_t * new, const arb_int_t original);

   since new is just arb_int_t that's not malloced yet. I will
   malloc twice for new to create a char** and copy the string 
   contained by arb_int_t original  


// int arb_from_string (arb_int_t *i, const char* s);

   this function checks sign of i, and then check if any element in s
   is not a digit. if any of the two conditions fails return 1, otherwise
   handle leading "0" of s, then malloc char ** and char* for *i ,and 
   strcpy the cleaned string to i

// int arb_from_int (arb_int_t *i, signed long long int source);

   this function first counts length of the llong int and allocate
   memory according to the length of source, then copy the value 
   to *i 

// int arb_to_string ( const arb_int_t i, char* buf, size_t max);
   this function is relatively easy, just check the length of 
   arb_int_t if it's smaller than max then strcpy to buf

// int arb_to_int(const arb_int_t i, long long int * out);

   this function first check the arb_int_i i is larger or smaller 
   than LLONG_MAX and LLONG_MIN by length and by looping thru each
   digit, if i is within the two boundaries then output it to buf 

// int arb_assign(arb_int_t x, const arb_int_t y);

   arb_assign first free the char string pointed by *x, 
   then malloc a new char* to *x and strcpy string from y 

// int arb_compare(const arb_int_t x, const arb_int_t y);
    
    arb_assign compares, first, x with y by sign. if one is + and 
    another is - then output accordingly. Second, if signs of x and 
    are same, compares the length. longer negative and positive are 
    smaller and bigger respectively. if x and y are same length and 
    sign, loop thru each digit and compares. 

// int arb_add(arb_int_t x, const arb_int_t y);
   
   arb_add is closely related to arb_subtract. these two FUNCTIONS
   call each other depending on the calculation. 
   
   the basic logics are
   positive arb_int_t + positive arb_int_t, which lies in arb_add function
   It's implemented like operand_1+ operand_2 = [carry][result], carry = 0 
   initally, and could be 1 later. e.g 7+8=15, carry = 1, result =5

   if we have a + b (a<0, b<0) it's like -(a+b) (a>0, b>0), we reuse arb_add()
   if we have a + b (a>0, b<0) it's like a-b (a>0, b>0), we call arb_subtract()
   if we have a + b (a<0, b>0) it's like b-a (a>0, b>0), we call arb_subtract()    

// int arb_subtract(arb_int_t x, const arb_int_t y);

   arb_subtract is closely related to arb_add. these two FUNCTIONS call each 
   other depending on the calculation. 
   
   the basic logics are
   positive arb_int_t - positive arb_int_t, which lies in arb_subtract function
   It's implemented like operand_1 - operand_2 - carry= [carry][result], 
   carry = 0 initally, and could be 1 later. e.g 7-8=19, 
   carry = 1, result = 9.

   if we have a - b (a>0, b<0) it's like (a+b) (a>0, b>0), we call arb_add()
   if we have a - b (a<0, b<0) it's like b-a (a>0, b>0), we call arb_subtract()
   if we have a - b (a<0, b>0) it's like -(b+a) (a>0, b>0), we call arb_add()    

// int arb_multiply(arb_int_t x, const arb_int_t y);

   the basic idea of multiply is just like how to calculate 123*45
   you first get 123*5 then 123*40, and finally get sum of the two
   numbers.  
   
   result_temp is 123*9 or 123*90 ....
   product is 4 in first loop, and 50 in second.
   result_abs contains the running total of result_temp and finally 
   becomes the sum of 123*9 + 123*90 +......

   how to calculate 123*5, it's like a while loop for 5 times, each
   time result_temp += 123. 

   finally manipulate signs and assign the new value to x.  

// int arb_divide(arb_int_t x, const arb_int_t y);

// Thanks for reading! 
