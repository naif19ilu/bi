# bi - encoder and decoder
# 29 Jun 2025
# Error handlder

.section .rodata
	.usage_msg: .string "\n\tbi:usage: bi \"$(cat filename)\"\n\n"
	.usage_len: .quad 34

	.fatal: .string "\n\tbi:error: '%s' at (%d:%d)\n\n"
	.why_1: .string "token limit exceeded"
	.why_2: .string "nested loops exceeded"
	.why_3: .string "no opened loop"

	.fatal2: .string  "\n\tbi:error: no closed loop(s):\n"
	.coords: .string "\t(%d:%d)\n"

	.newlin: .string "\n"

.section .text

.macro DURLEX why
	movq	$2, %rdi
	leaq	.fatal(%rip), %rsi
	xorq	%rdx, %rdx
	xorq	%rcx, %rcx
	xorq	%r8, %r8
	leaq	\why, %rdx
	movl	(__numline), %ecx
	movl	(__offset), %r8d
	call	fp64
.endm

.macro EXIT status
	movq	\status, %rdi
	movq	$60, %rax
	syscall
.endm

.globl ErrUsage
ErrUsage:
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.usage_msg(%rip), %rsi
	movq	.usage_len(%rip), %rdx
	syscall
	EXIT	$0

.globl ErrOverFlow
ErrOverFlow:
	DURLEX	.why_1(%rip)
	EXIT	$1

.globl ErrMaxNested
ErrMaxNested:
	DURLEX	.why_2(%rip)
	EXIT	$2

.globl ErrNoOpened
ErrNoOpened:
	DURLEX	.why_3(%rip)
	EXIT	$3

.globl ErrCheckLoops
ErrCheckLoops:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%r11, -8(%rbp)
	movq	$0, -16(%rbp)
	cmpq	$0, %r11
	je	.cl_return
	movq	$2, %rdi
	leaq	.fatal2(%rip), %rsi
	call	fp64
.cl_loop:
	movq	-16(%rbp), %rbx
	cmpq	-8(%rbp), %rbx
	je	.cl_leave
	movq	$2, %rdi
	leaq	.coords(%rip), %rsi
	leaq	__bracestack(%rip), %rax
	movq	(%rax, %rbx, 8), %rax
	xorq	%rdx, %rdx
	xorq	%rcx, %rcx
	movl	12(%rax), %edx
	movl	16(%rax), %ecx
	call	fp64
	incq	-16(%rbp)
	jmp	.cl_loop
.cl_leave:
	movq	$1, %rax
	movq	$2, %rdi
	leaq	.newlin(%rip), %rsi
	movq	$1, %rdx
	syscall
	EXIT	$4
.cl_return:
	leave
	ret
