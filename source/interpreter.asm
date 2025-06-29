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

 	# this array is used as an stack to keep
	# track of loop's braces
	LoopsBros: .zero 256 * 8

	.globl TokenStream
	.globl LoopsBros

	.a: .zero 8				# REMOVE

.section .rodata
	TokenStreamLength: .quad 1024
	TokenSize:         .quad 20
	MaxNestedNoLoops:  .quad 256

	.globl TokenSize
	.globl TokenStreamLength
	.globl MaxNestedNoLoops

	.fmt: .string "%c :: %d\n"		# REMOVE

.section .text

.globl Interpreter

Interpreter:	
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	movq	$0, -16(%rbp)
.loop:
	movq	-16(%rbp), %rax
	cmpq	%rax, -8(%rbp)
	je	.return

	movq	TokenSize(%rip), %rbx
	mulq	%rbx
	movq	%rax, %rbx
	leaq	TokenStream(%rip), %rax
	addq	%rbx, %rax
	movq	%rax, %r8

	movq	$1, %rdi
	leaq	.fmt(%rip), %rsi

	xorq	%rdx, %rdx
	xorq	%rcx, %rcx

	movq	12(%r8), %rax
	movzbl	(%rax), %eax
	cltq
	movq	%rax, %rdx

	movzbl	0(%r8), %ecx
	call	fp64

	incq	-16(%rbp)
	jmp	.loop
.return:
	leave
	ret
