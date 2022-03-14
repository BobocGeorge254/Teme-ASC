.data
	n: .long 4
	m: .long 4
	aux: .long 4
	top: .long 4
	total: .space 4
	sir: .space 100
	formatScanf: .asciz "%300[^\n]"
	formatPrintf: .asciz "%d "
	formatPrintf1: .asciz "%s "
	delim: .asciz " "
	terminator: .asciz "\n"
.text

valid:
	pushl %ebp
	movl %esp, %ebp
	
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx
	
	movl (%esi, %eax, 4), %edx
	
	cmp $0, %edx
	je ret1
	
	cmp $3, %edx
	jb ret0
	
	addl n, %eax
	movl %edx, (%esi, %eax, 4)
	subl %edx, %ebx
	
	cmp %edx, m
	jge ret0
	
	jmp ret1 
	
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
	je exit
	
	subl n, %eax
	addl %ecx, %eax
	movl %ebx, (%esi, %eax, 4)
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
	
	#if (a[top] != 0 && Valid(a[top], top))
	movl top, %ecx
	movl (%edi, %ecx, 4), %ebx
	
	cmp $0, %ebx
	jne test_valid
	
	jmp else
	
test_valid:

	pushl %ebx
	pushl top
	call valid
	popl %edx
	popl %ebx
	
	cmp $1, %eax
	je executa1
	
	jmp else
	
executa1:
	
	# ebx = a[top] = x
	
	#st[x]++
	addl $1, (%esi, %ebx, 4) 
	
	#aux = st[x + n]
	addl n, %ebx
	movl (%esi, %ebx, 4), %edx
	movl %edx, aux 
	
	#st[x + n] = top
	movl %edx, (%esi, %ebx, 4)
	movl top, %edx
	
	#st[top + 2 * n] = x
	subl n, %ebx
	xorl %eax, %eax
	addl top, %eax
	addl n, %eax
	addl n, %eax
	movl %ebx, (%esi, %eax, 4)
	
	#Back(top + 1)	
	incl top
	pushl top
	call back
	popl %ebx
	
	#st[x + n] = aux
	addl n, %ebx
	movl aux, %edx
	movl %edx, (%esi, %ebx, 4)
	
	#st[x] --
	subl n, %ebx
	decl (%esi, %ebx, 4)
	
else:

	movl $1, %ecx
	jmp et_for

et_for:
	
	#if ( Valid(i, top) )
	pushl top
	pushl %ecx
	call valid
	popl %ecx
	popl %ebx
	
	cmp $1, %eax
	je executa2
	
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
	
	#Back( top + 1 )
	pushl %ecx
	incl top
	pushl top
	call back
	popl %edx
	popl %ecx
	
	#st[i + n] = aux
	movl aux, %edx
	movl %edx, (%esi, %ecx, 4)
	
	#st[i] --
	subl n, %ecx
	decl (%esi, %ecx, 4)
	
.global main

main:
	pushl $sir
	pushl $formatScanf
	call scanf
	popl %ebx
	popl %ebx
	
	pushl $delim
	pushl $sir
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
	mull m
	movl %eax, total
	
	xorl %ecx, %ecx
	
citire_vector:
	
	incl %ecx
	
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
	
	movl %eax, (%edi, %ecx, 4)
	
	cmp %ecx, total
	je rezolva
	
	jmp citire_vector
	
rezolva:
	
	pushl $1
	call back
	popl %edx	
	
exit:
	pushl $terminator
	pushl $formatPrintf1
	call printf
	popl %ebx
	popl %ebx
	
	movl $1, %eax
	xorl %ebx, %ebx
	int $0x80
