.org 0x0
	movl $0xa00, %edx
	movw %dx, %ds
	addw $0x100, %dx
	movl $0x08090a0b, %eax
	movl $0xfd, %ebx
	movl $0x03040506, -1(%ebx)
	movl %eax, 0x3(%ebx)
	movq -1(%ebx), %xmm0
	hlt
.end
	
