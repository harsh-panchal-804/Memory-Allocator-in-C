	.file	"main.c"
	.text
	.globl	head
	.bss
	.align 8
	.type	head, @object
	.size	head, 8
head:
	.zero	8
	.globl	tail
	.align 8
	.type	tail, @object
	.size	tail, 8
tail:
	.zero	8
	.globl	global_malloc_lock
	.align 32
	.type	global_malloc_lock, @object
	.size	global_malloc_lock, 40
global_malloc_lock:
	.zero	40
	.text
	.globl	get_free_block
	.type	get_free_block, @function
get_free_block:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, -24(%rbp)
	movq	head(%rip), %rax
	movq	%rax, -8(%rbp)
	jmp	.L2
.L5:
	movq	-8(%rbp), %rax
	movl	8(%rax), %eax
	testl	%eax, %eax
	je	.L3
	movq	-8(%rbp), %rax
	movq	(%rax), %rax
	cmpq	%rax, -24(%rbp)
	ja	.L3
	movq	-8(%rbp), %rax
	jmp	.L4
.L3:
	movq	-8(%rbp), %rax
	movq	16(%rax), %rax
	movq	%rax, -8(%rbp)
.L2:
	cmpq	$0, -8(%rbp)
	jne	.L5
	movl	$0, %eax
.L4:
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	get_free_block, .-get_free_block
	.globl	my_malloc
	.type	my_malloc, @function
my_malloc:
.LFB1:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	cmpq	$0, -40(%rbp)
	jne	.L7
	movl	$0, %eax
	jmp	.L8
.L7:
	leaq	global_malloc_lock(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	movq	-40(%rbp), %rax
	movq	%rax, %rdi
	call	get_free_block
	movq	%rax, -24(%rbp)
	cmpq	$0, -24(%rbp)
	je	.L9
	movq	-24(%rbp), %rax
	movl	$0, 8(%rax)
	leaq	global_malloc_lock(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	movq	-24(%rbp), %rax
	addq	$24, %rax
	jmp	.L8
.L9:
	movq	-40(%rbp), %rax
	addq	$24, %rax
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	sbrk@PLT
	movq	%rax, -8(%rbp)
	cmpq	$-1, -8(%rbp)
	jne	.L10
	leaq	global_malloc_lock(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	movl	$0, %eax
	jmp	.L8
.L10:
	movq	-8(%rbp), %rax
	movq	%rax, -24(%rbp)
	movq	-24(%rbp), %rax
	movl	$0, 8(%rax)
	movq	-24(%rbp), %rax
	movq	-40(%rbp), %rdx
	movq	%rdx, (%rax)
	movq	-24(%rbp), %rax
	movq	$0, 16(%rax)
	movq	head(%rip), %rax
	testq	%rax, %rax
	jne	.L11
	movq	-24(%rbp), %rax
	movq	%rax, head(%rip)
.L11:
	movq	tail(%rip), %rax
	testq	%rax, %rax
	je	.L12
	movq	tail(%rip), %rax
	movq	-24(%rbp), %rdx
	movq	%rdx, 16(%rax)
.L12:
	movq	-24(%rbp), %rax
	movq	%rax, tail(%rip)
	leaq	global_malloc_lock(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	movq	-24(%rbp), %rax
	addq	$24, %rax
.L8:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	my_malloc, .-my_malloc
	.globl	my_calloc
	.type	my_calloc, @function
my_calloc:
.LFB2:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	cmpq	$0, -24(%rbp)
	je	.L14
	cmpq	$0, -32(%rbp)
	jne	.L15
.L14:
	movl	$0, %eax
	jmp	.L16
.L15:
	movq	-32(%rbp), %rax
	imulq	-24(%rbp), %rax
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rax
	movl	$0, %edx
	divq	-24(%rbp)
	cmpq	%rax, -32(%rbp)
	je	.L17
	movl	$0, %eax
	jmp	.L16
.L17:
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	my_malloc
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jne	.L18
	movl	$0, %eax
	jmp	.L16
.L18:
	movq	-16(%rbp), %rdx
	movq	-8(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	memset@PLT
	movq	-8(%rbp), %rax
.L16:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	my_calloc, .-my_calloc
	.globl	my_free
	.type	my_free, @function
my_free:
.LFB3:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	cmpq	$0, -40(%rbp)
	je	.L28
	leaq	global_malloc_lock(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_lock@PLT
	movq	-40(%rbp), %rax
	subq	$24, %rax
	movq	%rax, -16(%rbp)
	movl	$0, %edi
	call	sbrk@PLT
	movq	%rax, -8(%rbp)
	movq	-16(%rbp), %rax
	movq	(%rax), %rdx
	movq	-40(%rbp), %rax
	addq	%rdx, %rax
	cmpq	%rax, -8(%rbp)
	jne	.L22
	movq	head(%rip), %rdx
	movq	tail(%rip), %rax
	cmpq	%rax, %rdx
	jne	.L23
	movq	$0, tail(%rip)
	movq	tail(%rip), %rax
	movq	%rax, head(%rip)
	jmp	.L24
.L23:
	movq	head(%rip), %rax
	movq	%rax, -24(%rbp)
	jmp	.L25
.L27:
	movq	-24(%rbp), %rax
	movq	16(%rax), %rdx
	movq	tail(%rip), %rax
	cmpq	%rax, %rdx
	jne	.L26
	movq	-24(%rbp), %rax
	movq	$0, 16(%rax)
	movq	-24(%rbp), %rax
	movq	%rax, tail(%rip)
	jmp	.L24
.L26:
	movq	-24(%rbp), %rax
	movq	16(%rax), %rax
	movq	%rax, -24(%rbp)
.L25:
	cmpq	$0, -24(%rbp)
	je	.L24
	movq	-24(%rbp), %rax
	movq	16(%rax), %rax
	testq	%rax, %rax
	jne	.L27
.L24:
	movq	-16(%rbp), %rax
	movq	(%rax), %rdx
	movq	$-24, %rax
	subq	%rdx, %rax
	movq	%rax, %rdi
	call	sbrk@PLT
	leaq	global_malloc_lock(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	jmp	.L19
.L22:
	movq	-16(%rbp), %rax
	movl	$1, 8(%rax)
	leaq	global_malloc_lock(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_unlock@PLT
	jmp	.L19
.L28:
	nop
.L19:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	my_free, .-my_free
	.globl	my_realloc
	.type	my_realloc, @function
my_realloc:
.LFB4:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	movq	%rsi, -32(%rbp)
	cmpq	$0, -24(%rbp)
	je	.L30
	cmpq	$0, -32(%rbp)
	jne	.L31
.L30:
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	my_malloc
	jmp	.L32
.L31:
	movq	-24(%rbp), %rax
	subq	$24, %rax
	movq	%rax, -16(%rbp)
	movq	-16(%rbp), %rax
	movq	(%rax), %rax
	cmpq	%rax, -32(%rbp)
	ja	.L33
	movq	-24(%rbp), %rax
	jmp	.L32
.L33:
	movq	-32(%rbp), %rax
	movq	%rax, %rdi
	call	my_malloc
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je	.L34
	movq	-16(%rbp), %rax
	movq	(%rax), %rdx
	movq	-24(%rbp), %rcx
	movq	-8(%rbp), %rax
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	memcpy@PLT
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	my_free
.L34:
	movq	-8(%rbp), %rax
.L32:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	my_realloc, .-my_realloc
	.section	.rodata
.LC0:
	.string	"Allocation failed"
.LC1:
	.string	"Values in mallocd array:"
.LC2:
	.string	"%d "
.LC3:
	.string	"Values in callocd array:"
.LC4:
	.string	"Reallocated string: %s\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB5:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movl	$20, %edi
	call	my_malloc
	movq	%rax, -24(%rbp)
	cmpq	$0, -24(%rbp)
	jne	.L36
	leaq	.LC0(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	movl	$1, %eax
	jmp	.L37
.L36:
	movl	$0, -36(%rbp)
	jmp	.L38
.L39:
	movl	-36(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	leaq	(%rdx,%rax), %rcx
	movl	-36(%rbp), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	addl	%eax, %eax
	movl	%eax, (%rcx)
	addl	$1, -36(%rbp)
.L38:
	cmpl	$4, -36(%rbp)
	jle	.L39
	leaq	.LC1(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	movl	$0, -32(%rbp)
	jmp	.L40
.L41:
	movl	-32(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %eax
	movl	%eax, %esi
	leaq	.LC2(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	addl	$1, -32(%rbp)
.L40:
	cmpl	$4, -32(%rbp)
	jle	.L41
	movl	$10, %edi
	call	putchar@PLT
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	my_free
	movl	$4, %esi
	movl	$5, %edi
	call	my_calloc
	movq	%rax, -16(%rbp)
	cmpq	$0, -16(%rbp)
	je	.L42
	leaq	.LC3(%rip), %rax
	movq	%rax, %rdi
	call	puts@PLT
	movl	$0, -28(%rbp)
	jmp	.L43
.L44:
	movl	-28(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-16(%rbp), %rax
	addq	%rdx, %rax
	movl	(%rax), %eax
	movl	%eax, %esi
	leaq	.LC2(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	addl	$1, -28(%rbp)
.L43:
	cmpl	$4, -28(%rbp)
	jle	.L44
	movl	$10, %edi
	call	putchar@PLT
	movq	-16(%rbp), %rax
	movq	%rax, %rdi
	call	my_free
.L42:
	movl	$10, %edi
	call	my_malloc
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movw	$26952, (%rax)
	movb	$0, 2(%rax)
	movq	-8(%rbp), %rax
	movl	$2, %esi
	movq	%rax, %rdi
	call	my_realloc
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	strlen@PLT
	movq	%rax, %rdx
	movq	-8(%rbp), %rax
	addq	%rdx, %rax
	movabsq	$9400216233473056, %rcx
	movq	%rcx, (%rax)
	movq	-8(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC4(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	my_free
	leaq	global_malloc_lock(%rip), %rax
	movq	%rax, %rdi
	call	pthread_mutex_destroy@PLT
	movl	$0, %eax
.L37:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
