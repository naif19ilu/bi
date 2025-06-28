# bi - brainfuck interpreter
# 28 Jun 2025
# This file handles code reading, lexing and parsing

.section .text

.globl _start

_start:
	popq	%rax
	cmpq	$2, %rax
	jne	.usage

	popq	%rax
	popq	%rsi

	movq	$1, %rax
	movq	$1, %rdi
	movq	$10, %rdx
	syscall

	jmp	.fini

.usage:
	call	UsageMsg

.fini:
	movq	$60, %rax
	movq	$0, %rdi
	syscall
