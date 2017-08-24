#pragma once 
#include <string.h>

typedef char ** arb_int_t;

void arb_free (arb_int_t* i);

int arb_duplicate(arb_int_t * new, const arb_int_t original); 

int arb_from_string (arb_int_t *i, const char* s);

int arb_from_int (arb_int_t *i, signed long long int source);

int arb_to_string ( const arb_int_t i, char* buf, size_t max);

int arb_to_int(const arb_int_t i, long long int * out);

int arb_assign(arb_int_t x, const arb_int_t y);

int arb_compare(const arb_int_t, const arb_int_t y);

int arb_add(arb_int_t x, const arb_int_t y);

int arb_subtract(arb_int_t x, const arb_int_t y);

int arb_multiply(arb_int_t x, const arb_int_t y);

int arb_divide(arb_int_t x, const arb_int_t y);

unsigned int copyAndConvert(const char * source, char * dest, unsigned int destsize);

