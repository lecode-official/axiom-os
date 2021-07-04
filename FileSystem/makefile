
objects = main.o file_system.o

all: axiomfs

$(objects): %.o: %.c
	gcc -g3 -c $< -o $@

axiomfs: $(objects)
	gcc -g3 -o axiomfs $(objects) -lm

.PHONY: clean
clean:
	rm ${objects} axiomfs
