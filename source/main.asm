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
	movl	%rbx, 4(%rax)
	movl	(.offset), %ebx
	movl	%rbx, 8(%rax)
	movq	%r8, 12(%rax)
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
	SETOK
	

.left_one:
	SETOK

.right_one:
	SETOK

.token_stored:
	incq	%r9
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
	movq	$60, %rax
	movq	$0, %rdi
	syscall

.e_usage:
	call	UsageMsg
.e_overflow:
	call	OverFlow
