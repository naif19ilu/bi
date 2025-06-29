# bi - brainfuck interpreter
# 28 Jun 2025
# This file handles program's errors

.section .rodata
	.usage_msg:  .string "\n\tbi::usage: bi \"$(cat filename)\"\n\n"
	.usage_len:  .quad   35

	.templaterr: .string "\t\tbi::fatal: '%s' (%d:%d)\n"

	.why_1: .string "token limit exceeded"
	.why_2: .string "nested loops limit exceeded"
	.why_3: .string "unmatched brace"

.section .text

.macro INIT why
	movq	$2, %rdi
	leaq	.templaterr(%rip), %rsi
	leaq	\why, %rdx
	xorq	%rcx, %rcx
	xorq	%r8,  %r8
	movl	(numberline), %ecx
	movl	(offset), %r8d
	call	fp64
.endm

.macro EXIT status
	movq	\status, %rdi
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
	INIT	.why_1(%rip)
	EXIT	$1

.globl MaxNestedLoops
MaxNestedLoops:
	INIT	.why_2(%rip)
	EXIT	$2

.globl BraceNoOpened
BraceNoOpened:
	INIT	.why_3(%rip)
	EXIT	$3
