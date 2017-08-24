PROGRAMS = incorrect_program

CFLAGS=-Wall -pedantic -std=c11 -g

.phony: all
all: $(PROGRAMS)

.phony: clean
clean:
	-rm $(PROGRAMS)

%: %.c
	gcc $(CFLAGS) -o $@ $^
