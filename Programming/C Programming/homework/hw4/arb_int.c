#include "arb_int.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>

int arb_divide(arb_int_t x, const arb_int_t y)
{
   char sign_x =  (*x[0]=='-')?'-':'+';   
   char sign_y =  (*y[0]=='-')?'-':'+';   
   
   // result_abs is the product of X*Y, absolute value
   // arb_int_zero = "0", which is used to control the while loop
   // which is the essential part of the mutilply
   // arb_int_one = "1"
   arb_int_t  y_copy, result_abs, arb_int_one;

   // we need to modify y, so we copy y 
   arb_duplicate(&y_copy,y); 
   arb_from_string(&result_abs, "0");
   arb_from_string(&arb_int_one, "1");
   // change x and y_copy to postive 
   if (sign_x =='-') {for(int i =0; i<strlen(*x);i++)    *((*x)+i) = *((*x)+i+1);}
   if (sign_y =='-') {for(int i =0; i<=strlen(*y_copy);i++)   *((*y_copy)+i) = *((*y_copy)+i+1);}

   // calculate the product of X/Y, absolute value 

   while(arb_compare(x,y_copy) >=0)
   {
      arb_add(result_abs, arb_int_one);
      arb_subtract(x, y_copy);
   }

   // result is the relative version of result_abs; 
   // it contains sign; 
   // try to assign "+" or "-" to the resul
   
   char result [2]= "";
   if(sign_x != sign_y)
   {
      result [0]= '-';
      strcat(result, *result_abs);
   } 

   else strcat(result, *result_abs);
   
   free(*x);
   *x = (char *) malloc(strlen(result)+100);  
   strcpy(*x, result);
 
   arb_free(&arb_int_one);
   arb_free(&y_copy);
   arb_free(&result_abs);

   return 0;
}



int arb_multiply(arb_int_t x, const arb_int_t y)
{
   char sign_x =  (*x[0]=='-')?'-':'+';   
   char sign_y =  (*y[0]=='-')?'-':'+';   
   
   // result_abs is the product of X*Y, absolute value
   // arb_int_zero = "0", which is used to control the while loop
   // which is the essential part of the mutilply
   // arb_int_one = "1"
   arb_int_t x_copy, y_copy, result_abs, arb_int_zero, arb_int_one;

   // we need to modify y, so we copy y 
   arb_duplicate(&y_copy,y); 
   arb_duplicate(&x_copy,x); 
   arb_from_string(&result_abs, "0");
   arb_from_string(&arb_int_zero, "0");
   arb_from_string(&arb_int_one, "1");

   // change x and y_copy to postive 
   if (sign_x =='-') for(int i =0; i<=strlen(*x_copy);i++) *((*x_copy)+i) = *((*x_copy)+i+1);
   if (sign_y =='-') for(int i =0; i<=strlen(*y_copy);i++) *((*y_copy)+i) = *((*y_copy)+i+1);

   // calculate the product of X*Y,absolute value 

   for(int i =0; i<strlen(*x_copy);i++) 
   {
      char b[2]="0"; 
      b[0] =  *((*x_copy)+strlen(*x_copy)-i-1);

      arb_int_t product;
      arb_int_t result_temp;
      arb_from_string(&result_temp, "0");
      arb_from_string(&product, b);

      while(arb_compare(product,arb_int_zero) ==1)
      {
         arb_add(result_temp, y_copy);
         arb_subtract(product ,arb_int_one);
      }
      // multiply result_temp by 0s

      for(int j=0; j<i;j++) strcat(*result_temp, "0");
      arb_add(result_abs,result_temp);
      
      arb_free(&product);
      arb_free(&result_temp);
   }

   char result [2]= "";
   if(sign_x != sign_y)
   {
      result [0]= '-';
      strcat(result, *result_abs);
   } 

   else strcat(result, *result_abs);
   
   free(*x);
   *x = (char *) malloc(strlen(*result_abs)+10);  
   strcpy(*x, result);

   arb_free(&x_copy);
   arb_free(&y_copy);
   arb_free(&arb_int_one);
   arb_free(&arb_int_zero);
   arb_free(&result_abs);

   return 0;
} 



int arb_add(arb_int_t x, const arb_int_t y)
{ 
   char sign_x =  (*x[0]=='-')?'-':'+';   
   char sign_y =  (*y[0]=='-')?'-':'+';   
   

   // if "+XXXXXXX" + "+XXXX" 
   if ( sign_x =='+' && sign_y =='+') 
   {

       char copy_y[500] ="0" ;
       char copy_x[500] ="0";

       if(strlen(*x) > strlen(*y))  for (int i =0; i<(strlen(*x) - strlen(*y));i++) strcat(copy_y,"0");
       if(strlen(*x) < strlen(*y))  for (int i =0; i<(strlen(*y) - strlen(*x));i++) strcat(copy_x,"0");

       strcat(copy_y,*y);
       strcat(copy_x,*x); 
       char carry[2] ="0";
       // if x is longer than y

       for(int i=0; i<strlen(copy_x);i++)
       {
          char operand_1[2] ="0";
          char operand_2[2] ="0";
          char result[3]="0";
          int sum=0;

          if (!isdigit(copy_x[strlen(copy_x)-i-1])) operand_1[0]='0';
          else operand_1[0] = copy_x[strlen(copy_x)-i-1]; 
          
          if (!isdigit(copy_y[strlen(copy_y)-i-1])) operand_2[0]='0';
          else operand_2[0] = copy_y[strlen(copy_y)-i-1]; 

          // in case last step has carry 
          // I will put a '0' at the beginning of operand_2
          // convert it to int and sum them up then convert back to str
          sum = atoi(operand_1) + atoi(operand_2) + atoi(carry);
          sprintf(result,"%d",sum);
             
          // handle carry and result 
          if(strlen(result) ==2) 
          { 
             carry[0] = result[0];
             copy_y[strlen(copy_y)-i-1] = result[1];   
          }
          else 
          {
             carry[0] = '0'; 
             copy_y[strlen(copy_y)-i-1] = result[0];   
          }
       }

       int max = strlen(*x) > strlen(copy_y) ? strlen(*x) :strlen(copy_y);
       free(*x);
       *x = (char *) malloc(max+100);  
       strcpy(*x, copy_y); 

       // get rid of the first '0' if there is it
       while(*((*x)+0) == '0'){for(int i =0; i<=strlen(*x);i++) *((*x)+i) = *((*x)+i+1);}
       return 0;
   }

   // if the operands are both negative  
   else if ( sign_x =='-' && sign_y =='-') 
   {
      for(int i =0; i <=strlen(*x); i++)  *((*x)+i)=*((*x)+i+1); 
      for(int i =0; i <=strlen(*y); i++)  *((*y)+i)=*((*y)+i+1); 

      arb_add(x, y);
      char copy_x[200] = "-";
      strcat(copy_x,*x);

      free(*x);
      *x = (char *) malloc(strlen(copy_x)+100);  
      strcpy(*x, copy_x);
   }

   // if x is positive and y is negative
   else if ( sign_x =='+' && sign_y =='-') 
   {
      arb_int_t negate_y;
      arb_duplicate(&negate_y,y); 
 
      // negate y if y is negative
      while(*((*negate_y)+0) == '-'){for(int i =0; i<=strlen(*negate_y);i++) *((*negate_y)+i) = *((*negate_y)+i+1);}
      arb_subtract(x, negate_y);
      arb_free(&negate_y);
   }

   
   // if x is positive and y is negative
   else if ( sign_x =='-' && sign_y =='+') 
   {
      arb_int_t y_copy;
      arb_duplicate(&y_copy,y); 

      // negate y if y is negative
      while(*((*x)+0) == '-'){for(int i =0; i<=strlen(*x);i++) *((*x)+i) = *((*x)+i+1);}
      arb_subtract(y_copy, x);
      arb_assign(x, y_copy);
      arb_free(&y_copy);
   }
   return 0; 
}

int arb_subtract(arb_int_t x, const arb_int_t y)
{
   char sign_x =  (*x[0]=='-')?'-':'+';   
   char sign_y =  (*y[0]=='-')?'-':'+';   

   if ( sign_x =='+' && sign_y =='+')
   {

      // if x >= y
      if(arb_compare(x,y) >= 0) 
      {
         // create a copy of y and left pad the copy with 0s
         char y_copy[500]="0";
         char x_copy[500]="0";
 
         if(strlen(*x) > strlen(*y))  for (int i =0; i<(strlen(*x) - strlen(*y));i++) strcat(y_copy,"0");
         if(strlen(*x) < strlen(*y))  for (int i =0; i<(strlen(*y) - strlen(*x));i++) strcat(x_copy,"0");

         strcat(y_copy, *y);
         strcat(x_copy, *x);

         char carry[2] ="0";

         for(int i=0; i<strlen(y_copy);i++)
         {
            char operand_1[2] ="0";
            char operand_2[2] ="0";
            char result[2];
            int sum=0;

            operand_1[0] = x_copy[strlen(x_copy)-i-1]; 
            operand_2[0] = y_copy[strlen(y_copy)-i-1]; 
      
            //if(operand_2[0] =='\0') operand_2[0] = '0';
               
            // if operand from x s larger than that from y
            // we don't need to carry 1 to the next digit     

            if ((operand_1[0] - operand_2[0]) >= atoi(carry))
            {
               sum  = atoi(operand_1) - atoi(operand_2) - atoi(carry);
               carry[0] = '0';
               sprintf(result, "%d", sum);
               x_copy[strlen(x_copy)-i-1] = result[0];
            }
       
            else
            {
               sum  = 10 + atoi(operand_1) - atoi(operand_2) - atoi(carry);
               carry[0] = '1';
               sprintf(result, "%d", sum);
               x_copy[strlen(x_copy)-i-1] = result[0];
            }
         }

         arb_int_t temp;
         arb_from_string(&temp ,x_copy);

         free(*x);
         *x = (char *) malloc(strlen(*temp)+100);  
         strcpy(*x, *temp);
  
         arb_free(&temp);
         return 0;
      }

      // if x < y
      else  
      {
         // if x<y then x-y = -(y-x)
         arb_int_t y_copy;
         arb_duplicate(&y_copy, y);
         arb_subtract(y_copy, x); 
         // add a negative sign to y_copy;
         char x_new[100]="-";
         strcat(x_new, *y_copy);


         free(*x);
         *x = (char *) malloc(strlen(x_new)+100);  
         strcpy(*x, x_new);
         arb_free(&y_copy);  
      }
 
   }

   else if ( sign_x =='+' && sign_y =='-')
   {
      arb_int_t negate_y;
      arb_duplicate(&negate_y,y); 
 
      // negate y if y is negative
      while(*((*negate_y)+0) == '-'){for(int i =0; i<=strlen(*negate_y);i++) *((*negate_y)+i) = *((*negate_y)+i+1);}
      arb_add(x, negate_y);
      arb_free(&negate_y);
   }

   else if ( sign_x =='-' && sign_y =='+')
   {
      // negate y if y is negative
      while(*((*x)+0) == '-'){for(int i =0; i<=strlen(*x);i++) *((*x)+i) = *((*x)+i+1);}
      arb_add(x, y);

      // put a "-" sign to negate_x
      char x_new[2] = "-";
      strcat(x_new, *x);
  
      free(*x);
      *x = (char *) malloc(strlen(x_new)+100);  
      strcpy(*x, x_new);
   }

   else //if sign_x and sign_y both are "-"
   {
      // ("-xxx" - "-yyyy") = "yyyy" - "xxxx"  
      // negate_y is -y
      arb_int_t negate_y;
      arb_duplicate(&negate_y, y);
      while(*((*negate_y)+0) == '-'){for(int i =0; i<=strlen(*negate_y);i++) *((*negate_y)+i) = *((*negate_y)+i+1);}

      //negate_x is -x
      arb_int_t negate_x;
      arb_duplicate(&negate_x, x);
      while(*((*negate_x)+0) == '-'){for(int i =0; i<=strlen(*negate_x);i++) *((*negate_x)+i) = *((*negate_x)+i+1);}

      arb_subtract(negate_y, negate_x);

      arb_assign(x, negate_y);
      arb_free(&negate_y); 
      arb_free(&negate_x); 
   }
   return 0; 
}



int arb_compare (const arb_int_t x, const arb_int_t y)
{

   // sign_x sign_y can be '-+0123456789'
   char sign_x =  (*x[0]=='-')?'-':'+';   
   char sign_y =  (*y[0]=='-')?'-':'+';   
 
   // if we could compare x with y by sign
   if (sign_x =='-' && sign_y == '+')  return -1;
   if (sign_x =='+' && sign_y == '-')  return 1;

   // if we could not compare x with y by length

   
   if (sign_x =='-' && sign_y == '-') 
   {
      // if length is different then the longer guy is smaller 
      if(strlen(*x) > strlen(*y)) return -1;
      else if(strlen(*x) < strlen(*y)) return 1;
      else 
      {
         for(int i =0; i<=strlen(*y);i++)
         {
             if (*((*y)+i) < *((*x)+i)) return -1;
             else if (*((*y)+i) > *((*x)+i)) return 1;
             else continue;
         }
      }
   }

   // if both x and y are "+"
   if (sign_x =='+' && sign_y == '+') 
   {
      // if length is different then the longer guy is smaller 
      if(strlen(*x) < strlen(*y)) return -1;
      else if(strlen(*x) > strlen(*y)) return 1;
      else 
      {
         for(int i =0; i<=strlen(*y);i++)
         {
             if (*((*y)+i) > *((*x)+i)) return -1;
             else if (*((*y)+i) < *((*x)+i)) return 1;
             else continue;
         }
      }
   }
   return 0;
}


int arb_from_string (arb_int_t *i, const char* s)
{

   // if the first char in s is not -+ or digit, return 1! 
   if (!(isdigit(*s) || *s =='+' || *(s) == '-')) return 1;   

   // if it contains any char other than 0-9 behind the first char 
   // then can not take it as a arb_int
   for(int h = 1; h<strlen(s);h++) 
   {
     if (!isdigit(*(s+h))) return 1; 
   }

   // make a copy of the input s 
   // and remove prevailing "+" and "0"
   char s_copy[strlen(s)+5];
   strcpy(s_copy,s);
   
   for(int j=0; j<strlen(s_copy);) 
   {
      if (*(s_copy+j)=='0'|| *(s_copy+j) == '+') 
      {
         for(int h = j; h<strlen(s_copy);h++) *(s_copy+h)=*(s_copy+h+1); 
      }
      else if (*(s_copy+j)=='-'){j++;continue;} 
      else break;       
   }
 
   if(s_copy[0]=='-' && strlen(s_copy)==1) s_copy[0] = '0';
   else if(s_copy[0]=='\0') strcpy(s_copy,"0");
   // allocate memory for i of arb_int_t* type 
   // which should contain a copy of s_copy
 
   *i = (char**) malloc(strlen(s_copy)+50);
   **i = (char*) malloc(strlen(s_copy)+50);

   strcpy(**i, s_copy);
  
   return 0;
}

int arb_from_int (arb_int_t *i, signed long long int source)
{ 
   // allocate some room for llong int 
   // count is how many digits source is
   int count=0;

   for(signed long long int i=source;i!=0;) {i = i/10; count++;};

   *i = (char **) malloc(sizeof(char) * (count+2));
   **i = (char *) malloc(sizeof(char) * (count+2));
   sprintf(**i,"%lld",source);
   return 0;   
}

int arb_to_string(const arb_int_t i, char* buf, size_t max)
{

   if (strlen(*i)>max) return 1;
   else strcpy(buf,*i);
 
   return 0;
}


int arb_to_int (const arb_int_t i, long long int * out)
{
   // p is to hold LLMAX or LLMIN  
   char p[21]; 
   if(*(*i+0) == '-') sprintf(p,"%lld",LLONG_MIN);
   else  sprintf(p,"%lld",LLONG_MAX);

   // if length(i) < length(LLMAX or LLMIN) then output 
   if (strlen(*i) < strlen(p)) *out= atoi(*i);
   
   // if length(i) > length(LLMAX or LLMIN) then output 
   else if (strlen(*i) > strlen(p)) return 1;

   // if length(i) = length(LLMAX or LLMIN) then loop thru
   // each digit to see if it's smaller than corresponding 
   // digits in LL_MAX or LL_MIN 
   else 
   {
      for(int j =0; j< strlen(p);j++) 
      { 
         if(*((*i)+j) == p[j]) continue; 
         else if (*((*i)+j) > p[j])return 1;
      }
      int base = 10;  
      char* p;
      *out=strtoll(*i,&p,base);
     
   }  
   return 0;
}


int arb_assign(arb_int_t x, const arb_int_t y)
{

   free(*x);
   *x = (char *) malloc(strlen(*y)+1);  
   strcpy(*x,*y);

   return 0;
}



int arb_duplicate(arb_int_t * new, const arb_int_t original)
{ 
   *new=(char**) malloc(strlen(*original)+50);
   **new = (char *) malloc(strlen(*original)+50); 
   strcpy(**new,*original);
  
   return 0;
}


void arb_free(arb_int_t *i)
{  
   free(**i);
   free(*i);
}

