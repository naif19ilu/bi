.section .bss
	# struct token {
	#   QUAD CONTEXT;	8 B      0
	#   LONG TIMES;		4 B      8
	#   LONG NOLINE;	4 B      12
	#   LONG OFFSET;	4 B      16
	# }                     20 B
	__tokstream: .zero 20 * 1024

	.globl __tokstream

.section .rodata
	__toksize:   .quad 20
	__streamcap: .quad 1024

	.globl __toksize
	.globl __streamcap

.section .text
