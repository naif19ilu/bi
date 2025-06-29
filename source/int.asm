.section .bss
	# struct token {
	#   QUAD CONTEXT;	8 B      0
	#   LONG TIMES;		4 B      8
	#   LONG NOLINE;	4 B      12
	#   LONG OFFSET;	4 B      16
	# }                     20 B
	__tokstream:  .zero 20 * 1024

	__bracestack: .zero 8 * 256

	.globl __tokstream
	.globl __bracestack

.section .rodata
	__toksize:   .quad 20
	__streamcap: .quad 1024
	__stackcap:  .quad 256

	.globl __toksize
	.globl __streamcap
	.globl __stackcap


	# NOTE: REMOVE
	.fmt: .string "%c %d\n"

.section .text

.globl Int

Int:
	pushq	%rbp
	movq	%rsp, %rbp
	#  -8: number of tokens
	# -16: aka i
	subq	$16, %rsp
	movq	%r9, -8(%rbp)
	movq	$0, -16(%rbp)
.int_loop:
	movq	-16(%rbp), %rax
	cmpq	-8(%rbp), %rax
	je	.int_return
	# getting nth token
	movq	__toksize(%rip), %rbx
	mulq	%rbx
	movq	%rax, %rbx
	leaq	__tokstream(%rip), %rax
	addq	%rbx, %rax

	movq	$1, %rdi
	leaq	.fmt(%rip), %rsi

	movq	(%rax), %rdx
	movzbl	(%rdx), %edx


	xorq	%rcx, %rcx
	movl	8(%rax), %ecx

	call	fp64

	jmp	.int_resume
.int_resume:
	incq	-16(%rbp)
	jmp	.int_loop

.int_return:
	leave
	ret

