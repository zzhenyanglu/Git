
#include <string.h>

// Let's say this header also needs something from mylib2
#include "mylib2.h"

// size_t is an unsigned type big enough to refer to the size of objects in
// memory. It is provided by string.h

// Copy from source to dest, writing at most destsize-1 characters,
// always terminating dest by a 0-byte. Makes characters in dest lowercase.
int copy_and_lower(char * dest, const char * source, size_t destsize);


