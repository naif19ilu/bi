.section .rodata
	.usage_msg: .string "\n\tbi:usage: bi \"$(cat filename)\"\n\n"
	.usage_len: .quad 34

.section .text

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
