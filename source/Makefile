objs = main.o error.o
name = bi

all: $(name)

$(name): $(objs)
	ld	-o $(name) $(objs)

%.o: %.asm
	as	-o $@ $<

clean:
	rm 	-rf $(objs) $(name)
