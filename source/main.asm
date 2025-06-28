# bi - brainfuck interpreter
# 28 Jun 2025
# This file handles code reading, lexing and parsing

.section .data
	.numberline: .long 1
	.offset:     .long 0

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
	jmp	.resume
.acumu:
	cmpq	$0, %r9
	jne	.acu_may
	SETOK	$1
	jmp	.resume
.acu_may:
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


.right_one:

.ok_token:

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
	movl	$60, %eax
	movl	0(%r10), %edi
	syscall

.e_usage:
	call	UsageMsg
.e_overflow:
	call	OverFlow
