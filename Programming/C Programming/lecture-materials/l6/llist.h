#pragma once

#ifndef MY_LIST_HEADER
#define MY_LIST_HEADER

struct listnode_t
{
   void * data;
   struct listnode_t * next;
};

typedef struct 
{
   listnode_t * first;
} llist_t;

typedef struct listnode_t listnode_t;

typedef listnode_t llist_t;

// l needs to be a valid pointer to a llist_t
void llist_create (llist_t * l);

void llist_insert_begin(llist_t * l, void * data);


#endif
