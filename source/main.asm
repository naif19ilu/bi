# bi - brainfuck interpreter
# 28 Jun 2025
# This file handles code reading, lexing and parsing

.section .data
	.numberline: .long 1
	.offset:     .long 0
	.noloops:    .quad 0

.section .text

.macro SETOK reps
	# 1. Makes sure there's room for one more token
	cmpq	TokenStreamLength(%rip), %r9
	je	.e_overflow
	# 2. Contextualize the next token in the stream
	movq	TokenSize(%rip), %rax
	mulq	%r9
	movq	%rax, %rbx
	leaq	TokenStream(%rip), %rax
	addq	%rbx, %rax
	xorq	%rbx, %rbx
	movl	\reps, (%rax)
	movl	(.numberline), %ebx
	movl	%ebx, 4(%rax)
	movl	(.offset), %ebx
	movl	%ebx, 8(%rax)
	movq	%r8, 12(%rax)
	incq	%r9
	movq	%rax, %r10
.endm

.globl _start

_start:
	popq	%rax
	cmpq	$2, %rax
	jne	.e_usage
	popq	%rax
	# r8  will contain the source code throughout the program
	# r9  will store the number of tokens stored so far
	# r10 will store the last token saved
	popq	%r8
	xorq	%r9,  %r9
	xorq	%r10, %r10
.loop:
	movzbl	(%r8), %edi
	cmpb	$0, %dil
	je	.fini
	cmpb	$'+', %dil
	je	.acumu
	cmpb	$'-', %dil
	je	.acumu
	cmpb	$'<', %dil
	je	.acumu
	cmpb	$'>', %dil
	je	.acumu
	cmpb	$'.', %dil
	je	.acumu
	cmpb	$',', %dil
	je	.acumu
	cmpb	$'[', %dil
	je	.left_one
	cmpb	$']', %dil
	je	.right_one
	cmpb	$'\n', %dil
	je	.newline
	# anything else shall be taken as a comment
	jmp	.resume
.acumu:
	cmpq	$0, %r9
	jne	.acu_may
	SETOK	$1
	jmp	.resume
.acu_may:
 	# Whenever we found a token followed by more
	# tokens of the same type, we're going to only
	# use one chunk in TokenStream and increase the
	# number of reps for that token
	# example: +++
	# this would make room for a single token of kind +
	# but the number of reps would be 3
	movq	12(%r10), %rax
	movzbl	(%rax), %eax
	cmpb	%dil, %al
	je	.acu_is
	SETOK	$1
	jmp	.resume
.acu_is:
	incl	0(%r10)
	jmp	.resume
.left_one:
 	# making sure there's room for one more
	movq	(.noloops), %r15
	cmpq	MaxNestedNoLoops(%rip), %r15
	je	.e_maxnest
	# for tokens [ and ] the 'reps' within the structure
	# will take a different meaning; now it will represent
	# the position within the stream where its pair can be
	# found
	# we pass r9 as reps value since we want to store this token's
	# position
	SETOK	%r9d
	leaq	LoopsBros(%rip), %rax
	movq	%r10, (%rax, %r15, 8)
	incq	(.noloops)
	jmp	.resume
.right_one:
	# making sure there's at least one opened brace
	decq	(.noloops)
	movq	(.noloops), %r15
	cmpq	$0, %r15
	jl	.e_nopened
	# Getting last brace pushed into LoopsBros
	leaq	LoopsBros(%rip), %rax
	movq	(%rax, %r15, 8), %r15
	movl	0(%r15), %r13d
	movq	%r9, %r14
	SETOK	%r13d
	movl	%r14d, (%r15)
	jmp	.resume
.newline:
	incl	(.numberline)
	movl	$0, (.offset)
	incq	%r8
	jmp	.loop
.resume:
	incq	%r8
	incl	(.offset)
	jmp	.loop
.fini:
	movq	%r9, %rdi
	call	Interpreter
	movq	$60, %rax
	movq	$0, %rdi
	syscall

.e_usage:
	call	UsageMsg
.e_overflow:
	call	OverFlow
.e_maxnest:
	call	MaxNestedLoops
.e_nopened:
	call	BraceNoOpened

