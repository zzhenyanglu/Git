
struct X
{
   char c;
   int i;
};

// sizeof(struct X) >= sizeof(c) + sizeof(i);

// [C]  [] [] [] [i][i][i][i]
// 0    1  2  3  4  5  6  7 

// Note: union and struct share tag space (so can't have struct and union with same tag name)
union Y
{
   char c;
   int i;
};

// |[C ] [] [] []
// |[i] [i] [i][i]
//
//  0    1  2  3
