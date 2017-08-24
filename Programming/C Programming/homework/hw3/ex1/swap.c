//NOTICE: the following function swap()
//        will perform swap in place by reference 
void swap(int* a,int* b)
{
   int* temp;
   temp = a;
   a = b;
   b = temp;
}

