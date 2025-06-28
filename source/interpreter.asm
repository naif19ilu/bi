# bi - brainfuck interpreter
# 28 Jun 2025
# Interpreter per se implementation

.section .bss
	# we define a token like
	# Token {
	#    long reps;                         4 B	off = 0
	#    long numberline;			4 B	off = 4
	#    long line_offset;			4 B	off = 8
	#    quad context;                      8 B	off = 12
	# }
	#                                       20 B total
	TokenStream: .zero 20 * 1024

	.globl TokenStream

.section .rodata
	TokenStreamLength: .quad 1024
	TokenSize:         .quad 20

	.globl TokenSize
	.globl TokenStreamLength

.section .text
