objs = main.o fp64.o err.o int.o
name = bi

all: $(name)

$(name): $(objs)
	ld	-o $(name) $(objs)
%.o: %.asm
	as	-o $@ $<
clean:
	rm	-rf $(objs) $(name)

