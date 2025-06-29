.section .rodata
	.usage_msg: .string "\n\tbi:usage: bi \"$(cat filename)\"\n\n"
	.usage_len: .quad 34

	.err_fmt: .string "\n\tbi:error: '%s' at (%d:%d)\n\n"
	.why_1:   .string "token limit exceeded"
	.why_2:   .string "nested loops exceeded"
	.why_3:   .string "no opened loop"

.section .text

.macro BEFINT why
	movq	$2, %rdi
	leaq	.err_fmt(%rip), %rsi
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
	BEFINT	.why_1(%rip)
	EXIT	$1

.globl ErrMaxNested
ErrMaxNested:
	BEFINT	.why_2(%rip)
	EXIT	$2

.globl ErrNoOpened
ErrNoOpened:
	BEFINT	.why_3(%rip)
	EXIT	$3

