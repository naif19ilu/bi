# bi - encoder and decoder
# 29 Jun 2025
# Interpreter per se

.section .bss
	# struct token {
	#   QUAD CONTEXT;	8 B      0
	#   LONG TIMES;		4 B      8
	#   LONG NOLINE;	4 B      12
	#   LONG OFFSET;	4 B      16
	# }                     20 B
	__tokstream:  .zero 20 * 1024

	__bracestack: .zero 8 * 256

	.globl __tokstream
	.globl __bracestack

	.memory: .zero 30000

.section .rodata
	__toksize:   .quad 20
	__streamcap: .quad 1024
	__stackcap:  .quad 256

	.globl __toksize
	.globl __streamcap
	.globl __stackcap

.section .text

.globl Int

Int:
	pushq	%rbp
	movq	%rsp, %rbp
	#  -8: number of tokens
	# -16: aka i
	subq	$16, %rsp
	movq	%r9, -8(%rbp)
	movq	$0, -16(%rbp)
	# r8 : current token
	# r9 : pointer to current cell
	# r10: token.times
	leaq	.memory(%rip), %r9
	xorq	%r10, %r10
.int_loop:
	movq	-16(%rbp), %rax
	cmpq	-8(%rbp), %rax
	jge	.int_return
	# getting nth token
	movq	__toksize(%rip), %rbx
	mulq	%rbx
	leaq	__tokstream(%rip), %r8
	addq	%rax, %r8
	xorq	%r10, %r10
	movl	8(%r8), %r10d
	movq	(%r8), %rax
	movzbl	(%rax), %edi
	cmpb	$'+', %dil
	je	.int_inc
	cmpb	$'-', %dil
	je	.int_dec
	cmpb	$'<', %dil
	je	.int_prv
	cmpb	$'>', %dil
	je	.int_nxt
	cmpb	$'.', %dil
	je	.int_out
	cmpb	$',', %dil
	je	.int_inp
	cmpb	$'[', %dil
	je	.int_opn
	cmpb	$']', %dil
	je	.int_cls
	# program should never get here
	movq	$60, %rax
	movq	$-1, %rdi
	syscall
.int_inc:
	addb	%r10b, (%r9)
	jmp	.int_resume
.int_dec:
	subb	%r10b, (%r9)
	jmp	.int_resume
.int_nxt:
	addq	%r10, %r9
	jmp	.int_resume
.int_prv:
	subq	%r10, %r9
	jmp	.int_resume
.int_out:
	cmpl	$0, %r10d
	je	.int_resume
	movq	$1, %rax
	movq	$1, %rdi
	movq	%r9, %rsi
	movq	$1, %rdx
	syscall
	decl	%r10d
	jmp	.int_out
.int_inp:
	cmpl	$0, %r10d
	je	.int_resume
	movq	$0, %rax
	movq	$0, %rdi
	movq	%r9, %rsi
	movq	$1, %rdx
	syscall
	decl	%r10d
	jmp	.int_inp
.int_opn:
	movzbl	(%r9), %edi
	cmpb	$0, %dil
	je	.int_opn_0
	jmp	.int_resume
.int_opn_0:
	movq	%r10, -16(%rbp)
	jmp	.int_loop
.int_cls:
	movzbl	(%r9), %edi
	cmpb	$0, %dil
	je	.int_resume	
	movq	%r10, -16(%rbp)
	jmp	.int_loop
.int_resume:
	incq	-16(%rbp)
	jmp	.int_loop
.int_return:
	leave
	ret

