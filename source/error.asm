# bi - brainfuck interpreter
# 28 Jun 2025
# This file handles program's errors

.section .rodata
	.usage_msg: .string "\n\tbi::usage: bi \"$(cat filename)\"\n\n"
	.usage_len: .quad   35

.section .text

.macro EXIT st
	movq	\st, %rdi
	movq	$60, %rax
	syscall
.endm

.globl UsageMsg
UsageMsg:
	movq	$1, %rax
	movq	$1, %rdi
	leaq	.usage_msg(%rip), %rsi
	movq	.usage_len(%rip), %rdx
	syscall
	EXIT	$0

.globl OverFlow
OverFlow:
	EXIT	$1

.globl MaxNestedLoops
MaxNestedLoops:
	EXIT	$2

.globl BraceNoOpened
BraceNoOpened:
	EXIT	$3

