.section .text

.globl _start

_start:
	popq	%rax
	cmpq	$2, %rax
	jne	.e_usage

.e_usage:
	call	ErrUsage
