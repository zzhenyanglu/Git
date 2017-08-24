#include <stdlib.h>
#include <stdio.h>
#include "arb_int.c"
#include <string.h>
#include <ctype.h>
#include <limits.h>

int main(int argc, char** argv)
{
   // if incorrect number of arguments 
   if (argc!=4 && argc!=1) printf("You must enter exactly 3 arguments. Two operands and one operator(+,-,\\,\\*) in between\n");

   else if(argc ==4) 
   {
      if ( (argv[2][0] == '-') || (argv[2][0] == '+') || (argv[2][0] == '\\') || (argv[2][0] == '*')) 
      {
         // check if argv[1] is valid 
         if (!isdigit(argv[1][0]) && argv[1][0] != '+' && argv[1][0] !='-') 
         {
            printf("%s is not valid operand\n", argv[1]); 
            return 0; 
         }

         for(int i=1; i<strlen(argv[1]);i++) 
         { 
             if(!isdigit(argv[1][i])) 
             {
                printf("%s is not valid operand\n", argv[1]); 
                return 0;
             }         
         }

         // check if argv[3] is valid 
         if (!isdigit(argv[3][0]) && argv[3][0] != '+' && argv[3][0] !='-') 
         {
            printf("%s is not valid operand\n", argv[3]); 
            return 0; 
         }

         for(int i=1; i<strlen(argv[3]);i++) 
         { 
             if(!isdigit(argv[3][i])) 
             {
                printf("%s is not valid operand\n", argv[3]); 
                return 0;
             }
         }

         arb_int_t a,b; 
         arb_from_string(&a, argv[1]);
         arb_from_string(&b, argv[3]);

         if(argv[2][0] == '+') {arb_add(a, b);} 
         else if(argv[2][0] == '-') {arb_subtract(a, b);} 
         else if(argv[2][0] == '*') {arb_multiply(a, b);} 
         else if(argv[2][0] == '\\') {arb_divide(a, b);}
            
 
         printf("%s\n",*a); 
         arb_free(&a);
         arb_free(&b);
      }
      else printf("%s is not an invalid operator. You must specify +,-,\\*,\\\\ as your input operator\n", argv[2]);  
   }
 
   // if no arguments 
   else
   {
 
      arb_int_t arb_int_a, arb_int_b; 
    
      // TEST PART 1: arb_from_string 
   
      printf("\n TEST 1: ARB_FROM_STRING() \n");

      arb_from_string(&arb_int_a,"+000000023453634563456758701231234"); 
      printf("output string is  %s\n\n",*arb_int_a);

      arb_free(&arb_int_a);
   
      arb_from_string(&arb_int_a,"-000000123004234532463457456756"); 
      printf("output arb_int is %s\n\n",*arb_int_a);  
   
      arb_free(&arb_int_a);


      
      // TEST PART 2: arb_from_int
      printf("\n TEST 2: ARB_FROM_INT() \n");
      signed long long int arb_number_3 = -12123434567890123;
   
      arb_from_int(&arb_int_a ,arb_number_3);
      printf("input LLONG INT is %lld\noutput arb_int is %s\n\n",arb_number_3 ,*arb_int_a);
   
      arb_free(&arb_int_a);
   
      arb_number_3 = LLONG_MAX;
      arb_from_int(&arb_int_a ,arb_number_3);
      printf("input LLONG INT is %lld\noutput arb_int is %s\n\n",arb_number_3 ,*arb_int_a); 
   
      
   
      // TEST PART 3: arb_duplicate
      
      printf("\n TEST 3: ARB_DUPLICATE() \n");
      // still use arb_int_a 
   
      printf("arb_int_a is now: %s\n", *arb_int_a);
      printf("arb_int_b is now uninitialized\n");
   
      arb_duplicate(&arb_int_b,arb_int_a);
   
      printf("arb_int_b duplicated arb_int_a\n");
      printf("arb_int_b is now :%s\n",*arb_int_b);
      
      // let's see what's arb_int_a if we modify arb_int_b
   
      arb_free(&arb_int_a);
   
      long long int arb_number_4 = -999999999999999999;
      arb_from_int(&arb_int_a ,arb_number_4);
    
      printf("after arb_int_a being modified, arb_int_a is now: %s\n", *arb_int_a);
      printf("after arb_int_a being modified, arb_int_b is now: %s\n", *arb_int_b);
   
      arb_free(&arb_int_a);
      arb_free(&arb_int_b);
   

   
      // TEST PART 4: arb_to_string 
      
      arb_number_3 = LLONG_MIN;
      arb_from_int(&arb_int_a ,arb_number_3);
   
      arb_from_string(&arb_int_b ,"+000000123234523442897652345234523452346");
   
      printf("\n TEST 4: ARB_TO_STRING() \n");
      printf("before arb_to_string, arb_int_a is: %s\n", *arb_int_a);
      printf("before arb_to_string, arb_int_b is: %s\n", *arb_int_b);
   
      char string_from_arb[30]="";
   
      if(arb_to_string(arb_int_b, string_from_arb, strlen(*arb_int_a)-1)) printf("arb_to_string() failed, because of insufficient buffer size!\n");
      if(!arb_to_string(arb_int_a, string_from_arb, strlen(*arb_int_b))) printf("arb_to_string() succeeded, buffer contains %s\n",string_from_arb);
      
 
        
      // TEST PART 5: arb_to_int 
      
      arb_free(&arb_int_b);
      arb_free(&arb_int_a);
   
      arb_number_3 = LLONG_MIN; 
      char arb_number_6[] ="99999999999999999999999999999999999999999";
   
    
      arb_from_int(&arb_int_a ,arb_number_3);
      arb_from_string(&arb_int_b ,arb_number_6);
   
      printf("\n TEST 5: ARB_TO_INT() \n");
      printf("before arb_to_int, arb_int_a is: %s\n", *arb_int_a);
      printf("before arb_to_int, arb_int_b is: %s\n", *arb_int_b);
   
      signed long long int int_from_arb = 0;
   
      if(!arb_to_int(arb_int_a, &int_from_arb))printf("after arb_to_int, arb_int_a is: %lld\n", int_from_arb);
      else printf("number too large as an long long int\n");
      if(!arb_to_int(arb_int_b, &int_from_arb))printf("after arb_to_int, arb_int_b is: %lld\n", int_from_arb);
      else printf("number too large as an long long int\n");
   
      arb_free(&arb_int_b);
      arb_free(&arb_int_a);

   
      // TEST PART 6: arb_assign
      
      
      printf("\n TEST 6: ARB_ASSIGN()  \n");
      arb_number_3 = LLONG_MAX;
   
   
      char arb_number_2[] = "+00000023142135";
      arb_from_int(&arb_int_b, arb_number_3);
      arb_from_string(&arb_int_a, arb_number_2);
   
      printf("before arb_assign, arb_int_a is: %s\n", *arb_int_a);
      printf("before arb_assign, arb_int_b is: %s\n", *arb_int_b);
      
      arb_assign(arb_int_a, arb_int_b);
   
      printf("after arb_assign, arb_int_b is: %s\n", *arb_int_b);
      printf("after arb_assign, arb_int_a is: %s\n", *arb_int_a);
   
   
      // TEST PART 7: arb_free 
      
      printf("\n TEST 7: ARB_FREE() \n");
      arb_free(&arb_int_a);
      arb_free(&arb_int_b);
   
      printf("arb_int_a and arb_int_b have been freed! \n");
  
 


      // PART II - arb_add arb_subtract arb_multiply arb_divide 
      // PART II - arb_add arb_subtract arb_multiply arb_divide 
      // PART II - arb_add arb_subtract arb_multiply arb_divide 
  
    
      // TEST PART 9: arb_add
      

      arb_int_t arb_int_c, arb_int_d; 
      printf("\n TEST 9: ARB_ADD() \n");
      arb_from_string(&arb_int_d, "1987987981123423452345242341");
      arb_from_string(&arb_int_c, "1912322345234534234523452354");
      printf(" AS YOU WILL SEE, ARB_ADD() DO NOT WORK WITH THESE LARGE NUMBERS \n");
      
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      arb_add(arb_int_c,arb_int_d);
      printf(" arb_add is: %s\n", *arb_int_c);
  
      arb_free(&arb_int_c);
      arb_free(&arb_int_d);

      arb_from_string(&arb_int_d, "1");
      arb_from_string(&arb_int_c, "99999999");
      
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      arb_add(arb_int_c,arb_int_d);
      printf(" arb_add is: %s\n", *arb_int_c);
  
      arb_free(&arb_int_c);
      arb_free(&arb_int_d);

 
      // TEST PART 10: arb_subtract
   
      printf("\n TEST 10: ARB_subtract() \n");
      arb_from_string(&arb_int_c, "1231223450");
      arb_from_string(&arb_int_d, "12342102345");
      
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      arb_subtract(arb_int_c,arb_int_d);
      printf(" arb_subtract is: %s\n", *arb_int_c);
   
      arb_free(&arb_int_c);
      arb_free(&arb_int_d);
      
      arb_from_string(&arb_int_c, "-3412");
      arb_from_string(&arb_int_d, "-129");
   
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      arb_subtract(arb_int_c, arb_int_d);
   
      printf("arb_subtract is: %s\n", *arb_int_c);
 
      arb_free(&arb_int_c);
      arb_free(&arb_int_d);
   

      // TEST PART 11: arb_compare
   
      printf("\n TEST 11: ARB_compare() \n");


      arb_from_string(&arb_int_c, "1231223450");
      arb_from_string(&arb_int_d, "12342102345");
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      printf("arb_compare is: %d\n", arb_compare(arb_int_c, arb_int_d));

      arb_free(&arb_int_c);
      arb_free(&arb_int_d);

      arb_from_string(&arb_int_c, "123");
      arb_from_string(&arb_int_d, "123");
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      printf("arb_compare is: %d\n", arb_compare(arb_int_c, arb_int_d));

      arb_free(&arb_int_c);
      arb_free(&arb_int_d);

      arb_from_string(&arb_int_c, "123");
      arb_from_string(&arb_int_d, "12");
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      printf("arb_compare is: %d\n", arb_compare(arb_int_c, arb_int_d));

      arb_free(&arb_int_c);
      arb_free(&arb_int_d);


      // TEST PART 12: arb_multiply
 
      printf("\n TEST 11: ARB_multiply() \n");


      arb_from_string(&arb_int_c, "124"); 
      arb_from_string(&arb_int_d, "12");
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      arb_multiply(arb_int_c, arb_int_d);
      printf("arb_multiply is: %s\n", *arb_int_c);

      arb_free(&arb_int_c);
      arb_free(&arb_int_d);

      arb_from_string(&arb_int_c, "-123");
      arb_from_string(&arb_int_d, "-123");
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      arb_add(arb_int_c, arb_int_d);
      printf("arb_multiply is: %s\n", *arb_int_c);

      arb_free(&arb_int_c);
      arb_free(&arb_int_d);

      arb_from_string(&arb_int_c, "123");
      arb_from_string(&arb_int_d, "-12342");
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      arb_add(arb_int_c, arb_int_d);
      printf("arb_multiply is: %s\n", *arb_int_c);

      arb_free(&arb_int_c);
      arb_free(&arb_int_d);


      // TEST PART 13: arb_divide
   
      printf("\n TEST 13: ARB_divide() \n");

      arb_from_string(&arb_int_c, "-121230");
      arb_from_string(&arb_int_d, "-1345");
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      arb_divide(arb_int_c, arb_int_d);
      printf("arb_divide is: %s\n", *arb_int_c);

      arb_free(&arb_int_c);
      arb_free(&arb_int_d);

      arb_from_string(&arb_int_c, "123423");
      arb_from_string(&arb_int_d, "123");
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      arb_divide(arb_int_c, arb_int_d);
      printf("arb_divide is: %s\n", *arb_int_c);

      arb_free(&arb_int_c);
      arb_free(&arb_int_d);

      arb_from_string(&arb_int_c, "187723");
      arb_from_string(&arb_int_d, "-12342");
      printf(" arb_int_a is: %s\n", *arb_int_c);
      printf(" arb_int_b is: %s\n", *arb_int_d);
      arb_divide(arb_int_c, arb_int_d);
      printf("arb_divide is: %s\n", *arb_int_c);

      arb_free(&arb_int_c);
      arb_free(&arb_int_d);

      }
   return 0;    

}
