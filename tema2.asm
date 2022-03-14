.data
	n: .long 4
	m: .long 4
	aux: .long 4
	top: .long 4
	total: .space 4
	saver: .space 4
	x: .space 4
	a: .space 400
	st: .space 800
	formatScanf: .asciz "%300[^\n]"
	formatPrintf: .asciz "%d "
	formatPrintf1: .asciz "%s"
	delim: .asciz " "
	terminator: .asciz "\n"
.text
 
valid:
	pushl %ebp
	movl %esp, %ebp
 
	# eax = x
	movl 8(%ebp), %eax 
	# ebx = y
	movl 12(%ebp), %ebx
 
	movl %ebx, saver
 
	# edx = st[x]
	movl (%esi, %eax, 4), %edx
 
	# if ( st[x] == 0 ) return 1
	cmp $0, %edx
	je ret1
 
	# if ( st[x] >= 3 ) return 0
	cmp $3, %edx
	jge ret0
 
	# x = x + n
	addl n, %eax
	# edx = st[x + n]
	movl (%esi, %eax, 4), %edx
	# x = x - n
	subl n, %eax
	# ebx = ebx - edx = y - st[x + n]
	subl %edx, %ebx
 
	cmp m, %ebx
	jle ret0
 
	# ecx = y
	movl saver, %ecx
	movl saver, %edx
	addl m, %edx
	jmp for 
 
for:
	# final de for
	cmp %ecx, %edx
	jl ret1
 
	# ebx = a[i]
	movl (%edi, %ecx, 4), %ebx
	# if ( x == a[i] ) return 0
	cmp %eax, %ebx
	je ret0
 
	incl %ecx
	jmp for 
 
ret0:
	xorl %eax, %eax
	popl %ebp
	ret
 
ret1:
	movl $1, %eax
	popl %ebp
	ret
 
afisare:
 
	movl $1, %ecx
	movl n, %eax
	movl $3, %ebx
	mull %ebx
	jmp afisare1
 
afisare1:
 
	cmp %ecx, %eax
	jl exit
 
	subl n, %eax
	addl %ecx, %eax
	movl (%esi, %eax, 4), %ebx
	subl %ecx, %eax
	addl n, %eax
 
	pushl %eax
	pushl %ecx
	pushl %ebx
	pushl $formatPrintf
 
	call printf
 
	popl %ebx
	popl %ebx 
	popl %ecx
	popl %eax
 
	incl %ecx
	jmp afisare1
 
back:
 
	pushl %ebp
	movl %esp, %ebp
 
	#if ( top == 3 * n + 1 )
	movl 8(%ebp), %edx
	movl %edx, top
 
	#eax = 3 * n + 1
	movl n, %eax
	movl $3, %ebx
	mull %ebx
	addl $1, %eax
 
	cmp top, %eax
	je afisare
 
	#if (a[top] != 0)
	movl top, %ecx
	movl (%edi, %ecx, 4), %ebx
 
	cmp $0, %ebx
	jne executa1
 
	jmp else
 
executa1:
 
	# ebx = a[top] = x
	movl %ebx, x 
 
	#aux = st[x + n]
	addl n, %ebx
	movl (%esi, %ebx, 4), %edx
	movl %edx, aux 
 
	#st[x + n] = top
	movl top, %edx
	movl %edx, (%esi, %ebx, 4)
 
	#st[top + 2 * n] = x
	subl n, %ebx
	xorl %eax, %eax
	addl top, %eax
	addl n, %eax
	addl n, %eax
	movl %ebx, (%esi, %eax, 4)
 
 	pushl %ecx
	pushl top
	pushl aux
 
	#Back(top + 1)	
	incl top
	pushl top
	call back
 
	popl %ebx
 
	popl aux
	popl top
	popl %ecx
 
	#st[x + n] = aux
	movl x, %ebx
	addl n, %ebx
	movl aux, %edx
	movl %edx, (%esi, %ebx, 4)
 
	jmp final
 
else:
 
	movl $1, %ecx
	jmp et_for
 
et_for:
	movl n, %eax
	cmp %eax, %ecx
	jg final
 
	#if ( Valid(i, top) )
	pushl top
	pushl %ecx
	call valid
	popl %ecx
	popl top
 
	cmp $1, %eax
	je executa2
 
	incl %ecx
	jmp et_for
 
executa2:
 
	#st[i] ++
	incl (%esi, %ecx, 4)
 
	#st[top + 2 * n] = i
	xorl %eax, %eax
	addl top, %eax
	addl n, %eax
	addl n, %eax
	movl %ecx, (%esi, %eax, 4)
 
	#aux = st[i + n]
	addl n, %ecx
	movl (%esi, %ecx, 4), %edx
	movl %edx, aux
 
	#st[i + n] = top
	movl top, %edx
	movl %edx, (%esi, %ecx, 4)
 
 	pushl %ecx
	pushl top
	pushl aux
 
	#Back(top + 1)	
	incl top
	pushl top
	call back
 
	popl %ebx
 
	popl aux
	popl top
	popl %ecx
 
	#st[i + n] = aux
	movl aux, %edx
	movl %edx, (%esi, %ecx, 4)
 
	#st[i] --
	subl n, %ecx
	decl (%esi, %ecx, 4)
 
	incl %ecx
	jmp et_for
 
final:
	popl %ebp
	ret
 
.global main
 
main:
	pushl $a
	pushl $formatScanf
	call scanf
	popl %ebx
	popl %ebx
 
	pushl $delim
	pushl $a
	call strtok
	popl %ebx
	popl %ebx
 
	pushl %eax
	call atoi
	popl %ebx
	movl %eax, n
 
	pushl $delim
	pushl $0
	call strtok
	popl %ebx
	popl %ebx
 
	pushl %eax
	call atoi
	popl %ebx
	movl %eax, m
 
	movl n, %eax
	movl $3, %ebx
	mull %ebx
	movl %eax, total
 
	xorl %ecx, %ecx
 
citire_vector:
 
	incl %ecx
 
	cmp total, %ecx
	jg init
 
	pushl %ecx
	pushl $delim
	pushl $0
 
	call strtok
 
	popl %ebx
	popl %ebx
	popl %ecx
 
	pushl %ecx
	pushl %eax
	call atoi
	popl %ebx
	popl %ecx
 
	movl $st, %esi
	movl %eax, (%edi, %ecx, 4)
	incl (%esi, %eax, 4)
 
	jmp citire_vector
	
init:
	movl $1, %ecx

init_last:

	cmp n, %ecx
	jg rezolva
	
	addl n, %ecx
	movl $-30, (%esi, %ecx, 4)
	subl n, %ecx
	incl %ecx
	
	jmp init_last
 
rezolva:
 
	pushl $1
	call back
	popl %edx	
 
	pushl $-1
	pushl $formatPrintf
	call printf
	popl %ebx
	popl %ebx
 
exit:
	pushl $terminator
	pushl $formatPrintf1
	call printf
	popl %ebx
	popl %ebx
 
	movl $1, %eax
	xorl %ebx, %ebx
	int $0x80
