.section .data
	__numline: .long 1
	__offset : .long 0

	.globl __numline
	.globl __offset

.section .text

.macro SETUP times
	cmpq	__streamcap(%rip), %r9
	je	.e_overflow
	movq	%r9, %rax
	movq	__toksize(%rip), %rbx
	mulq	%rbx
	movq	%rax, %rbx
	leaq	__tokstream(%rip), %rax
	addq	%rbx, %rax
	xorq	%rbx, %rbx
	movq	%r8, (%rax)
	movl	\times, 8(%rax)
	movl	(__numline), %ebx
	movl	%ebx, 12(%rax)
	movl	(__offset), %ebx
	movl	%ebx, 16(%rax)
	incq	%r9
	movq	%rax, %r10
.endm

.globl _start

_start:
	popq	%rax
	cmpq	$2, %rax
	jne	.e_usage
	popq	%rax
	# r8 : source code
	# r9 : number of tokens created
	# r10: pointer to last token created
	popq	%r8
	xorq	%r9, %r9
	xorq	%r10, %r10
.loop:
	movzbl	(%r8), %edi
	cmpb	$0, %dil
	je	.fini
	cmpb	$'+', %dil
	je	.accumulative
	cmpb	$'-', %dil
	je	.accumulative
	cmpb	$',', %dil
	je	.accumulative
	cmpb	$'.', %dil
	je	.accumulative
	cmpb	$'<', %dil
	je	.accumulative
	cmpb	$'>', %dil
	je	.accumulative
	# anything else shall be taken
	# as a comment
	jmp	.resume
.accumulative:	
	cmpq	$0, %r9
	jne	.acu_maybe
	SETUP	$1
	jmp	.resume
.acu_maybe:
	movq	(%r10), %rax
	movzbl	(%rax), %eax
	cmpb	%dil, %al
	je	.acu_it_is
	SETUP	$1
	jmp	.resume
.acu_it_is:
	incl	8(%r10)
	jmp	.resume

.resume:
	incq	%r8
	jmp	.loop
.fini:
	movq	$60, %rax
	movq	$0, %rdi
	syscall
.e_usage:
	call	ErrUsage
.e_overflow:
	call	ErrOverFlow

